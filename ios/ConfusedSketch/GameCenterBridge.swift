import Foundation
import GameKit
import UIKit
import WebKit

/// Collegamento tra il gioco (window.webkit.messageHandlers.gameCenter) e Game Center. Identificativi: prefisso "cs." (vedi docs/ACHIEVEMENTS.md).
/// Messaggi: ready · disable · achievement {id, percent, banner} · score {leaderboard, value} · event (ignorato).
@MainActor
final class GameCenterBridge: NSObject, WKScriptMessageHandler, GKGameCenterControllerDelegate {
    weak var webView: WKWebView?
    private var authStarted = false
    /// Interruttore nelle Impostazioni: da spento non si inviano obiettivi/punteggi né si apre l'accesso.
    private var enabled = true

    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let type = body["type"] as? String else { return }
        switch type {
        case "ready":
            enabled = true
            authenticate()
        case "disable":
            enabled = false
        case "achievement":
            guard enabled, GKLocalPlayer.local.isAuthenticated,
                  let id = body["id"] as? String,
                  let percent = (body["percent"] as? NSNumber)?.doubleValue else { return }
            let achievement = GKAchievement(identifier: id)
            achievement.percentComplete = max(0, min(100, percent))
            achievement.showsCompletionBanner = (body["banner"] as? Bool) ?? false
            GKAchievement.report([achievement]) { error in
                if let error { NSLog("GameCenter achievement %@: %@", id, error.localizedDescription) }
            }
        case "score":
            guard enabled, GKLocalPlayer.local.isAuthenticated,
                  let id = body["leaderboard"] as? String,
                  let value = (body["value"] as? NSNumber)?.intValue, value > 0 else { return }
            GKLeaderboard.submitScore(value, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [id]) { error in
                if let error { NSLog("GameCenter score %@: %@", id, error.localizedDescription) }
            }
        case "showGameCenter":
            guard enabled, GKLocalPlayer.local.isAuthenticated else { return }
            let controller = GKGameCenterViewController(state: .achievements)
            controller.gameCenterDelegate = self
            topController()?.present(controller, animated: true)
        default:
            break
        }
    }

    nonisolated func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        Task { @MainActor in gameCenterViewController.dismiss(animated: true) }
    }

    private func authenticate() {
        guard !authStarted else { return }
        authStarted = true
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                guard let self else { return }
                if let viewController {
                    self.topController()?.present(viewController, animated: true)
                } else if GKLocalPlayer.local.isAuthenticated {
                    let alias = GKLocalPlayer.local.alias.replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "\"", with: "")
                    // Il gioco rimanda tutti i progressi: così obiettivi e punteggi già maturati arrivano a Game Center.
                    self.webView?.evaluateJavaScript("window.GC&&window.GC.authenticated(\"\(alias)\")", completionHandler: nil)
                } else if let error {
                    NSLog("GameCenter login: %@", error.localizedDescription)
                }
            }
        }
    }

    private func topController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first { $0.activationState == .foregroundActive }
        var top = scene?.windows.first(where: \.isKeyWindow)?.rootViewController
        while let next = top?.presentedViewController { top = next }
        return top
    }
}
