import Foundation
import WebKit

/// Bộ nhúng mã JavaScript tự động hóa thao tác trên WKWebView
@MainActor
public final class WebScriptInjector {
    private weak var webView: WKWebView?

    public init(webView: WKWebView?) {
        self.webView = webView
    }

    public func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }

    /// Click vào một tọa độ pixel tương đối trên trang web
    public func clickCoordinate(x: Double, y: Double) async throws {
        let js = """
        (function() {
            var el = document.elementFromPoint(\(x), \(y));
            if (el) {
                var clickEvent = new MouseEvent('click', {
                    view: window,
                    bubbles: true,
                    cancelable: true,
                    clientX: \(x),
                    clientY: \(y)
                });
                el.dispatchEvent(clickEvent);
                return 'Clicked: ' + (el.tagName || 'UNKNOWN');
            }
            return 'No element at point';
        })();
        """
        _ = try await webView?.evaluateJavaScript(js)
    }

    /// Click vào một CSS Selector
    public func clickSelector(_ selector: String) async throws {
        let escaped = selector.replacingOccurrences(of: "'", with: "\\'")
        let js = """
        (function() {
            var el = document.querySelector('\(escaped)');
            if (el) {
                el.click();
                return 'Success';
            }
            return 'Element not found';
        })();
        """
        _ = try await webView?.evaluateJavaScript(js)
    }

    /// Cuộn trang web
    public func scrollBy(deltaX: Int, deltaY: Int) async throws {
        let js = "window.scrollBy(\(deltaX), \(deltaY));"
        _ = try await webView?.evaluateJavaScript(js)
    }

    /// Điền văn bản vào ô Input
    public func fillInput(selector: String, text: String) async throws {
        let escapedSelector = selector.replacingOccurrences(of: "'", with: "\\'")
        let escapedText = text.replacingOccurrences(of: "'", with: "\\'")
        let js = """
        (function() {
            var el = document.querySelector('\(escapedSelector)');
            if (el) {
                el.value = '\(escapedText)';
                el.dispatchEvent(new Event('input', { bubbles: true }));
                el.dispatchEvent(new Event('change', { bubbles: true }));
                return 'Input set';
            }
            return 'Element not found';
        })();
        """
        _ = try await webView?.evaluateJavaScript(js)
    }
}
