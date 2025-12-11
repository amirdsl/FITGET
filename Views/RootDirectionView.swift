//
//  RootDirectionView.swift
//  Fitget
//
//  يلف أي Root View ويضبط اتجاه الواجهة حسب اللغة
//

import SwiftUI

struct RootDirectionView<Content: View>: View {
    @EnvironmentObject var languageManager: LanguageManager
    let content: () -> Content
    
    var body: some View {
        content()
            .environment(\.layoutDirection,
                         languageManager.currentLanguage == "ar"
                         ? .rightToLeft
                         : .leftToRight)
    }
}
