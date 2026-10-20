#!/usr/bin/env bash
# Decides if Heidi Fix runs for the event of the workflow. It reads only the event data, and it writes run=true or run=false.
# Environment: EVENT_NAME, REPOSITORY, HEAD_REPOSITORY, HEAD_BRANCH, CURRENT_BRANCH_FORM, GITHUB_OUTPUT, GITHUB_STEP_SUMMARY.
set -euo pipefail

case "$CURRENT_BRANCH_FORM" in
  split | chain) ;;
  *)
    echo "::error::The input current-branch must be split or chain."
    exit 1
    ;;
esac

case "$EVENT_NAME" in
  schedule | workflow_dispatch)
    run=true
    ;;
  pull_request)
    if [ -z "$HEAD_REPOSITORY" ]; then
      echo "::error::The head repository of the pull request does not exist."
      exit 1
    fi
    if [ "$HEAD_REPOSITORY" != "$REPOSITORY" ]; then
      echo "::error::Heidi Fix does not run for a pull request from a fork."
      exit 1
    fi
    # A pull request of Heidi Fix can start the workflows with HEIDI_FIX_GITHUB_TOKEN, so it must not start a run.
    if [[ "$HEAD_BRANCH" == heidi-fix/* ]]; then
      run=false
      echo "This is a pull request of Heidi Fix, so Heidi Fix does not run." >> "$GITHUB_STEP_SUMMARY"
    else
      run=true
    fi
    ;;
  *)
    echo "::error::Heidi Fix runs only for the events schedule, workflow_dispatch, and pull_request, not for $EVENT_NAME."
    exit 1
    ;;
esac
echo "run=$run" >> "$GITHUB_OUTPUT"
