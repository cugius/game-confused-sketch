import Foundation
import GameKit
import UIKit
import WebKit

/// Bounded, persistent deliveries belong to the first authenticated local account.
/// No score or achievement is copied to a different account without an explicit local reset.
@MainActor
final class GameCenterBridge: NSObject, WKScriptMessageHandler, GKGameCenterControllerDelegate {
    weak var webView: WKWebView?
    var pageURL: URL?
    private var enabled = false
    private var authStarted = false
    private var dashboardRequested = false
    private var dashboardVisible = false
    private var pending: [String: Double] = [:]
    private var sending = Set<String>()
    private var retry: DispatchWorkItem?
    private var retryDelay: Double = 1
    private let store = UserDefaults.standard
    private let ownerKey = "sketch.gamecenter.owner.v1"
    private var achievementIDs = Set<String>()
    private var leaderboardIDs = Set<String>()
    private var owner: String? { store.string(forKey: ownerKey) }
    private var account: String? { GKLocalPlayer.local.isAuthenticated ? GKLocalPlayer.local.gamePlayerID : nil }
    private var queueKey: String? { owner.map { "sketch.gamecenter.pending.v1." + $0 } }
    private var mayDeliver: Bool {
        enabled && account != nil && account == owner && UIApplication.shared.applicationState == .active
    }

    func loadCatalog(_ url: URL) {
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        achievementIDs = Set((json["achievements"] as? [[String: Any]] ?? []).compactMap { $0["id"] as? String })
        leaderboardIDs = Set((json["leaderboards"] as? [[String: Any]] ?? []).compactMap { $0["id"] as? String })
    }

    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard BridgeOrigin.accepts(message, page: pageURL),
              let body = message.body as? [String: Any], let type = body["type"] as? String else { return }
        switch type {
        case "ready":
            enabled = true
            authenticate()
        case "disable":
            enabled = false; dashboardRequested = false; retry?.cancel(); retry = nil
            status("disabled")
        case "achievement":
            guard enabled, let id = body["id"] as? String, achievementIDs.contains(id),
                  let value = body["percent"] as? Double, value.isFinite, value >= 0, value <= 100 else { return }
            enqueue("achievement:" + id, value: value)
        case "score":
            guard enabled, let id = body["leaderboard"] as? String, leaderboardIDs.contains(id),
                  let value = body["value"] as? Double, value.isFinite, value > 0,
                  value <= 1_000_000_000, value.rounded(.down) == value else { return }
            enqueue("score:" + id, value: value)
        case "showGameCenter":
            guard enabled else { status("disabled"); return }
            dashboardRequested = true
            if mayDeliver { showDashboard() } else { authenticate() }
        case "clearLocalProgress":
            // Only the game's explicit local-data deletion sends this message.
            retry?.cancel(); retry = nil
            if let key = queueKey { store.removeObject(forKey: key) }
            store.removeObject(forKey: ownerKey); pending.removeAll(); sending.removeAll()
        default: break
        }
    }

    private func enqueue(_ key: String, value: Double) {
        guard let account, account == owner else { return }
        pending[key] = max(pending[key] ?? 0, value)
        saveQueue(); flush()
    }
    private func saveQueue() { if let key = queueKey { store.set(pending, forKey: key) } }
    private func loadQueue() {
        guard let key = queueKey else { return }
        let saved = store.dictionary(forKey: key) ?? [:]
        pending = [:]
        for (key, raw) in saved {
            let parts = key.split(separator: ":", maxSplits: 1).map(String.init)
            guard parts.count == 2, let value = raw as? Double, value.isFinite, value >= 0 else { continue }
            if parts[0] == "achievement", achievementIDs.contains(parts[1]), value <= 100 { pending[key] = value }
            if parts[0] == "score", leaderboardIDs.contains(parts[1]), value <= 1_000_000_000, value.rounded(.down) == value { pending[key] = value }
        }
    }
    private func flush() {
        guard mayDeliver, let targetAccount = account else { return }
        for (key, value) in pending where !sending.contains(key) {
            sending.insert(key)
            let parts = key.split(separator: ":", maxSplits: 1).map(String.init)
            let completion: (Error?) -> Void = { [weak self] error in
                Task { @MainActor in
                    guard let self else { return }
                    self.sending.remove(key)
                    guard self.account == targetAccount, self.owner == targetAccount else { return }
                    if error == nil {
                        if (self.pending[key] ?? 0) <= value { self.pending.removeValue(forKey: key) }
                        self.retryDelay = 1
                        self.saveQueue()
                        self.status(self.pending.isEmpty ? "connected" : "pending")
                        self.notify("receipt", ["kind": parts[0], "id": parts[1], "value": value])
                    } else { self.status("pending") }
                    if !self.pending.isEmpty { self.scheduleRetry() }
                }
            }
            if parts[0] == "achievement" {
                let achievement = GKAchievement(identifier: parts[1])
                achievement.percentComplete = value
                achievement.showsCompletionBanner = false
                GKAchievement.report([achievement], withCompletionHandler: completion)
            } else {
                GKLeaderboard.submitScore(Int(value), context: 0, player: GKLocalPlayer.local,
                                          leaderboardIDs: [parts[1]], completionHandler: completion)
            }
        }
    }
    private func scheduleRetry() {
        guard enabled, retry == nil else { return }
        let work = DispatchWorkItem { [weak self] in
            Task { @MainActor in self?.retry = nil; self?.flush() }
        }
        retry = work
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay, execute: work)
        retryDelay = min(60, retryDelay * 2)
    }

    func appBecameActive() {
        guard enabled else { return }
        if GKLocalPlayer.local.isAuthenticated { authenticated() }
        else { status("disconnected") }
    }
    private func authenticate() {
        if GKLocalPlayer.local.isAuthenticated { authenticated(); return }
        guard !authStarted else { status("connecting"); return }
        authStarted = true; status("connecting")
        GKLocalPlayer.local.authenticateHandler = { [weak self] controller, error in
            Task { @MainActor in
                guard let self, self.enabled else { return }
                if let controller {
                    guard let top = self.topController(), !top.isBeingPresented else { return }
                    top.present(controller, animated: true)
                } else if GKLocalPlayer.local.isAuthenticated { self.authenticated() }
                else { self.authStarted = false; self.dashboardRequested = false; self.status(error == nil ? "disconnected" : "error") }
            }
        }
    }
    private func authenticated() {
        guard enabled, let account else { return }
        if owner == nil { store.set(account, forKey: ownerKey) }
        guard owner == account else { dashboardRequested = false; status("accountMismatch"); return }
        loadQueue()
        let args = [GKLocalPlayer.local.alias, account]
        guard let data = try? JSONSerialization.data(withJSONObject: args), let json = String(data: data, encoding: .utf8) else { return }
        webView?.evaluateJavaScript("window.GC&&window.GC.authenticated(...\(json))", completionHandler: nil)
        status(pending.isEmpty ? "connected" : "pending")
        flush()
        if dashboardRequested { showDashboard() }
    }
    private func showDashboard() {
        guard mayDeliver, !dashboardVisible, let top = topController(), !(top is GKGameCenterViewController) else { return }
        dashboardRequested = false; dashboardVisible = true
        let controller = GKGameCenterViewController(state: .achievements)
        controller.gameCenterDelegate = self
        top.present(controller, animated: true)
    }
    nonisolated func gameCenterViewControllerDidFinish(_ controller: GKGameCenterViewController) {
        Task { @MainActor in self.dashboardVisible = false; controller.dismiss(animated: true) }
    }
    private func status(_ state: String) { notify("nativeStatus", ["state": state]) }
    private func notify(_ method: String, _ payload: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: payload), let json = String(data: data, encoding: .utf8) else { return }
        webView?.evaluateJavaScript("window.GC&&window.GC.\(method)&&window.GC.\(method)(\(json))", completionHandler: nil)
    }
    private func topController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first { $0.activationState == .foregroundActive }
        var top = scene?.windows.first(where: \.isKeyWindow)?.rootViewController
        while let next = top?.presentedViewController { top = next }
        return top
    }
}
