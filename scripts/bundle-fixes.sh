#!/usr/bin/env bash
# Writes the git bundle of the fixes of a run: the heidi-fix/* branches, and the current branch in the chain form.
# Usage: bundle-fixes.sh <bundle> <start commit> [<current branch>]
# The bundle has only the commits after the start commit. Without such a commit, the script writes no bundle.
set -euo pipefail

bundle="$1"
start_commit="$2"
current_branch="${3:-}"

if [[ ! "$start_commit" =~ ^([0-9a-f]{40}|[0-9a-f]{64})$ ]]; then
  echo "::error::The start commit is not a commit id."
  exit 1
fi

has_fix_branches=false
if [ -n "$(git rev-list -n 1 --branches='heidi-fix/*' --not "$start_commit" --)" ]; then
  has_fix_branches=true
fi
has_chain=false
if [ -n "$current_branch" ] && [ -n "$(git rev-list -n 1 "$start_commit..refs/heads/$current_branch" --)" ]; then
  has_chain=true
fi

rm -f "$bundle"
if [ "$has_chain" = true ]; then
  git bundle create "$bundle" --branches='heidi-fix/*' "refs/heads/$current_branch" --not "$start_commit"
elif [ "$has_fix_branches" = true ]; then
  git bundle create "$bundle" --branches='heidi-fix/*' --not "$start_commit"
fi
