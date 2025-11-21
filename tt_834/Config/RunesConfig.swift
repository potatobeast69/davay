import SwiftUI
import StoreKit
import MessageUI

struct RunesConfig {
    static let privacyURL = "https://example.com/privacy"
    static let rulesURL = "https://example.com/rules"
    static let supportEmail = "support@example.com"
}

struct RunesUtilities {
    static var appVersion: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown" }
    static var buildNumber: String { Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown" }
    static func rateApp() { if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene { SKStoreReviewController.requestReview(in: scene) } }
    static func openRules() { if let url = URL(string: RunesConfig.rulesURL) { UIApplication.shared.open(url) } }
    static func openPrivacy() { if let url = URL(string: RunesConfig.privacyURL) { UIApplication.shared.open(url) } }
}

struct RunesMailComposer: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController(); mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients([RunesConfig.supportEmail]); mail.setSubject("Support Request")
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let deviceModel = UIDevice.current.model; let systemVersion = UIDevice.current.systemVersion
        let body = """


            ---
            App Version: \(appVersion) (\(buildNumber))
            Device: \(deviceModel)
            iOS Version: \(systemVersion)
            """; mail.setMessageBody(body, isHTML: false); return mail
    }
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: RunesMailComposer; init(_ parent: RunesMailComposer) { self.parent = parent }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) { parent.dismiss() }
    }
}

