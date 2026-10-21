# Fixes for a pull request

Read this page if you want Heidi Fix to fix the vulnerable dependencies of a
pull request before the merge.

Before you start, do the [setup of GitHub Actions](github-actions.md#setup).

## Add the caller file

Add a separate caller file for the pull requests. Do not add the event
`pull_request` to the caller file of the setup. Its `concurrency:` group keeps
one running run and one pending run, so GitHub cancels the other runs without
a message.

Add the file `.github/workflows/heidi-fix-pull-request.yml` to the default
branch:

```yaml
name: Heidi Fix for a pull request

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: write
  pull-requests: write

jobs:
  heidi-fix:
    uses: MeterianHQ/heidi-fix-public/.github/workflows/heidi-fix.yml@v0.1.0-alpha.7
    permissions:
      contents: write
      pull-requests: write
    with:
      current-branch: split
    secrets: inherit
```

This file has no `concurrency:` group. The reusable workflow has its own
groups for each pull request.

## What Heidi Fix fixes

For a pull request, Heidi Fix scans only the projects whose manifests the
pull request changes. When the pull request changes no manifest, the run ends
at once, without the agent.

## The form of the fixes

The input `current-branch` selects the form of the fixes. Both forms open
pull requests into the branch of the pull request, not into the default
branch. A person merges them.

| Value | Result |
|---|---|
| `split` (default) | One pull request for each fix. |
| `chain` | One pull request with all the fixes. Heidi Fix tests each fix with the fixes before it. |

Heidi Fix never pushes to the branch of the pull request itself.

## A new push

A new push to the pull request runs Heidi Fix again:

- In the form `split`, a new fix replaces the fix branch of the earlier run.
  When the fix pull request is open, Heidi Fix adds a comment to it. When no
  fix pull request is open, Heidi Fix opens a new one.
- In the form `chain`, each push gives a new chain pull request when the run
  has fixes. Close the old one.

## The pull requests that Heidi Fix does not fix

Heidi Fix does not run for a pull request from a fork, because a fork can
contain unknown build scripts. The workflow then fails with
"Heidi Fix does not run for a pull request from a fork". Heidi Fix also does
not run for its own pull requests.

## The repository file of the pull request

The job `publish` reads the repository file `.heidi-fix.yml` of the pull
request branch. This file cannot change the publisher or the destination of
the token. It can only remove a component from a list.

## The limits

Know these limits:

- A new push cancels the job `fix` of the old push. Thus the old commit gets
  a failed check.
- A Dependabot pull request gets only the Dependabot secrets. Set the secrets
  `METERIAN_API_TOKEN` and `CLAUDE_CODE_OAUTH_TOKEN` also as Dependabot
  secrets.
- Each push to a pull request that changes a manifest gives a full run, with
  the cost of the agent.
- The workflow checks out the branch of the pull request, not the commit of
  the event. Thus "Re-run jobs" on an old run tests the current tip of the
  branch.
- The job `publish` can check out a newer commit than the job `fix`. Then,
  in the form `chain`, `heidi-fix publish` checks that the start commit is
  still on the branch. In the form `split`, it checks each fix branch from
  `git merge-base HEAD <tip>`.
- A force push to the branch of the pull request can come between the job
  `fix` and the job `publish`. It can remove the start commit from the clone
  of the job `publish`. Then the step that gets the fixes fails, and the job `publish`
  fails. The next push starts a new run.

## Next steps

- [Use Heidi Fix in GitHub Actions](github-actions.md)
- [Security in GitHub Actions](security.md)
- [Common problems in GitHub Actions](troubleshooting.md#common-problems-in-github-actions)
- [The home page](../README.md)
