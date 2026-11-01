# The configuration

Read this page if you want to change the policy, the budgets, the build
commands, or another setting of Heidi Fix.

## The configuration files

Heidi Fix reads two configuration files:

| File | Location | Purpose |
|---|---|---|
| The user file | `~/.heidi-fix/config.yml` | Your settings, for example the budgets and the build commands. |
| The repository file | `.heidi-fix.yml` in the repository, or the file of `--config` | The settings of the project. |

The repository file cannot set these sections: `kiwi`, `limits`,
`environment`, `verifier`, `validator`, `publishing`, `security`,
`telemetry`, `open-telemetry`, `scope`, `reachability`, `upgrade`, and
`repair`. These sections contain, for example, the budgets, the build
commands, the remote, and the GitHub host. A pull request can change the repository file, so these
sections stay in the user file.

To change a setting for one run, use `--set <key>=<value>`, for example
`--set limits.agent-cost-usd=5`.

## The policy

By default, Heidi Fix fixes the findings with the severity HIGH or CRITICAL.
The default also ignores the AUTO-CPEDIA advisories, which report
unmaintained libraries. An upgrade cannot fix them. The reports show these
findings as ignored.

**A change in this version.** The thresholds of the policy now combine: each
threshold with a value must pass. Before, one threshold was sufficient. The
default policy no longer has `cvss: 7.0`. A file that has `severity: high` and
`cvss: 7.0` now selects fewer findings: a HIGH finding with a CVSS less than
7.0 is not selected. To keep the HIGH findings, remove `cvss` from the file. The
default policy does not select a finding with no severity but with a CVSS.

The repository file or the user file can give another policy:

```yaml
policy:
  severity: critical
  cvss: 7.0
  epss: 0.1
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

Each threshold is a minimum: `severity` (low, medium, high, or critical),
`cvss` (0 to 10), and `epss` (0 to 1). A finding must pass each threshold that
has a value for it. A threshold without a value does not count. A code finding
has no CVSS and no EPSS, so only the severity applies to it. A policy without
`severity` does not select a code finding. Examples with the
policy above:

| Finding | Selected | Why |
|---|---|---|
| CRITICAL, CVSS 9.8, EPSS 0.3 | Yes | It passes each threshold. |
| CRITICAL, CVSS 9.8, EPSS 0.01 | No | The EPSS is less than 0.1. |
| CRITICAL, CVSS 9.8, no EPSS | Yes | The EPSS threshold does not count. |
| HIGH, CVSS 8.1, EPSS 0.5 | No | The severity is less than CRITICAL. |

A finding with no value for the thresholds of the policy is not selected.
`selection.json` shows the decision `NO_POLICY_DATA`. The reports show the
reason "no value for the rule ..." or "no value for the rules ...".

To change one threshold for one run, use `--set`:

```text
--set policy.severity=critical
--set policy.cvss=7
--set policy.epss=none
```

The value `none` removes the threshold. The other thresholds and the ignore
list stay the same. `--set` cannot change the ignore list, because each entry
needs a reason. Write the ignore list in a file.

## The scan type

The setting `scan-type` selects the scans. It has three values:

| Value | Scans |
|---|---|
| `sca` | The dependencies only. This is the default. |
| `all` | The dependencies (SCA) and then the source code (SAST). |
| `sast` | The source code only. |

Each real SAST finding costs agent quota.

**A run with SAST can fail before the scans.** The SAST scan needs Opengrep.
Opengrep has a binary only for Linux x64, Linux arm64, and macOS arm64. There
is no binary for Windows or macOS x64. The not-bundled program downloads
Opengrep from GitHub at run time. When the machine cannot reach GitHub, the
preflight fails, and the SCA scan does not run either. Use the
[bundled program](getting-started.md#the-bundled-program) on a supported
platform.

With `all`, the SAST scan runs after a successful SCA scan of a supported
repository. A
failed or not-applicable SCA scan stops the run before the SAST scan. To scan
a repository without a supported manifest, use `--scan-type sast`.

The repository file can only narrow the setting, for example from `all` to
`sca`. To widen it, use the user file or `--scan-type`.

## The maximum upgrade

The setting `upgrade.maximum` limits the kind of upgrade of a dependency.
It has three values:

- `patch`: the fix can change only the patch number, for example 2.3.1 to 2.3.4.
- `minor`: the fix can change the minor number, for example 2.3.1 to 2.9.0.
- `major`: the fix can change the major number. This is the default.

A fix that needs a higher upgrade gets the result `FAILED`. When the value is
`patch` or `minor`, a version that Heidi Fix cannot read is above the limit.

To set the limit for one run, use `--set upgrade.maximum=minor`. To set it
for each run, use the user file:

```yaml
upgrade:
  maximum: minor
```

The repository file cannot set this section.
In GitHub Actions, use the input `upgrade-maximum`. See
[The input `upgrade-maximum`](github-actions.md#the-input-upgrade-maximum).

## The settings of repair

The section `repair` holds the settings of the command
[`heidi-fix repair`](command-line.md#repair-a-branch-after-an-upgrade):

| Setting | Option | Content |
|---|---|---|
| `repair.base` | `--base` | The base branch of the comparison. The default is the branch in the variable `GITHUB_BASE_REF`, else the default branch of the remote. |
| `repair.upgrades` | `--upgrade` | The upgraded libraries, as `<ecosystem>:<name>:<version>`. Join two or more values with `,`. These values replace the comparison of the dependency trees. |

The user file or `--set` can set these settings, for example:

```yaml
repair:
  base: origin/develop
```

The repository file cannot set this section. Only `repair` uses these
settings: `--set repair.base=...` with another command is an error.

## The budget of the agent

Each agent task has a limit of 2 US dollars, 5 000 000 tokens, and 20
minutes. All the agent tasks of one run share a limit of 20 US dollars and
50 000 000 tokens. To change these limits, use the user file:

```yaml
limits:
  agent-cost-usd: 5
  agent-tokens: 2000000
  agent-timeout: 30m
  run-agent-cost-usd: 40
  run-agent-tokens: 100000000
```

## The build commands

Heidi Fix knows the build and the tests of Maven, Gradle, and npm. For
another project, give the commands in the user file. The tests must write
JUnit XML reports:

```yaml
validator:
  build-command: pip install -e .
  test-command: pytest --junitxml=reports/junit.xml
  reports: reports/*.xml
```

The agent can run the programs of these commands.

## A run without an agent

In a run without an agent, Heidi Fix only upgrades the dependencies. It does
not change the code when a test fails. Use this user file:

```yaml
components:
  auto-fixer: [meterian]
  advanced-fixer: []
```

A run without an agent does not analyze the reachability. Do not use
`--reachability` in a run without an agent.

## The reachability analysis

The agent tells which vulnerable code the application uses. Heidi Fix then
fixes these dependencies first. The analysis costs one more agent task.

Heidi Fix runs the analysis when the agent uses a subscription, for example
`CLAUDE_CODE_OAUTH_TOKEN`. With an API key, the analysis costs money, so it
stays off. `--reachability` turns it on, and `--reachability=off` turns it
off.

## The security mode

A file of the repository can contain instructions for the agent. The setting
`security.mode` selects the controls against such a prompt injection:

| Value | Result |
|---|---|
| `secure` (default) | The file tools of Claude Code cannot read or write a file outside the worktree. The verifier rejects a fix that contains a credential. |
| `yolo` | Heidi Fix turns off these two controls. The other checks of the verifier still run. Heidi Fix shows a warning at the start of each command, for example `plan` and `run`. |

The repository file cannot set this setting, because a pull request can
change the repository file. Set it in the user file, or with
`--set security.mode=<value>`:

```yaml
security:
  mode: secure
```

## The environment of the processes

Heidi Fix does not give its full environment to the processes that it
starts, for example the agent, git, and the build tools. Each process gets
only these variables:

- `PATH`, `HOME`, `LANG`, `LC_ALL`, `TMPDIR`, and `JAVA_HOME`.
- On Windows, also `SystemRoot`, `ComSpec`, `PATHEXT`, `TEMP`, `TMP`, and
  `USERPROFILE`.
- The variables of a proxy: `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`, and
  their lower-case names.
- The variables of the certificates: `SSL_CERT_FILE`, `SSL_CERT_DIR`,
  `NODE_EXTRA_CA_CERTS`, `REQUESTS_CA_BUNDLE`, `GIT_SSL_CAINFO`, and
  `GIT_SSL_CAPATH`.

The agent also gets its credentials, for example `ANTHROPIC_API_KEY` or
`CLAUDE_CODE_OAUTH_TOKEN`. The build tools of the scan, the upgrade, and the
tests also get the variables of the tools, for example `M2_HOME`,
`GRADLE_USER_HOME`, `GOPATH`, and `CARGO_HOME`.

Two settings change these variables:

| Setting | Result |
|---|---|
| `environment.add` | Each process also gets these variables, also the agent and the build tools. |
| `environment.ban` | No process gets these variables. A ban also removes a variable of the lists above and a credential of the agent. |

```yaml
environment:
  add: [ANTHROPIC_BASE_URL, ANTHROPIC_MODEL]
  ban: [ANTHROPIC_API_KEY]
```

The repository file cannot set this section. Set it in the user file.

Heidi Fix shows a warning for a name in `environment.add` that looks like a
secret, for example `ANTHROPIC_AUTH_TOKEN`. The warning tells you that each
process gets the variable, also the agents and the build tools.

## An on-prem or a dedicated Meterian instance

By default, Heidi Fix gets the vulnerability data from the public Meterian
service. An on-prem or a dedicated Meterian instance gives the same data
through the Meterian API. To use your instance, set `kiwi.api` to `meterian`
in the user file, and give the base URL of the instance:

```yaml
kiwi:
  api:          meterian
  url:          https://meterian.example.com
  discovery:    false
```

Then give your Meterian API token in the variable `METERIAN_API_TOKEN`:

```sh
export METERIAN_API_TOKEN=...
heidi-fix run .
```

Heidi Fix reads `METERIAN_API_TOKEN` only when `kiwi.api` is `meterian`. Do
not write the token in a configuration file. These rules apply:

- `url` is required. Heidi Fix stops when only the defaults give it.
- `discovery` must be `false`.
- The URL must use `https`, because each request sends the token.
- The URL can have a path, for example `https://tools.example.com/meterian`.
- `max-parallel` must be from 1 to 99. The default is 10.

The Meterian API accepts less than 100 requests at the same time for one
token. Thus, keep the sum of `kiwi.max-parallel` below 100 for all the runs
that use one token at the same time.

The repository file cannot set the `kiwi` section. For one run, use `--set`
for each setting, for example
`--set kiwi.api=meterian --set kiwi.discovery=false --set kiwi.url=https://meterian.example.com`.

## A proxy

Heidi Fix uses the variables `https_proxy`, `http_proxy`, and `no_proxy`, as
git and curl do. The upper-case names also work.

## Next steps

- [Use Heidi Fix on your computer](command-line.md)
- [The supported ecosystems](ecosystems.md)
- [Use another LLM provider](llm-providers.md)
- [The input `config` in GitHub Actions](github-actions.md#the-input-config)
- [The home page](../README.md)
