# API Client Usage Analysis

## Overview

This document analyzes the usage of `RommAPIClient` throughout the project and identifies places where manual `URLSession` calls are used instead of the central API client.

**Last Updated**: 2025-11-16

---

## 🎯 Goal

The `RommAPIClient` is the central abstraction for all API calls and provides:
- Centralized authentication (Basic Auth)
- Self-signed certificate support
- Consistent error handling
- Unified logging via `Logger.network`
- Easier testing through mock capability

---

## 📊 Analysis Results

### 🟢 Correctly Implemented Manually (DO NOT CHANGE)

#### 1. SetupRepository - OAuth2 Token Acquisition
**File**: [romm/romm/Data/Repositories/SetupRepository.swift](../romm/romm/Data/Repositories/SetupRepository.swift)
**Lines**: 176-255
**Method**: `validateBasicAuthConnection()`

**Code Location**:
```swift
private func validateBasicAuthConnection(serverURL: String, username: String, password: String) async throws -> String {
    // OAuth2 Token request to /api/token
    let (data, response) = try await URLSession.shared.data(for: request)
    // ...
}
```

**Why Manual Implementation is Correct**:
- ✅ Setup runs **BEFORE** API client configuration
- ✅ Bootstrap problem: RommAPIClient needs this token data to function
- ✅ Cannot depend on TokenProvider during setup
- ✅ Manual URLSession call is the right solution here

**Recommendation**: ✅ **Keep as is**

---

#### 2. ConfigurationService - Token Refresh & Basic Auth Test
**File**: [romm/romm/Data/Services/ConfigurationService.swift](../romm/romm/Data/Services/ConfigurationService.swift)
**Lines**: 145-211 (Token Refresh), 216-283 (Basic Auth Test)

**Code Locations**:
```swift
// Token Refresh
func refreshToken() async throws -> Bool {
    let (data, response) = try await URLSession.shared.data(for: request)
    // ...
}

// Basic Auth Test
private func testBasicAuthConnection(serverURL: String, username: String, password: String) async throws {
    let (data, response) = try await URLSession.shared.data(for: request)
    // ...
}
```

**Why Manual Implementation is Correct**:
- ✅ Runs independently from configured API client
- ✅ Manages the RommAPIClient's configuration
- ✅ Used for setup validation
- ✅ Token refresh should be independent of API client state

**Recommendation**: ✅ **Keep as is**

---

### 🟡 Borderline Case - Can Stay, Could Be Improved

#### 3. RomsRepository - Multipart Request for Favorites
**File**: [romm/romm/Data/Repositories/RomsRepository.swift](../romm/romm/Data/Repositories/RomsRepository.swift)
**Lines**: 183-226
**Method**: `makeMultipartRequest()`

**Code Location**:
```swift
private func makeMultipartRequest(path: String, boundary: String, formData: Data) async throws -> Data {
    // Manual multipart request for collection updates
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    // Manually add Basic Auth
    let loginString = "\(username):\(password)"
    let base64LoginString = loginData.base64EncodedString()
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await URLSession.shared.data(for: request)
    // ...
}
```

**Used In**:
- `toggleRomFavorite()` - Updates the Favorites collection

**PRO Manual**:
- ✅ Very specialized request type (multipart)
- ✅ Only used in one place
- ✅ RommAPIClient doesn't currently support multipart

**CONTRA Manual**:
- ⚠️ Duplicates auth logic (TokenProvider, Basic Auth header)
- ⚠️ Duplicates URL building
- ⚠️ No central error handling
- ⚠️ No self-signed certificate support (uses `URLSession.shared` instead of custom session)

**Recommendation**: 🟡 **Can stay as is**, but if more multipart requests are needed:
→ Extend RommAPIClient with multipart support

**Alternative Solution**:
```swift
// Extend RommAPIClient:
extension RommAPIClient {
    func makeMultipartRequest(
        path: String,
        fields: [String: String],
        files: [String: Data]? = nil
    ) async throws -> Data {
        // Central multipart implementation with Auth & SSL support
    }
}
```

---

### 🔴 Should Definitely Use RommAPIClient

#### 4. SFTPUploadViewModel - ROM File Download ⭐ CRITICAL
**File**: [romm/romm/UI/Devices/SFTP/SFTPUploadViewModel.swift](../romm/romm/UI/Devices/SFTP/SFTPUploadViewModel.swift)
**Lines**: 469-607
**Method**: `downloadRomFile()`

**Code Location**:
```swift
private func downloadRomFile(fileInfo: RomFileInfo) async throws -> String {
    // Manual download request
    let downloadURLString = "\(serverURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/api/roms/\(rom.id)/content/\(fileInfo.fileName)"

    var request = URLRequest(url: downloadURL)
    request.httpMethod = "GET"

    // Manually add auth
    let tokenProvider = TokenProvider()
    guard let username = tokenProvider.getUsername(),
          let password = tokenProvider.getPassword() else {
        throw SFTPError.authenticationFailed
    }

    let loginString = "\(username):\(password)"
    let base64LoginString = loginData.base64EncodedString()
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

    let downloadTask = URLSession.shared.downloadTask(with: request) { ... }
    // ...
}
```

**Problems**:
- ❌ **Duplicates complete auth logic** (TokenProvider, Basic Auth header creation)
- ❌ **Duplicates URL building** (serverURL trimming, path construction)
- ❌ **No self-signed certificate support** (uses `URLSession.shared`)
- ❌ **No central error handling** (custom error mapping)
- ❌ **No central logging** via `Logger.network`
- ❌ **Harder to test** (no mock capability)

**Recommendation**: 🔴 **SHOULD BE CHANGED**

**Proposed Solution**:
```swift
// 1. Extend RommAPIClient:
extension RommAPIClient {
    /// Downloads a file with progress tracking
    func downloadFile(
        path: String,
        progressHandler: @escaping (Int64, Int64) -> Void
    ) async throws -> URL {
        let url = try buildURL(path: path)

        // Get credentials (like in makeRequest)
        guard let username = tokenProvider.getUsername(),
              let password = tokenProvider.getPassword() else {
            throw APIClientError.noCredentials
        }

        // Create request with auth
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let loginString = "\(username):\(password)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        // Download with progress
        let (tempURL, response) = try await urlSession.download(for: request)

        // Response validation
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIClientError.invalidResponse(...)
        }

        return tempURL
    }
}

// 2. Simplify SFTPUploadViewModel:
private func downloadRomFile(fileInfo: RomFileInfo) async throws -> String {
    // Simply use RommAPIClient
    let tempURL = try await apiClient.downloadFile(
        path: "api/roms/\(rom.id)/content/\(fileInfo.fileName)",
        progressHandler: { [weak self] downloaded, total in
            // Progress updates
            self?.prepareProgress = Double(downloaded) / Double(total)
        }
    )

    // Move file to desired location
    let localPath = getTemporaryFilePath(for: fileInfo.fileName)
    try FileManager.default.moveItem(at: tempURL, to: URL(fileURLWithPath: localPath))
    return localPath
}
```

**Benefits**:
- ✅ Eliminates ~50 lines of duplicated code
- ✅ Self-signed certificate support automatically
- ✅ Central error handling
- ✅ Consistent logging
- ✅ Testable through RommAPIClient mock

---

#### 5. LocalROMDownloadService - ROM File Download ⭐ CRITICAL
**File**: [romm/romm/Data/Services/LocalROMDownloadService.swift](../romm/romm/Data/Services/LocalROMDownloadService.swift)
**Lines**: 182-241
**Method**: `downloadFile()`

**Code Location**:
```swift
private func downloadFile(
    fileName: String,
    romId: Int,
    to destinationURL: URL,
    expectedSize: Int64,
    progressHandler: @escaping (Int64) -> Void
) async throws {
    // Manual download - exact same problems as SFTPUploadViewModel
    guard let serverURL = tokenProvider.getServerURL() else {
        throw LocalROMDownloadError.downloadFailed("No server URL configured")
    }

    let downloadURLString = "\(cleanServerURL)/api/roms/\(romId)/content/\(fileName)"

    var request = URLRequest(url: downloadURL)
    request.httpMethod = "GET"

    // Manual auth
    if let username = tokenProvider.getUsername(),
       let password = tokenProvider.getPassword() {
        let loginString = "\(username):\(password)"
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    }

    let (tempFileURL, response) = try await URLSession.shared.download(for: request)
    // ...
}
```

**Problems**: Exactly identical to #4
- ❌ Duplicates auth logic
- ❌ Duplicates URL building
- ❌ No self-signed certificate support
- ❌ No central error handling
- ❌ No central logging

**Recommendation**: 🔴 **SHOULD BE CHANGED**

**Proposed Solution**: Use the same `downloadFile()` method in RommAPIClient as #4

---

## 📋 Action Items

### Priority 1: Consolidate Download Functionality
**Affected Files**:
- `SFTPUploadViewModel.swift`
- `LocalROMDownloadService.swift`

**Action**:
1. Extend `RommAPIClient` with `downloadFile(path:progressHandler:)` method
2. Migrate both services to use this method
3. Eliminate ~100 lines of duplicated code

**Estimated Effort**: 2-3 hours

**Benefits**:
- ✅ Eliminates significant code duplication
- ✅ Self-signed certificate support for downloads
- ✅ Consistent error handling
- ✅ Better logging
- ✅ Easier testing

---

### Priority 2 (Optional): Centralize Multipart Support
**Affected File**: `RomsRepository.swift`

**Action**:
- Only if more multipart requests are needed
- Extend `RommAPIClient` with generic multipart method
- Migrate `RomsRepository`

**Estimated Effort**: 1-2 hours

---

### Do Not Change: Setup & Configuration
**Affected Files**:
- `SetupRepository.swift`
- `ConfigurationService.swift`

**Reason**: Bootstrap problem - these services configure the RommAPIClient and must work independently

---

## 🔍 Code Statistics

### Current State
- **Repositories correctly using RommAPIClient**: 4
  - AuthRepository
  - ManualRepository
  - CollectionsRepository
  - PlatformsRepository

- **Services with manual URLSession (justified)**: 2
  - SetupRepository
  - ConfigurationService

- **Services with manual URLSession (should be changed)**: 2
  - SFTPUploadViewModel
  - LocalROMDownloadService

- **Borderline cases**: 1
  - RomsRepository (multipart)

### After Refactoring
- **Potential line savings**: ~100-120 lines
- **Eliminated code duplication**: Auth logic, URL building, error handling
- **New RommAPIClient methods**: 1-2 (downloadFile, optional: multipart)

---

## 📝 Implementation Checklist

### Phase 1: Download Consolidation
- [ ] Extend RommAPIClient with `downloadFile()`
  - [ ] Progress handler support
  - [ ] Self-signed certificate support (already present through urlSession)
  - [ ] Error handling
  - [ ] Logging
- [ ] Refactor SFTPUploadViewModel
  - [ ] Migrate `downloadRomFile()` to new API client
  - [ ] Update tests
- [ ] Refactor LocalROMDownloadService
  - [ ] Migrate `downloadFile()` to new API client
  - [ ] Update tests
- [ ] Perform integration tests
  - [ ] ROM download via SFTP
  - [ ] ROM download to local device
  - [ ] Verify self-signed certificate support

### Phase 2 (Optional): Multipart Support
- [ ] Extend RommAPIClient with generic `makeMultipartRequest()`
- [ ] Refactor RomsRepository
  - [ ] Migrate favorites toggle
  - [ ] Update tests

---

## 🎓 Lessons Learned

### When Manual URLSession is Correct:
1. **Bootstrap/Setup**: When the service configures the API client
2. **Independent Services**: Token refresh, configuration management
3. **Before API Client Initialization**: Setup flow

### When RommAPIClient Should Be Used:
1. **Standard API Calls**: GET, POST, PUT, DELETE
2. **Authenticated Requests**: Anything requiring auth
3. **Self-signed Certificates**: Self-hosted servers
4. **Consistent Error Handling**: When unified error handling is desired
5. **Logging**: Central traceability

### Code Smell Indicators for Manual URLSession:
- ⚠️ Calling TokenProvider directly
- ⚠️ Manually building Basic Auth headers
- ⚠️ Manually building URLs with string trimming
- ⚠️ Using URLSession.shared instead of custom session with SSL support
- ⚠️ Duplicating error handling

---

## 📚 References

- **Main API Client**: [RommAPIClient.swift](../romm/romm/Data/DataSources/RommAPIClient.swift)
- **Token Provider**: [TokenProvider.swift](../romm/romm/Data/Services/TokenProvider.swift)
- **Logging System**: [Logging-System.md](./Logging-System.md)

---

*Last Updated: 2025-11-16*
