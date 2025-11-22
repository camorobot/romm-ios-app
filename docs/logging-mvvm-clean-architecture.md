# Logger System: Perfect for MVVM and Clean Architecture

This logger system was specifically designed for modern iOS architecture patterns like MVVM (Model-View-ViewModel) and Clean Architecture. Through its category-based structure and configurable filters, it optimally supports separation of concerns and enables precise debugging strategies.

## Architecture Integration

### MVVM Layer Support

The logger system provides dedicated categories for each area of the MVVM architecture:

```swift
// View Layer - UI Events and View Lifecycle
private let logger = Logger.ui

// ViewModel Layer - State Management and Data Binding
private let logger = Logger.viewModel

// Model/Data Layer - Repositories and Data Access
private let logger = Logger.data
```

### Clean Architecture Layers

The logger categories perfectly correspond to Clean Architecture layers:

| Clean Architecture Layer | Logger Category | Purpose |
|--------------------------|-----------------|---------|
| **Presentation Layer** | `.ui`, `.viewModel` | Views, ViewModels, UI-State |
| **Domain Layer** | `.general`, `.auth` | Use Cases, Business Logic |
| **Data Layer** | `.data`, `.network` | Repositories, External APIs |
| **Infrastructure** | `.performance`, `.manual` | Cross-cutting Concerns |

## MVVM Benefits

### 1. Clear Separation of Concerns

```swift
// ViewModel - only ViewModel-specific logs
class ProductDetailViewModel: ObservableObject {
    private let logger = Logger.viewModel
    
    @Published var product: Product?
    @Published var isLoading = false
    
    func loadProduct(id: String) {
        logger.info("Starting product load for ID: \(id)")
        isLoading = true
        
        // Use Case is called - has its own logging
        loadProductUseCase.execute(id: id) { result in
            switch result {
            case .success(let product):
                logger.info("Successfully loaded product: \(product.title)")
                self.product = product
            case .failure(let error):
                logger.error("Failed to load product: \(error)")
            }
            self.isLoading = false
        }
    }
}

// Repository - own logging category
class ProductRepository {
    private let logger = Logger.data
    
    func fetchProduct(id: String) async throws -> Product {
        logger.debug("Fetching product from cache for ID: \(id)")
        
        if let cachedProduct = cache.product(for: id) {
            logger.info("Product found in cache: \(id)")
            return cachedProduct
        }
        
        logger.info("Product not in cache, fetching from network: \(id)")
        return try await networkService.fetchProduct(id: id)
    }
}
```

### 2. Granular Debugging Control

For MVVM-specific problems, you can target individual layers for debugging:

```swift
// Investigate only ViewModel problems
Logger.viewModel → Debug-Level
Logger.ui → Warning-Level
Logger.data → Error-Level

// Analyze only data flow problems
Logger.data → Debug-Level  
Logger.network → Debug-Level
Logger.viewModel → Warning-Level
```

### 3. Performance Optimization per Layer

```swift
// In ViewModels - measure performance-critical operations
class ProductListViewModel: ObservableObject {
    private let logger = Logger.viewModel
    
    func filterProducts(by searchText: String) {
        let measurement = PerformanceMeasurement(
            operation: "Filter products by '\(searchText)'",
            logger: logger
        )
        
        // Filtering logic...
        filteredProducts = products.filter { /* ... */ }
        
        measurement.end() // Automatic performance logging
    }
}
```

## Clean Architecture Benefits

### 1. Dependency Direction Compliance

The logger system follows the Dependency Rule - inner layers are not dependent on outer ones:

```swift
// Domain Layer Use Case
class LoginUseCase {
    private let logger = Logger.auth  // No UI/Framework Dependencies
    
    func execute(credentials: LoginCredentials) async -> Result<User, AuthError> {
        logger.info("Attempting login for user: \(credentials.username)")
        
        // Business logic without external dependencies
        guard validateCredentials(credentials) else {
            logger.warning("Invalid credentials format")
            return .failure(.invalidFormat)
        }
        
        // Repository call (Dependency Injection)
        do {
            let user = try await authRepository.authenticate(credentials)
            logger.info("Login successful for user: \(user.id)")
            return .success(user)
        } catch {
            logger.error("Login failed: \(error)")
            return .failure(.authenticationFailed)
        }
    }
}
```

### 2. Cross-Cutting Concerns Support

```swift
// Performance Monitoring - Infrastructure Layer
class PerformanceMonitor {
    private let logger = Logger.performance
    
    func measureUseCase<T>(_ name: String, operation: () async throws -> T) async rethrows -> T {
        let measurement = PerformanceMeasurement(operation: "UseCase: \(name)", logger: logger)
        defer { measurement.end() }
        
        return try await operation()
    }
}

// Usage in Use Case
class LoadProductListUseCase {
    private let logger = Logger.general
    private let monitor = PerformanceMonitor()
    
    func execute() async -> [Product] {
        return await monitor.measureUseCase("LoadProductList") {
            logger.info("Loading product list from repository")
            return await productRepository.getAllProducts()
        }
    }
}
```

### 3. Testability and Debugging

```swift
// Integration Tests - specific categories for different flows
class ProductLoadingIntegrationTests: XCTestCase {
    
    func testProductLoadingFlow() {
        // Setup: Only relevant logs for this test
        LogConfiguration.shared.setLevel(.debug, for: .data)
        LogConfiguration.shared.setLevel(.debug, for: .network)
        LogConfiguration.shared.setLevel(.warning, for: .ui) // Reduce UI noise
        
        // Test execution...
        // Logs show exactly the Data/Network flow
    }
}
```

## Configuration Strategies for Different Scenarios

### Development - MVVM Debugging

```swift
// Debug ViewModel problems
Logger.viewModel: .debug     // All ViewModel state changes
Logger.ui: .info            // Important UI updates
Logger.data: .warning       // Only data problems
Logger.network: .error      // Only network errors
```

### Development - Data Flow Analysis

```swift
// Track end-to-end data flow  
Logger.network: .debug      // API calls in detail
Logger.data: .debug         // Repository operations
Logger.general: .debug      // Use case execution
Logger.viewModel: .info     // State updates
Logger.ui: .warning         // Minimize UI noise
```

### Production - Error Monitoring

```swift
// Only critical issues in production
Global Level: .warning
Logger.auth: .warning       // Login problems
Logger.network: .error      // API errors  
Logger.data: .error         // Data inconsistencies
Performance Logs: false     // Avoid performance overhead
```

## Architecture-Specific Features

### 1. ViewModel State Tracking

```swift
class ProductDetailViewModel: ObservableObject {
    private let logger = Logger.viewModel
    
    @Published var product: Product? {
        didSet {
            logger.debug("Product state changed: \(product?.title ?? "nil")")
        }
    }
    
    @Published var isLoading: Bool = false {
        didSet {
            logger.debug("Loading state changed: \(isLoading)")
        }
    }
}
```

### 2. Use Case Orchestration Logging

```swift
class ProductDetailOrchestrator {
    private let logger = Logger.general
    
    func loadProductDetail(id: String) async {
        logger.info("📺 Starting product detail orchestration for: \(id)")
        
        async let productDetails = loadProductUseCase.execute(id: id)
        async let productManual = loadManualUseCase.execute(productId: id)  
        async let productImage = loadImageUseCase.execute(productId: id)
        
        let results = await (productDetails, productManual, productImage)
        logger.info("📺 Product detail orchestration completed for: \(id)")
    }
}
```

### 3. Repository Pattern Logging

```swift
class ProductRepository {
    private let logger = Logger.data
    
    func getProduct(id: String) async -> Product? {
        logger.debug("🗃️ Repository: Getting product \(id)")
        
        // 1. Check cache first
        if let cached = cacheService.getProduct(id: id) {
            logger.info("🗃️ Repository: Product \(id) found in cache")
            return cached
        }
        
        // 2. Fetch from network
        logger.info("🗃️ Repository: Product \(id) not in cache, fetching from network")
        guard let networkProduct = await networkService.fetchProduct(id: id) else {
            logger.warning("🗃️ Repository: Product \(id) not found in network")
            return nil
        }
        
        // 3. Cache for future use
        cacheService.store(product: networkProduct)
        logger.debug("🗃️ Repository: Product \(id) cached successfully")
        
        return networkProduct
    }
}
```

## Best Practices for Architecture Patterns

### 1. Logger Instantiation

```swift
// ✅ Correct - One logger instance per class with appropriate category
class ProductListViewModel: ObservableObject {
    private let logger = Logger.viewModel  // Constant, private logger instance
}

// ❌ Wrong - Switching logger categories or global instances
class ProductListViewModel: ObservableObject {
    func someMethod() {
        Logger.network.info("...")  // Wrong category for ViewModel
    }
}
```

### 2. Hierarchical Logging Strategies

```swift
// Domain Layer - Business-focused logs
class AuthenticationUseCase {
    private let logger = Logger.auth
    
    func authenticate(credentials: Credentials) async -> AuthResult {
        logger.info("🔐 Authentication attempt for user: \(credentials.username)")
        // Business logic...
        logger.info("🔐 Authentication successful")
    }
}

// Infrastructure Layer - Technical details
class KeychainAuthRepository {
    private let logger = Logger.data
    
    func storeToken(_ token: String) {
        logger.debug("🔑 Storing auth token in keychain")
        // Keychain implementation...
        logger.debug("🔑 Auth token stored successfully")
    }
}
```

### 3. Error Handling and Logging

```swift
// Clean Architecture Error Handling with structured logging
enum ProductLoadError: Error, LocalizedError {
    case networkUnavailable
    case productNotFound
    case invalidData
}

class LoadProductUseCase {
    private let logger = Logger.general
    
    func execute(productId: String) async -> Result<Product, ProductLoadError> {
        logger.info("⚡ LoadProductUseCase: Starting for product \(productId)")
        
        do {
            let product = try await productRepository.fetchProduct(id: productId)
            logger.info("⚡ LoadProductUseCase: Successfully loaded \(product.title)")
            return .success(product)
        } catch NetworkError.noConnection {
            logger.error("⚡ LoadProductUseCase: Network unavailable for product \(productId)")
            return .failure(.networkUnavailable)
        } catch RepositoryError.notFound {
            logger.warning("⚡ LoadProductUseCase: Product \(productId) not found")
            return .failure(.productNotFound)
        } catch {
            logger.error("⚡ LoadProductUseCase: Unexpected error for product \(productId): \(error)")
            return .failure(.invalidData)
        }
    }
}
```

## Conclusion

This logger system is perfect for MVVM and Clean Architecture because it:

1. **Supports layer separation** through dedicated categories
2. **Provides debugging flexibility** through granular configuration
3. **Works performance-consciously** through intelligent filtering
4. **Promotes testability** through specific logging strategies
5. **Respects dependency rules** without external dependencies in inner layers

The category-based structure makes it easy to trace complex application flows, identify performance issues, and focus debugging sessions on specific architecture layers.

---

*For detailed configuration see: [Logging-System.md](./Logging-System.md)*  
*Last updated: August 2025*