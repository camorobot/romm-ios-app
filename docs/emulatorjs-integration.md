# EmulatorJS Integration Plan (Server-Side)

## Übersicht

Integration von **server-side EmulatorJS** zum direkten Spielen von ROMs in der romm-app via WebView. Die Emulation läuft auf dem User's ROMM Server, die iOS-App fungiert als interaktiver Viewer mit Overlay-Controls.

## ⚖️ Rechtliche Begründung: Warum Server-Side?

### ❌ Problem: Cores im App Bundle

**GPL-Lizenz Konflikt:**
- libretro Cores sind GPL/LGPL lizenziert
- Apple App Store Terms sind **inkompatibel** mit GPL
- GPL erfordert Zugang zum Source Code - App Store verschleiert das
- **Folge:** App würde vom App Store abgelehnt

**App Store Guidelines:**
- Verbot von dynamischem Laden von "executable code"
- Cores = ausführbarer Code
- Auch WASM ist eine Grauzone

**Praktische Probleme:**
- Alle Cores = 100-200 MB zusätzliche App-Größe
- User braucht nicht alle Cores
- Updates schwieriger

### ✅ Lösung: Server-Side Emulation

**Der ROMM Server macht die Emulation:**

```
┌─────────────┐                    ┌──────────────────┐
│             │  WebSocket/Stream  │                  │
│  iOS App    │ ◄─────────────────►│  ROMM Server     │
│  (WebView)  │  Video + Audio +   │  (EmulatorJS +   │
│             │  Input Events      │   Cores)         │
└─────────────┘                    └──────────────────┘
```

**Rechtlich sauber:**
- ✅ GPL-Code läuft auf User's own hardware (erlaubt)
- ✅ App enthält keinen GPL-Code (App Store konform)
- ✅ Kein "executable code download" (nur HTML/CSS/JS für UI)

**Technisch überlegen:**
- ✅ Server hat mehr Rechenleistung als iPhone
- ✅ Bessere Emulations-Performance
- ✅ States/Saves automatisch auf Server (kein manuelles Sync nötig)
- ✅ Konsistentes Spielerlebnis über alle Geräte
- ✅ Kleiner App-Footprint

## Architektur

### High-Level Übersicht

```
┌────────────────────────────────────────────────────────────────┐
│                      iOS App (romm-app)                         │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐        ┌──────────────┐                     │
│  │ RomDetailView│───────►│ EmulatorView │                     │
│  │ [Play Button]│        │  (WKWebView) │                     │
│  └──────────────┘        └──────┬───────┘                     │
│                                  │                              │
│                          ┌───────▼────────┐                    │
│                          │ Overlay Controls│                    │
│                          │ - Pause/Resume  │                    │
│                          │ - Settings      │                    │
│                          │ - Exit          │                    │
│                          └────────────────┘                    │
└────────────────────────────────────────────────────────────────┘
                                  │
                                  │ HTTPS
                                  │
                                  ▼
┌────────────────────────────────────────────────────────────────┐
│                    ROMM Server (User's Hardware)                │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Endpoint: /play/{romId}                                       │
│  ├── Lädt EmulatorJS UI                                        │
│  ├── Wählt passenden Core (nestopia, snes9x, etc.)            │
│  ├── Streamt ROM-Datei                                         │
│  ├── Verwaltet States via /api/states                         │
│  └── Verwaltet Saves via /api/saves                           │
│                                                                 │
│  EmulatorJS + libretro Cores (GPL-konform auf User's HW)      │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### Komponenten-Struktur (iOS App)

```
romm/romm/UI/Emulator/
├── EmulatorView.swift              # WebView Container + Overlay
├── EmulatorViewModel.swift         # URL Building, State
├── EmulatorControlsOverlay.swift   # Pause/Settings/Exit Buttons
└── EmulatorSettings.swift          # User Preferences (Display, Audio)

romm/romm/Domain/UseCases/Emulator/
└── LaunchEmulatorUseCase.swift     # Pre-flight Checks

romm/romm/Data/Services/
└── EmulatorService.swift           # Helper für Server-Communication
```

**Keine lokalen Cores, kein lokales State-Management nötig!**
Alles läuft auf dem Server.

## Implementierungs-Plan

### Phase 1: Server-Requirement Definition

Der ROMM Server muss einen neuen Endpoint bereitstellen:

```
GET /play/{romId}
```

**Response:** HTML-Seite mit:
1. EmulatorJS initialisiert
2. Passender Core geladen (basierend auf ROM's Platform)
3. ROM-Datei als Data-URL oder Stream
4. State/Save-Management über `/api/states` und `/api/saves`

**Falls ROMM Server das noch nicht hat:**
- Feature Request im ROMM GitHub repo stellen
- Oder: App lädt eine eigene HTML-Seite, die den Server nur für ROM + States/Saves nutzt

### Phase 2: iOS WebView Implementation

#### 2.1 EmulatorView.swift

```swift
import SwiftUI
import WebKit

struct EmulatorView: View {
    let rom: Rom
    @StateObject private var viewModel: EmulatorViewModel
    @Environment(\.dismiss) private var dismiss

    init(rom: Rom) {
        self.rom = rom
        _viewModel = StateObject(wrappedValue: EmulatorViewModel(rom: rom))
    }

    var body: some View {
        ZStack {
            // Full-Screen WebView
            EmulatorWebView(viewModel: viewModel)
                .ignoresSafeArea()

            // Overlay Controls
            if viewModel.showControls {
                EmulatorControlsOverlay(
                    viewModel: viewModel,
                    onExit: { dismiss() }
                )
                .transition(.opacity)
            }

            // Loading Indicator
            if viewModel.isLoading {
                LoadingView(message: "Starting Emulator...")
            }

            // Error Alert
            if let error = viewModel.errorMessage {
                ErrorOverlay(message: error) {
                    viewModel.clearError()
                }
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .persistentSystemOverlays(.hidden) // Hide iOS UI for immersion
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.startEmulator()
        }
        .onDisappear {
            viewModel.cleanup()
        }
        // Tap to toggle controls
        .onTapGesture {
            withAnimation {
                viewModel.showControls.toggle()
            }
        }
    }
}

struct EmulatorWebView: UIViewRepresentable {
    @ObservedObject var viewModel: EmulatorViewModel

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()

        // Allow inline media playback
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Disable zoom
        let source = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        let script = WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(script)

        // Optional: Message handlers for advanced features
        config.userContentController.add(context.coordinator, name: "emulatorReady")
        config.userContentController.add(context.coordinator, name: "emulatorError")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = viewModel.emulatorURL, webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let viewModel: EmulatorViewModel

        init(viewModel: EmulatorViewModel) {
            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in
                viewModel.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                viewModel.errorMessage = "Failed to load emulator: \(error.localizedDescription)"
                viewModel.isLoading = false
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "emulatorReady":
                Task { @MainActor in
                    viewModel.isLoading = false
                }
            case "emulatorError":
                if let errorMsg = message.body as? String {
                    Task { @MainActor in
                        viewModel.errorMessage = errorMsg
                    }
                }
            default:
                break
            }
        }
    }
}
```

#### 2.2 EmulatorViewModel.swift

```swift
import Foundation
import Observation

@Observable
@MainActor
class EmulatorViewModel {
    // State
    var isLoading: Bool = true
    var showControls: Bool = false
    var errorMessage: String?
    var emulatorURL: URL?

    // Dependencies
    private let rom: Rom
    private let tokenProvider: TokenProviderProtocol

    init(
        rom: Rom,
        tokenProvider: TokenProviderProtocol = TokenProvider()
    ) {
        self.rom = rom
        self.tokenProvider = tokenProvider
    }

    func startEmulator() {
        guard let serverURL = tokenProvider.getServerURL() else {
            errorMessage = "No server configured"
            isLoading = false
            return
        }

        // Build URL to ROMM Server's play endpoint
        let cleanURL = serverURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let playPath = "\(cleanURL)/play/\(rom.id)"

        guard let url = URL(string: playPath) else {
            errorMessage = "Invalid server URL"
            isLoading = false
            return
        }

        emulatorURL = url
    }

    func cleanup() {
        // Optional: Send "exit" event to server to save state
        // Or rely on server's auto-save
    }

    func clearError() {
        errorMessage = nil
    }
}
```

#### 2.3 EmulatorControlsOverlay.swift

```swift
import SwiftUI

struct EmulatorControlsOverlay: View {
    @ObservedObject var viewModel: EmulatorViewModel
    let onExit: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()

                // Exit Button
                Button(action: onExit) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                }
                .padding()
            }

            Spacer()

            // Bottom Controls
            HStack(spacing: 30) {
                // Settings (future: adjust display, audio, etc.)
                Button(action: {
                    // Show settings sheet
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 30))
                        Text("Settings")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }

                // Screenshot (future feature)
                Button(action: {
                    // Take screenshot
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 30))
                        Text("Screenshot")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }
            }
            .padding(.bottom, 40)
            .shadow(color: .black.opacity(0.5), radius: 4)
        }
        .background(
            LinearGradient(
                colors: [.black.opacity(0.4), .clear, .black.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
```

### Phase 3: ROM Detail Integration

#### 3.1 RomDetailView.swift - Play Button

```swift
// Add to actionBar in RomDetailView.swift

// Play Button
Button(action: {
    Task {
        await viewModel.launchEmulator()
    }
}) {
    HStack {
        Image(systemName: "play.circle.fill")
            .font(.title3)
        Text("Play")
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 14)
    .background(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.green)
    )
    .foregroundColor(.white)
    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
}
.disabled(!viewModel.canPlayEmulator)
.opacity(viewModel.canPlayEmulator ? 1.0 : 0.6)

// Navigation
.navigationDestination(isPresented: $viewModel.showingEmulator) {
    EmulatorView(rom: rom)
}
```

#### 3.2 RomDetailViewModel.swift - Emulator Logic

```swift
// Add to RomDetailViewModel.swift

var showingEmulator: Bool = false
var canPlayEmulator: Bool = false

private let checkEmulatorSupportUseCase: CheckEmulatorSupportUseCase

func loadRomDetails(romId: Int) async {
    // ... existing code ...

    // Check if platform is supported for emulation
    await checkEmulatorSupport()
}

func checkEmulatorSupport() async {
    guard let platformSlug = romDetails?.platformSlug else {
        canPlayEmulator = false
        return
    }

    canPlayEmulator = await checkEmulatorSupportUseCase.execute(
        platformSlug: platformSlug
    )
}

func launchEmulator() async {
    guard canPlayEmulator else {
        errorMessage = "Emulator not supported for this platform"
        return
    }

    showingEmulator = true
}
```

### Phase 4: Platform Support Check

#### 4.1 CheckEmulatorSupportUseCase.swift

```swift
// Domain/UseCases/Emulator/CheckEmulatorSupportUseCase.swift

class CheckEmulatorSupportUseCase {
    // Supported platforms (based on what ROMM server provides)
    private let supportedPlatforms: Set<String> = [
        "nes", "snes", "n64",
        "gb", "gbc", "gba",
        "genesis", "megadrive", "mastersystem",
        "psx", "ps1",
        "arcade"
    ]

    func execute(platformSlug: String) async -> Bool {
        return supportedPlatforms.contains(platformSlug.lowercased())
    }
}
```

### Phase 5: Settings (Optional)

#### 5.1 EmulatorSettings.swift

```swift
import Foundation
import SwiftUI

@Observable
class EmulatorSettings {
    // Display
    @AppStorage("emulator.fullscreen") var fullscreen: Bool = true
    @AppStorage("emulator.showFPS") var showFPS: Bool = false

    // Controls
    @AppStorage("emulator.hapticFeedback") var hapticFeedback: Bool = true
    @AppStorage("emulator.controlsAutoHide") var controlsAutoHide: Bool = true
    @AppStorage("emulator.controlsAutoHideDelay") var controlsAutoHideDelay: Double = 3.0

    // Performance
    @AppStorage("emulator.lowLatencyMode") var lowLatencyMode: Bool = false
}
```

#### 5.2 Settings UI

```swift
// In SettingsView.swift, add:

Section("Emulator") {
    NavigationLink("Emulator Settings") {
        EmulatorSettingsView()
    }
}

// New file: EmulatorSettingsView.swift
struct EmulatorSettingsView: View {
    @StateObject private var settings = EmulatorSettings()

    var body: some View {
        Form {
            Section("Display") {
                Toggle("Show FPS Counter", isOn: $settings.showFPS)
            }

            Section("Controls") {
                Toggle("Haptic Feedback", isOn: $settings.hapticFeedback)
                Toggle("Auto-Hide Controls", isOn: $settings.controlsAutoHide)

                if settings.controlsAutoHide {
                    Stepper(
                        "Hide After: \(Int(settings.controlsAutoHideDelay))s",
                        value: $settings.controlsAutoHideDelay,
                        in: 1...10,
                        step: 1
                    )
                }
            }

            Section("Performance") {
                Toggle("Low Latency Mode", isOn: $settings.lowLatencyMode)
                    .help("Reduces input lag but may increase battery usage")
            }

            Section("About") {
                HStack {
                    Text("Emulation")
                    Spacer()
                    Text("Server-Side (EmulatorJS)")
                        .foregroundColor(.secondary)
                }

                Link("EmulatorJS on GitHub", destination: URL(string: "https://github.com/EmulatorJS/EmulatorJS")!)
            }
        }
        .navigationTitle("Emulator Settings")
    }
}
```

## ROMM Server Requirements

### Needed Endpoint

Der ROMM Server muss einen `/play/{romId}` Endpoint bereitstellen:

```python
# Beispiel (FastAPI)
@app.get("/play/{rom_id}")
async def play_rom(rom_id: int):
    rom = get_rom(rom_id)
    platform = get_platform(rom.platform_id)

    # Determine emulator core
    core = PLATFORM_CORE_MAP.get(platform.slug, "snes9x")

    return templates.TemplateResponse("emulator.html", {
        "rom_id": rom_id,
        "rom_url": f"/api/roms/{rom_id}/content/{rom.file_name}",
        "core": core,
        "state_load_url": f"/api/states?rom_id={rom_id}",
        "state_save_url": f"/api/states?rom_id={rom_id}",
    })
```

### HTML Template (Server-Side)

```html
<!-- templates/emulator.html -->
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>EmulatorJS</title>
    <script src="/static/emulatorjs/loader.js"></script>
    <style>
        body {
            margin: 0;
            padding: 0;
            background: #000;
            overflow: hidden;
        }
        #game {
            width: 100vw;
            height: 100vh;
        }
    </style>
</head>
<body>
    <div id="game"></div>
    <script>
        EJS_player = '#game';
        EJS_core = '{{ core }}';
        EJS_gameUrl = '{{ rom_url }}';
        EJS_pathtodata = '/static/emulatorjs/data/';

        // Auto-save state on exit
        window.addEventListener('beforeunload', function() {
            if (window.EJS_saveState) {
                EJS_saveState();
            }
        });

        // Load latest state
        fetch('{{ state_load_url }}')
            .then(r => r.json())
            .then(states => {
                if (states.length > 0) {
                    // Load most recent state
                    const latest = states.sort((a,b) =>
                        new Date(b.updated_at) - new Date(a.updated_at)
                    )[0];

                    if (window.EJS_loadState) {
                        fetch(latest.download_path)
                            .then(r => r.blob())
                            .then(blob => EJS_loadState(blob));
                    }
                }
            });
    </script>
</body>
</html>
```

## Testing-Strategie

### 1. Server Verfügbarkeit

```swift
class EmulatorServerCheckTests: XCTestCase {
    func testServerHasPlayEndpoint() async throws {
        let serverURL = "https://test-server.com"
        let url = URL(string: "\(serverURL)/play/1")!

        let (_, response) = try await URLSession.shared.data(from: url)
        let httpResponse = response as! HTTPURLResponse

        XCTAssertEqual(httpResponse.statusCode, 200)
    }
}
```

### 2. Platform Support

```swift
func testPlatformSupport() async {
    let useCase = CheckEmulatorSupportUseCase()

    XCTAssertTrue(await useCase.execute(platformSlug: "nes"))
    XCTAssertTrue(await useCase.execute(platformSlug: "snes"))
    XCTAssertFalse(await useCase.execute(platformSlug: "ps5")) // not supported
}
```

### 3. Integration Test

Manuell:
1. ROM Detail View öffnen für NES-ROM
2. "Play" Button sollte enabled sein
3. Klick auf "Play"
4. EmulatorView öffnet sich
5. WebView lädt Server-Seite
6. Emulator startet und ROM läuft
7. Controls Overlay mit Tap ein/ausblenden
8. Exit Button schließt Emulator

## Vorteile dieser Architektur

### ✅ Rechtlich

- Keine GPL-Cores in der App
- App Store konform
- Kein "executable code download"

### ✅ Technisch

- Server hat mehr Power → bessere Performance
- States/Saves automatisch auf Server
- Kein manuelles Sync nötig
- Kleinere App-Größe
- Einfacheres Update-Management (Server-Seite)

### ✅ User Experience

- Konsistentes Spielerlebnis über alle Geräte
- Spiel auf iPhone pausieren, auf iPad weiterspielen
- Kein lokaler Speicher für States/Saves nötig
- Automatisches Backup auf Server

## Nächste Schritte

### 1. ROMM Server Check

Prüfen ob der ROMM Server bereits einen `/play/{romId}` Endpoint hat:
- Falls ja: Dokumentation lesen, wie er funktioniert
- Falls nein: Feature Request im ROMM GitHub repo stellen

### 2. Prototyp

Minimale Implementation:
- EmulatorView mit WKWebView
- Test mit bekanntem EmulatorJS-Server
- Controls Overlay

### 3. Integration

- Play Button in RomDetailView
- Navigation zu EmulatorView
- Platform Support Check

### 4. Polish

- Settings
- Error Handling
- Loading States
- UI/UX Verbesserungen

## Offene Fragen

1. **Hat ROMM Server bereits EmulatorJS integriert?**
   - Prüfen: ROMM Dokumentation/GitHub

2. **Welche Platforms werden unterstützt?**
   - Liste der verfügbaren Cores auf dem Server

3. **Network Performance:**
   - Latency bei Remote-Emulation akzeptabel?
   - Local Network (WiFi) empfohlen

4. **Fallback:**
   - Was wenn Server offline ist?
   - Fehlermeldung anzeigen: "Server nicht erreichbar"
