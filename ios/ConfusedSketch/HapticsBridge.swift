import UIKit
import WebKit

/// Riceve {kind} dal gioco (window.webkit.messageHandlers.haptics) e produce il feedback aptico di iOS.
/// kind: selection · soft · light · medium · heavy · rigid · success · warning · error
@MainActor
final class HapticsBridge: NSObject, WKScriptMessageHandler {
    private var last = Date.distantPast
    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let kind = body["kind"] as? String else { return }
        fire(kind)
    }
    private func fire(_ kind: String) {
        let now = Date()
        guard now.timeIntervalSince(last) > 0.03 else { return }
        last = now
        switch kind {
        case "soft": UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case "light": UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case "medium": UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case "heavy": UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case "rigid": UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case "success": UINotificationFeedbackGenerator().notificationOccurred(.success)
        case "warning": UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case "error": UINotificationFeedbackGenerator().notificationOccurred(.error)
        default: UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}
