import UIKit
import WebKit
import AVFoundation

final class GameViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var gameCenter: GameCenterBridge!
    private let haptics = HapticsBridge()
    private var pageURL: URL?
    override var prefersStatusBarHidden: Bool { true }
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = WKWebViewConfiguration()
        configuration.ignoresViewportScaleLimits = false
        configuration.websiteDataStore = .default()
        configuration.userContentController.add(haptics, name: "haptics")
        gameCenter = GameCenterBridge()
        configuration.userContentController.add(gameCenter, name: "gameCenter")
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        gameCenter.webView = webView
        webView.isMultipleTouchEnabled = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 1, green: 0.988, blue: 0.961, alpha: 1)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        lockPageScale()
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeAudio), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioServicesReset), name: AVAudioSession.mediaServicesWereResetNotification, object: nil)
        guard let page = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web") else {
            let error = UILabel(frame: view.bounds)
            error.text = NSLocalizedString("Game resources unavailable", comment: "Missing offline game")
            error.textAlignment = .center
            error.numberOfLines = 0
            view.addSubview(error)
            return
        }
        pageURL = page
        gameCenter.pageURL = page
        haptics.pageURL = page
        gameCenter.loadCatalog(page.deletingLastPathComponent().appendingPathComponent("gamecenter.json"))
        webView.loadFileURL(page, allowingReadAccessTo: page.deletingLastPathComponent())
    }
    private func lockPageScale() {
        // Native page zoom is disabled; pointer events still drive the canvas camera.
        webView.scrollView.minimumZoomScale = 1
        webView.scrollView.maximumZoomScale = 1
        webView.scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { lockPageScale() }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }
        // This app runs bundled content only; it never fetches a remote game.
        // The only external link is the privacy policy, opened in the system browser.
        if navigationAction.navigationType == .linkActivated, url.scheme == "https", url.host == "confusedbyme.com", url.path == "/confused-sketch.html" {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(navigationAction.targetFrame?.isMainFrame == true && url.standardizedFileURL == pageURL?.standardizedFileURL ? .allow : .cancel)
    }
    @objc private func pauseGame() {
        webView.evaluateJavaScript("window.__audioSuspend&&window.__audioSuspend();window.dispatchEvent(new Event('blur'))", completionHandler: nil)
    }
    @objc private func resumeAudio() {
        guard UIApplication.shared.applicationState == .active else { return }
        do { try AVAudioSession.sharedInstance().setActive(true) }
        catch { return } // Retry on the next foreground event or player gesture.
        webView.evaluateJavaScript("window.__audioResume&&window.__audioResume()", completionHandler: nil)
        gameCenter.appBecameActive()
    }
    @objc private func audioInterruption(_ notification: Notification) {
        guard let value = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: value) else { return }
        switch type {
        case .began: pauseGame()
        case .ended: resumeAudio()
        @unknown default: break
        }
    }
    @objc private func audioRouteChanged(_ notification: Notification) {
        guard let value = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: value) else { return }
        if reason == .oldDeviceUnavailable { pauseGame() }
        // A game has no media-playback UI: restore its enabled audio channels, keep gameplay paused.
        resumeAudio()
    }
    @objc private func audioServicesReset() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        webView.evaluateJavaScript("window.__audioReset&&window.__audioReset()", completionHandler: nil)
    }
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // Recover to the home screen; the game checkpoints before entering the background.
        if let pageURL { webView.loadFileURL(pageURL, allowingReadAccessTo: pageURL.deletingLastPathComponent()) }
    }
    deinit { NotificationCenter.default.removeObserver(self) }
}
