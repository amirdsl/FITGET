import SwiftUI
import Combine // هذا هو السطر المفقود الذي يسبب الخطأ

class AuthSession: ObservableObject {
    @Published var isLoggedIn: Bool = false
}
