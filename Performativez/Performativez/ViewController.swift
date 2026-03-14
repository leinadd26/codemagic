import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!
    var splashView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupSplash()
        loadApp()
    }

    func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Allow localStorage & cookies
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        // Allow cross-origin for local files
        let dataStore = WKWebsiteDataStore.default()
        config.websiteDataStore = dataStore

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = UIColor(red: 0.969, green: 0.961, blue: 0.941, alpha: 1)
        view.addSubview(webView)
    }

    func setupSplash() {
        splashView = UIView(frame: view.bounds)
        splashView.backgroundColor = UIColor(red: 0.969, green: 0.961, blue: 0.941, alpha: 1)
        splashView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Logo label
        let label = UILabel()
        label.text = "PERFORMATIVEZ"
        label.font = UIFont.systemFont(ofSize: 28, weight: .black)
        label.textColor = UIColor(red: 0.239, green: 0.620, blue: 0.408, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(label)

        // Icon image
        if let iconImg = UIImage(named: "AppIcon") {
            let iv = UIImageView(image: iconImg)
            iv.contentMode = .scaleAspectFit
            iv.layer.cornerRadius = 18
            iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            splashView.addSubview(iv)
            NSLayoutConstraint.activate([
                iv.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
                iv.centerYAnchor.constraint(equalTo: splashView.centerYAnchor, constant: -40),
                iv.widthAnchor.constraint(equalToConstant: 100),
                iv.heightAnchor.constraint(equalToConstant: 100),
                label.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
                label.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 16),
            ])
        } else {
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: splashView.centerYAnchor),
            ])
        }

        view.addSubview(splashView)
    }

    func loadApp() {
        guard let wwwPath = Bundle.main.resourcePath else { return }
        let wwwURL = URL(fileURLWithPath: wwwPath).appendingPathComponent("www")
        let indexURL = wwwURL.appendingPathComponent("index.html")
        webView.loadFileURL(indexURL, allowingReadAccessTo: wwwURL)
    }

    // Hide splash once page loaded
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 0.4, delay: 0.3, options: .curveEaseOut) {
            self.splashView.alpha = 0
        } completion: { _ in
            self.splashView.removeFromSuperview()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView error: \(error)")
    }

    // Handle window.open / target=_blank links
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    // Safe area / status bar
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
}
