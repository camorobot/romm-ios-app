# Feature Specification: Platforms

## Overview
Das Platforms Feature ermöglicht Benutzern das Durchsuchen und Verwalten ihrer ROM-Sammlung nach Gaming-Plattformen (z.B. Nintendo, PlayStation, etc.).

## User Stories

### US1: Platform Overview
**Als Benutzer möchte ich eine Übersicht aller verfügbaren Gaming-Plattformen sehen, damit ich schnell zu einer bestimmten Konsole navigieren kann.**

#### Acceptance Criteria:
- [ ] Zeige alle verfügbaren Plattformen in einer Liste an
- [ ] Jede Plattform zeigt ihr Logo/Bild
- [ ] Jede Plattform zeigt die Anzahl der verfügbaren ROMs
- [ ] Bei Tap auf eine Plattform öffnet sich die Platform Detail Seite
- [ ] Pull-to-refresh Funktionalität
- [ ] Loading states während dem Laden der Daten
- [ ] Error handling bei Netzwerkproblemen

### US2: Platform Detail View
**Als Benutzer möchte ich alle ROMs einer bestimmten Plattform durchsuchen können, damit ich gezielt nach Spielen für eine Konsole suchen kann.**

#### Acceptance Criteria:
- [ ] Zeige alle ROMs der ausgewählten Plattform paginiert an
- [ ] Unterstütze verschiedene View-Modi:
  - [ ] Small Card View (kompakte Liste)
  - [ ] Big Card View (große Karten mit Cover-Bildern)
  - [ ] Scrollable Table View (tabellarische Ansicht)
- [ ] View-Modi können über Buttons in der Toolbar gewechselt werden
- [ ] A-Z Alphabet-Leiste an der Seite für schnelle Navigation
- [ ] Pull-to-refresh für aktuelle Daten
- [ ] Infinite Scrolling/Pagination für Performance
- [ ] Search Bar für Filterung nach ROM-Namen

### US3: Alphabet Navigation
**Als Benutzer möchte ich über eine A-Z Leiste schnell zu ROMs mit einem bestimmten Anfangsbuchstaben springen können.**

#### Acceptance Criteria:
- [ ] A-Z Leiste am rechten Rand der Detail View
- [ ] Bei Tap auf einen Buchstaben scrollt die Liste zum ersten ROM mit diesem Buchstaben
- [ ] Haptic Feedback bei Buchstaben-Selection
- [ ] Visual Feedback welcher Buchstabe aktuell aktiv ist
- [ ] Unterstütze auch Zahlen (0-9) und Sonderzeichen (#)

## Technical Requirements

### Data Models
```swift
struct Platform {
    let id: Int
    let name: String
    let slug: String
    let igdbId: Int?
    let logoPath: String?
    let romCount: Int
    let logoUrl: String? // Computed property für vollständige URL
}

struct PlatformRom {
    let id: Int
    let name: String
    let coverUrl: String?
    let releaseDate: String?
    let isFavorite: Bool
    let isPlayable: Bool
}
```

### API Endpoints
- `GET /api/platforms` - Liste aller Plattformen
- `GET /api/platforms/{id}/roms?page={page}&limit={limit}&search={query}` - ROMs einer Plattform

### Views
- `PlatformsListView` - Hauptübersicht aller Plattformen
- `PlatformDetailView` - Detail-Ansicht einer Plattform mit ROMs
- `PlatformRomCardView` - Verschiedene Card-Layouts für ROMs
- `AlphabetScrollView` - A-Z Navigation Component

### ViewModels
- `PlatformsViewModel` - Verwaltet Platform-Liste
- `PlatformDetailViewModel` - Verwaltet ROM-Liste einer Plattform

### Navigation
- Von `PlatformsListView` zu `PlatformDetailView` via NavigationLink
- Von `PlatformDetailView` zu `RomDetailView` via NavigationLink

## UI/UX Specifications

### Platform List View
- **Layout**: Vertical ScrollView mit LazyVStack
- **Platform Card**: 
  - Logo (60x60pt) links
  - Plattform-Name (Headline font)
  - ROM-Anzahl (Caption, secondary color)
  - Chevron rechts für Navigation-Indikator
- **Loading State**: Skeleton cards während dem Laden
- **Empty State**: Illustration + Text wenn keine Plattformen verfügbar

### Platform Detail View
- **Header**: 
  - Plattform-Logo und Name
  - ROM-Anzahl
  - View-Mode Toggle Buttons (Grid/List Icons)
- **Content Area**:
  - Small Card: 50px Cover + Titel + Jahr (1 Zeile)
  - Big Card: 120px Cover + Titel + Jahr + Bewertung (2 Zeilen)
  - Table: Text-only Liste mit Separatoren
- **A-Z Sidebar**: 
  - Fixed position rechts
  - Semi-transparent background
  - Haptic feedback on selection

### Loading & Error States
- **Loading**: ProgressView mit beschreibendem Text
- **Error**: Alert mit Retry-Option
- **Empty**: Illustration mit "Keine ROMs gefunden" Message
- **Network Error**: Offline-Banner mit Retry-Button

## Performance Considerations
- Lazy loading für Platform-Bilder
- Pagination für ROM-Listen (20-50 items pro Seite)
- Image caching für Cover-Arts
- Debounced search (300ms delay)
- Background refresh ohne UI-Blocking

## Accessibility
- VoiceOver Labels für alle Interactive Elements
- Dynamic Type Support
- High Contrast Mode Support
- Haptic Feedback für wichtige Aktionen
- Keyboard Navigation Support (iOS 15+)

## Testing Strategy
- Unit Tests für ViewModels
- Integration Tests für API Calls
- UI Tests für Navigation Flow
- Performance Tests für große ROM-Listen
- Accessibility Tests mit VoiceOver

## Dependencies
- RommAPI Client für Backend-Kommunikation
- AsyncImage für Image Loading
- SwiftUI Navigation für Routing

## Future Enhancements
- Favoriten-Filter in Platform Detail
- Platform-spezifische Sortierung (Release Date, Rating, etc.)
- Offline-Modus mit Core Data Caching
- Platform-Statistiken (meist gespielte ROMs, etc.)
- Custom Platform-Gruppierungen