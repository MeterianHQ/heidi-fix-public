# Use Heidi Fix on your computer

Read this page if you want to fix a repository on your computer, or in your
own CI system.

For a short first run, read [Get started](getting-started.md).

## What you need

- Linux x64, Linux arm64, or macOS arm64. Heidi Fix has no program for
  Windows.
- git 2.23 or later.
- The build tools of your project, for example Maven or npm. The build and
  the tests of the project must run on your computer.
- An agent: Claude Code or Codex. See
  [Log in to an agent](#log-in-to-an-agent).

Heidi Fix needs no Java and no Meterian account. The command line needs no
Meterian token at this time. A future version can need one.

## Install the program

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
4. On macOS, if you download the program with a browser, run
   `xattr -d com.apple.quarantine heidi-fix-macos-arm64`.

   A download with a browser gets the quarantine flag. The program has no
   Apple signature, so macOS then refuses it. A download with `curl` does not
   get the flag.
5. Move the program to a directory of your `PATH` with the name `heidi-fix`.
   For another platform, use the file name of your platform:

   ```bash
   mkdir -p ~/.local/bin && mv heidi-fix-linux-x64 ~/.local/bin/heidi-fix
   ```

   Make sure that `~/.local/bin` is in your `PATH`. On macOS, add it to your
   shell profile.
6. Run `heidi-fix --help`.

The Linux programs need glibc 2.39 or later, for example Ubuntu 24.04 or
later. The macOS program needs the macOS version of the GitHub runner
`macos-latest`, or a later version. An older system stops the program with a
loader error.

## Log in to an agent

Heidi Fix starts the agent as a separate program. Do these steps:

1. Install Claude Code or Codex.
2. Log in with a subscription or with an API key. The table gives the
   command or the variable.

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

## Run Heidi Fix

Heidi Fix needs a git repository with no changes that are not committed. It
builds, tests, and fixes in separate git worktrees outside your directory.

1. Go to the directory of your repository.
2. Run `heidi-fix plan` to see the vulnerable dependencies and the planned
   fixes. This command changes nothing.
3. Run `heidi-fix run --publish local` to make the fixes. Heidi Fix keeps each
   verified fix as a local branch `heidi-fix/...`. It pushes nothing.
4. Run `git branch --list 'heidi-fix/*'` to see the branches.
5. Review each branch.
6. Merge the branches that you accept.

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

## Where the fixes go

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

## Fix only the changes of a branch

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

## The report and the exit code

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

With `--current-branch`, an earlier fix of the chain can remove the
vulnerable version of a later fix. For example, a new version of Express does
not use an old `body-parser`. Heidi Fix then does not start the later fix.
This fix counts as fixed and gets the publication of the chain. The report
shows "fixed by R9", where R9 is the earlier fix.

A fix that Heidi Fix does not start fails in two cases:

- A fix after it in the chain brings back the finding.
- The publication of the chain fails.

## Next steps

- [The configuration](configuration.md)
- [The supported ecosystems](ecosystems.md)
- [Use another LLM provider](llm-providers.md)
- [Common problems](troubleshooting.md#common-problems-on-your-computer)
- [Use Heidi Fix in GitHub Actions](github-actions.md)
- [The home page](../README.md)
