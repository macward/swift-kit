---
paths:
  - "**/*.swift"
---

## Concurrency

- Default isolation is set per target: read it before adding or dropping `@MainActor`. Where the
  default is MainActor (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` in an Xcode target,
  `.defaultIsolation(MainActor.self)` in `Package.swift`), don't write `@MainActor`. A target
  without it is nonisolated by default: mark UI-bound types `@MainActor` explicitly
- Blocking I/O or heavy work runs in a `@concurrent` async function. `nonisolated` alone only
  drops MainActor isolation: with approachable concurrency the work still runs on the caller's actor
- A `nonisolated` type's extensions don't inherit the modifier: write `nonisolated extension Foo: P`.
  The mistake crashes at runtime (`dispatch_assert_queue`) with no compiler warning
- Don't silence isolation errors with `@unchecked Sendable`, `nonisolated(unsafe)`,
  `@preconcurrency` or `MainActor.assumeIsolated` without a comment saying why it's safe
- ALWAYS async/await in your own APIs, NEVER completion handlers or `DispatchQueue.main.async`.
  System APIs built on callbacks or GCD (FSEvents, Network.framework, delegates) are wrapped
  once at the boundary with a continuation or an `AsyncStream`
- AsyncStream for continuous data (sockets, listeners, delegate conversions); it MUST clean up
  in `onTermination`
- Long loops check `Task.isCancelled` or call `try Task.checkCancellation()`

### Patterns to Avoid

- `Task { @MainActor in }` when already on MainActor
