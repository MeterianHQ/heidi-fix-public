# Security in GitHub Actions

Read this page if you want to know how Heidi Fix keeps the write token away
from the agent, and what the agent can do.

## How Heidi Fix keeps the write token away from the agent

The workflow has four jobs. Each job runs on a new machine.

1. `event` checks the event. It has no token and no secret. It refuses a
   pull request from a fork and an unknown event.
2. `fix` runs Heidi Fix and the agent with a read-only token. Heidi Fix
   keeps each verified fix as a local branch `heidi-fix/...`. The job puts
   these branches in a git bundle. Then it checks the report and the
   changes for the values of the Meterian token and the Claude token. It
   uploads only `report.json` and the bundle.
3. `publish` gets the bundle and opens the pull requests. It has the write
   token, but it runs no agent and no build tool. It does not trust the
   files of the job `fix`. It accepts only verified `heidi-fix/` branches
   that exist and that have no merge commit. No commit of a branch can
   change `.github/`.
4. `result` fails when a job fails or when Heidi Fix gives an exit code that
   is not 0.

The summary of the job `fix` shows the report of Heidi Fix. The summary of
the job `publish` shows the pull requests.

## The events of the workflow

The workflow runs only for the events `schedule`, `workflow_dispatch`, and
`pull_request`. It refuses a pull request from a fork, and it refuses
`pull_request_target`. Thus only a person or an app with write access to the
repository, or Dependabot, can start it for a pull request. The build scripts
of the pull request run on the machine of the job `fix`, with the two tokens.

## What the agent can read

**Warning:** The agent can read the Meterian token and the Claude token on
the machine of the job `fix`. A prompt injection can send them to the
internet. Use tokens for Heidi Fix only.

The check for the token values finds only the exact values in the report
and in the changes. It stops an accidental leak. It cannot stop an agent
that controls the machine of the job.

The setup action and the GitHub Actions caches have their own risks. See
[The tools of your build](github-actions.md#the-tools-of-your-build).

## The security mode

The setting `security.mode` selects the controls against a prompt
injection. The default value `secure` turns the controls on. Then the file
tools of Claude Code cannot read or write a file outside the worktree. The
value `yolo` turns the controls off. The repository file cannot set this setting. See
[The security mode](configuration.md#the-security-mode) in the configuration.

## Next steps

- [Use Heidi Fix in GitHub Actions](github-actions.md)
- [Fixes for a pull request](pull-requests.md)
- [The configuration](configuration.md)
- [The home page](../README.md)
