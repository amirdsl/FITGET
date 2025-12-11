//
//  BackendConfig.swift
//  FITGET
//

import Foundation

enum BackendConfig {
    /// عنوان السيرفر الخاص بقاعدة البيانات / الـ API
    static let baseURL = URL(string: "https://wzroxxomcrofxaphgfuy.supabase.co")!
    
    /// مفتاح الـ API العام (إن احتجت استخدامه من التطبيق)
    /// ملاحظة: أي مفتاح سري حقيقي يجب أن يبقى في السيرفر فقط.
    static let publicApiKey: String = "eeyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cm94eG9tY3JvZnhhcGhnZnV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MTQ2MTYsImV4cCI6MjA3OTk5MDYxNn0.jXuCptr9Q_CED1fReAvJeOtez0D8ZrdcVnjsh7i1JaoE"
}
