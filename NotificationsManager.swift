//
//  NotificationsManager.swift
//  FITGET
//
//  Created on 25/11/2025.
//
import Combine
import Foundation
import UserNotifications

@MainActor
final class NotificationsManager: ObservableObject {
    static let shared = NotificationsManager()
    
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        refreshAuthorizationStatus()
    }
    
    func refreshAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            DispatchQueue.main.async {
                self.refreshAuthorizationStatus()
            }
        }
    }
    
    func scheduleRandomDailyTipNotification(
        hour: Int = 9,
        minute: Int = 0,
        tipsManager: TipsManager
    ) {
        guard let tip = tipsManager.randomTip() else { return }
        
        let language = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        let isArabic = (language == "ar")
        
        let content = UNMutableNotificationContent()
        content.title = isArabic ? "نصيحة اليوم" : "Tip of the Day"
        content.body = isArabic ? tip.bodyAR : tip.bodyEN
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_tip_notification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func cancelDailyTipNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["daily_tip_notification"])
    }
}
