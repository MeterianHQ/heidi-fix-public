# Presenter notes: Heidi Fix on a Node.js project (npm)

## The message of the demo

Heidi Fix finds the vulnerable dependencies of a project and fixes them one by
one. One upgrade breaks the tests. A coding agent then changes the code, and
the tests pass again.

Heidi Fix is a security remediation orchestrator, not a coding agent. It uses
a coding agent only for the tasks that need one. An algorithm, not the agent,
makes the final decision to accept a fix.

## The project

| Item | Value |
|---|---|
| Project | `project/`: a small Express service with one endpoint and one test |
| Main vulnerable dependency | `express` 3.21.2 |
| Safe version of Express | 5.3.0 |
| Why the upgrade breaks the tests | Express 4 removed `express.bodyParser()`, and `app.js` uses it |
| Expected code change | `express.bodyParser()` becomes `express.json()` and `express.urlencoded()` |
| Other remediations | 11 more, mostly old dependencies of Express 3, for example `qs`, `morgan`, and `body-parser` |

## Before the demo

1. Make sure that Claude Code is logged in. Run `claude` and check that it starts without a login prompt.
2. Make sure that the network is available. The scan uses the Meterian service, and npm downloads the packages.
3. Do one full run of the demo before the audience arrives. The script resets the project at each start.
4. Open a terminal with a large font. Make the window wide, because the run output has long lines.
5. Go to the folder of the demo: `cd demos/npm`.

Duration: approximately 10 minutes. Step 4 takes approximately 2 minutes. The
test run of 2026-10-20 took 45 seconds for step 4.

Cost: step 4 calls Claude. The limit of one agent task is 2 US dollars. The
limit of one run is 20 US dollars. The test run of 2026-10-20 cost about 0.1 US
dollars.

## Start

```bash
./demo.sh
```

The script checks the tools and creates the project again in
`demo-repository/`. Then it stops after each step. Press Enter to go to the next step.

The demo has no reachability analysis by default. To add it, start the demo
with `./demo.sh --reachability`. Then Express comes early in the order, and
most of the other remediations become "fixed by an earlier fix". The analysis
takes approximately 2.5 minutes.

## Step 1: a small Node.js service with a vulnerable dependency

**The screen shows:**
- One commit in the history.
- Express version 3.21.2 in `package.json`.
- Line 5 of `app.js`: `app.use(express.bodyParser());`.

**Say:**
- "This is a small Express service. It uses Express 3.21.2, an old version."
- "Look at line 5. The code uses `express.bodyParser()`. Remember this line."

## Step 2: the project builds and its tests pass

**The screen shows:** `npm ci` and `npm test`. The test "echoes the JSON body"
passes, and then "Build OK".

The test output also shows two "connect deprecated" warnings. They come from
Express 3. You can show them as a sign of an old dependency.

**Say:**
- "Before we change anything, the tests pass."
- "Heidi Fix uses these tests later to check each fix."

## Step 3: Heidi Fix plans the remediation

**The screen shows:** `heidi-fix plan .`, with these lines:
- Scan: 56 vulnerabilities.
- Select findings: 15 vulnerabilities selected.
- Plan: 12 remediations, the most urgent first. R1 and R2 are CRITICAL (`morgan`, `minimist`). R10 is `express`.

**Say:**
- "`plan` only reads. It changes nothing."
- "The scan finds 56 vulnerabilities, in the direct and in the transitive dependencies."
- "The policy keeps only the HIGH and the CRITICAL ones: 15 vulnerabilities, in 12 remediations."
- "Heidi Fix orders the remediations: the most urgent first."

## Step 4: Heidi Fix fixes the project

**The screen shows:** `heidi-fix run --current-branch --publish local --reachability=off --verbose .`

**Expected sequence, for each remediation:**
1. Heidi Fix upgrades the dependency.
2. Heidi Fix runs the tests.
3. If the tests pass, the verifier checks the fix, and Heidi Fix commits it.
4. If the tests fail, the advanced fixer starts the agent (Claude Code). The agent changes the code. Heidi Fix runs the tests again.

**The important remediation is `express`:**
1. Heidi Fix upgrades Express to version 5.3.0.
2. The test fails, because `express.bodyParser()` does not exist in Express 5.
3. The agent gets the failure and changes `app.js`.
4. The test passes. The verifier accepts the fix.

Each remediation succeeds. The test run of 2026-10-20 gave this summary:
`10 published, 2 fixed by an earlier fix (exit code 0)`.

| Remediation | Result | Explanation |
|---|---|---|
| R1 to R9 | Published | A simple upgrade. No agent. R9 removes the old `debug` 2.2.0 that nine packages of Express 3 use. |
| R10 `express` | Published | The upgrade breaks the test. The agent changes `app.js`. |
| R11 `body-parser`, R12 `multiparty` | Fixed by R10 | Express 5 does not use these old versions. Heidi Fix sees this in the scan after R10, so it does not start these two remediations and does not call the agent. |

If somebody asks about R11 and R12, say: "The upgrade of Express already
removes these old packages. Heidi Fix checks the project after each fix, so it
does not do unnecessary work."

The plan does not show two AUTO-CPEDIA advisories, for `stream-counter` and
`basic-auth-connect`. They report unmaintained libraries. The default policy
ignores them, and `--verbose` shows the reason: "Tracking of unmaintained
libraries is currently disabled". If somebody asks, say: "Heidi Fix sees these
signals, but this version does not act on them."

**Say:**
- "Heidi Fix fixes one remediation at a time, and checks each one."
- "Most upgrades are simple, and need no agent."
- "Now look at Express. The upgrade breaks the test. Heidi Fix gives the task to a coding agent, with the error and a budget."
- "The agent does not decide that the fix is good. Heidi Fix tests and scans again. Only then does it accept the fix."

**Flags to explain, if somebody asks:**
- `--current-branch`: put the fixes on the current branch, not on new fix branches.
- `--publish local`: push nothing and open no pull request.
- `--reachability=off`: no reachability analysis. Without this flag, a
  Claude Code subscription turns the analysis on. `./demo.sh --reachability`
  turns it on.
- `--verbose`: show the details of each step.

## Step 5: the fixes as uncommitted changes

**The screen shows:**
- The history with one commit for each fix.
- The script removes the commits and keeps the changes in the files.
- `git status --short`: the changed files, for example `package.json`, `package-lock.json`, and `app.js`.
- `git diff --stat`: the size of the change in each file.
- `git diff` without `package-lock.json`: the new versions in `package.json`, and the code change in `app.js`.

The script hides the diff of `package-lock.json`, because it is very long.

**Say:**
- "Here is the complete result: the new versions, and the code change of the agent."
- "In a normal run, Heidi Fix opens one pull request for each fix. A person reviews them."

## Step 6: the fixed project builds and its tests pass

**The screen shows:** `npm ci` and `npm test`, and then "Build OK". The
"connect deprecated" warnings are gone.

**Say:**
- "The project uses the safe versions, and the test passes."

## Questions from the audience

**"Is the agent safe? Can it do anything on my machine?"**
Heidi Fix runs the agent in the `secure` mode by default. Each agent task has a
budget: 2 US dollars, 5 000 000 tokens, and 20 minutes. One run has a total
budget of 20 US dollars. The verifier shows each change outside the expected files.

**"Which agents are supported?"**
Claude Code and Codex. Use `--agent codex` to select Codex.

**"Can I fix only one dependency?"**
Not with a flag. The policy selects the findings by severity (HIGH and more by
default) and by CVSS score (7.0 and more by default).

**"What does a normal run do?"**
Without the demo flags, Heidi Fix puts each fix on its own branch. With a
remote on GitHub, it opens one pull request for each verified fix.

**"Where is the evidence?"**
The last line of each run gives a folder in `~/.heidi-fix/runs/`. The folder
has the log, the evidence of each step, and the telemetry.

## If something goes wrong

- **Step 4 stops with a login error:** Claude Code is not logged in. Run `claude`, log in, and start `./demo.sh` again.
- **Step 2, 3, or 4 stops with a network error:** the scan needs the Meterian service, and npm needs the npm registry. Check the network.
- **The agent fails or reaches its budget:** Heidi Fix reports the remediation as not remediated. Explain that Heidi Fix does not accept a fix that does not pass the checks.
- **Step 4 takes too long:** use the Maven demo. It has only one remediation.
- **You want to start again:** run `./demo.sh` again. It creates the project again.
