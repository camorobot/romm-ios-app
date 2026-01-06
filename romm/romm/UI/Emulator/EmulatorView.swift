//
//  EmulatorView.swift
//  romm
//
//  Created by Ilyas Hallak on 11.12.25.
//

import SwiftUI
import WebKit
import AVFoundation

struct EmulatorView: View {
    let rom: Rom
    private let viewModel: EmulatorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showExitConfirmation = false

    init(rom: Rom) {
        self.rom = rom
        self.viewModel = EmulatorViewModel(rom: rom)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // WebView - Full screen
                if viewModel.emulatorURL != nil {
                    EmulatorWebView(viewModel: viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.bottom)  // Ignore bottom, navbar handles top
                }

                // Overlay Controls (optional, für später)
                if viewModel.showControls {
                    EmulatorControlsOverlay(
                        viewModel: viewModel,
                        onExit: { showExitConfirmation = true }
                    )
                    .transition(.opacity)
                }

            // Loading Indicator
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Starting Emulator...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.black.opacity(0.7))
                )
            }

            // Error Alert
            if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)

                    Text(error)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Button("Close") {
                        viewModel.clearError()
                        dismiss()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.red)
                    )
                    .foregroundColor(.white)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.black.opacity(0.9))
                )
                .padding()
            }
            }
            .navigationTitle(rom.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showExitConfirmation = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.9), for: .navigationBar)
        }
        .navigationViewStyle(.stack)
        .statusBar(hidden: false)
        .preferredColorScheme(.dark)
        .alert("Emulator beenden?", isPresented: $showExitConfirmation) {
            Button("Abbrechen", role: .cancel) {}
            Button("Beenden", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Möchtest du den Emulator wirklich beenden?")
        }
        .task {
            // Start emulator when view appears
            viewModel.startEmulator()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

struct EmulatorWebView: UIViewRepresentable {
    var viewModel: EmulatorViewModel

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()

        // Use persistent data store to keep cookies and login between app restarts
        config.websiteDataStore = WKWebsiteDataStore.default()

        // SYNC: Copy all cookies from HTTPCookieStorage to WKWebView
        // This ensures app's login cookies are available in WebView
        let sharedCookies = HTTPCookieStorage.shared.cookies ?? []
        print("🍪 Syncing \(sharedCookies.count) cookies from HTTPCookieStorage to WKWebView")
        for cookie in sharedCookies {
            config.websiteDataStore.httpCookieStore.setCookie(cookie)
        }

        // Audio & Media playback configuration
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Enable JavaScript and audio output in WebView
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        // Disable zoom
        let source = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            var head = document.getElementsByTagName('head')[0];
            if (head) {
                head.appendChild(meta);
            }
        """
        let script = WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(script)

        // Console.log forwarding for debugging
        let consoleScript = WKUserScript(
            source: """
            console.log = (function(oldLog) {
                return function(message) {
                    oldLog.apply(console, arguments);
                    window.webkit.messageHandlers.consoleLog.postMessage(String(message));
                };
            })(console.log);
            console.error = (function(oldError) {
                return function(message) {
                    oldError.apply(console, arguments);
                    window.webkit.messageHandlers.consoleError.postMessage(String(message));
                };
            })(console.error);
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        config.userContentController.addUserScript(consoleScript)

        // Message handlers
        config.userContentController.add(context.coordinator, name: "consoleLog")
        config.userContentController.add(context.coordinator, name: "consoleError")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.backgroundColor = .black
        webView.isOpaque = true

        // Configure audio session for playback (non-simulator only)
        #if !targetEnvironment(simulator)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            print("🔊 Audio session activated for playback")
        } catch {
            print("⚠️ Failed to activate audio session: \(error)")
        }
        #endif

        // Enable inspection in iOS Simulator
        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let emulatorURL = viewModel.emulatorURL,
              context.coordinator.hasLoaded == false else {
            return
        }

        print("📱 Loading ROMM EmulatorJS from: \(emulatorURL.absoluteString)")

        // Store webView reference first
        context.coordinator.webView = webView
        context.coordinator.hasLoaded = true

        // Sync cookies from HTTPCookieStorage before loading
        Task { @MainActor in
            await context.coordinator.syncCookiesFromHTTPStorage(for: webView, url: emulatorURL)

            // Create request
            let request = URLRequest(url: emulatorURL)

            // Load the ROMM EmulatorJS page
            print("📱 Loading page now...")
            webView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let viewModel: EmulatorViewModel
        var hasLoaded = false
        weak var webView: WKWebView?
        private let logger = Logger.viewModel

        init(viewModel: EmulatorViewModel) {
            self.viewModel = viewModel
        }

        func syncCookiesFromHTTPStorage(for webView: WKWebView, url: URL) async {
            logger.info("🍪 Syncing cookies from HTTPCookieStorage to WKWebView")

            guard let domain = url.host else {
                logger.warning("⚠️ Cannot extract domain from URL: \(url.absoluteString)")
                return
            }

            // Get ALL cookies from shared storage (used by URLSession/API calls)
            let sharedCookies = HTTPCookieStorage.shared.cookies ?? []

            // Filter cookies relevant for this domain
            let relevantCookies = sharedCookies.filter { cookie in
                // Match if cookie domain contains URL domain or vice versa
                cookie.domain.contains(domain) || domain.contains(cookie.domain)
            }

            logger.info("🍪 Found \(sharedCookies.count) total cookies in HTTPCookieStorage")
            logger.info("🍪 \(relevantCookies.count) cookies match domain '\(domain)'")

            // Copy each relevant cookie to WKWebView
            for cookie in relevantCookies {
                await webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
                logger.info("   ✅ Synced: \(cookie.name) (domain: \(cookie.domain), expires: \(cookie.expiresDate?.description ?? "session"))")
            }

            logger.info("✅ Cookie sync complete - WKWebView should now be authenticated")
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            logger.info("🌐 WebView started loading navigation")
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            logger.info("🌐 WebView committed navigation (HTML parsing started)")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            logger.info("✅ WebView finished loading navigation")

            // Inject CSS to hide ROMM UI and make emulator fullscreen
            injectFullscreenCSS(webView)

            // Check if JavaScript is working
            webView.evaluateJavaScript("document.body ? 'body exists' : 'no body'") { result, error in
                if let error = error {
                    self.logger.error("❌ JavaScript test failed: \(error.localizedDescription)")
                } else if let result = result {
                    self.logger.info("✅ JavaScript working: \(result)")
                }
            }

            Task { @MainActor in
                viewModel.isLoading = false
            }
        }

        private func injectFullscreenCSS(_ webView: WKWebView) {
            // CSS to hide ROMM UI elements and make emulator fullscreen
            let css = """
            /* Hide ROMM UI elements */
            header.v-toolbar,
            header.v-bottom-navigation,
            nav.v-navigation-drawer,
            .v-toolbar,
            .v-navigation-drawer,
            .v-bottom-navigation,
            div.my-4,
            div.mt-4.align-center > div:first-child,
            div.sticky-bottom {
                display: none !important;
                visibility: hidden !important;
            }

            /* Body fullscreen */
            body {
                margin: 0 !important;
                padding: 0 !important;
                overflow: hidden !important;
            }

            /* Make EmulatorJS canvas fullscreen */
            canvas {
                position: fixed !important;
                top: 0 !important;
                left: 0 !important;
                width: 100vw !important;
                height: 100vh !important;
                object-fit: contain !important;
            }
            """

            let javascript = """
            (function() {
                try {
                    var style = document.createElement('style');
                    style.textContent = `\(css)`;
                    document.head.appendChild(style);
                    console.log('✅ CSS injected');
                } catch(e) {
                    console.error('❌ CSS injection failed:', e);
                }
            })();
            """

            webView.evaluateJavaScript(javascript) { result, error in
                if let error = error {
                    self.logger.error("❌ Failed to inject CSS: \(error.localizedDescription)")
                } else {
                    self.logger.info("✅ CSS injected successfully")
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            logger.error("❌ WebView navigation failed: \(error.localizedDescription)")

            // Ignore cancelled navigation (common during normal operation)
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled {
                logger.info("ℹ️ Navigation cancelled, safe to ignore")
                return
            }

            Task { @MainActor in
                viewModel.errorMessage = "Failed to load emulator: \(error.localizedDescription)"
                viewModel.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            logger.error("❌ WebView provisional navigation failed: \(error.localizedDescription)")
            Task { @MainActor in
                viewModel.errorMessage = "Failed to connect to server: \(error.localizedDescription)"
                viewModel.isLoading = false
            }
        }

        // Handle WebView process termination (memory crash)
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            logger.error("⚠️ WebView process terminated - likely memory issue or crash")

            Task { @MainActor in
                viewModel.errorMessage = "Emulator crashed. This might be caused by:\n• ROM file too large\n• Not enough memory\n• Corrupted ROM\n\nTry restarting or use a smaller ROM."
                viewModel.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                logger.info("📍 Navigation request: \(url.absoluteString)")
            }
            decisionHandler(.allow)
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            logger.info("📨 Received message from WebView: \(message.name)")

            switch message.name {
            case "consoleLog":
                if let msg = message.body as? String {
                    logger.info("🎮 [JS] \(msg)")
                }

            case "consoleError":
                if let msg = message.body as? String {
                    logger.error("❌ [JS Error] \(msg)")
                }

            default:
                logger.warning("⚠️ Unknown message: \(message.name)")
                break
            }
        }
    }
}
