# Feature-Spezifikation: iOS ROM-Verwaltungs-App mit SFTP-Geräteanbindung

## Kontext
Eine iOS-App zur Verwaltung von ROM-Dateien mit einem Backend namens romm-app. Die App ermöglicht das Verwalten von Geräten, die per SFTP angebunden sind, und das Übertragen von ROM-Dateien auf diese Geräte.

---

## 1. Geräteverwaltung

- Geräte können per SFTP angebunden werden (Hostname, Port, Benutzername, Passwort/Schlüssel).
- Jedes Gerät wird mit einem individuellen Namen gespeichert.
- Geräte werden in einer Liste übersichtlich angezeigt.
- Geräte können hinzugefügt, bearbeitet oder gelöscht werden.

---

## 2. ROM Detail Screen (existiert bereits)

- Der ROM Detail Screen existiert bereits und zeigt die Details der ROM-Datei an.
- Er enthält einen Button „An Gerät senden“, um die ROM auf ein Gerät hochzuladen.
- Die bestehende Logik dieses Screens wird genutzt und nicht neu entwickelt.

---

## 3. Zielgerät-Auswahl und Upload-Ordner

- Nach Klick auf „An Gerät senden“ öffnet sich eine View mit einer Liste der gespeicherten Geräte.
- Möglichkeit, Geräte zu verwalten oder neue Geräte anzulegen.
- Nach Auswahl eines Geräts wird die Verzeichnisstruktur des Geräts über SFTP angezeigt.
- Benutzer kann einen Zielordner auf dem Gerät wählen.
- Ordner können mit einem „Stern“-Button als Favoriten markiert werden.
- Favoriten-Ordner werden lokal pro Gerät gespeichert und stehen bei künftigen Uploads als Schnellzugriff bereit.

---

## 4. Upload der ROM-Datei

- Die ROM-Datei wird vom romm-app Backend per HTTP heruntergeladen.
- Anschließend wird die Datei über SFTP (mit der *mft* Bibliothek) in den ausgewählten Zielordner auf dem Gerät hochgeladen.
- Upload-Fortschritt wird dem Nutzer in Echtzeit angezeigt.
- Nach Abschluss erscheint eine Erfolgsmeldung und der Upload-Dialog schließt sich.

---

## 5. Online-/Offline-Indikator für Geräte

- Neben jedem Gerät in der Geräteliste wird ein farbiger Status-Indikator angezeigt:
  - Grün: Gerät ist online und erreichbar.
  - Rot: Gerät ist offline oder nicht erreichbar.
- Vor oder beim Anzeigen der Liste wird asynchron eine schnelle Verbindungsprüfung zu jedem Gerät durchgeführt.
- Verbindungsprüfung erfolgt durch kurzzeitiges Öffnen und Authentifizieren der SFTP-Verbindung mit *mft* (Verbindung wird anschließend wieder geschlossen).
- UI zeigt während der Statusabfrage einen neutralen grauen Punkt oder Spinner an.
- Nutzer kann Status durch Pull-to-Refresh manuell aktualisieren.

---

## 6. Technische Details zur Implementierung mit der mft Bibliothek

- Verbindung herstellen mit `MFTSftpConnection(hostname:port:username:password:)`.
- Verbindung und Authentifizierung mit `connect()` und `authenticate()`.
- Verzeichnisinhalte abrufen mit `contentsOfDirectory(atPath:maxItems:)`.
- Dateien hochladen mit `write(stream:toFileAtPath:append:progress:)` unter Nutzung eines InputStreams für die lokale ROM-Datei.
- Upload-Fortschritt kann mit einem Callback überwacht und angezeigt werden.
- Verbindung nach Aktionen sauber mit `disconnect()` schließen.
- Geräteinformationen, Favoriten-Ordner und andere Einstellungen lokal speichern (z.B. mit UserDefaults oder CoreData).

---

## 7. Fehlerbehandlung & UX-Optimierungen

- Zeige bei Verbindungs- oder Authentifizierungsfehlern aussagekräftige Fehlermeldungen.
- Handle Timeouts und Verbindungsabbrüche robust.
- UI muss während Netzwerkaktionen reaktionsfähig bleiben, Ladezustände anzeigen.
- Geräte- und Ordnerlisten sollten scrollbar, übersichtlich und nutzerfreundlich sein.
- Favoriten-Ordner können schnell ausgewählt werden, ohne jedes Mal neu suchen zu müssen.

---

## Beispielcode Ausschnitt (Upload mit mft)
```swift
import mft
func uploadRomToDevice(device: Device, remoteFolder: String, localRomPath: String) throws {let sftp = MFTSftpConnection(hostname: device.hostname,port: device.port,username: device.username,password: device.password)

try sftp.connect()
try sftp.authenticate()

let inputStream = InputStream(fileAtPath: localRomPath)!
try sftp.write(stream: inputStream, toFileAtPath: "$$remoteFolder)/$$romFileName)", append: false) { uploaded in
    print("Upload Fortschritt: $$uploaded) Bytes")
    return true
}

sftp.disconnect()
```

Das framework wird im projekt bereits vorhanden sein. Bitte bau eine kleine fassade dafür, damit diese gekapselt ist.

---