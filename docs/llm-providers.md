# Use another LLM provider

This page is for a user who wants Heidi Fix to use a model of a local Ollama,
OpenRouter, or AWS Bedrock.

## How Heidi Fix uses a model

Heidi Fix does not call a model. It starts a coding agent, and the agent
calls the model. So you configure the agent, not Heidi Fix.

At this time, only Claude Code on the command line can use another provider:

| Agent | Command line | GitHub Actions |
|---|---|---|
| Claude Code | Yes, with the settings of this page | Not yet |
| Codex | Not yet | Not yet |

Heidi Fix gives the agent only a small set of environment variables. To give
the agent the variables of a provider, add their names to `environment.add`.
Put this setting in your user file `~/.heidi-fix/config.yml`. A configuration
file inside the repository cannot set `environment`. See
[the environment of the processes](configuration.md#the-environment-of-the-processes).

In a run of Heidi Fix, Claude Code does not read the block `env` of
`~/.claude/settings.json`. Set the variables in your shell.

## Use a local Ollama

1. Start the Ollama server with a context window of 64000 tokens or more:

   ```bash
   OLLAMA_CONTEXT_LENGTH=64000 ollama serve
   ```

   In the Ollama app, you can set the context length in the settings.
2. Download a model that can use tools, for example `ollama pull qwen3.5`.
3. Set the variables in your shell:

   ```bash
   export ANTHROPIC_BASE_URL=http://localhost:11434
   export ANTHROPIC_AUTH_TOKEN=ollama
   export ANTHROPIC_MODEL=qwen3.5
   unset ANTHROPIC_API_KEY
   ```

4. Add these lines to `~/.heidi-fix/config.yml`:

   ```yaml
   environment:
     add: [ANTHROPIC_BASE_URL, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_MODEL]
   ```

5. Do the check of [Check the settings](#check-the-settings).
6. Run Heidi Fix with `--agent claude`.

A small local model can fail with the tools of the agent. Then Heidi Fix
reports the fix as failed. Use a larger model.

## Use OpenRouter

1. Get an API key from OpenRouter.
2. Set the variables in your shell. Replace `<your OpenRouter key>` with your
   key, and `<model>` with the name of an OpenRouter model:

   ```bash
   export ANTHROPIC_BASE_URL=https://openrouter.ai/api
   export ANTHROPIC_AUTH_TOKEN=<your OpenRouter key>
   export ANTHROPIC_MODEL=<model>
   unset ANTHROPIC_API_KEY
   ```

3. Add these lines to `~/.heidi-fix/config.yml`:

   ```yaml
   environment:
     add: [ANTHROPIC_BASE_URL, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_MODEL]
   ```

4. Do the check of [Check the settings](#check-the-settings).
5. Run Heidi Fix with `--agent claude`.

## Use AWS Bedrock

1. Make sure that your AWS account can use the Claude models in Bedrock.
2. Set the variables in your shell. Replace `<region>` and `<profile>` with
   your values:

   ```bash
   export CLAUDE_CODE_USE_BEDROCK=1
   export AWS_REGION=<region>
   export AWS_PROFILE=<profile>
   ```

   You can use `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and
   `AWS_SESSION_TOKEN` in place of `AWS_PROFILE`. You can also use a Bedrock
   API key in `AWS_BEARER_TOKEN_BEDROCK`. To select a model, also set
   `ANTHROPIC_MODEL`.
3. Add these lines to `~/.heidi-fix/config.yml`. Add the names of the other
   variables that you set in step 2:

   ```yaml
   environment:
     add: [CLAUDE_CODE_USE_BEDROCK, AWS_REGION, AWS_PROFILE]
   ```

4. Do the check of [Check the settings](#check-the-settings).
5. Run Heidi Fix with `--agent claude`.

The agent reads the files of `~/.aws`, because Heidi Fix gives it the variable
`HOME`.

## Check the settings

Run `claude auth status --json` in the same shell. The output must show
`"loggedIn": true`. With Bedrock, it also shows `"apiProvider": "bedrock"`.

This check reads all the variables of your shell and the file
`~/.claude/settings.json`. A run gives Claude Code only the variables of
`environment.add` and the small set of Heidi Fix. A run does not read
`~/.claude/settings.json`. So this check can pass, and the run can fail.

To check the settings as a run does, run this command in the same shell:

```bash
env -i HOME="$HOME" PATH="$PATH" \
  ANTHROPIC_BASE_URL="$ANTHROPIC_BASE_URL" \
  ANTHROPIC_AUTH_TOKEN="$ANTHROPIC_AUTH_TOKEN" \
  ANTHROPIC_MODEL="$ANTHROPIC_MODEL" \
  claude -p --setting-sources "" "Reply with the word OK"
```

Replace the variable names with the names of your `environment.add`. The
command sends one small request to the model. The output must contain `OK`.

## What changes with another provider

- **The cost limits.** Claude Code calculates the cost with the prices of
  Anthropic. For another model, this cost can be wrong. The cost limit still
  applies. If the cost is wrong, raise `agent-cost-usd` and
  `run-agent-cost-usd`, and use the token limits `agent-tokens` and
  `run-agent-tokens`. See
  [the budget of the agent](configuration.md#the-budget-of-the-agent).
- **A warning.** Heidi Fix shows a warning for a variable with a secret name,
  for example `ANTHROPIC_AUTH_TOKEN`. The warning tells you that each process
  gets the variable.
- **The build tools.** The build and the tests of your project also get the
  variables of `environment.add`.

## Next steps

- [Use Heidi Fix on your computer](command-line.md)
- [The configuration](configuration.md)
- [The home page](../README.md)
