---
paths:
  - "**/*.swift"
---

## Architecture & Patterns

### Defaults

Unless the project's `AGENTS.md` says otherwise: SwiftUI with Observation (`@Observable`),
SwiftData for persistence, Keychain for tokens and secrets, OSLog for logging, `URLSession` for
networking, and no dependency-injection library.

### Layers

View → ViewModel (when needed) → Store / Service

### Roles

Name types by the role they play, with full words, never abbreviations (`HomeView`,
`HomeViewModel`, `SessionStore`). Each suffix means one thing:

- **Store** — `@Observable` source of truth for a piece of state; usually lives as long as the app
  (`SessionStore`, `CartStore`). Views and ViewModels read it; it owns the mutations
- **Service** — does I/O (network, processes, files, git, Keychain) and holds little or no state
  (`GitService`, `PaymentsService`)
- **Repository** — ONLY persistence access (SwiftData, SQLite, a DB), and only when there is logic
  beyond a fetch: views may use `@Query` directly. If it doesn't read or write storage, it is not
  a Repository
- **Coordinator** — coordinates UI concerns across views (focus, sheets, closing the active tab);
  no business logic

### ViewModels

When a view needs one. First match wins:

1. The view only reads or calls a store or service → read it from `@Environment`, no ViewModel
2. It has logic worth unit-testing, or state derived from several sources → `@Observable` ViewModel
3. Otherwise (toggles, form fields, local UI state) → `@State`

```swift
// ✅ No ViewModel - only reads a store
struct SessionList: View {
    @Environment(SessionStore.self) private var sessions
    // ...
}

// ✅ ViewModel - logic worth testing
@Observable
final class CheckoutViewModel {
    private let payments: PaymentsService
    func processPayment() async { ... }
}

// ✅ @State - local UI state
struct ExpandableCard: View {
    @State private var isExpanded = false
    // ...
}
```

- ViewModels: `final class`; import SwiftUI only for navigation types
- A ViewModel that needs environment dependencies is created by the parent and passed in:
  `@State` can't read `@Environment` in `init`

### Dependency Injection

- ALWAYS use @Environment for sharing stores and services across views, and inject
  dependencies at the App root level (`@Environment(T.self)` needs `@Observable`; other services
  use an `@Entry` value)
- NEVER use singletons or shared instances. Exception: stateless, thread-safe caches such as
  formatters (`static let dateFormatter`); say so in a comment
- ViewModels, stores and services receive dependencies via init injection

### Async work in views

- `.task` for async work scoped to the view's visibility (loading what it shows)
- Avoid `.task` with nested `Task { }` inside

### Error Handling

- The type the view calls (ViewModel or store) catches errors and exposes them as state
- Views react to error state; they don't catch
- Work that runs without a screen logs its errors and records them in its own state

### Swift packages

- Same roles and the same rule against singletons. A package without views starts at
  Store / Service
- Stores and services receive dependencies via init injection. The package exposes initializers
  and leaves the wiring to the app
- The public API throws; the app decides how to present the error
