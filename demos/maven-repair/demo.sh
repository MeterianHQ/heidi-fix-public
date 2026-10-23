#!/usr/bin/env bash
# Demo of the Heidi Fix command repair: a pull request upgrades the corporate parent POM, and the agent repairs the code of the branch.
# Usage: ./demo.sh
set -euo pipefail

DEMO_HOME="$(cd "$(dirname "$0")" && pwd)"
REPOSITORY="$DEMO_HOME/demo-repository"
source "$DEMO_HOME/../common.sh"
BASE_BRANCH=main
UPGRADE_BRANCH=upgrade-corporate-parent

if [[ $# -gt 0 ]]; then
    echo "Usage: ./demo.sh"
    exit 1
fi

verify_the_command_repair() {
    heidi-fix help | grep '^  repair ' >/dev/null \
        || { echo "This Heidi Fix has no command repair. Install a release later than 0.1.0-alpha.7. See README.md."; exit 1; }
}

# The branch of the pull request changes only the version of the parent in pom.xml.
create_the_upgrade_branch() {
    git -C "$REPOSITORY" switch --quiet --create "$UPGRADE_BRANCH"
    git -C "$REPOSITORY" apply "$DEMO_HOME/upgrade.patch"
    commit_all "$REPOSITORY" "Upgrade the corporate parent to 2.0.0"
}

verify_the_tools mvn claude
verify_the_command_repair
create_the_repository "$DEMO_HOME/project" "$REPOSITORY" "Inventory library"
create_the_upgrade_branch
START_COMMIT="$(git -C "$REPOSITORY" rev-parse HEAD)"
cd "$REPOSITORY"

show_title "1. A pull request upgrades the corporate parent POM"
show_and_run git log --oneline --graph --all
show_and_run git diff "$BASE_BRANCH" -- pom.xml
wait_for_enter

show_title "2. The new parent manages a new Guava version"
show_and_run grep -h -A1 '<artifactId>guava</artifactId>' \
    repository/com/example/corporate-parent/1.0.0/corporate-parent-1.0.0.pom \
    repository/com/example/corporate-parent/2.0.0/corporate-parent-2.0.0.pom
show_and_run grep -n 'toStringHelper' src/main/java/com/example/inventory/Item.java
wait_for_enter

show_title "3. On the branch, the build fails"
echo "${BOLD}\$ mvn -q test${RESET}"
if BUILD_OUTPUT="$(mvn -q test 2>&1)"; then
    echo "Build OK (not expected: see README.md)"
else
    grep 'ERROR.*\.java' <<<"$BUILD_OUTPUT" | sort -u | sed "s#$REPOSITORY/##"
    echo "Build FAILED"
fi
wait_for_enter

show_title "4. Heidi Fix repairs the code of the branch"
show_and_run heidi-fix repair --base "$BASE_BRANCH" --publish local --verbose .
wait_for_enter

show_title "5. The repair is one commit on the branch of the pull request"
show_and_run git log --oneline --graph --all
show_and_run git show --stat HEAD
show_and_run git diff "$START_COMMIT" HEAD
wait_for_enter

show_title "6. The repaired branch builds and its tests pass"
show_and_run mvn -q test
echo "Build OK"
