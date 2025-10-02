import SwiftUI

struct SplashScreen: View {
    @State private var isLoading = true
    @State private var webViewURL: String?
    @State private var showNativeApp = false
    @State private var isWebViewLoading = false
    @StateObject private var serverManager = ServerManager.shared
    
    var body: some View {
        ZStack {
            if showNativeApp {
                ContentView()
            } else if let webURL = webViewURL {
                ZStack {
                    WebViewController(url: webURL, isLoading: $isWebViewLoading)
                        .ignoresSafeArea(.all, edges: .all)
                        .statusBarHidden(true)
                        .id("webview-\(webURL)") // Stable ID to prevent recreation
                        .onAppear {
                            print("🔗 WebView appeared with URL: \(webURL)")
                            if isWebViewLoading {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                    if isWebViewLoading {
                                        print("⏰ WebView loading timeout - hiding loading screen")
                                        isWebViewLoading = false
                                    }
                                }
                            }
                        }
                    
                    if isWebViewLoading {
                        LoadingView()
                    }
                }
            } else if isLoading {
                LoadingView()
            }
        }
        .statusBarHidden(true)
        .ignoresSafeArea(.all, edges: .all)
        .onAppear {
            // Clear saved URL for testing
            // serverManager.clearSavedURL()
            checkAppState()
        }
        .onTapGesture(count: 5) {
            print("🧹 5-tap detected - clearing saved data for testing")
            serverManager.clearSavedURL()
            isLoading = true
            webViewURL = nil
            showNativeApp = false
            isWebViewLoading = false
            checkAppState()
        }
    }
    
    private func checkAppState() {
        print("🔄 Checking app state...")
        print("🔧 DEBUG: Calling getSavedURL()...")
        if let savedURL = serverManager.getSavedURL() {
            print("💾 Found saved URL: \(savedURL)")
            print("💾 DEBUG: DECISION -> WEBVIEW (using cached URL)")
            webViewURL = savedURL
            isWebViewLoading = true // Set to show loading overlay
            isLoading = false
        } else {
            print("🌐 No saved URL found, performing server check...")
            print("🌐 DEBUG: Will check server for token validation...")
            performServerCheck()
        }
    }
    
    private func performServerCheck() {
        print("📡 Starting server check...")
        print("🔧 DEBUG: About to call checkUserStatus...")
        serverManager.checkUserStatus() { result in
            print("🔧 DEBUG: Received result from checkUserStatus")
            switch result {
            case .success(let urlString):
                print("🔧 DEBUG: Success case - urlString: \(urlString ?? "nil")")
                if let url = urlString {
                    print("✅ Got WebView URL: \(url)")
                    print("✅ DEBUG: DECISION -> WEBVIEW (valid token & URL received)")
                    self.webViewURL = url
                    self.isWebViewLoading = true // Set to show loading overlay
                } else {
                    print("🏠 Showing native app (bot detected)")
                    print("🏠 DEBUG: DECISION -> NATIVE APP (nil URL - invalid token or bot)")
                    self.showNativeApp = true
                }
                self.isLoading = false
                
            case .failure(let error):
                print("❌ Server check failed: \(error.localizedDescription)")
                print("❌ DEBUG: DECISION -> RETRY (network/server error)")
                print("🔄 Retrying in 2 seconds...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.performServerCheck()
                }
            }
        }
    }
}

struct LoadingView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all, edges: .all)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2.0)
        }
        .statusBarHidden(true)
        .onAppear {
            rotationAngle = 360
        }
    }
}

#Preview {
    SplashScreen()
}
