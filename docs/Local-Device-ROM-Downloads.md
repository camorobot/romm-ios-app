# Feature Plan: Local Device ROM Downloads

**Status:** Planning
**Branch:** `feature/device_downloader`
**Date:** 2025-11-07

## 1. Übersicht

Erweiterung des bestehenden Device-Downloader-Features, um das eigene iPhone/iPad als Download-Ziel zu unterstützen. Nutzer können ROMs direkt auf ihr Gerät herunterladen und später entweder in der App spielen oder mit externen Emulator-Apps öffnen.

## 2. Motivation & Use Cases

### Primäre Use Cases

1. **Offline-Spielen vorbereiten**
   - Nutzer lädt ROMs im WLAN herunter
   - Spielt später unterwegs ohne Internetverbindung mit Emulator-Apps

2. **Schneller Zugriff**
   - Keine SFTP-Konfiguration erforderlich
   - Ein Klick zum Download, ein Klick zum Spielen

3. **Integration mit Emulator-Apps**
   - ROMs per Share Sheet an Delta, RetroArch, PPSSPP etc. senden
   - System-weite "Öffnen mit..."-Funktion nutzen

4. **Zukünftige In-App-Emulation**
   - Grundlage für spätere Integration eines Emulators
   - ROMs sind bereits lokal verfügbar

### Vorteile gegenüber SFTP

| Feature | SFTP zu externem Gerät | Local Download |
|---------|------------------------|----------------|
| Setup-Aufwand | Hoch (Credentials, Netzwerk) | Niedrig (automatisch) |
| Geschwindigkeit | Netzwerk-abhängig | Nur Server-Download |
| Offline-Nutzung | Nur wenn Gerät erreichbar | Immer verfügbar |
| Integration | Externe Hardware nötig | Native iOS-Features |

## 3. Funktionale Anforderungen

### 3.1 Automatisches "Dieses Gerät"-Device

- **Auto-Registrierung:** Beim ersten App-Start wird automatisch ein Device "Dieses iPhone/iPad" angelegt
- **Persistenz:** Device bleibt über App-Neustarts erhalten
- **Standard-Auswahl:** Dieses Device ist standardmäßig in der Upload-Auswahl vorausgewählt
- **Nicht löschbar:** User kann dieses Device nicht versehentlich löschen
- **Gerätename:** Automatisch den echten Gerätenamen verwenden (via `UIDevice.current.name`)

### 3.2 ROM Download Management

#### Download-Verhalten

```
ROM-Detail-Ansicht
    ↓
[Auf diesem Gerät speichern] Button
    ↓
Download-Optionen
    ├─ Welche Datei(en) herunterladen?
    ├─ Zielordner auswählen (optional)
    └─ Speicherplatz-Warnung bei wenig Platz
    ↓
Download-Fortschritt
    ├─ Fortschrittsbalken (Bytes/Total)
    ├─ Download-Geschwindigkeit
    └─ Geschätzte verbleibende Zeit
    ↓
Download abgeschlossen
    ├─ [In App öffnen] (zukünftig)
    ├─ [Mit Emulator öffnen] (Share Sheet)
    └─ [Im Dateien-Browser anzeigen]
```

#### Datei-Speicherung

- **Speicherort:** App-eigenes Documents-Verzeichnis
- **Ordnerstruktur:** `Documents/ROMs/{Platform}/{ROM-Name}/`
- **File Provider Extension:** ROMs im iOS Files-App sichtbar machen
- **Dateinamen:** Original-Dateinamen vom Server beibehalten

#### Beispiel-Struktur

```
Documents/
└── ROMs/
    ├── Nintendo Game Boy/
    │   ├── Pokemon Red/
    │   │   └── Pokemon Red (USA).gb
    │   └── The Legend of Zelda - Link's Awakening/
    │       └── Zelda - Link's Awakening (USA).gb
    ├── Sony PlayStation/
    │   └── Final Fantasy VII/
    │       ├── Final Fantasy VII (Disc 1).bin
    │       ├── Final Fantasy VII (Disc 1).cue
    │       ├── Final Fantasy VII (Disc 2).bin
    │       └── Final Fantasy VII (Disc 2).cue
    └── Nintendo 64/
        └── Super Mario 64/
            └── Super Mario 64 (USA).z64
```

### 3.3 Download-Manager

#### Features

- **Parallele Downloads:** Mehrere ROMs gleichzeitig herunterladen (max. 3)
- **Download-Queue:** Weitere Downloads in Warteschlange
- **Pausieren/Fortsetzen:** Downloads unterbrechen und später fortsetzen
- **Hintergrund-Downloads:** URLSession Background Tasks nutzen
- **Fehlerbehandlung:** Automatische Wiederholungen bei Netzwerkfehlern
- **Speicherplatz-Überwachung:** Download abbrechen bei Speichermangel

#### Download-Status-Ansicht

```swift
struct DownloadItem {
    let romId: Int
    let romName: String
    let fileName: String
    let totalBytes: Int64
    var downloadedBytes: Int64
    var status: DownloadStatus
    var error: String?
    var startedAt: Date
    var estimatedCompletion: Date?
}

enum DownloadStatus {
    case queued
    case downloading
    case paused
    case completed
    case failed
}
```

### 3.4 Lokal gespeicherte ROMs anzeigen

#### "Meine Downloads" Ansicht

- **Tab in der App:** Neuer Tab "Downloads" oder Sektion in "Library"
- **Gruppierung:** Nach Plattform gruppiert
- **Sortierung:** Zuletzt heruntergeladen, Name, Größe, Plattform
- **Metadaten:** ROM-Größe, Download-Datum, Plattform-Icon
- **Aktionen pro ROM:**
  - ▶️ In App öffnen (zukünftig)
  - 📤 Mit Emulator-App teilen
  - 📁 Im Dateien-Browser zeigen
  - 🗑️ Von Gerät löschen
  - ℹ️ ROM-Details anzeigen

#### Speicher-Management

- **Speicherplatz-Übersicht:** Genutzter vs. verfügbarer Speicher
- **Größte ROMs anzeigen:** Liste sortiert nach Dateigröße
- **Bulk-Löschen:** Mehrere ROMs gleichzeitig entfernen
- **Cache-Bereinigung:** Unvollständige Downloads löschen

### 3.5 Integration mit Emulator-Apps

#### Share Sheet Integration

```swift
func shareROM(at localPath: URL) {
    let activityVC = UIActivityViewController(
        activityItems: [localPath],
        applicationActivities: nil
    )
    // System zeigt kompatible Emulator-Apps an:
    // - Delta Emulator
    // - RetroArch
    // - PPSSPP
    // - Dolphin
    // - etc.
}
```

#### Quick Actions

- **Lange drücken auf ROM:** Kontextmenü mit "Öffnen mit..."
- **Favoriten-Emulator:** Nutzer kann Standard-Emulator-App festlegen
- **Letzter Emulator:** "Zuletzt verwendet"-Option im Share-Menü

### 3.6 Zukünftige Erweiterungen (Optional)

1. **In-App Emulator**
   - ROMs direkt in der App spielen
   - Save-State-Management
   - Controller-Support

2. **Cloud-Sync**
   - ROMs auf iCloud speichern
   - Über mehrere Geräte synchronisieren

3. **ROM-Scanning**
   - Nutzer kann eigene ROMs aus Files-App importieren
   - Automatisches Matching mit RomM-Datenbank

## 4. Technische Architektur

### 4.1 Neue Komponenten

#### Domain Layer

```
Domain/Models/
├── LocalDevice.swift              // Model für "Dieses Gerät"
├── DownloadedROM.swift            // Lokal gespeicherte ROM-Metadaten
└── ROMDownloadTask.swift          // Download-Status-Model

Domain/UseCases/LocalDevice/
├── RegisterLocalDeviceUseCase.swift
├── DownloadROMToLocalDeviceUseCase.swift
├── GetDownloadedROMsUseCase.swift
├── DeleteDownloadedROMUseCase.swift
├── ShareROMWithEmulatorUseCase.swift
└── GetDownloadProgressUseCase.swift

Domain/RepositoryProtocols/
└── LocalROMRepositoryProtocol.swift
```

#### Data Layer

```
Data/Repositories/
└── LocalROMRepository.swift       // Verwaltet lokale ROM-Dateien

Data/Services/
├── ROMDownloadService.swift       // URLSession Download-Manager
├── FileStorageService.swift       // Dateisystem-Operationen
└── ROMFileProviderExtension.swift // iOS Files-App Integration
```

#### UI Layer

```
UI/LocalDevice/
├── LocalDeviceViewModel.swift
├── LocalDeviceView.swift
├── DownloadManagerView.swift
├── DownloadManagerViewModel.swift
├── DownloadedROMsView.swift
└── DownloadedROMsViewModel.swift
```

### 4.2 Device-Type Erweiterung

Aktuell gibt es nur SFTP-Devices. Wir brauchen einen Device-Type:

```swift
enum DeviceType: String, Codable {
    case sftp       // Externes Gerät via SFTP
    case local      // Dieses iPhone/iPad
}

protocol DeviceProtocol {
    var id: UUID { get }
    var name: String { get }
    var type: DeviceType { get }
    var isDefault: Bool { get }
}

struct LocalDevice: DeviceProtocol {
    let id: UUID
    let name: String                    // z.B. "Ilyas's iPhone"
    let type: DeviceType = .local
    var isDefault: Bool = true
    let deviceModel: String             // z.B. "iPhone 15 Pro"
    let systemVersion: String           // z.B. "iOS 18.1"
    let availableStorage: Int64         // Verfügbarer Speicher
    let totalStorage: Int64             // Gesamt-Speicher
}

// SFTPConnection erweitern
extension SFTPConnection: DeviceProtocol {
    var type: DeviceType { .sftp }
}
```

### 4.3 Unified Device Selection

In `SFTPUploadView` sollte jetzt eine einheitliche Device-Auswahl erscheinen:

```swift
@Observable
class DeviceSelectionViewModel {
    var allDevices: [any DeviceProtocol] = []
    var selectedDevice: (any DeviceProtocol)?

    init() {
        // Lokales Gerät immer als erstes
        allDevices.append(LocalDeviceManager.shared.currentDevice)

        // Dann alle SFTP-Devices
        allDevices.append(contentsOf: sftpRepository.getAllConnections())
    }
}
```

### 4.4 Download-Service Architektur

```swift
protocol ROMDownloadServiceProtocol {
    func downloadROM(
        romId: Int,
        fileIds: [Int],
        progressHandler: @escaping (Int64, Int64) -> Void
    ) async throws -> [URL]

    func pauseDownload(taskId: UUID)
    func resumeDownload(taskId: UUID) async throws
    func cancelDownload(taskId: UUID)
    func getAllDownloadTasks() -> [ROMDownloadTask]
}

class ROMDownloadService: ROMDownloadServiceProtocol {
    private let session: URLSession
    private var activeTasks: [UUID: URLSessionDownloadTask] = [:]

    init() {
        let config = URLSessionConfiguration.background(
            withIdentifier: "com.romm.downloads"
        )
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        self.session = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: nil
        )
    }

    func downloadROM(...) async throws -> [URL] {
        // 1. ROM-Datei-URLs vom Server abrufen
        // 2. Download-Tasks erstellen
        // 3. In lokales Verzeichnis herunterladen
        // 4. Fortschritt tracken
        // 5. URLs der heruntergeladenen Dateien zurückgeben
    }
}
```

### 4.5 Persistence Layer

#### Core Data Schema (Optional)

Falls ROMs mit Core Data getrackt werden sollen:

```swift
entity DownloadedROMEntity {
    romId: Int
    romName: String
    platformName: String
    downloadedAt: Date
    totalSizeBytes: Int64
    localDirectory: String
    files: [DownloadedROMFileEntity]
}

entity DownloadedROMFileEntity {
    fileName: String
    filePath: String
    fileSizeBytes: Int64
    fileHash: String?
}
```

#### Alternative: JSON-basierte Metadaten

Einfachere Variante ohne Core Data:

```
Documents/ROMs/{Platform}/{ROM}/
├── rom_files...
└── .metadata.json
```

```json
{
  "romId": 123,
  "romName": "Pokemon Red",
  "platformName": "Game Boy",
  "downloadedAt": "2025-11-07T10:30:00Z",
  "files": [
    {
      "fileName": "Pokemon Red (USA).gb",
      "fileSizeBytes": 1048576,
      "md5Hash": "abc123..."
    }
  ]
}
```

### 4.6 File Provider Extension

Um ROMs in der iOS Files-App anzuzeigen:

```swift
// FileProviderExtension Target
class ROMFileProvider: NSFileProviderExtension {
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        // ROM-Dateien als Items bereitstellen
    }

    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        // URLs zu lokalen ROM-Dateien zurückgeben
    }
}
```

## 5. Implementation Plan

### Phase 1: Foundation (1-2 Tage)

**Ziel:** Basis-Infrastruktur für lokales Gerät

- [ ] `DeviceType` Enum hinzufügen
- [ ] `DeviceProtocol` definieren
- [ ] `LocalDevice` Model erstellen
- [ ] `LocalDeviceManager` Singleton implementieren
- [ ] Auto-Registrierung beim App-Start
- [ ] Unified Device-Selection in `SFTPUploadView` integrieren

**Acceptance Criteria:**
- Lokales Gerät erscheint als erstes Device in der Liste
- Name wird automatisch von iOS-Gerätename übernommen
- Device ist standardmäßig vorausgewählt

### Phase 2: Download-Service (2-3 Tage)

**Ziel:** ROMs auf lokales Gerät herunterladen

- [ ] `ROMDownloadService` implementieren
- [ ] URLSession Background Configuration
- [ ] Download-Progress-Tracking
- [ ] Pause/Resume-Funktionalität
- [ ] Fehlerbehandlung & Retry-Logik
- [ ] Speicherplatz-Prüfung vor Download
- [ ] Ordnerstruktur erstellen (`Documents/ROMs/...`)

**Acceptance Criteria:**
- ROM kann vom Server heruntergeladen werden
- Fortschritt wird in Echtzeit angezeigt
- Download läuft im Hintergrund weiter
- Bei Fehler wird automatisch wiederholt

### Phase 3: Download-Manager UI (2-3 Tage)

**Ziel:** Download-Queue & Status-Ansicht

- [ ] `DownloadManagerView` erstellen
- [ ] `DownloadManagerViewModel` implementieren
- [ ] Download-Queue visualisieren
- [ ] Aktive Downloads mit Fortschritt anzeigen
- [ ] Pause/Resume/Cancel-Buttons
- [ ] Download-Historie
- [ ] Push-Benachrichtigungen bei Download-Abschluss

**Acceptance Criteria:**
- Mehrere Downloads können parallel laufen
- Status jedes Downloads ist sichtbar
- Downloads können pausiert und fortgesetzt werden
- Nutzer wird bei Abschluss benachrichtigt

### Phase 4: Lokale ROM-Bibliothek (2-3 Tage)

**Ziel:** Heruntergeladene ROMs anzeigen & verwalten

- [ ] `DownloadedROMsView` erstellen
- [ ] `LocalROMRepository` implementieren
- [ ] ROMs aus Dateisystem auslesen
- [ ] Metadaten-Datei (.metadata.json) pro ROM
- [ ] Gruppierung nach Plattform
- [ ] Sortier- & Filteroptionen
- [ ] ROM löschen-Funktion
- [ ] Speicher-Übersicht

**Acceptance Criteria:**
- Alle heruntergeladenen ROMs werden angezeigt
- ROMs sind nach Plattform gruppiert
- Speicherplatz-Nutzung ist sichtbar
- ROMs können gelöscht werden

### Phase 5: Emulator-Integration (1-2 Tage)

**Ziel:** ROMs mit externen Apps teilen

- [ ] Share Sheet Integration
- [ ] "Öffnen mit..." Kontextmenü
- [ ] Standard-Emulator-Einstellung
- [ ] URL-Scheme-Support für bekannte Emulatoren
- [ ] "Im Dateien-Browser zeigen"-Funktion

**Acceptance Criteria:**
- ROMs können per Share Sheet geteilt werden
- System schlägt kompatible Emulator-Apps vor
- ROM öffnet sich korrekt in ausgewähltem Emulator

### Phase 6: File Provider Extension (Optional, 2-3 Tage)

**Ziel:** ROMs in iOS Files-App anzeigen

- [ ] File Provider Extension Target erstellen
- [ ] ROMs als NSFileProviderItem bereitstellen
- [ ] In Files-App unter "Auf meinem iPhone" anzeigen
- [ ] Thumbnail-Provider für ROM-Cover

**Acceptance Criteria:**
- ROMs erscheinen in iOS Files-App
- Ordnerstruktur ist navigierbar
- ROM-Cover werden als Thumbnails angezeigt

### Phase 7: Polishing & Testing (2-3 Tage)

- [ ] Unit Tests für Download-Service
- [ ] UI Tests für Download-Flow
- [ ] Performance-Tests (große ROMs, viele Downloads)
- [ ] Fehlerbehandlung testen (Netzwerkausfall, Speicher voll)
- [ ] Accessibility-Support
- [ ] Lokalisierung (Deutsch/Englisch)
- [ ] App Icon Badges für aktive Downloads

**Gesamt-Zeitaufwand:** 12-19 Tage (ca. 2-3 Wochen)

## 6. UI/UX Mockup-Überlegungen

### 6.1 Device-Auswahl

```
┌─────────────────────────────────────┐
│ Gerät auswählen                 [×] │
├─────────────────────────────────────┤
│                                     │
│ ⭐ Dieses iPhone                   │
│    Verfügbar: 25.3 GB              │
│    [√] Standard                     │
│                                     │
│ ─────────────────────────────────  │
│                                     │
│ 🖥️  Nintendo Switch                │
│    192.168.1.50                    │
│    Verbunden                        │
│                                     │
│ 🖥️  Raspberry Pi                   │
│    192.168.1.100                   │
│    Getrennt                         │
│                                     │
└─────────────────────────────────────┘
```

### 6.2 Download-Manager

```
┌─────────────────────────────────────┐
│ ⬇️ Downloads                        │
├─────────────────────────────────────┤
│                                     │
│ Aktiv (2)                           │
│                                     │
│ Pokemon Red                         │
│ ████████░░░░ 65% • 3.2 MB/s        │
│ [⏸️ Pause]                          │
│                                     │
│ Final Fantasy VII (Disc 1)         │
│ ██░░░░░░░░░░ 15% • 1.8 MB/s        │
│ [⏸️ Pause]                          │
│                                     │
│ ─────────────────────────────────  │
│                                     │
│ Warteschlange (1)                  │
│                                     │
│ Super Mario 64                     │
│ Wartet... • 8.0 MB                 │
│ [▶️ Starten] [×]                   │
│                                     │
│ ─────────────────────────────────  │
│                                     │
│ Abgeschlossen (5)                  │
│ Zuletzt: Zelda - Link's Awakening │
│                                     │
└─────────────────────────────────────┘
```

### 6.3 Lokale ROM-Bibliothek

```
┌─────────────────────────────────────┐
│ 📁 Meine Downloads          [⚙️]   │
├─────────────────────────────────────┤
│ 🔍 Suchen...          [↕️ Sortieren] │
├─────────────────────────────────────┤
│                                     │
│ 🎮 Game Boy (3)                    │
│                                     │
│ ┌─────┐ Pokemon Red                │
│ │ 🔴  │ 1.0 MB • Vor 2 Tagen       │
│ └─────┘ [▶️] [📤] [🗑️]              │
│                                     │
│ ┌─────┐ Pokemon Blue               │
│ │ 🔵  │ 1.0 MB • Vor 3 Tagen       │
│ └─────┘ [▶️] [📤] [🗑️]              │
│                                     │
│ ─────────────────────────────────  │
│                                     │
│ 🎮 Nintendo 64 (1)                 │
│                                     │
│ ┌─────┐ Super Mario 64             │
│ │ 🟡  │ 8.0 MB • Vor 1 Woche       │
│ └─────┘ [▶️] [📤] [🗑️]              │
│                                     │
├─────────────────────────────────────┤
│ 💾 12.5 GB verwendet von 128 GB    │
│ [🗑️ Speicher bereinigen]           │
└─────────────────────────────────────┘
```

## 7. Open Questions & Entscheidungen

### 7.1 Architektur-Entscheidungen

**Frage 1: Core Data vs. JSON-Metadaten?**

| Option | Vorteile | Nachteile |
|--------|----------|-----------|
| Core Data | - Mächtige Queries<br>- iCloud-Sync einfacher | - Setup-Overhead<br>- Migration komplexer |
| JSON-Dateien | - Einfach<br>- Portabel | - Keine komplexen Queries<br>- Manuelles Parsing |

**Empfehlung:** JSON-Metadaten für MVP, später auf Core Data migrieren falls nötig

**Frage 2: Parallele Downloads-Limit?**

**Empfehlung:** 3 parallele Downloads (Balance zwischen Geschwindigkeit & Ressourcen)

**Frage 3: File Provider Extension bereits in MVP?**

**Empfehlung:** Optional für Phase 6, da separate App Extension nötig

### 7.2 UX-Fragen

**Frage 1: Wo wird "Meine Downloads"-Ansicht angezeigt?**

Optionen:
- A) Neuer Tab in der Tab-Bar
- B) Sektion in der Library-Ansicht
- C) Separater Screen über Settings

**Empfehlung:** Option B (Library-Sektion), da thematisch passend

**Frage 2: Download-Manager persistent sichtbar?**

**Empfehlung:** Kleines Badge/Banner am unteren Bildschirmrand bei aktiven Downloads

**Frage 3: Standard-Emulator festlegen?**

**Empfehlung:** Einstellung in Settings, zeigt "Öffnen mit [Delta]" im Kontextmenü

### 7.3 Technische Fragen

**Frage 1: Speicherort der ROMs?**

Optionen:
- A) App Documents (iCloud-backup, in Files sichtbar)
- B) App Support (kein iCloud-backup)
- C) Caches (kann vom System gelöscht werden)

**Empfehlung:** Documents für wichtige ROMs, mit Option zum Ausschluss vom Backup

**Frage 2: Download-Resume bei App-Neustart?**

**Empfehlung:** Ja, via URLSession Background Tasks automatisch

**Frage 3: ROM-Hashes validieren?**

**Empfehlung:** Ja, MD5/SHA1 vom Server mit heruntergeladener Datei vergleichen

## 8. Migrations-Strategie

### Bestehende User

Für User, die bereits SFTP-Devices konfiguriert haben:

1. **Beim nächsten App-Start:**
   - Lokales Gerät wird automatisch hinzugefügt
   - Alert: "Neu: Du kannst jetzt ROMs direkt auf dein iPhone herunterladen!"
   - Tutorial-Screen zeigen (optional überspringbar)

2. **Device-Liste:**
   - Lokales Gerät erscheint **oben** in der Liste
   - SFTP-Devices darunter
   - Standard-Device bleibt erhalten (falls User SFTP-Device als Standard hatte)

### Neue User

1. **Onboarding:**
   - Lokales Gerät ist einziges Device
   - Tutorial zeigt Download-Feature als erstes
   - Hinweis: "Möchtest du ROMs an andere Geräte senden? Füge ein SFTP-Gerät hinzu!"

## 9. Testing Strategy

### 9.1 Unit Tests

```swift
// Tests für Download-Service
func testDownloadROM_Success()
func testDownloadROM_NetworkError_Retry()
func testDownloadROM_InsufficientStorage()
func testPauseResumeDownload()
func testCancelDownload()

// Tests für LocalROMRepository
func testGetAllDownloadedROMs()
func testDeleteROM_RemovesFilesAndMetadata()
func testGetStorageInfo()
```

### 9.2 Integration Tests

```swift
func testFullDownloadFlow_ServerToLocalStorage()
func testMultipleParallelDownloads()
func testDownloadWithAppBackgrounding()
func testShareROMWithExternalApp()
```

### 9.3 UI Tests

```swift
func testDownloadROMFromRomDetail()
func testPauseAndResumeDownloadInManager()
func testDeleteROMFromLibrary()
func testOpenROMWithShareSheet()
```

### 9.4 Performance Tests

- Download-Geschwindigkeit (großer ROM, 1 GB+)
- Parallele Downloads (3+ gleichzeitig)
- Datei-Listing-Performance (1000+ ROMs)
- Speicher-Nutzung während Download

## 10. Success Metrics

### MVP-Erfolgskriterien

- [ ] Lokales Gerät wird automatisch registriert
- [ ] ROMs können erfolgreich heruntergeladen werden
- [ ] Download-Fortschritt wird korrekt angezeigt
- [ ] Heruntergeladene ROMs werden in Library angezeigt
- [ ] ROMs können per Share Sheet mit Emulatoren geteilt werden
- [ ] Speicher-Management funktioniert (Löschen, Speicherplatz-Anzeige)
- [ ] App stürzt nicht bei großen Downloads ab
- [ ] Downloads funktionieren im Hintergrund

### Langfristige Metriken

- % der User, die lokales Device vs. SFTP nutzen
- Durchschnittliche Anzahl heruntergeladener ROMs pro User
- Download-Erfolgsrate vs. Fehlerrate
- Durchschnittliche Download-Geschwindigkeit

## 11. Next Steps

1. **Review dieses Plans mit Team**
2. **Priorisierung der Phasen** (MVP = Phasen 1-5)
3. **Detailliertes UI-Design** (Mockups/Figma)
4. **Technische Spikes:**
   - URLSession Background Download testen
   - File Provider Extension Prototyp
   - Share Sheet mit Emulator-Apps testen
5. **Story-Breakdown** für Sprint-Planung
6. **Implementation starten** (Branch: `feature/device_downloader`)

---

**Autor:** Claude
**Review benötigt von:** Product Owner, iOS-Lead
**Nächste Schritte:** Feedback sammeln & Implementierung starten
