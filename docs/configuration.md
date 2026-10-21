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
`telemetry`, `open-telemetry`, `scope`, and `reachability`. These sections
contain, for example, the budgets, the build commands, the remote, and the
GitHub host. A pull request can change the repository file, so these
sections stay in the user file.

To change a setting for one run, use `--set <key>=<value>`, for example
`--set limits.agent-cost-usd=5`.

## The policy

By default, Heidi Fix fixes the findings with the severity HIGH or CRITICAL,
or with a CVSS score of 7.0 or more. The default also ignores the
AUTO-CPEDIA advisories, which report unmaintained libraries. An upgrade
cannot fix them. The reports show these findings as ignored.

The repository file or the user file can give another policy:

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

## A proxy

Heidi Fix uses the variables `https_proxy`, `http_proxy`, and `no_proxy`, as
git and curl do. The upper-case names also work.

## Next steps

- [Use Heidi Fix on your computer](command-line.md)
- [The supported ecosystems](ecosystems.md)
- [Use another LLM provider](llm-providers.md)
- [The input `config` in GitHub Actions](github-actions.md#the-input-config)
- [The home page](../README.md)
