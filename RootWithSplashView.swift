//
//  RootWithSplashView.swift
//  Fitget
//
//  يظهر SplashView أولاً ثم أي Root View تمرّره له.
//  مثال الاستخدام في FITGETApp موجود في الكومنت تحت.
//

import SwiftUI

struct RootWithSplashView<Content: View>: View {
    @State private var showSplash = true
    let content: () -> Content
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(AnyTransition.opacity)
            } else {
                content()
                    .transition(AnyTransition.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeInOut) {
                    showSplash = false
                }
            }
        }
    }
}

/*
 مثال استخدام في FITGETApp.swift (فقط للتوضيح):

 WindowGroup {
     RootDirectionView {
         RootWithSplashView {
             MainTabView()  // <-- هنا ضع الـ Root الحقيقي عندك (مثلاً MainTabView أو RootView)
         }
     }
     .environmentObject(LanguageManager.shared)
     .environmentObject(ThemeManager.shared)
     .environmentObject(AuthenticationManager.shared)
 }
 
*/
