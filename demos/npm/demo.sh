#!/usr/bin/env bash
# Demo of the Heidi Fix advanced fixer on an npm project: many upgrades, one breaks the test, and the agent changes the code.
# Usage: ./demo.sh [--reachability]
set -euo pipefail

DEMO_HOME="$(cd "$(dirname "$0")" && pwd)"
REPOSITORY="$DEMO_HOME/demo-repository"
source "$DEMO_HOME/../common.sh"

# The run has no reachability analysis, so each login gives the same run. --reachability turns the analysis on.
RUN_OPTIONS=(--current-branch --publish local --reachability=off --verbose)
if [[ "${1:-}" == "--reachability" ]]; then
    RUN_OPTIONS=(--current-branch --publish local --reachability --verbose)
elif [[ $# -gt 0 ]]; then
    echo "Usage: ./demo.sh [--reachability]"
    exit 1
fi

verify_the_tools node npm claude
create_the_repository "$DEMO_HOME/project" "$REPOSITORY" "Echo service"
FIRST_COMMIT="$(git -C "$REPOSITORY" rev-parse HEAD)"
cd "$REPOSITORY"

show_title "1. A small Node.js service with a vulnerable dependency"
show_and_run git log --oneline
show_and_run grep -A2 '"dependencies"' package.json
show_and_run grep -n 'bodyParser' app.js
wait_for_enter

show_title "2. The project builds and its tests pass"
show_and_run npm ci --silent
show_and_run npm test --silent
echo "Build OK"
wait_for_enter

show_title "3. Heidi Fix plans the remediation"
show_and_run heidi-fix plan .
wait_for_enter

show_title "4. Heidi Fix fixes: upgrade, the build fails, the agent changes the code"
show_and_run heidi-fix run "${RUN_OPTIONS[@]}" .
wait_for_enter

show_title "5. The fix as uncommitted changes"
show_and_run git log --oneline
show_and_run git reset -q "$FIRST_COMMIT"
show_and_run git status --short
show_and_run git diff --stat
show_and_run git diff -- . ':!package-lock.json'
wait_for_enter

show_title "6. The fixed project builds and its tests pass"
show_and_run npm ci --silent
show_and_run npm test --silent
echo "Build OK"
