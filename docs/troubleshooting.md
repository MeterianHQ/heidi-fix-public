# Common problems

Read this page if Heidi Fix stops with a message that you do not understand.

## Common problems on your computer

| Message | What to do |
|---|---|
| `The repository ... has changes that are not committed` | Commit or remove the changes. Then run Heidi Fix again. |
| `No agent is logged in` | Log in to Claude Code or Codex. See [Log in to an agent](command-line.md#log-in-to-an-agent). |
| `The publisher ... is not ready` | Give the credentials of the publisher, or use `--publish local`. See [Where the fixes go](command-line.md#where-the-fixes-go). |
| `The validator gives a baseline whose build does not pass` | Make the build pass before the run. For a project that is not Maven, Gradle, or npm, give the [build commands](configuration.md#the-build-commands). |
| macOS refuses the program | Remove the quarantine flag. See [Install the program](command-line.md#install-the-program). |
| A loader error on Linux | Use a system with glibc 2.39 or later, for example Ubuntu 24.04. |

## Common problems in GitHub Actions

| Line in the log | What to do |
|---|---|
| `Set the secret METERIAN_API_TOKEN` | Save a Meterian token as a secret of the repository. |
| `Set the secret CLAUDE_CODE_OAUTH_TOKEN` | Run `claude setup-token`, and save the result as a secret of the repository. |
| `Heidi Fix runs only for the events schedule, workflow_dispatch, and pull_request` | Use only the triggers `schedule`, `workflow_dispatch`, and `pull_request` in the caller file. Do not use `pull_request_target`. |
| `Heidi Fix does not run for a pull request from a fork` | Push the branch to the repository, and open the pull request from it. |
| `The head repository of the pull request does not exist` | Somebody deleted the fork of the pull request. Push the branch to the repository, and open a new pull request from it. |
| `HEAD is a detached commit, so --current-branch has no branch` | Check out the branch of the pull request, with `ref: ${{ format('refs/heads/{0}', github.head_ref) }}`. The reusable workflow does this. |
| `The earlier run has no current branch, but heidi-fix publish expects ...`, `The earlier run has another form than ...`, or `The earlier run has another start commit than ...` | The report of the job `fix` does not agree with the inputs of the job `publish`. The agent can change the report, so Heidi Fix publishes nothing. Read the log of the job `fix`. |
| `The input start-commit is empty, so Heidi Fix cannot check the run of the job fix.` | Give the input `start-commit` the output `start-commit` of the action `fix`. The reusable workflow does this. |
| `The input current-branch must be split or chain` | Set the input `current-branch` to `split` or `chain`, or remove it. |
| `A Dependabot pull request gets only the Dependabot secrets` | Save the secrets also as Dependabot secrets: Settings > Secrets and variables > Dependabot. |
| `Heidi Fix does not run on its own branch` | Run the workflow on the default branch, not on a branch `heidi-fix/...`. |
| `The run contains a secret` | Heidi Fix uploads nothing and publishes nothing. Make new tokens. Then read the log of the job `fix`. |
| `not permitted to create or approve pull requests` | Do steps 4 and 5 of the [setup](github-actions.md#setup), or set the secret `HEIDI_FIX_GITHUB_TOKEN`. |
| `The SHA-256 of heidi-fix-... is not correct` | Do not use the program. Tell Meterian. |
| `Heidi Fix has no program for the runner` | Use a runner Linux X64, Linux ARM64, or macOS ARM64. The reusable workflow uses `ubuntu-latest`. |
| `has changes that are not committed` | Change the setup action so that it writes outside the checkout, for example in `$RUNNER_TEMP`. |
| `heidi-fix run gives the exit code ...` | A fix failed, or the run stopped. Read the summary of the job `fix`. The verified fixes still get their pull requests. |

## Next steps

- [Use Heidi Fix on your computer](command-line.md)
- [Use Heidi Fix in GitHub Actions](github-actions.md)
- [The configuration](configuration.md)
- [The home page](../README.md)
