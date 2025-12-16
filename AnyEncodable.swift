//
//  AnyEncodable.swift
//  FITGET
//

import Foundation

/// Wrapper يسمح بتمرير Any إلى Encodable (مطلوب لـ Supabase)
struct AnyEncodable: Encodable {

    private let value: Any

    init(_ value: Any?) {
        self.value = value ?? ()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let v as String:
            try container.encode(v)
        case let v as Int:
            try container.encode(v)
        case let v as Double:
            try container.encode(v)
        case let v as Bool:
            try container.encode(v)
        case let v as UUID:
            try container.encode(v.uuidString)
        case let v as Date:
            try container.encode(v)
        case Optional<Any>.none:
            try container.encodeNil()
        default:
            let context = EncodingError.Context(
                codingPath: encoder.codingPath,
                debugDescription: "Unsupported value: \(value)"
            )
            throw EncodingError.invalidValue(value, context)
        }
    }
}
