# swift-rules

Rules for coding agents (Claude Code) working on Swift apps and packages for macOS and iOS.
Each one is a lesson that agents don't get right on their own, or a convention a project has to
state once. Generic Swift advice an agent already follows is left out on purpose.

## What is here

| File | Covers |
|---|---|
| `rules/architecture.md` | defaults, roles (Store / Service / Repository / Coordinator), when a view needs a ViewModel, dependency injection, errors as state, packages |
| `rules/concurrency.md` | default isolation per target, `@concurrent`, `nonisolated` extensions, wrapping callback APIs |
| `rules/composition.md` | composition root, `@Environment` contracts, cross-store reactions, work that outlives the window, SwiftData schema versions |
| `rules/structure.md` | folder layout for a new app, where a new file goes, dependency direction, packages |
| `rules/testing.md` | Swift Testing, test doubles, what to cover, UI tests, command shapes |
| `rules/style.md` | access control, `MARK`, SwiftLint baseline |

Every file starts with `paths: "**/*.swift"`: installed under `.claude/rules/`, Claude Code loads
it when it touches a Swift file and not before.

## Install in a project

```bash
mkdir -p .claude/rules/swift
cp ~/Developer/1_PROJECTS/swift-rules/rules/*.md .claude/rules/swift/
```

Copy, don't symlink, and commit the copies: a symlink out of the repo is missing in every
worktree, clone and CI checkout. The project's `.gitignore` must not ignore `.claude/rules/`.

To update, run the same `cp` again and review the diff.

## What stays in the project

The copies are not edited in the project. What is specific to it goes in its `AGENTS.md`, in a
short section that says the rules apply "with these adjustments" and wins over them:

- the real test and lint commands
- its layout, when it is not the one in `structure.md`
- whether the app writes `internal` out
- its stack where it differs from the defaults
