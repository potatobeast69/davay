import SwiftUI

@main
struct CircuitLinesDuelApp: App {dsdas
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MenuView()
            } else {
                OnboardingView()
            }
        }
    }
}
