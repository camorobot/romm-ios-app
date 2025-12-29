# Claude Code Assistenz - RomM iOS App

## 📋 Projekt Übersicht
- **App Name**: RomM iOS
- **Architektur**: Clean Architecture + MVVM
- **UI Framework**: SwiftUI
- **iOS Target**: 16.0+
- **Navigation**: NavigationStack (modern)

## 🏗️ Projekt Struktur

```
romm/
├── Data/
│   ├── DataSources/     # API Clients, Persistence
│   ├── Repositories/    # Repository Implementierungen
│   └── Services/        # Helper Services (SFTP, etc.)
├── Domain/
│   ├── Models/          # Domain Models
│   ├── UseCases/        # Business Logic (einzelne Use Cases)
│   ├── Errors/          # Custom Error Types
│   └── RepositoryProtocols/  # Repository Interfaces
├── UI/
│   ├── App/            # App Entry Points, Main Views
│   ├── Collection/     # Collection Views & ViewModels
│   ├── Platforms/      # Platform Views & ViewModels
│   ├── Search/         # Search Views & ViewModels
│   ├── SFTP/          # SFTP Device Management
│   ├── Rom/           # ROM Detail Views
│   ├── Shared/        # Reusable Components
│   ├── Components/    # UI Components
│   └── DI/           # Dependency Injection
└── CLAUDE.md         # Diese Datei (nicht in Git)
```

## 🎯 Architektur Prinzipien

### Clean Architecture
- **Domain**: Business Logic, Models, Use Cases
- **Data**: Repository Implementierungen, API Clients
- **UI**: Views, ViewModels, Components

### Dependency Injection
- **DependencyFactory**: Zentrale Factory für alle Dependencies
- **Protocol-basiert**: Alle Repositories als Protocols definiert
- **Testability**: Einfach mockbare Dependencies

### MVVM Pattern
```swift
@Observable
@MainActor  
class SomeViewModel {
    // Properties für UI State
    // Use Cases als Dependencies
    // Business Logic Methods
}
```

## 🔧 Wichtige Code Standards

### API Guidelines
- **OpenAPI First**: Verwende IMMER die OpenAPI-generierten API Wrapper wenn verfügbar
- **RommAPIClient Extensions**: Alle API Calls sollten durch RommAPIClient Wrapper-Extensions gehen
- **Authentication Setup**: Jeder API Call muss `setupAPIConfiguration()` aufrufen für Auth Headers
- **Beispiel**: Verwende `apiClient.getPlatforms()` statt direkte HTTP Requests
- **Sonderfälle**: Manche APIs (wie Collections) benötigen manuelle Implementation wenn OpenAPI unvollständig ist

### Keychain Management
- **Generischer KeychainService**: Verwende `KeychainService(service: "com.romm.servicename")` für alle Keychain-Operationen
- **Vordefinierte Services**: `KeychainService.setup` und `KeychainService.sftp` für Setup und SFTP Credentials
- **Keine direkten Security-APIs**: Immer über KeychainService abstrahieren
- **Beispiel**: `try keychain.save(key: "password", value: password)`

### API Authentication
- **Standard**: Die meisten APIs verwenden Basic Auth mit Username:Password (Base64)
- **Collections API Sonderfall**: Benötigt echten Basic Auth statt JWT Bearer Token
- **Manual Basic Auth**: `"admin:password".data(using: .utf8).base64EncodedString()`
- **Multipart Form Data**: Collections API erfordert `multipart/form-data` statt JSON

### ViewModels
```swift
@Observable
@MainActor
class MyViewModel {
    var isLoading: Bool = false
    var error: String?
    var items: [Item] = []
    
    private let getSomeItemsUseCase: GetSomeItemsUseCase
    private let deleteSomeItemUseCase: DeleteSomeItemUseCase
    private let updateSomeItemUseCase: UpdateSomeItemUseCase
    
    // Dependency Injection via Factory
    init(factory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        self.getSomeItemsUseCase = factory.makeGetSomeItemsUseCase()
        self.deleteSomeItemUseCase = factory.makeDeleteSomeItemUseCase()
        self.updateSomeItemUseCase = factory.makeUpdateSomeItemUseCase()
    }
    
    // Alternative: Direkte Use Case Injection (für Tests)
    init(
        getSomeItemsUseCase: GetSomeItemsUseCase,
        deleteSomeItemUseCase: DeleteSomeItemUseCase,
        updateSomeItemUseCase: UpdateSomeItemUseCase
    ) {
        self.getSomeItemsUseCase = getSomeItemsUseCase
        self.deleteSomeItemUseCase = deleteSomeItemUseCase
        self.updateSomeItemUseCase = updateSomeItemUseCase
    }
    
    func loadItems() async {
        isLoading = true
        error = nil
        
        do {
            let loadedItems = try await getSomeItemsUseCase.execute()
            self.items = loadedItems
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteItem(_ item: Item) async {
        do {
            try await deleteSomeItemUseCase.execute(itemId: item.id)
            items.removeAll { $0.id == item.id }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
```

### Factory Pattern
```swift
// Protocol für Dependency Factory
protocol DependencyFactoryProtocol {
    func makeGetSomeItemsUseCase() -> GetSomeItemsUseCase
    func makeDeleteSomeItemUseCase() -> DeleteSomeItemUseCase
    func makeMyViewModel() -> MyViewModel
}

// Implementierung
class DefaultDependencyFactory: DependencyFactoryProtocol {
    static let shared = DefaultDependencyFactory()
    
    func makeGetSomeItemsUseCase() -> GetSomeItemsUseCase {
        GetSomeItemsUseCase(repository: makeSomeRepository())
    }
    
    func makeMyViewModel() -> MyViewModel {
        MyViewModel(factory: self)
    }
}
```

### Use Cases
- **Einzelne Verantwortlichkeit**: Ein Use Case = Eine Aufgabe
- **Repository Pattern**: Use Cases verwenden Repository Protocols
- **Error Handling**: Proper Swift Error Handling

### SwiftUI Views
- **State Management**: `@Observable` ViewModels
- **Navigation**: NavigationStack pro Tab
- **Reusable Components**: Shared Components Ordner

## 📱 UI Komponenten

### LoadingView
```swift
LoadingView("Loading message")           // Vollbild
LoadingView("Loading...", fillScreen: false)  // Inline
```

### Navigation Struktur
```swift
TabView {
    NavigationStack { PlatformsView() }
    NavigationStack { CollectionView() }
    NavigationStack { SearchView() }      // Suchfeld nur hier
    NavigationStack { SFTPDevicesView() } // FAB nur hier
    NavigationStack { ProfileView() }
}
```

## 🎨 UI Guidelines

### Cards (BigRomCardView)
- **Bild**: 180px hoch, nur oben abgerundet
- **Info**: 100px hoch, feste Höhe für Konsistenz
- **Titel**: 3 Zeilen möglich
- **Metadata**: Jahr • Plattform • Rating (kompakt)

### Dark Mode Support
- `Color(.systemBackground)` für Card Backgrounds
- `Color.primary.opacity(0.15)` für Schatten
- `Color(.separator).opacity(0.3)` für Borders

### FAB (Floating Action Button)
- **Nur im SFTP Devices Tab**
- 56x56px, rund, Accent Color
- 16px Abstand von Rändern

## 🔍 Features

### Suche
- **Nur im Search Tab**: Suchfeld erscheint nur dort
- **Globale ROM Suche**: Durchsucht alle ROMs
- **Throttling**: 300ms Verzögerung für API Calls

### SFTP Management
- **Device Management**: Add, Edit, Delete Devices
- **Connection Testing**: Status Indicators
- **File Upload**: Mit Progress Tracking

### Collections
- **Virtual Collections**: System-generierte Sammlungen
- **Custom Collections**: Benutzer-erstellte Sammlungen
- **Pagination**: Lazy Loading mit "Load More"

## 🛠️ Build Commands

### Standard Build
```bash
xcodebuild -scheme romm -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' build
```

### Clean Build
```bash
xcodebuild -scheme romm -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' clean build
```

## 🔌 API Spezial-Implementierungen

### Collections API (Sonderfall)
Die Collections API erfordert eine manuelle Implementation, da die OpenAPI-Spezifikation unvollständig ist:

```swift
// Problem: OpenAPI unterstützt nur 'artwork' Parameter
func createCollection(artwork: URL?) // ❌ Unvollständig

// Lösung: Manuelle multipart/form-data Implementation
func createCollection(name: String, description: String, isPublic: Bool, artwork: URL?) 
```

**Warum manuell?**
- OpenAPI-Definition fehlen `name`, `description`, `isPublic` Parameter
- Server erwartet `multipart/form-data` Format (wie Web UI)
- Basic Auth mit Username:Password statt JWT Bearer Token

**Implementation Details:**
- **Authentication**: `Basic \(base64("username:password"))`
- **Content-Type**: `multipart/form-data; boundary=----WebKitFormBoundary...`
- **Required Fields**: `name`, `description`, `url_cover`, `rom_ids`
- **Format**: Exakt wie Safari Browser (6 Striche Boundary, `\r\n` Line Endings)

## 📝 Entwicklungsnotizen

### Aktuelle Architektur Verbesserungen
1. **Use Cases aufgeteilt**: Statt Wrapper-Klassen einzelne Use Cases
2. **@MainActor ViewModels**: Kein manuelles MainActor.run mehr nötig
3. **NavigationStack**: Moderne Navigation statt NavigationView
4. **Konsistente Loading States**: Einheitliche LoadingView Komponente

### Bekannte Probleme (behoben)
- ✅ Duplicate LoadingView Symbole
- ✅ Search Navigation verschwand nach verlassen
- ✅ Plus Buttons überall sichtbar
- ✅ Card Bilder gingen über Grenzen hinaus
- ✅ Dark Mode Kontrast zu schwach

### Next Steps / Verbesserungen
- [ ] Error Boundary Pattern implementieren
- [ ] Offline Support erweitern
- [ ] Performance Monitoring hinzufügen
- [ ] Unit Tests für Use Cases
- [ ] UI Tests für kritische Flows

## 📚 Dependencies
- **Kingfisher**: Für Image Caching (CachedAsyncImage)
- **OpenAPI**: Generierte API Client

## 🔄 State Management Pattern

### Loading States
```swift
enum ViewState {
    case loading
    case loaded([Item])
    case empty(String)
    case error(String)
    case loadingMore([Item])
}
```

### Error Handling
```swift
var errorMessage: String?

private func handleError(_ error: Error) {
    self.errorMessage = error.localizedDescription
}
```

---
**Letzte Aktualisierung**: 28.08.2025
**Claude Version**: Sonnet 4