# Use Heidi Fix in GitHub Actions

Read this page if you want a scheduled run, or a run on request, on a
repository on GitHub.

A reusable workflow runs Heidi Fix on a schedule, on request, or for a pull
request. It opens a pull request for each verified fix. The workflow uses the
same program as the command line. The workflow installs it and the agent
Claude Code.

## Setup

1. Run `claude setup-token` on your computer.
2. Save the result as the secret `CLAUDE_CODE_OAUTH_TOKEN` of the repository.
3. Save a Meterian token as the secret `METERIAN_API_TOKEN` of the
   repository.
4. Go to Settings > Actions > General of the repository.
5. Turn on "Allow GitHub Actions to create and approve pull requests".
6. Add the file `.github/workflows/heidi-fix.yml` to the default branch:

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
       uses: MeterianHQ/heidi-fix-public/.github/workflows/heidi-fix.yml@v0.1.0-alpha.9
       permissions:
         contents: write
         pull-requests: write
       secrets: inherit
   ```

7. Start the workflow from the tab Actions, or wait for the schedule.

You can skip steps 4 and 5 when you set the secret `HEIDI_FIX_GITHUB_TOKEN`.
See [The optional secret `HEIDI_FIX_GITHUB_TOKEN`](#the-optional-secret-heidi_fix_github_token).

The workflow can also run for a pull request. See
[Fixes for a pull request](pull-requests.md).

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

The page [The configuration](configuration.md) gives the settings of this
file.

## The SAST scan

The workflow runs only the SCA scan. The default of `scan-type` is `sca`,
and the workflow has no input for the SAST scan. A file inside the
repository cannot widen `scan-type`. See
[The scan type](configuration.md#the-scan-type).

## The input `upgrade-maximum`

The input `upgrade-maximum` limits the kind of upgrade of a dependency. The
values are `patch`, `minor`, and `major`. An empty input keeps the default
`major`. Example:

```yaml
    with:
      upgrade-maximum: minor
```

The repository file cannot set this limit. See
[The maximum upgrade](configuration.md#the-maximum-upgrade).

## The optional secret `HEIDI_FIX_GITHUB_TOKEN`

Without this secret, the workflow opens the pull requests with the token of
the run, `github.token`. GitHub then does not start the checks of your
repository on these pull requests. To start the checks, close and reopen
the pull request.

To make the pull requests start your checks, do these steps:

1. Make a fine-grained token with the write access to the contents and to the
   pull requests of this repository only.
2. Save it as the secret `HEIDI_FIX_GITHUB_TOKEN`.

Then the pull requests start your checks. Only the job that opens the pull
requests gets this token.

**Warning:** If you set this secret, your checks run on the fix before a
person reviews it. These checks get the secrets of your repository. Set this
secret only when your checks do not give secrets to the code of a pull
request.

## A rerun

This section is about the events `schedule` and `workflow_dispatch`. A later
run can make the same fix with the same branch name. When the pull request of
this branch is open, Heidi Fix gives this pull request again. It does not
push the branch again and does not open a second pull request.

A run for a pull request replaces the fix branches. See
[Fixes for a pull request](pull-requests.md).

## Next steps

- [Fixes for a pull request](pull-requests.md)
- [Security in GitHub Actions](security.md)
- [The configuration](configuration.md)
- [Common problems in GitHub Actions](troubleshooting.md#common-problems-in-github-actions)
- [The home page](../README.md)
