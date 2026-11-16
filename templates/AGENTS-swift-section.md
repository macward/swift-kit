## Swift rules

`.claude/rules/swift/` is a copy of the `swift-kit` kit (https://github.com/macward/swift-kit):
it is not edited here; to update it, run the kit's `install.sh` again and review the diff. The
rules apply with these adjustments, which win over them:

- **Access control**: <whether the app target writes `internal` out, like the packages do>.
- **Layout**: <"the one in `structure.md`", or where this project's layout differs>.
- **Isolation**: <which targets are `MainActor` by default and which declare no `defaultIsolation`>.
- **Stack**: <deployment targets and anything that differs from the defaults in `architecture.md`>.
- **Commands**: <the real test command for each scheme and package, and `bash scripts/lint.sh`>.

Delete a bullet when the rule applies as written.
