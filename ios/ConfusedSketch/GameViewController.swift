import UIKit
import WebKit
import AVFoundation

final class GameViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var gameCenter: GameCenterBridge!
    override var prefersStatusBarHidden: Bool { true }
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = WKWebViewConfiguration()
        configuration.ignoresViewportScaleLimits = false
        configuration.websiteDataStore = .default()
        configuration.userContentController.add(HapticsBridge(), name: "haptics")
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
        NotificationCenter.default.addObserver(self, selector: #selector(resumeAudio), name: AVAudioSession.interruptionNotification, object: nil)
        guard let page = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web") else {
            let error = UILabel(frame: view.bounds)
            error.text = "Il foglio non è disponibile. Ricompila le risorse Web."
            error.textAlignment = .center
            error.numberOfLines = 0
            view.addSubview(error)
            return
        }
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
        if navigationAction.navigationType == .linkActivated, url.scheme == "https", url.host == "confusedbyme.com", url.path.hasPrefix("/confused-sketch") {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(url.isFileURL || url.absoluteString == "about:blank" ? .allow : .cancel)
    }
    @objc private func pauseGame() {
        webView.evaluateJavaScript("window.dispatchEvent(new Event('blur'))", completionHandler: nil)
    }
    @objc private func resumeAudio() {
        try? AVAudioSession.sharedInstance().setActive(true)
        webView.evaluateJavaScript("window.__audioResume && window.__audioResume()", completionHandler: nil)
    }
    deinit { NotificationCenter.default.removeObserver(self) }
}
