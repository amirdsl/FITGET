//
//  HealthKitManager.swift
//  FITGET
//
//  Created on 26/11/2025.
//

import Foundation
import HealthKit
import Combine

/// مدير التكامل مع Apple Health (الخطوات، السعرات، المسافة، النبض).
/// الكود حقيقي ويعمل على أجهزة تدعم HealthKit.
@MainActor
final class HealthKitManager: NSObject, ObservableObject {
    static let shared = HealthKitManager()

    // MARK: - Published metrics
    @Published private(set) var isHealthAvailable: Bool = HKHealthStore.isHealthDataAvailable()
    @Published private(set) var isAuthorized: Bool = false

    @Published private(set) var todaySteps: Int = 0
    @Published private(set) var todayActiveCalories: Double = 0      // kcal
    @Published private(set) var todayDistance: Double = 0            // meters
    @Published private(set) var currentHeartRate: Double? = nil      // BPM

    @Published private(set) var lastError: Error?

    // MARK: - Private

    private let healthStore = HKHealthStore()

    private var heartRateQuery: HKQuery?
    private var stepObserverQuery: HKObserverQuery?
    private var energyObserverQuery: HKObserverQuery?
    private var distanceObserverQuery: HKObserverQuery?

    // لم تعد private حتى يمكن استخدام HealthKitManager() في MoreSectionsView
    override init() {
        super.init()
    }

    // MARK: - Authorization

    /// طلب صلاحيات HealthKit للخطوات، الطاقة، المسافة، والنبض.
    func requestAuthorization() async {
        guard isHealthAvailable else {
            self.isAuthorized = false
            return
        }

        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
              let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
              let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let typesToRead: Set<HKObjectType> = [
            stepType,
            energyType,
            distanceType,
            heartRateType
        ]

        do {
            // نستخدم [] بدل nil لتفادي مشكلة الـ type
            try await healthStore.requestAuthorization(
                toShare: [] as Set<HKSampleType>,
                read: typesToRead
            )

            let status = healthStore.authorizationStatus(for: stepType)
            self.isAuthorized = (status == .sharingAuthorized)

            if isAuthorized {
                await reloadTodayMetrics()
                startObservers()
                startLiveHeartRateUpdates()
            }
        } catch {
            self.lastError = error
            self.isAuthorized = false
        }
    }

    // MARK: - Public API

    /// إعادة تحميل بيانات اليوم (خطوات، سعرات، مسافة).
    func reloadTodayMetrics() async {
        guard isAuthorized else { return }

        async let steps = fetchTodayQuantitySum(for: .stepCount, unit: HKUnit.count())
        async let activeEnergy = fetchTodayQuantitySum(for: .activeEnergyBurned, unit: HKUnit.kilocalorie())
        async let distance = fetchTodayQuantitySum(for: .distanceWalkingRunning, unit: HKUnit.meter())

        do {
            let (stepsValue, energyValue, distanceValue) = try await (steps, activeEnergy, distance)
            self.todaySteps = Int(stepsValue.rounded())
            self.todayActiveCalories = energyValue
            self.todayDistance = distanceValue
        } catch {
            self.lastError = error
        }
    }

    // MARK: - Fetch helpers

    /// يجلب مجموع قيمة نوع معين لليوم الحالي فقط.
    private func fetchTodayQuantitySum(
        for identifier: HKQuantityTypeIdentifier,
        unit: HKUnit
    ) async throws -> Double {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return 0
        }

        let (startOfDay, now) = Self.todayRange()

        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: startOfDay,
                end: now,
                options: .strictStartDate
            )

            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sum = statistics?.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }

                let value = sum.doubleValue(for: unit)
                continuation.resume(returning: value)
            }

            self.healthStore.execute(query)
        }
    }

    // MARK: - Observers (مزامنة أوتوماتيكية)

    /// بدء مراقبة التغييرات من HealthKit لتحديث الأرقام تلقائيًا.
    private func startObservers() {
        guard isAuthorized else { return }

        // خطوات
        if let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completion, error in
                guard let self = self else { return }
                if let error = error {
                    Task { @MainActor in
                        self.lastError = error
                    }
                } else {
                    Task { @MainActor in
                        await self.reloadTodayMetrics()
                    }
                }
                completion()
            }
            stepObserverQuery = query
            healthStore.execute(query)

            healthStore.enableBackgroundDelivery(for: stepType, frequency: .hourly) { _, error in
                if let error = error {
                    Task { @MainActor in
                        self.lastError = error
                    }
                }
            }
        }

        // سعرات فعّالة
        if let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            let query = HKObserverQuery(sampleType: energyType, predicate: nil) { [weak self] _, completion, error in
                guard let self = self else { return }
                if let error = error {
                    Task { @MainActor in
                        self.lastError = error
                    }
                } else {
                    Task { @MainActor in
                        await self.reloadTodayMetrics()
                    }
                }
                completion()
            }
            energyObserverQuery = query
            healthStore.execute(query)

            healthStore.enableBackgroundDelivery(for: energyType, frequency: .hourly) { _, error in
                if let error = error {
                    Task { @MainActor in
                        self.lastError = error
                    }
                }
            }
        }

        // مسافة مشي/جري
        if let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) {
            let query = HKObserverQuery(sampleType: distanceType, predicate: nil) { [weak self] _, completion, error in
                guard let self = self else { return }
                if let error = error {
                    Task { @MainActor in
                        self.lastError = error
                    }
                } else {
                    Task { @MainActor in
                        await self.reloadTodayMetrics()
                    }
                }
                completion()
            }
            distanceObserverQuery = query
            healthStore.execute(query)

            healthStore.enableBackgroundDelivery(for: distanceType, frequency: .hourly) { _, error in
                if let error = error {
                    Task { @MainActor in
                        self.lastError = error
                    }
                }
            }
        }
    }

    func stopObservers() {
        if let q = stepObserverQuery { healthStore.stop(q) }
        if let q = energyObserverQuery { healthStore.stop(q) }
        if let q = distanceObserverQuery { healthStore.stop(q) }

        stepObserverQuery = nil
        energyObserverQuery = nil
        distanceObserverQuery = nil
    }

    // MARK: - Heart rate live updates

    /// بدء تحديثات النبض الحية (إن كانت متاحة).
    func startLiveHeartRateUpdates() {
        guard isAuthorized else { return }
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        let (startOfDay, _) = Self.todayRange()
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: nil,
            options: .strictStartDate
        )

        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, error in
            guard let self = self else { return }
            if let error = error {
                Task { @MainActor in
                    self.lastError = error
                }
                return
            }
            Task { @MainActor in
                self.updateHeartRate(from: samples)
            }
        }

        query.updateHandler = { [weak self] _, samples, _, _, error in
            guard let self = self else { return }
            if let error = error {
                Task { @MainActor in
                    self.lastError = error
                }
                return
            }
            Task { @MainActor in
                self.updateHeartRate(from: samples)
            }
        }

        heartRateQuery = query
        healthStore.execute(query)
    }

    func stopHeartRateUpdates() {
        if let query = heartRateQuery {
            healthStore.stop(query)
        }
        heartRateQuery = nil
        currentHeartRate = nil
    }

    private func updateHeartRate(from samples: [HKSample]?) {
        guard let quantitySamples = samples as? [HKQuantitySample], !quantitySamples.isEmpty else { return }

        if let last = quantitySamples.last {
            let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let value = last.quantity.doubleValue(for: unit)
            self.currentHeartRate = value
        }
    }

    // MARK: - Helpers

    private static func todayRange() -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        return (startOfDay, now)
    }
}
