import Foundation
import WebKit

/// Every native capability is restricted to the bundled main document.
enum BridgeOrigin {
    static func accepts(_ message: WKScriptMessage, page: URL?) -> Bool {
        guard let page, message.frameInfo.isMainFrame,
              let origin = message.frameInfo.request.url,
              origin.isFileURL, origin.standardizedFileURL == page.standardizedFileURL,
              let body = message.body as? [String: Any], body.count <= 8,
              let data = try? JSONSerialization.data(withJSONObject: body), data.count <= 4096,
              let version = body["version"] as? Int, version == 1 else { return false }
        return true
    }
}
