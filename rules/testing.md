---
paths:
  - "**/*.swift"
---

## Testing Guidelines

### Framework

- Unit tests: Swift Testing (`@Test`)
- Performance tests (`measure(metrics:)`): XCTest, which Swift Testing doesn't cover

### Naming

- Function names: `subjectAction` or `subjectActionCondition`
- ALWAYS add a descriptive string to `@Test`: `@Test("User login fails when password is empty")`

### Test doubles

- Add a protocol only at a real I/O seam a test must replace (network, process, clock, filesystem)
- Otherwise test the concrete type, with a temp directory or, with SwiftData, an in-memory
  `ModelContainer`
- Doubles are written by hand; do NOT use mocking libraries
- An object kept alive only by a `[weak self]` observer dies right after `init` in a test;
  hold it with `withExtendedLifetime`

### Coverage

**For Apps:**

- ALWAYS test ViewModels
- ALWAYS test Stores and Repositories
- Services: test only if they contain logic
- Do NOT write unit tests for Views

**For Packages:**

- ALWAYS test public API thoroughly
- Test internal logic only if complex
- Do NOT test private implementation details

### UI tests

- Framework: XCUITest (`XCTestCase`); Swift Testing doesn't cover UI tests
- Test user-facing flows end-to-end, not individual views
- Use `.accessibilityIdentifier(_:)` on key views to make them queryable
- Test functions use the `test` prefix (XCTest requirement) and descriptive names:
  `testCheckoutFlowShowsReceipt`

### Commands

The project's `AGENTS.md` has the exact commands. Their shape:

- Apps: `xcodebuild -scheme <Scheme> -destination '<platform>' -skip-testing:<UITestTarget> test`
  is the routine gate. UI tests take over the mouse and keyboard: the routine run skips them
- Packages: `swift build`, `swift test`; a package that needs the iOS SDK uses
  `xcodebuild -scheme <Package> -destination '<platform>' test`
