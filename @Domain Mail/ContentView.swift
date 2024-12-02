import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("username") private var username: String = ""

    var body: some View {
        if hasCompletedOnboarding {
            MailAppView(username: username)
        } else {
            OnboardingView()
                .onDisappear {
                    hasCompletedOnboarding = true
                }
        }
    }
}
