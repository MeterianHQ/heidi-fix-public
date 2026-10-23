# Common problems

Read this page if Heidi Fix stops with a message that you do not understand.

## Common problems on your computer

| Message | What to do |
|---|---|
| `The repository ... has changes that are not committed` | Commit or remove the changes. Then run Heidi Fix again. |
| `No agent is logged in` | Log in to Claude Code or Codex. See [Log in to an agent](command-line.md#log-in-to-an-agent). |
| `The publisher ... is not ready` | Give the credentials of the publisher, or use `--publish local`. See [Where the fixes go](command-line.md#where-the-fixes-go). |
| `The validator gives a baseline whose build does not pass` | Make the build pass before the run. For a project that is not Maven, Gradle, or npm, give the [build commands](configuration.md#the-build-commands). |
| `the setting 'kiwi.api' must be kiwi or meterian` | Set `kiwi.api` to `kiwi` or `meterian`. |
| `The setting kiwi.url must have no path when kiwi.api is kiwi` | Remove the path from `kiwi.url`. For an on-prem or a dedicated instance, set `kiwi.api` to `meterian`. See [An on-prem or a dedicated Meterian instance](configuration.md#an-on-prem-or-a-dedicated-meterian-instance). |
| `The setting kiwi.url must give the Meterian instance when kiwi.api is meterian` | Set `kiwi.url` to the URL of your Meterian instance in the user file or with `--set`. |
| `The setting kiwi.discovery must be false when kiwi.api is meterian` | Set `kiwi.discovery` to `false`. |
| `The setting kiwi.max-parallel must be from 1 to 99 when kiwi.api is meterian` | Set `kiwi.max-parallel` to a value from 1 to 99. |
| `The setting kiwi.url must use https when kiwi.api is meterian` | Use an `https` URL of your Meterian instance. |
| `The setting kiwi.url must not have a . or .. path segment` | Remove the `.` and `..` segments from the path of `kiwi.url`. |
| `The setting kiwi.api is meterian, but the variable METERIAN_API_TOKEN has no value` | Export your Meterian API token in `METERIAN_API_TOKEN`. |
| `The setting kiwi.api is meterian, but the variable METERIAN_API_TOKEN must have only visible ASCII characters` | Copy the token again, without spaces or other characters. |
| `The command repair needs a publisher and the chain form of the current branch` | Check out the branch of the pull request, and use a publisher, for example `--publish git-push`. |
| `The base reference ... is not in the clone` | Fetch the base branch, for example with `git fetch origin main`, or give it with `--base`. |
| `The branch has no common commit with ...` | Fetch the full history, for example with `git fetch --unshallow`. |
| `The base branch does not build, so Heidi Fix has no baseline` | Make the build of the base branch pass. Then run `repair` again. |
| `The dependency tree of the base commit cannot be read` or `The dependency tree of the branch cannot be read` | Give the upgraded libraries with `--upgrade`. |
| `The dependency tree of the branch is empty` or `The dependency trees of the base commit and of the branch are empty` | Give the upgraded libraries with `--upgrade`. |
| `The upgrade ... is not in the dependency tree of the branch` | Give the version that the branch uses in `--upgrade`. |
| `The lines that the branch adds to the build files cannot be read` | Make sure that git works in the repository. Then run `repair` again. |
| `... and the baseline runs ... Set verifier.allow-test-removal to true when the branch removes tests on purpose` | When the branch removes tests on purpose, set `verifier.allow-test-removal: true` in the user file. |
| `The repair changes line ... of ..., which the branch adds` | The agent changes a line of a build file of the branch, so Heidi Fix rejects the repair. Run `repair` again, or repair the code yourself. |
| `The repair changes line ...`, after a tool writes a manifest again | A tool can change the lines that the branch adds, for example `npm install` that changes the order of `package.json`. Keep the lines of the branch, or repair the branch by hand. |
| `The branch changes the build file ..., but its diff is binary, so its lines cannot be protected` | Remove the `-diff` attribute or the Git LFS rule of the build file, or repair the branch by hand. |
| macOS refuses the program | Remove the quarantine flag. See [Install the program](command-line.md#install-the-program). |
| A loader error on Linux | Use a system with glibc 2.39 or later, for example Ubuntu 24.04. |

## Common problems in GitHub Actions

| Line in the log | What to do |
|---|---|
| `Set the secret METERIAN_API_TOKEN` | Save a Meterian token as a secret of the repository. |
| `Set the secret CLAUDE_CODE_OAUTH_TOKEN` | Run `claude setup-token`, and save the result as a secret of the repository. |
| `the setting 'upgrade.maximum' is not valid` | Set the input `upgrade-maximum` to `patch`, `minor`, or `major`, or remove it. |
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
