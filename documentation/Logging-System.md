# Logging-System Dokumentation

Das RomM iOS App Logging-System bietet eine vollständig konfigurierbare, strukturierte Logging-Lösung basierend auf Apple's Unified Logging System.

## Überblick

Das Logging-System ersetzt alle `print()` Statements durch ein strukturiertes, kategorien-basiertes System mit konfigurierbaren Log-Leveln und Performance-optimierten Filterungen.

## Zugriff auf die Konfiguration

Die Logging-Konfiguration findest du in der App unter:

**Profil → Logging Configuration**

## Konfigurationsmöglichkeiten

### Globale Einstellungen

#### Global Minimum Level
Basis-Log-Level für die gesamte App:
- **Debug**: Zeigt alle Log-Nachrichten (sehr detailliert)
- **Info**: Zeigt informative Nachrichten und höher
- **Notice**: Zeigt bemerkenswerte Ereignisse und höher  
- **Warning**: Zeigt nur Warnungen, Fehler und kritische Meldungen
- **Error**: Zeigt nur Fehler und kritische Meldungen
- **Critical**: Zeigt nur kritische System-Meldungen

#### Weitere globale Optionen
- **Show Performance Logs**: Ein/Aus für Performance-Messungen und Timing-Informationen
- **Show Timestamps**: Zeitstempel in Log-Nachrichten anzeigen (Format: HH:mm:ss.SSS)
- **Include Source Location**: Dateiname und Zeilennummer in Logs einblenden

### Kategorien-spezifische Konfiguration

Jede App-Komponente hat eine eigene Kategorie, die individuell konfiguriert werden kann:

| Kategorie | Beschreibung | Beispiel-Inhalte |
|-----------|--------------|------------------|
| **Network** | Netzwerk-Operationen | API-Aufrufe, HTTP-Requests, Response-Codes, Netzwerk-Fehler |
| **UI** | Benutzeroberfläche | View-Updates, User-Interaktionen, Navigation, UI-Komponenten |
| **Data** | Daten-Operationen | Repository-Operationen, Daten-Caching, Persistierung, Datenbank |
| **Auth** | Authentifizierung | Login, Logout, Token-Management, Berechtigungen |
| **Performance** | Leistungs-Metriken | Timing-Messungen, Performance-Analysen, Optimierungen |
| **General** | Allgemeine Logik | Use Cases, Business-Logik, allgemeine App-Operationen |
| **Manual** | PDF-Manual System | Manual-Downloads, PDF-Verarbeitung, Manual-spezifische Operationen |
| **ViewModel** | View-Model Layer | Zustandsänderungen, Data-Binding, View-Model Lifecycle |

## Log-Level Hierarchie

Die Log-Level funktionieren hierarchisch - ein höheres Level schließt alle niedrigeren Level ein:

```
Debug ← Info ← Notice ← Warning ← Error ← Critical
  ↑                                          ↑
Zeigt alles                          Zeigt nur kritische
```

### Praktische Bedeutung:
- **Debug-Level**: Siehst alle Nachrichten (Debug, Info, Notice, Warning, Error, Critical)
- **Info-Level**: Siehst Info und höher (Info, Notice, Warning, Error, Critical)  
- **Warning-Level**: Siehst nur Warnings und höher (Warning, Error, Critical)
- **Error-Level**: Siehst nur Errors und Critical
- **Critical-Level**: Siehst nur Critical-Meldungen

## Anwendungsszenarien

### Normale Nutzung
```
Global Level: Info
Network: Info          → Wichtige API-Calls sehen
UI: Warning           → Nur bei UI-Problemen
Data: Info            → Wichtige Daten-Operationen
Performance: Aus      → Nicht nötig im normalen Betrieb
```

### Debugging von Netzwerk-Problemen  
```
Global Level: Debug
Network: Debug        → Alle Netzwerk-Details sehen
Auth: Debug           → Authentifizierungs-Details
UI: Warning          → UI-Rauschen reduzieren
Data: Warning        → Daten-Rauschen reduzieren
```

### Performance-Analyse
```
Performance Logs: Ein
Performance: Debug    → Alle Timing-Informationen
Global Level: Error   → Minimales Logging für bessere Performance
Alle anderen: Error   → Rauschen eliminieren
```

### Produktions-Monitoring
```
Global Level: Warning
Network: Warning      → Nur bei Netzwerk-Problemen
Auth: Warning        → Nur bei Auth-Problemen  
UI: Error           → Nur bei schweren UI-Fehlern
```

## Log-Format

Jeder Log-Eintrag wird automatisch formatiert:

```
[Timestamp] [Emoji] [Kategorie] [Quellenangabe] Funktion - Nachricht
```

### Beispiel:
```
14:32:15.123 🌐 [Network] [RommAPIClient:94] makeRequest - GET /api/roms - Status: 200
14:32:15.125 ℹ️ [ViewModel] [RomDetailViewModel:49] loadRomDetails - Loaded ROM details for Super Mario Bros
14:32:15.127 ⚠️ [UI] [PDFViewer:27] makeUIView - Failed to create PDF document from data
```

### Emoji-Bedeutungen:
- 🔍 **Debug**: Detaillierte Debugging-Informationen
- ℹ️ **Info**: Informative Nachrichten über normale Operationen
- 📢 **Notice**: Bemerkenswerte Ereignisse
- ⚠️ **Warning**: Warnungen über potentielle Probleme
- ❌ **Error**: Fehler-Bedingungen
- 💥 **Critical**: Kritische System-Fehler

## Log-Ausgabe-Orte

Die Logs werden über Apple's Unified Logging System ausgegeben und sind verfügbar in:

### Entwicklung
- **Xcode Console**: Logs erscheinen direkt in der Xcode-Konsole während des Debuggens
- **Xcode Debug Area**: Strukturierte Anzeige mit Filterungsmöglichkeiten

### Produktions-/Test-Umgebung
- **Console.app** (macOS): Alle Logs des verbundenen iOS-Geräts
- **iOS Settings**: Analytics & Improvements → Analytics & Improvements Data
- **Instruments**: Performance-Analyse mit detaillierter Log-Korrelation

### Log-Kommandos (Terminal/Console.app)
```bash
# Alle Logs der RomM App
log stream --predicate 'subsystem == "com.romm.app"'

# Nur Network-Kategorie
log stream --predicate 'subsystem == "com.romm.app" && category == "Network"'

# Nur Error-Level und höher
log stream --level error --predicate 'subsystem == "com.romm.app"'
```

## Performance-Vorteile

### Effiziente Filterung
- Logs werden nur verarbeitet, wenn sie den konfigurierten Level erreichen
- Kategorien können komplett deaktiviert werden ohne Performance-Verlust
- String-Interpolation findet nur statt, wenn der Log auch ausgegeben wird

### Performance-Messung
Das System bietet eingebaute Performance-Messung:

```swift
// Automatische Timing-Messung
let measurement = PerformanceMeasurement(operation: "Load ROM Details")
// ... Operation ausführen ...
measurement.end() // Loggt automatisch die Dauer
```

### Memory-Effizienz
- Strukturierte Logs verwenden weniger Memory als string-basierte print-Statements
- Automatische Log-Rotation durch das System
- Keine Log-Dateien im App-Bundle

## Entwickler-Hinweise

### Verwendung im Code

```swift
// Logger-Instanz erstellen (einmalig pro Klasse)
private let logger = Logger.network // oder .ui, .data, etc.

// Verschiedene Log-Level verwenden
logger.debug("Detaillierte Debug-Information")
logger.info("Normale Operation abgeschlossen")
logger.warning("Potentielles Problem erkannt")
logger.error("Fehler aufgetreten: \(error)")

// Convenience-Methoden für Netzwerk
logger.logNetworkRequest(method: "GET", url: "/api/roms", statusCode: 200)
logger.logNetworkError(method: "POST", url: "/api/login", error: error)

// Performance-Messung
logger.logPerformance("Database Query", duration: 0.145)
```

### Kategorie-Zuordnung

| Code-Bereich | Empfohlene Kategorie | Grund |
|--------------|---------------------|-------|
| ViewModels | `.viewModel` | UI-Zustand und Data-Binding |
| Views/UI | `.ui` | User Interface Events |
| Repositories | `.data` | Daten-Zugriff und Persistierung |
| API Clients | `.network` | Netzwerk-Kommunikation |
| Use Cases | `.general` | Business-Logik |
| Auth Services | `.auth` | Authentifizierung und Autorisierung |

### Best Practices

1. **Passende Log-Level wählen**:
   - `debug()`: Detaillierte Entwickler-Informationen
   - `info()`: Wichtige Geschäfts-Events
   - `warning()`: Probleme, die behandelt werden können
   - `error()`: Fehler, die Funktionalität beeinträchtigen

2. **Sensitive Daten vermeiden**:
   ```swift
   // ❌ Falsch - Password im Klartext
   logger.debug("Login with password: \(password)")
   
   // ✅ Richtig - Nur Existenz loggen
   logger.debug("Password: \(password != nil ? "provided" : "missing")")
   ```

3. **Performance-bewusst loggen**:
   ```swift
   // ✅ Gut - Lazy evaluation
   logger.debug("Complex calculation result: \(expensiveCalculation())")
   
   // ✅ Noch besser - Guard clause
   guard logger.config.shouldLog(.debug, for: .data) else { return }
   let result = expensiveCalculation()
   logger.debug("Complex calculation result: \(result)")
   ```

## Konfiguration zurücksetzen

In der Logging Configuration View gibt es einen "Reset to Defaults" Button, der alle Einstellungen auf die Standardwerte zurücksetzt:

- Global Level: **Debug**
- Alle Kategorien: **Debug**  
- Performance Logs: **Ein**
- Timestamps: **Ein**
- Source Location: **Ein**

## Fehlerbehebung

### Keine Logs sichtbar
1. **Log-Level prüfen**: Ist das globale oder kategorien-spezifische Level zu hoch gesetzt?
2. **Kategorie prüfen**: Ist die richtige Kategorie für den gewünschten Code-Bereich ausgewählt?
3. **Console.app verwenden**: Manchmal sind Logs nur in der macOS Console App sichtbar

### Performance-Probleme
1. **Debug-Level in Produktion**: Setze das globale Level auf `Warning` oder höher
2. **Performance Logs deaktivieren**: Schalte "Show Performance Logs" aus
3. **Kategorien einschränken**: Setze unwichtige Kategorien auf `Error`-Level

### Zu viele Logs
1. **Source Location ausschalten**: Reduziert die Log-Größe
2. **Timestamps ausschalten**: Spart Platz in der Ausgabe  
3. **Kategorien-spezifische Filterung**: Erhöhe das Level für laute Kategorien

---

*Letzte Aktualisierung: August 2025*
*Version: 1.0*