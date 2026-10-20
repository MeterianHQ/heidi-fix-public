# Heidi Fix

Heidi Fix finds the vulnerable dependencies of a repository and fixes them.
It runs the build and the tests to verify each fix. Then it gives each
verified fix to a person for review, for example as a pull request. Heidi Fix
never merges a change.

Heidi Fix uses a coding agent, Claude Code or Codex, for the tasks that need
one. An algorithm, not the agent, decides if a fix is verified.

## Two ways to use Heidi Fix

| Use | When | Section |
|---|---|---|
| The command line | You want to fix a repository on your computer, or in your own CI system. | [Use Heidi Fix on your computer](#use-heidi-fix-on-your-computer) |
| GitHub Actions | You want a scheduled run, or a run for each pull request, on a repository on GitHub. | [Use Heidi Fix in GitHub Actions](#use-heidi-fix-in-github-actions) |

Both ways use the same program. The GitHub Actions workflow downloads it and
runs it for you.

## Use Heidi Fix on your computer

### What you need

- Linux x64, Linux arm64, or macOS arm64. Heidi Fix has no program for
  Windows.
- git 2.23 or later.
- The build tools of your project, for example Maven or npm. The build and
  the tests of the project must run on your computer.
- An agent: Claude Code or Codex. See
  [Log in to an agent](#log-in-to-an-agent).

Heidi Fix needs no Java and no Meterian account. The command line needs no
Meterian token at this time. A future version can need one.

### Install the program

Each release has a native program for each platform. Use the program for
your platform:

| Platform | Release file |
|---|---|
| Linux x64 | `heidi-fix-linux-x64` |
| Linux arm64 | `heidi-fix-linux-arm64` |
| macOS arm64 (Apple silicon) | `heidi-fix-macos-arm64` |

To download and check the program, do these steps. The example uses Linux
x64 and the version `v0.1.0-alpha.7`.

1. Download the program and its checksum file. For another platform, replace
   `linux-x64` with the platform of the table:

   ```bash
   base=https://github.com/MeterianHQ/heidi-fix-public/releases/download/v0.1.0-alpha.7
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

### Log in to an agent

Heidi Fix starts the agent as a separate program. Install Claude Code or
Codex first. Then log in with a subscription or with an API key:

| Agent | Subscription | API key |
|---|---|---|
| Claude Code | Run `claude auth login`. | Set the variable `ANTHROPIC_API_KEY`. |
| Codex | Run `codex login`. | Run `printenv OPENAI_API_KEY \| codex login --with-api-key`. |

Claude Code also accepts the variable `CLAUDE_CODE_OAUTH_TOKEN`. Run
`claude setup-token` to get its value. Codex reads no variable. It uses only
the login that `codex login` stores.

Heidi Fix uses the first agent of the list `[claude, codex]` that is logged
in. To select the agent of one run, use `--agent codex` or `--agent claude`.

The command `plan` needs no agent.

### Run Heidi Fix

Heidi Fix needs a git repository with no changes that are not committed. It
builds, tests, and fixes in separate git worktrees outside your directory.

1. Go to the directory of your repository.
2. Run `heidi-fix plan` to see the vulnerable dependencies and the planned
   fixes. This command changes nothing.
3. Run `heidi-fix run --publish local` to make the fixes. Heidi Fix keeps each
   verified fix as a local branch `heidi-fix/...`. It pushes nothing.
4. Run `git branch --list 'heidi-fix/*'` to see the branches.
5. Review each branch. Merge the branches that you accept.

Each command also accepts the directory as its last argument, for example
`heidi-fix run --publish local ~/projects/shop`. The command `heidi-fix
--help` shows all the options.

A run does these steps:

1. It scans the dependencies and finds the vulnerabilities.
2. It builds the project and runs the tests before a change. The build must
   pass. A test that fails before the change is a known failure.
3. It upgrades each vulnerable dependency. If the build or the tests fail, the
   agent changes the code.
4. It verifies each fix: the build, the tests, the diff, and a new scan.
5. It makes a commit for each verified fix and publishes it.

### Where the fixes go

The publisher decides where a verified fix goes. Without `--publish`, Heidi
Fix selects the first publisher of the list `[github, git-push, local]` that
is ready:

| Publisher | Selected when | Result |
|---|---|---|
| `github` | The remote `origin` is on GitHub. | A branch on the remote and a pull request for each fix. |
| `git-push` | The remote is not on GitHub, and a dry run of `git push` succeeds. | A branch on the remote for each fix. No pull request. |
| `local` | Always ready. | A local branch for each fix. Nothing goes to the remote. |

**Caution:** In a clone of a GitHub repository, a plain `heidi-fix run`
opens pull requests. Use `--publish local` to keep the fixes on your
computer.

The publisher `github` needs two credentials:

- The git credentials for the push, for example an SSH key or
  `gh auth setup-git`.
- A token for the GitHub API. Heidi Fix reads the variable `GH_TOKEN`, then
  `GITHUB_TOKEN`. Without a variable, it runs `gh auth token`. The token needs
  the permissions "Contents: write", "Pull requests: write", and "Metadata:
  read".

To make the same fixes again, use `--replace-branches`. Heidi Fix then
replaces its own branches of an earlier run. An open pull request keeps its
number and gets a comment.

### Fix only the changes of a branch

To scan and fix only the projects whose manifests your branch changes, use
one of these options:

| Option | Base of the comparison |
|---|---|
| `--changed-only` | The variable `GITHUB_BASE_REF`, else the default branch of the remote. |
| `--changes-since <ref>` | The merge base with `<ref>`, for example `origin/main`. |

Heidi Fix never fetches. The base reference must be in your clone.

To put the fixes on your current branch, use one of these options with `run`:

| Option | Result |
|---|---|
| `--current-branch=split` | One fix branch for each fix, based on your current branch. |
| `--current-branch` | One chain of commits with all the fixes. |

**Caution:** With `--current-branch` and the publisher `local` or `git-push`,
Heidi Fix moves your branch to the chain. The publisher `git-push` also pushes
the chain to your branch. Use `--publish github` or `--current-branch=split`
when a person must review the fixes before they reach your branch.

### The report and the exit code

Each run writes its files to a run directory,
`~/.heidi-fix/runs/<run-id>/`. Use `--run-dir <directory>` for another
directory. The run directory contains:

- `report.json`, the report of the run.
- `evidence/`, the evidence of each fix, for example the test results.
- `heidi-fix.log`, the log of the run.

The console shows one line for each step. Use `--verbose` to see the details
of each step.

| Exit code | Meaning |
|---|---|
| 0 | Each fix is verified and published. A run with nothing to fix also gives 0. |
| 1 | A step stopped the run, or one or more fixes are not verified. |
| 2 | The command or the configuration is not correct. |
| 3 | Heidi Fix did not write a complete report, or an internal error occurred. |
| 4 | Each fix is verified, but one or more fixes have no publication. |

With `--current-branch`, an earlier fix of the chain can already remove the
vulnerable version of a later remediation. For example, a new version of
Express no longer uses an old `body-parser`. Heidi Fix then does not start
the later remediation. The report shows "fixed by R9", where R9 is the earlier
fix. Such a remediation counts as fixed and gets the publication of the chain.
When a later fix of the chain brings back a finding, or the publication of the
chain fails, such a remediation fails.

### The configuration

Heidi Fix reads two configuration files:

| File | Location | Purpose |
|---|---|---|
| The user file | `~/.heidi-fix/config.yml` | Your settings, for example the budgets and the build commands. |
| The repository file | `.heidi-fix.yml` in the repository, or the file of `--config` | The settings of the project. |

The repository file cannot set the budgets, the build commands, the remote,
or the GitHub host. A pull request can change this file, so these settings
stay in the user file. To change a setting for one run, use
`--set <key>=<value>`, for example `--set limits.agent-cost-usd=5`.

**The policy.** By default, Heidi Fix fixes the findings with the severity
HIGH or CRITICAL, or with a CVSS score of 7.0 or more. The default also
ignores the AUTO-CPEDIA advisories, which report unmaintained libraries. An
upgrade cannot fix them. The reports show these findings as ignored. The
repository file or the user file can give another policy:

```yaml
policy:
  severity: critical
  ignore:
    - id: CVE-2025-43731
      reason: The vulnerable function is not used.
    - package: lodash
      ecosystem: npm
    - id-prefix: AUTO-CPEDIA.
      reason: Tracking of unmaintained libraries is currently disabled
```

A `policy` section replaces the complete default policy. To keep the
AUTO-CPEDIA entry, repeat it in your policy.

**The budget of the agent.** Each agent task has a limit of 2 US dollars,
5 000 000 tokens, and 20 minutes. All the agent tasks of one run share a limit
of 20 US dollars and 50 000 000 tokens. To change these limits, use the user
file:

```yaml
limits:
  agent-cost-usd: 5
  agent-tokens: 2000000
  agent-timeout: 30m
  run-agent-cost-usd: 40
  run-agent-tokens: 100000000
```

**The build commands.** Heidi Fix knows the build and the tests of Maven,
Gradle, and npm. For another project, give the commands in the user file. The
tests must write JUnit XML reports:

```yaml
validator:
  build-command: pip install -e .
  test-command: pytest --junitxml=reports/junit.xml
  reports: reports/*.xml
```

The agent can run the programs of these commands.

**A run without an agent.** Heidi Fix then only upgrades the dependencies. It
does not change the code when a test fails. Use this user file:

```yaml
components:
  auto-fixer: [meterian]
  advanced-fixer: []
```

Do not use `--reachability` in a run without an agent.

**The reachability analysis.** With `--reachability`, the agent tells which
vulnerable code the application uses. Heidi Fix then fixes these
dependencies first. The analysis costs one more agent task.

**A proxy.** Heidi Fix uses the variables `https_proxy`, `http_proxy`, and
`no_proxy`, as git and curl do. The upper-case names also work.

### The supported ecosystems

The scan finds the dependencies of Maven, Gradle, Node.js, Python, Ruby, PHP
Composer, Go, Rust Cargo, .NET, and other ecosystems. Heidi Fix gives full
support to Maven, Gradle, and npm. For another ecosystem, give the build
commands in the user file. See [The configuration](#the-configuration).

### Common problems on your computer

| Message | What to do |
|---|---|
| `The repository ... has changes that are not committed` | Commit or remove the changes. Then run Heidi Fix again. |
| `No agent is logged in` | Log in to Claude Code or Codex. See [Log in to an agent](#log-in-to-an-agent). |
| `The publisher ... is not ready` | Give the credentials of the publisher, or use `--publish local`. |
| `The validator gives a baseline whose build does not pass` | Make the build pass before the run. For a project that is not Maven, Gradle, or npm, give the build commands. |
| macOS refuses the program | Remove the quarantine flag. See [Install the program](#install-the-program). |
| A loader error on Linux | Use a system with glibc 2.39 or later, for example Ubuntu 24.04. |

## Use Heidi Fix in GitHub Actions

A reusable workflow runs Heidi Fix on a schedule, on request, or for a pull
request. It opens a pull request for each verified fix. This section uses the
same program as the command line. The workflow installs it and the agent
Claude Code.

### Setup

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
    uses: MeterianHQ/heidi-fix-public/.github/workflows/heidi-fix.yml@v0.1.0-alpha.7
    permissions:
      contents: write
      pull-requests: write
    secrets: inherit
```

6. Start the workflow from the tab Actions, or wait for the schedule.

The workflow can also run for a pull request: see
[Fixes for a pull request](#fixes-for-a-pull-request).

The tag of the line `uses:` gives the workflow, the actions, and the native
programs of one version of Heidi Fix. To get a new version, change this tag.

The permissions of the caller are the maximum. Each job of the workflow
uses less. The job that runs the agent gets only `contents: read`.

### The tools of your build

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

### The input `config`

The default repository file of Heidi Fix is `.heidi-fix.yml`. Use the input
`config` for another file:

```yaml
    with:
      config: ci/heidi-fix.yml
```

### The optional secret `HEIDI_FIX_GITHUB_TOKEN`

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

### How Heidi Fix keeps the write token away from the agent

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

The workflow runs only for the events `schedule`, `workflow_dispatch`, and
`pull_request`. It refuses a pull request from a fork, and it refuses
`pull_request_target`. Thus only a person or an app with write access to the
repository, or Dependabot, can start it for a pull request. The build scripts
of the pull request run on the machine of the job `fix`, with the two tokens.

**Warning:** The agent can read the Meterian token and the Claude token on
the machine of the job `fix`. A prompt injection can send them to the
internet. Use tokens for Heidi Fix only.

The check for the token values finds only the exact values in the report
and in the changes. It stops an accidental leak. It cannot stop an agent
that controls the machine of the job.

### A rerun

This section is about the events `schedule` and `workflow_dispatch`. A later
run can make the same fix with the same branch name. When the pull request of
this branch is open, Heidi Fix gives this pull request again. It does not
push the branch again and does not open a second pull request.

A run for a pull request replaces the fix branches: see
[Fixes for a pull request](#fixes-for-a-pull-request).

### Fixes for a pull request

Heidi Fix can fix the vulnerable dependencies of a pull request before the
merge. Add a separate caller file for the pull requests. Do not add the event
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

For a pull request, Heidi Fix scans only the projects whose manifests the
pull request changes. When the pull request changes no manifest, the run ends
at once, without the agent.

The input `current-branch` selects the form of the fixes. Both forms open
pull requests into the branch of the pull request, not into the default
branch. A person merges them.

| Value | Result |
|---|---|
| `split` (default) | One pull request for each fix. |
| `chain` | One pull request with all the fixes. Heidi Fix tests each fix with the fixes before it. |

Heidi Fix never pushes to the branch of the pull request itself.

A new push to the pull request runs Heidi Fix again:

- In the form `split`, a new fix replaces the fix branch of the earlier run.
  When the fix pull request is open, Heidi Fix adds a comment to it. When no
  fix pull request is open, Heidi Fix opens a new one.
- In the form `chain`, each push gives a new chain pull request when the run
  has fixes. Close the old one.

Heidi Fix does not run for a pull request from a fork, because a fork can
contain unknown build scripts. The workflow then fails with
"Heidi Fix does not run for a pull request from a fork". Heidi Fix also does
not run for its own pull requests.

The job `publish` reads the repository file `.heidi-fix.yml` of the pull
request branch. This file cannot change the publisher or the destination of
the token. It can only remove a component from a list.

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
  branch. The job `publish` can also check out a newer commit than the job
  `fix`. Then, in the form `chain`, `heidi-fix publish` checks that the start
  commit is still on the branch. In the form `split`, it checks each fix
  branch from `git merge-base HEAD <tip>`.
- A force push to the branch of the pull request between the job `fix` and
  the job `publish` can remove the start commit from the clone of the job
  `publish`. Then the step that gets the fixes fails, and the job `publish`
  fails. The next push starts a new run.

### Common problems in GitHub Actions

| Line in the log | What to do |
|---|---|
| `Set the secret METERIAN_API_TOKEN` | Save a Meterian token as a secret of the repository. |
| `Set the secret CLAUDE_CODE_OAUTH_TOKEN` | Run `claude setup-token`, and save the result as a secret of the repository. |
| `Heidi Fix runs only for the events schedule, workflow_dispatch, and pull_request` | Use only the triggers `schedule`, `workflow_dispatch`, and `pull_request` in the caller file. Do not use `pull_request_target`. |
| `Heidi Fix does not run for a pull request from a fork` | Push the branch to the repository, and open the pull request from it. |
| `The head repository of the pull request does not exist` | The fork of the pull request is deleted. Push the branch to the repository, and open a new pull request from it. |
| `HEAD is a detached commit, so --current-branch has no branch` | Check out the branch of the pull request, with `ref: ${{ format('refs/heads/{0}', github.head_ref) }}`. The reusable workflow does this. |
| `The earlier run has no current branch, but heidi-fix publish expects ...`, `The earlier run has another form than ...`, or `The earlier run has another start commit than ...` | The report of the job `fix` does not agree with the inputs of the job `publish`. The agent can change the report, so Heidi Fix publishes nothing. Read the log of the job `fix`. |
| `The input start-commit is empty, so Heidi Fix cannot check the run of the job fix.` | Give the input `start-commit` the output `start-commit` of the action `fix`. The reusable workflow does this. |
| `The input current-branch must be split or chain` | Set the input `current-branch` to `split` or `chain`, or remove it. |
| `A Dependabot pull request gets only the Dependabot secrets` | Save the secrets also as Dependabot secrets: Settings > Secrets and variables > Dependabot. |
| `Heidi Fix does not run on its own branch` | Run the workflow on the default branch, not on a branch `heidi-fix/...`. |
| `The run contains a secret` | Heidi Fix uploads nothing and publishes nothing. Make new tokens. Then read the log of the job `fix`. |
| `not permitted to create or approve pull requests` | Do steps 3 and 4 of the setup, or set the secret `HEIDI_FIX_GITHUB_TOKEN`. |
| `The SHA-256 of heidi-fix-... is not correct` | Do not use the program. Tell Meterian. |
| `Heidi Fix has no program for the runner` | Use a runner Linux X64, Linux ARM64, or macOS ARM64. The reusable workflow uses `ubuntu-latest`. |
| `has changes that are not committed` | Change the setup action so that it writes outside the checkout, for example in `$RUNNER_TEMP`. |
| `heidi-fix run gives the exit code ...` | A remediation failed, or the run stopped. Read the summary of the job `fix`. The verified fixes still get their pull requests. |
