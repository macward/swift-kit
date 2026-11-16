#!/usr/bin/env bash
# SwiftLint gate for the project: fails only on violations that are not in the baseline.
#
# Usage, from anywhere inside the repo:
#   bash scripts/lint.sh                   # lint; exit 1 on any violation outside the baseline
#   bash scripts/lint.sh --write-baseline  # re-pin the current violations, after reviewing them
#
# The baseline (`.swiftlint-baseline.json` at the repo root) grandfathers the debt that existed
# when lint was adopted, so a project can turn the gate on without fixing everything first.
set -euo pipefail

PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if ! command -v swiftlint >/dev/null 2>&1; then
    echo "error: swiftlint not found. Install with: brew install swiftlint" >&2
    exit 1
fi

BASELINE=".swiftlint-baseline.json"

if [[ "${1:-}" == "--write-baseline" ]]; then
    swiftlint lint --quiet --write-baseline "${BASELINE}" >/dev/null || true
    echo "Wrote ${BASELINE}."
    exit 0
fi

args=(lint --quiet)
[[ -f "${BASELINE}" ]] && args+=(--baseline "${BASELINE}")

# The count decides the exit code, not swiftlint's status: swiftlint exits 0 on `warning`
# violations, and the size/complexity rules are warnings at their default thresholds.
OUTPUT="$(swiftlint "${args[@]}" 2>&1 || true)"
[[ -n "${OUTPUT}" ]] && printf '%s\n' "${OUTPUT}"

COUNT="$(printf '%s' "${OUTPUT}" | grep -c -E ': (warning|error): ' || true)"
if [[ "${COUNT}" -gt 0 ]]; then
    echo "" >&2
    echo "SwiftLint: ${COUNT} violation(s) not covered by ${BASELINE}." >&2
    echo "Fix them or, after reviewing the list, re-pin them with: bash scripts/lint.sh --write-baseline" >&2
    exit 1
fi

echo "SwiftLint: clean."
