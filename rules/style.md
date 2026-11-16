---
paths:
  - "**/*.swift"
---

## Code Style

- Access control: explicit `public`/`internal` in packages. In an app, follow what the code
  already does (some write `internal` out, some leave it implicit); don't mix both in one file
- Use `// MARK: -` to separate sections (Properties, Lifecycle, Public Methods, Private Methods)
- Protocol conformances may go in extensions (isolation caveat: see Concurrency)
- SwiftLint config is `.swiftlint.yml`. Freeze existing debt in a baseline file; never raise
  thresholds to get to zero
