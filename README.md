# Heidi Fix for GitHub Actions

Heidi Fix finds the vulnerable dependencies of a repository and fixes them.
It runs the build and the tests to verify each fix. Then it opens a pull
request for each verified fix. Heidi Fix never merges a pull request. A
person reviews each change.

## Setup

1. Run `claude setup-token` on your computer. Save the result as the secret
   `CLAUDE_CODE_OAUTH_TOKEN` of the repository.
2. Save a Meterian token as the secret `METERIAN_API_TOKEN` of the
   repository.
3. Go to Settings > Actions > General of the repository.
4. Turn on "Allow GitHub Actions to create and approve pull requests". You
   can skip steps 3 and 4 when you set the secret `HEIDI_FIX_GITHUB_TOKEN`
   (see below).
5. Add the file `.github/workflows/heidi-fix.yml` to the default branch:

```yaml
name: Heidi Fix

on:
  workflow_dispatch:
  schedule:
    - cron: "0 7 * * 1"

concurrency:
  group: heidi-fix
  cancel-in-progress: false

jobs:
  heidi-fix:
    uses: MeterianHQ/heidi-fix-public/.github/workflows/heidi-fix.yml@v0.1.0-alpha.6
    permissions:
      contents: write
      pull-requests: write
    secrets: inherit
```

6. Start the workflow from the tab Actions, or wait for the schedule.

The tag of the line `uses:` gives the workflow, the actions, and the native
programs of one version of Heidi Fix. To get a new version, change this tag.

The permissions of the caller are the maximum. Each job of the workflow
uses less. The job that runs the agent gets only `contents: read`.

## The tools of your build

Heidi Fix runs the build and the tests of your repository on
`ubuntu-latest`. The runner has many tools, for example a JDK 17, Node.js 22,
and Python 3.12. These versions are examples, and they change with the image
of the runner. The [list of the runner image](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md)
gives the current versions. Heidi Fix itself is a native program and needs no
JDK.

To use another version, add an input:

```yaml
    with:
      java-version: "11"
      node-version: "24"
      python-version: "3.11"
```

An empty input keeps the tool of the runner. The workflow does not read a
version from the files of your project, for example `.nvmrc`.

Claude Code runs with the Node.js of `node-version` too. Claude Code needs
Node.js 22 or later. Thus do not set `node-version` to a version before 22.

To install other tools or to start a service, add the composite action
`.github/actions/heidi-fix-setup/action.yml` to your repository. The
workflow runs it after the version inputs and before Heidi Fix. Example:

```yaml
name: Heidi Fix setup
description: Installs the tools of the build for Heidi Fix.
runs:
  using: composite
  steps:
    - shell: bash
      run: sudo apt-get update && sudo apt-get install --yes libxml2-dev
    - shell: bash
      run: docker run --detach --publish 5432:5432 --env POSTGRES_PASSWORD=test postgres:16
```

The setup action must not write files in the checkout. Heidi Fix stops when
the repository has changes before the run.

**Caution:** If the setup action uses a secret, the agent can read it. The
setup action runs in the same job as the agent. For example, use a
read-only token for a private registry.

**Caution:** If a release workflow of your repository restores a GitHub
Actions cache of the default branch, the agent can change this cache. The
agent can use `sudo` and can read the token of the runner. Thus it can
write the caches of the default branch. Do not restore these caches in your
release workflows.

## The input `config`

The default repository file of Heidi Fix is `.heidi-fix.yml`. Use the input
`config` for another file:

```yaml
    with:
      config: ci/heidi-fix.yml
```

## The optional secret `HEIDI_FIX_GITHUB_TOKEN`

Without this secret, the workflow opens the pull requests with the token of
the run, `github.token`. GitHub then does not start the checks of your
repository on these pull requests. To start the checks, close and reopen
the pull request.

Make a fine-grained token with the write access to the contents and to the
pull requests of this repository only. Save it as the secret
`HEIDI_FIX_GITHUB_TOKEN`. Then the pull requests start your checks. Only the
job that opens the pull requests gets this token.

**Warning:** If you set this secret, your checks run on the change of the
agent before a person reviews it. These checks get the secrets of your
repository. Set this secret only when your checks do not give secrets to the
code of a pull request.

## How Heidi Fix keeps the write token away from the agent

The workflow has three jobs. Each job runs on a new machine.

1. `fix` runs Heidi Fix and the agent with a read-only token. Heidi Fix
   keeps each verified fix as a local branch `heidi-fix/...`. The job puts
   these branches in a git bundle. Then it checks the report and the
   changes for the values of the Meterian token and the Claude token. It
   uploads only `report.json` and the bundle.
2. `publish` gets the bundle and opens the pull requests. It has the write
   token, but it runs no agent and no build tool. It does not trust the
   files of the job `fix`. It accepts only verified `heidi-fix/` branches
   that exist and that do not change `.github/`.
3. `result` fails when a job fails or when Heidi Fix gives an exit code that
   is not 0.

The summary of the job `fix` shows the report of Heidi Fix. The summary of
the job `publish` shows the pull requests.

The workflow runs only for the events `schedule` and `workflow_dispatch`.
Thus a pull request from another person cannot start it.

**Warning:** The agent can read the Meterian token and the Claude token on
the machine of the job `fix`. A prompt injection can send them to the
internet. Use tokens for Heidi Fix only.

The check for the token values finds only the exact values in the report
and in the changes. It stops an accidental leak. It cannot stop an agent
that controls the machine of the job.

## A rerun

A later run can make the same fix with the same branch name. When the pull
request of this branch is open, Heidi Fix gives this pull request again. It
does not push the branch again and does not open a second pull request.

## Download the command-line program

Each release has a native program for each platform. The program needs no
Java. Use the program for your platform:

| Platform | Release file |
|---|---|
| Linux x64 | `heidi-fix-linux-x64` |
| Linux arm64 | `heidi-fix-linux-arm64` |
| macOS arm64 (Apple silicon) | `heidi-fix-macos-arm64` |

To download and check the program, do these steps. The example uses Linux
x64 and the version `v0.1.0-alpha.6`.

1. Download the program and its checksum file. For another platform, replace
   `linux-x64` with the platform of the table:

   ```bash
   base=https://github.com/MeterianHQ/heidi-fix-public/releases/download/v0.1.0-alpha.6
   curl --fail --location --remote-name "$base/heidi-fix-linux-x64"
   curl --fail --location --remote-name "$base/heidi-fix-linux-x64.sha256"
   ```

2. Check the SHA-256: run `sha256sum -c heidi-fix-linux-x64.sha256`. On
   macOS, use `shasum -a 256 -c heidi-fix-macos-arm64.sha256` with the macOS
   files. If the check fails, do not use the program.
3. Run `chmod +x heidi-fix-linux-x64`.
4. Run `./heidi-fix-linux-x64 --help`.

On macOS, a download with a browser gets the quarantine flag. The program has
no Apple signature, so macOS then refuses it. Run
`xattr -d com.apple.quarantine heidi-fix-macos-arm64` to remove the flag. A
download with `curl` does not get the flag.

The Linux programs need glibc 2.39 or later, for example Ubuntu 24.04 or
later. The macOS program needs a macOS version that is the same as the macOS
of the GitHub runner `macos-latest`, or later. An older system stops the
program with a loader error.

## Common problems

| Line in the log | What to do |
|---|---|
| `Set the secret METERIAN_API_TOKEN` | Save a Meterian token as a secret of the repository. |
| `Set the secret CLAUDE_CODE_OAUTH_TOKEN` | Run `claude setup-token`, and save the result as a secret of the repository. |
| `Heidi Fix runs only for the events schedule and workflow_dispatch` | Use only the triggers `schedule` and `workflow_dispatch` in the caller file. |
| `Heidi Fix does not run on its own branch` | Run the workflow on the default branch, not on a branch `heidi-fix/...`. |
| `The run contains a secret` | Heidi Fix uploads nothing and publishes nothing. Make new tokens. Then read the log of the job `fix`. |
| `not permitted to create or approve pull requests` | Do steps 3 and 4 of the setup, or set the secret `HEIDI_FIX_GITHUB_TOKEN`. |
| `The SHA-256 of heidi-fix-... is not correct` | Do not use the program. Tell Meterian. |
| `Heidi Fix has no program for the runner` | Use a runner Linux X64, Linux ARM64, or macOS ARM64. The reusable workflow uses `ubuntu-latest`. |
| `has changes that are not committed` | Change the setup action so that it writes outside the checkout, for example in `$RUNNER_TEMP`. |
| `heidi-fix run gives the exit code ...` | A remediation failed, or the run stopped. Read the summary of the job `fix`. The verified fixes still get their pull requests. |
