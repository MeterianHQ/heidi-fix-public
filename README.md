# Heidi Fix

Heidi Fix finds the vulnerable dependencies of a repository and fixes them.
It runs the build and the tests to verify each fix. Then it gives each
verified fix to a person for review, for example as a pull request. Heidi Fix
never merges a change.

Heidi Fix uses a coding agent, Claude Code or Codex, for the tasks that need
one. An algorithm, not the agent, decides if a fix is verified.

Heidi Fix can also repair the code of a branch after a library upgrade, with
the command `heidi-fix repair`. See
[Repair a branch after an upgrade](docs/command-line.md#repair-a-branch-after-an-upgrade).

## Two ways to use Heidi Fix

| Use | When | Page |
|---|---|---|
| The command line | You want to fix a repository on your computer, or in your own CI system. | [Use Heidi Fix on your computer](docs/command-line.md) |
| GitHub Actions | You want a scheduled run, or a run for each pull request, on a repository on GitHub. | [Use Heidi Fix in GitHub Actions](docs/github-actions.md) |

Both ways use the same program. The GitHub Actions workflow downloads it and
runs it for you.

To try Heidi Fix on your computer for the first time, read
[Get started](docs/getting-started.md).

## The documentation

| Page | Content |
|---|---|
| [Get started](docs/getting-started.md) | Do a first run of Heidi Fix on your computer in five steps. |
| [Use Heidi Fix on your computer](docs/command-line.md) | Install the program, log in to an agent, run Heidi Fix, repair a branch after an upgrade, and read the report. |
| [The configuration](docs/configuration.md) | The configuration files and their settings: the policy, the budgets, the build commands, the upgrade limit, an on-prem or a dedicated Meterian instance, and more. |
| [Use Heidi Fix in GitHub Actions](docs/github-actions.md) | Set up the reusable workflow, the tools of your build, the tokens, and the upgrade limit. |
| [Fixes for a pull request](docs/pull-requests.md) | Fix the vulnerable dependencies of a pull request before the merge. |
| [Security in GitHub Actions](docs/security.md) | How Heidi Fix keeps the write token away from the agent. |
| [The supported ecosystems](docs/ecosystems.md) | The ecosystems that the scan finds and the ecosystems that Heidi Fix fully supports. |
| [Use another LLM provider](docs/llm-providers.md) | Use a model of a local Ollama, OpenRouter, or AWS Bedrock. |
| [Common problems](docs/troubleshooting.md) | The common messages on your computer and in GitHub Actions, and what to do. |
| [Demos](demos/README.md) | Three demos to run on your computer: two fixes that need a code change, and the repair of a pull request after an upgrade. |
