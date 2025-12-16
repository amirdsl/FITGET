//
//  WelcomeView.swift
//  FITGET
//
//  Created on 16/12/2025.
//

import SwiftUI

struct WelcomeView: View {
    // MARK: - Callbacks
    var onSignup: () -> Void
    var onLogin: () -> Void
    var onGuest: () -> Void
    
    var body: some View {
        ZStack {
            // MARK: - Background (Brand Identity)
            AppGradients.royalPower
                .ignoresSafeArea()
            
            // Decorative Background Circles
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: geo.size.width * 0.8)
                    .position(x: geo.size.width * 0.9, y: geo.size.height * 0.1)
                    .blur(radius: 30)
                
                Circle()
                    .fill(AppGradients.challengeFlare.opacity(0.2))
                    .frame(width: geo.size.width * 0.6)
                    .position(x: 0, y: geo.size.height * 0.5)
                    .blur(radius: 40)
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // MARK: - Hero Section
                VStack(spacing: 24) {
                    // Logo Container
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 120, height: 120)
                            // تصحيح الخطأ هنا: استخدام AppShadows بدلاً من AppShadow
                            .appShadow(AppShadows.softElevated)
                        
                        Image(systemName: "figure.strengthtraining.traditional")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 10)
                    
                    Text("FITGET")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(1)
                    
                    Text("Train smart. Eat well.\nAchieve your goals.")
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(8)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                Spacer()
                
                // MARK: - Action Buttons
                VStack(spacing: 16) {
                    // 1. Get Started Button
                    Button(action: onSignup) {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppGradients.challengeFlare)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    // 2. Login Button
                    Button(action: onLogin) {
                        Text("I already have an account")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // 3. Guest Mode
                    Button(action: onGuest) {
                        Text("Continue as Guest")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(
            onSignup: {},
            onLogin: {},
            onGuest: {}
        )
    }
}
