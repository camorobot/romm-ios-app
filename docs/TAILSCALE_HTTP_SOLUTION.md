# iOS HTTP/VPN Integration - Universal Prompt für Self-Hosted Apps

## 🎯 Problem
iOS App Transport Security (ATS) blockiert HTTP-Verbindungen zu self-hosted Servern über Tailscale VPN (100.x.x.x) und lokale Netzwerke (192.168.x.x), selbst mit `NSAllowsLocalNetworking=true`.

## ✅ Lösung
Custom URLSessionDelegate mit intelligenter Private IP Detection - akzeptiert HTTP + self-signed Certificates **nur** für private IP-Ranges, während öffentliche Server strikte HTTPS-Validierung behalten.

---

# 📋 Universal Prompt für andere iOS Apps

Kopiere diesen Prompt und passe die App-spezifischen Details an:

---

## Prompt für KI-Agent:

```
# iOS Tailscale/VPN HTTP-Support Integration

## 🎯 Ziel
Implementiere HTTP-Zugriff für self-hosted Server über Tailscale VPN und lokale Netzwerke in meiner iOS SwiftUI-App, während öffentliche Server weiterhin HTTPS-Validierung erfordern.

## 📱 Projekt-Kontext
- **App-Name:** [DEINE_APP_NAME]
- **iOS Version:** iOS 15+ / iOS 18+
- **Swift Version:** Swift 5.x / Swift 6
- **Architektur:** SwiftUI + URLSession / Alamofire / andere
- **Use-Case:** Self-hosted [SERVICE_NAME] (z.B. Nextcloud, Jellyfin, Home Assistant)

## 🔧 Anforderungen

### 1. Private IP-Range Support
Akzeptiere HTTP + self-signed Certificates für:
- **Tailscale CGNAT:** 100.64.0.0/10 (100.64.x.x - 100.127.x.x)
- **Private Class A:** 10.0.0.0/8
- **Private Class B:** 172.16.0.0/12
- **Private Class C:** 192.168.0.0/16
- **Localhost:** 127.0.0.0/8
- **IPv6 Local:** fe80::/10, fc00::/7, ::1

### 2. Security Requirements
- ✅ Öffentliche IPs/Domains: **Strikte HTTPS-Validierung** (Standard iOS)
- ✅ Keine globalen ATS-Bypasses (`NSAllowsArbitraryLoads` vermeiden)
- ✅ App Store Review compliant
- ✅ Debug-Logging für IP-Type Detection

### 3. Implementation Details

#### Option A: Custom URLSessionDelegate (empfohlen)
```swift
// Erstelle: YourApp/Network/PrivateNetworkURLSessionDelegate.swift

class PrivateNetworkURLSessionDelegate: NSObject, URLSessionDelegate {

    // IP-Range Detection
    private func isPrivateIPAddress(_ host: String) -> Bool {
        // Implementierung siehe Referenz-Code unten
    }

    // ServerTrust Handling
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if isPrivateIPAddress(challenge.protectionSpace.host) {
                // ✅ Private IP: Akzeptiere ServerTrust
                if let serverTrust = challenge.protectionSpace.serverTrust {
                    completionHandler(.useCredential, URLCredential(trust: serverTrust))
                }
            } else {
                // 🔒 Public IP: Standard HTTPS-Validierung
                completionHandler(.performDefaultHandling, nil)
            }
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
```

#### Integration in bestehenden Network Client
```swift
// YourApp/Network/APIClient.swift oder ähnlich

class APIClient {
    private let sessionDelegate = PrivateNetworkURLSessionDelegate()
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
    }()

    // Verwende urlSession für alle Requests
    func makeRequest(...) async throws {
        let (data, response) = try await urlSession.data(for: request)
        // ...
    }
}
```

### 4. Info.plist Konfiguration

**Minimal (empfohlen):**
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSLocalNetworkUsageDescription</key>
    <string>Connect to your self-hosted [SERVICE_NAME] on local network and VPN</string>
</dict>
```

**Hinweis:** `NSAllowsLocalNetworking` deckt **nicht** Tailscale 100.x.x.x ab - daher brauchen wir den Custom Delegate!

### 5. Logging & Debugging (optional)

```swift
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "",
                            category: "Network")

// In isPrivateIPAddress():
if isPrivate {
    logger.info("🔓 Private IP detected [\(ipType)]: \(host) - accepting HTTP")
} else {
    logger.info("🔒 Public server detected: \(host) - requiring HTTPS")
}
```

## 📦 Deliverables

Bitte erstelle/modifiziere folgende Dateien:

1. **Neu:** `PrivateNetworkURLSessionDelegate.swift`
   - Vollständige IP-Range Detection (IPv4 + IPv6)
   - URLSessionDelegate Implementation
   - Debug-Logging

2. **Modifizieren:** `[DEIN_API_CLIENT].swift`
   - Integriere `PrivateNetworkURLSessionDelegate`
   - Ersetze existierenden Delegate (falls vorhanden)

3. **Optional:** `Info.plist`
   - Nur falls noch nicht vorhanden: `NSAllowsLocalNetworking`
   - Entferne `NSAllowsArbitraryLoads` falls gesetzt

## 🧪 Test-Szenarien

Nach der Implementierung sollte die App funktionieren mit:

✅ `http://100.95.123.45:8096` - Tailscale VPN
✅ `http://192.168.1.50:8080` - Lokales Netzwerk
✅ `http://10.0.0.5:3000` - Private Class A
✅ `https://myservice.example.com` - Öffentlicher HTTPS-Server
❌ `http://myservice.example.com` - Öffentlicher HTTP-Server (iOS blockiert)

## 📱 App Store Review Notes

Für TestFlight/App Store Submission:

> "This app connects to self-hosted [SERVICE_NAME] servers via Tailscale VPN (private IPs: 100.x.x.x, 192.168.x.x, 10.x.x.x). Our custom URLSessionDelegate validates and accepts HTTP connections **exclusively for private IP address ranges**. Public servers continue to require valid HTTPS certificates per iOS security standards. This ensures user security while supporting legitimate self-hosted infrastructure."

## 🔗 Referenz-Implementation

Vollständige `isPrivateIPAddress()` Implementierung:

```swift
private func isPrivateIPAddress(_ host: String) -> Bool {
    // Localhost special cases
    if host == "localhost" || host == "::1" {
        return true
    }

    // IPv4 parsing
    if let ipv4Components = parseIPv4(host) {
        return isPrivateIPv4(ipv4Components)
    }

    // IPv6 check (basic)
    if host.contains(":") {
        return host.hasPrefix("fe80:") || host.hasPrefix("fc") || host.hasPrefix("fd")
    }

    return false
}

private func parseIPv4(_ host: String) -> [UInt8]? {
    let components = host.split(separator: ".").compactMap { UInt8($0) }
    guard components.count == 4 else { return nil }
    return components
}

private func isPrivateIPv4(_ components: [UInt8]) -> Bool {
    guard components.count == 4 else { return false }

    let octet1 = components[0]
    let octet2 = components[1]

    // 10.0.0.0/8
    if octet1 == 10 { return true }

    // 100.64.0.0/10 (Tailscale CGNAT)
    if octet1 == 100 && octet2 >= 64 && octet2 <= 127 { return true }

    // 172.16.0.0/12
    if octet1 == 172 && octet2 >= 16 && octet2 <= 31 { return true }

    // 192.168.0.0/16
    if octet1 == 192 && octet2 == 168 { return true }

    // 127.0.0.0/8 (Loopback)
    if octet1 == 127 { return true }

    return false
}
```

## ⚡ Quick Start

1. Kopiere `PrivateNetworkURLSessionDelegate.swift` in dein Projekt
2. Integriere Delegate in deinen Network Client
3. Teste mit lokalem Server (192.168.x.x) und Tailscale VPN (100.x.x.x)
4. Verifiziere Logging in Xcode Console: `🔓` für private IPs, `🔒` für öffentliche

## 🛠️ Kompatibilität

- ✅ iOS 14+ (NSAllowsLocalNetworking)
- ✅ Swift 5.5+ (async/await kompatibel)
- ✅ Swift 6 (Sendable/Concurrency compliant)
- ✅ URLSession, Alamofire, andere HTTP-Libraries
- ✅ SwiftUI + UIKit

## 📚 Alternative Ansätze

**Wenn du Alamofire verwendest:**
```swift
let session = Session(
    configuration: .default,
    delegate: PrivateNetworkURLSessionDelegate()
)
```

**Wenn du nur lokale IPs brauchst (kein Tailscale):**
```xml
<!-- Nur Info.plist, kein Custom Code -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```
⚠️ Funktioniert **nicht** mit Tailscale 100.x.x.x!

---

## 🎯 Zusammenfassung

Dieser Ansatz ist:
- ✅ **Sicher:** Öffentliche Server bleiben geschützt
- ✅ **App Store compliant:** Keine globalen Bypasses
- ✅ **Flexibel:** Funktioniert mit Tailscale + lokalen Netzwerken
- ✅ **Wartbar:** Klarer, dokumentierter Code
- ✅ **Universal:** Funktioniert mit allen URLSession-basierten Libraries

Bitte implementiere basierend auf meiner aktuellen Code-Struktur.
```

---

## 📝 Verwendung des Prompts

1. **Ersetze Platzhalter:**
   - `[DEINE_APP_NAME]` → z.B. "Nextcloud Client"
   - `[SERVICE_NAME]` → z.B. "Nextcloud", "Jellyfin", "Home Assistant"
   - `[DEIN_API_CLIENT]` → z.B. "NextcloudAPIClient.swift", "NetworkManager.swift"

2. **Passe Architektur an:**
   - Bei Alamofire: Erwähne das explizit
   - Bei Combine/RxSwift: Ergänze ReactiveX-Kontext
   - Bei UIKit statt SwiftUI: Erwähne das

3. **Optional ergänzen:**
   - Bestehende Error-Handling-Strategie
   - CI/CD Pipeline (falls betroffen)
   - Spezifische Logging-Frameworks (Crashlytics, Sentry, etc.)

## 🔄 Getestet mit

Diese Lösung wurde erfolgreich implementiert in:
- ✅ RomM iOS App (ROM Management, Swift 6, iOS 18.5+)
- Weitere Apps folgen...

## 📞 Support

Bei Problemen:
1. Prüfe Xcode Console für `🔓`/`🔒` Logs
2. Teste mit `curl -v http://192.168.1.x:port` vom gleichen Netzwerk
3. Verifiziere Tailscale-IP-Range: `tailscale ip -4`
