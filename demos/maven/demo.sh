#!/usr/bin/env bash
# Demo of the Heidi Fix advanced fixer on a Maven project: an upgrade breaks the build, and the agent changes the code.
# Usage: ./demo.sh [--no-reachability]
set -euo pipefail

DEMO_HOME="$(cd "$(dirname "$0")" && pwd)"
REPOSITORY="$DEMO_HOME/demo-repository"
source "$DEMO_HOME/../common.sh"

# The run asks the agent which vulnerable code the project reaches. --no-reachability skips this analysis.
RUN_OPTIONS=(--current-branch --publish local --reachability --verbose)
if [[ "${1:-}" == "--no-reachability" ]]; then
    RUN_OPTIONS=(--current-branch --publish local --reachability=off --verbose)
elif [[ $# -gt 0 ]]; then
    echo "Usage: ./demo.sh [--no-reachability]"
    exit 1
fi

verify_the_tools mvn claude
create_the_repository "$DEMO_HOME/project" "$REPOSITORY" "Inventory library"
FIRST_COMMIT="$(git -C "$REPOSITORY" rev-parse HEAD)"
cd "$REPOSITORY"

show_title "1. A small Java project with a vulnerable dependency"
show_and_run git log --oneline
show_and_run grep -B1 -A1 '<version>20.0</version>' pom.xml
show_and_run grep -n 'toStringHelper' src/main/java/com/example/inventory/Item.java
wait_for_enter

show_title "2. The project builds and its tests pass"
show_and_run mvn -q test
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
show_and_run git diff
wait_for_enter

show_title "6. The fixed project builds and its tests pass"
show_and_run mvn -q test
echo "Build OK"
