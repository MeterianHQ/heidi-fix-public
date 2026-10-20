#!/usr/bin/env bash
# Gets the branches of the fixes from the bundle of the job fix. In the chain form, it puts the commits of the current
# branch on the chain branch heidi-fix/<current branch>/chain-<start commit>, as heidi-fix run names it.
# Usage: fetch-fixes.sh <bundle> [<current branch> <start commit>]
set -euo pipefail

bundle="$1"
current_branch="${2:-}"
start_commit="${3:-}"

if [ -n "$current_branch" ]; then
  if [ "$(git check-ref-format --branch "$current_branch" 2> /dev/null)" != "$current_branch" ]; then
    echo "::error::The current branch is not a valid branch name."
    exit 1
  fi
  if [[ ! "$start_commit" =~ ^([0-9a-f]{40}|[0-9a-f]{64})$ ]]; then
    echo "::error::The start commit is not a commit id."
    exit 1
  fi
  chain_branch="heidi-fix/$current_branch/chain-${start_commit:0:8}"
  if [ -n "$(git bundle list-heads "$bundle" "refs/heads/$chain_branch")" ]; then
    echo "::error::The bundle already has the chain branch."
    exit 1
  fi
fi

git bundle verify --quiet "$bundle"
git fetch --no-tags "$bundle" 'refs/heads/heidi-fix/*:refs/heads/heidi-fix/*'
if [ -n "$current_branch" ] && [ -n "$(git bundle list-heads "$bundle" "refs/heads/$current_branch")" ]; then
  git fetch --no-tags "$bundle" "refs/heads/$current_branch:refs/heads/$chain_branch"
fi
