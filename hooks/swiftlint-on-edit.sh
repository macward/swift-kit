#!/usr/bin/env bash
# PostToolUse (Edit|MultiEdit|Write): lints the Swift file Claude just edited and hands the
# violations back to Claude as additionalContext. Feedback, not a block: the edit already
# happened, so it always exits 0.

PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

f=$(jq -r '.tool_input.file_path // empty')
[[ "$f" == *.swift ]] || exit 0

if ! command -v swiftlint >/dev/null; then
  echo "swiftlint-on-edit: swiftlint not found, skipping lint (brew install swiftlint)" >&2
  exit 0
fi

# Run from the project root so `.swiftlint.yml` and the baseline are found. `--force-exclude`
# applies `excluded` even though the file is passed explicitly.
# The path goes relative: the baseline matches by path, and absolute ones break across symlinks.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
f="${f#"$PWD"/}"
args=(lint --quiet --force-exclude)
[[ -f .swiftlint-baseline.json ]] && args+=(--baseline .swiftlint-baseline.json)
out=$(swiftlint "${args[@]}" "$f")
[[ -n "$out" ]] || exit 0

jq -n --arg ctx "$out" \
  '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $ctx}}'
exit 0
