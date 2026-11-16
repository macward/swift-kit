#!/usr/bin/env bash
# Installs the kit into a Swift project, or updates it.
#
# Usage: bash install.sh [project-dir]      (default: the current directory)
#
# What the kit owns is overwritten on every run, so an update is "run it again and review the
# diff": the rules, the agent, the skill and the hook scripts under `.claude/`, plus the hook
# wiring in `.claude/settings.json` (merged, never duplicated). What the project owns is only
# created when missing: `.swiftlint.yml`, `scripts/lint.sh` and the Swift section of AGENTS.md.
set -euo pipefail

PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="$(cd "${1:-.}" && pwd)"
MANIFEST="${KIT}/manifest.json"

command -v jq >/dev/null || { echo "error: jq not found. Install with: brew install jq" >&2; exit 1; }
[[ "${PROJECT}" != "${KIT}" ]] || { echo "error: pass the project's folder, not the kit's" >&2; exit 1; }

list() { jq -r "$1" "${MANIFEST}"; }

# `rm` first: a destination that is a symlink into another checkout must be replaced, not
# written through.
install_file() {
    mkdir -p "$(dirname "$2")"
    rm -rf "$2"
    cp "$1" "$2"
    echo "  ${2#"${PROJECT}"/}"
}

create_if_missing() {
    if [[ -e "$2" ]]; then
        echo "  kept $(basename "$2") (the project's own)"
    else
        mkdir -p "$(dirname "$2")"
        cp "$1" "$2"
        echo "  created ${2#"${PROJECT}"/}"
    fi
}

echo "Kit files:"
for f in $(list '.rules[]'); do install_file "${KIT}/$f" "${PROJECT}/.claude/rules/swift/$(basename "$f")"; done
for f in $(list '.agents[]'); do install_file "${KIT}/$f" "${PROJECT}/.claude/agents/$(basename "$f")"; done
for d in $(list '.skills[]'); do
    rm -rf "${PROJECT}/.claude/skills/$(basename "$d")"
    mkdir -p "${PROJECT}/.claude/skills"
    cp -R "${KIT}/$d" "${PROJECT}/.claude/skills/"
    echo "  .claude/skills/$(basename "$d")/"
done
for f in $(list '.hooks[].script'); do
    install_file "${KIT}/$f" "${PROJECT}/.claude/hooks/$(basename "$f")"
    chmod +x "${PROJECT}/.claude/hooks/$(basename "$f")"
done

# Each hook goes in as its own matcher group; a group that already runs the same command is
# left alone, so running the installer twice changes nothing.
SETTINGS="${PROJECT}/.claude/settings.json"
[[ -f "${SETTINGS}" ]] || echo '{}' > "${SETTINGS}"
jq --slurpfile manifest "${MANIFEST}" '
  reduce $manifest[0].hooks[] as $h (.;
    ("\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/" + ($h.script | split("/") | last)) as $cmd
    | if any(.hooks[$h.event][]?.hooks[]?; .command == $cmd) then .
      else .hooks[$h.event] += [{matcher: $h.matcher, hooks: [{type: "command", command: $cmd}]}]
      end)
' "${SETTINGS}" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "${SETTINGS}"
echo "  .claude/settings.json (hooks)"

echo "Project files:"
# A project with a `.swiftlint.yml` already has its lint set up, wherever its script lives.
if [[ -e "${PROJECT}/.swiftlint.yml" ]]; then
    echo "  kept .swiftlint.yml and the project's lint script"
else
    create_if_missing "${KIT}/$(list '.swiftlint')" "${PROJECT}/.swiftlint.yml"
    create_if_missing "${KIT}/$(list '.lintScript')" "${PROJECT}/scripts/lint.sh"
fi

if ! grep -qs 'swift-rules' "${PROJECT}/AGENTS.md"; then
    echo ""
    echo "Next: add the section in $(list '.agentsSection') to AGENTS.md and fill it in."
fi
if git -C "${PROJECT}" check-ignore -q .claude/rules/swift/style.md 2>/dev/null; then
    echo ""
    echo "Warning: .gitignore ignores .claude/rules/swift/; un-ignore it so the copies get committed." >&2
fi
