//
//  WebViewController.swift
//  Vineyard Management
//
//  Created by Assistant on 29.09.2025.
//

import SwiftUI
import WebKit

struct WebViewController: UIViewControllerRepresentable {
    let url: String
    @Binding var isLoading: Bool
    
    func makeUIViewController(context: Context) -> CustomWebViewController {
        let controller = CustomWebViewController()
        controller.delegate = context.coordinator
        // Load website after view loads to ensure webView is set up
        DispatchQueue.main.async {
            controller.loadWebsite(url: url)
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CustomWebViewController, context: Context) {
        // Don't reload on updates to prevent cancellation
        if uiViewController.currentURL != url {
            DispatchQueue.main.async {
                uiViewController.loadWebsite(url: url)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WebViewDelegate {
        var parent: WebViewController
        
        init(_ parent: WebViewController) {
            self.parent = parent
        }
        
        func webViewDidStartLoad() {
            parent.isLoading = true
        }
        
        func webViewDidFinishLoad() {
            parent.isLoading = false
        }
    }
}

protocol WebViewDelegate: AnyObject {
    func webViewDidStartLoad()
    func webViewDidFinishLoad()
}

class CustomWebViewController: UIViewController {
    private var webView: WKWebView?
    weak var delegate: WebViewDelegate?
    private(set) var currentURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        hideStatusBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideStatusBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideStatusBar()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.hideStatusBar()
            self.view.setNeedsLayout()
        }, completion: { _ in
            self.hideStatusBar()
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return nil
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    private func hideStatusBar() {
        setNeedsStatusBarAppearanceUpdate()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        // Add viewport meta tag injection for proper mobile scaling
        let viewportScript = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        let viewportUserScript = WKUserScript(source: viewportScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(viewportUserScript)
        
        let newWebView = WKWebView(frame: .zero, configuration: configuration)
        newWebView.navigationDelegate = self
        newWebView.uiDelegate = self
        newWebView.allowsBackForwardNavigationGestures = true
        newWebView.scrollView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(newWebView)
        newWebView.translatesAutoresizingMaskIntoConstraints = false
        
        // Use absolute full screen - edge to edge in all orientations
        let constraints = [
            newWebView.topAnchor.constraint(equalTo: view.topAnchor),
            newWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        // Set high priority to ensure WebView always fills the entire screen
        constraints.forEach { $0.priority = UILayoutPriority(999) }
        NSLayoutConstraint.activate(constraints)
        
        // Ensure WebView adapts to orientation changes
        newWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.webView = newWebView
    }
    
    func loadWebsite(url: String) {
        guard currentURL != url, 
              let webURL = URL(string: url),
              let webView = webView else { 
            print("🔄 Skipping load - same URL or webView not ready: \(url)")
            return 
        }
        
        print("🌐 Loading new URL: \(url)")
        currentURL = url
        let request = URLRequest(url: webURL)
        webView.load(request)
    }
}

extension CustomWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("🌐 WebView started loading")
        delegate?.webViewDidStartLoad()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ WebView finished loading")
        delegate?.webViewDidFinishLoad()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ WebView navigation failed: \(error.localizedDescription)")
        delegate?.webViewDidFinishLoad()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("❌ WebView provisional navigation failed: \(error.localizedDescription)")
        delegate?.webViewDidFinishLoad()
    }
}

extension CustomWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        present(alert, animated: true)
    }
}