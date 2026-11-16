# swift-kit

A kit for coding agents (Claude Code) working on Swift apps and packages for macOS and iOS:
rules, a review agent, an audit skill, hooks and a SwiftLint gate. The rules are the core.
Each one is a lesson that agents don't get right on their own, or a convention a project has to
state once. Generic Swift advice an agent already follows is left out on purpose.

## Rules

| File | Covers |
|---|---|
| `rules/architecture.md` | defaults, roles (Store / Service / Repository / Coordinator), when a view needs a ViewModel, dependency injection, errors as state, packages |
| `rules/concurrency.md` | default isolation per target, `@concurrent`, `nonisolated` extensions, wrapping callback APIs |
| `rules/composition.md` | composition root, `@Environment` contracts, cross-store reactions, work that outlives the window, SwiftData schema versions |
| `rules/structure.md` | folder layout for a new app, where a new file goes, dependency direction, packages |
| `rules/testing.md` | Swift Testing, test doubles, what to cover, UI tests, command shapes |
| `rules/style.md` | access control, `MARK`, SwiftLint baseline |

Every file starts with `paths: "**/*.swift"`: installed under `## The rest of the kit

| Path | What it is | Installed as |
|---|---|---|
| `agents/swift-code-review.md` | review agent for a diff or files: crashes, races, memory, over-engineering; reports only blockers | `.claude/agents/` |
| `skills/analyze-macos-ios-codebase/` | whole-codebase audit with SwiftLint, periphery, lizard and xccov plus targeted reading | `.claude/skills/` |
| `hooks/swiftlint-on-edit.sh` | after each edit of a `.swift` file, hands Claude the new violations | `.claude/hooks/`, wired in `settings.json` |
| `hooks/block-dangerous-commands.sh` | refuses `rm -rf /`, `git push --force` and `git reset --hard` | `.claude/hooks/`, wired in `settings.json` |
| `lint/swiftlint.yml` | safety and size/complexity rules only, no cosmetic ones | `.swiftlint.yml` |
| `lint/lint.sh` | the gate: exit 1 only on violations outside `.swiftlint-baseline.json` | `scripts/lint.sh` |
| `templates/AGENTS-swift-section.md` | the section where a project states its adjustments | pasted into `AGENTS.md` |
| `manifest.json` | what the kit contains and how each hook is wired | read by `install.sh` and DeadCode's project setup |

The hooks and the installer need `jq`; lint needs `swiftlint` (`brew install jq swiftlint`).

## Install in a project

```bash
git clone https://github.com/macward/swift-kit.git /tmp/swift-kit
bash /tmp/swift-kit/install.sh path/to/project
```

The installer copies; it never symlinks. Commit the copies: a symlink out of the repo is missing in
every worktree, clone and CI checkout. The project's `.gitignore` must not ignore what it writes
under `.claude/`; the installer warns when it does.

- **The kit's files** (rules, agent, skill, hook scripts) are overwritten on every run, and the hooks
  are merged into `.claude/settings.json` without duplicating them. To update, pull the kit, run the
  installer again and review the diff.
- **The project's files** (`.swiftlint.yml`, `scripts/lint.sh`) are created only when the project has no `.swiftlint.yml` yet: after
  that they belong to the project, which tunes `included`, `excluded` and `custom_rules`.

To adopt lint on a codebase with existing debt, run `bash scripts/lint.sh --write-baseline` once,
review the list and commit the baseline.

 ignore `.claude/rules/`.

To update, run the same `cp` again and review the diff.

## What stays in the project

The copies are not edited in the project. What is specific to it goes in its `AGENTS.md`, in a
short section that says the rules apply "with these adjustments" and wins over them:

- the real test and lint commands
- its layout, when it is not the one in `structure.md`
- whether the app writes `internal` out
- its stack where it differs from the defaults

`templates/AGENTS-swift-section.md` is that section with blanks to fill in.
