# Presenter notes: Heidi Fix on a Java project (Maven)

## The message of the demo

Heidi Fix finds a vulnerable dependency and upgrades it. The upgrade breaks
the build. A coding agent then changes the code, and the build passes again.

Heidi Fix is a security remediation orchestrator, not a coding agent. It uses
a coding agent only for the tasks that need one. An algorithm, not the agent,
makes the final decision to accept a fix.

## The project

| Item | Value |
|---|---|
| Project | `project/`: a small Java library with two classes and their tests |
| Vulnerable dependency | `com.google.guava:guava` 20.0 |
| Vulnerability | CVE-2023-2976 (HIGH) |
| Safe version | 33.7.2-jre |
| Why the upgrade breaks the build | Guava 21 removed `Objects.toStringHelper`, and `Item.java` uses it |
| Expected code change | `Objects.toStringHelper` becomes `MoreObjects.toStringHelper` |
| Reachable vulnerable code | `InventoryExport.java` buffers the CSV export in a `FileBackedOutputStream`, the class of CVE-2023-2976 |

## Before the demo

1. Make sure that Claude Code is logged in. Run `claude` and check that it starts without a login prompt.
2. Make sure that the network is available. The scan uses the Meterian service.
3. Do one full run of the demo before the audience arrives. The script resets the project at each start.
4. Open a terminal with a large font. Make the window wide, because the run output has long lines.
5. Go to the folder of the demo: `cd demos/maven`.

Duration: approximately 10 minutes. Step 4 takes the most time, because the
agent works and Maven builds the project more than one time.

Cost: step 4 calls Claude two times: for the reachability analysis and for
the code change. The limit of one agent task is 2 US dollars. The test runs of
2026-10-23 cost about 0.2 US dollars, and about 0.06 US dollars with
`--no-reachability`.

## Start

```bash
./demo.sh
```

The demo includes the reachability analysis. For a shorter run without it,
start the demo with:

```bash
./demo.sh --no-reachability
```

The script checks the tools and creates the project again in
`demo-repository/`. Then it stops after each step. Press Enter to go to the next step.

## Step 1: a small Java project with a vulnerable dependency

**The screen shows:**
- One commit in the history.
- Guava version 20.0 in `pom.xml`.
- Line 25 of `Item.java`: `Objects.toStringHelper(this)`.

**Say:**
- "This is a normal Java project. It uses Guava 20.0."
- "Guava 20.0 has a known vulnerability."
- "Look at line 25. The code uses `Objects.toStringHelper`. Remember this line."
- "The class `InventoryExport` writes a CSV export into a `FileBackedOutputStream` of Guava. This is the class of the vulnerability."

## Step 2: the project builds and its tests pass

**The screen shows:** `mvn -q test`, and then "Build OK".

**Say:**
- "Before we change anything, the build and the tests pass."
- "Heidi Fix uses these tests later to check each fix."

## Step 3: Heidi Fix plans the remediation

**The screen shows:** `heidi-fix plan .`, with these lines:
- Scan: 3 vulnerabilities.
- Select findings: 1 vulnerability selected.
- Plan: 1 remediation, R1, HIGH, `com.google.guava:guava` 20.0, CVE-2023-2976.

**Say:**
- "`plan` only reads. It changes nothing."
- "The scan finds 3 vulnerabilities. The policy keeps only the HIGH and the CRITICAL ones, so 1 is left."
- "The plan gives one remediation: upgrade Guava."

## Step 4: Heidi Fix fixes the project

**The screen shows:** `heidi-fix run --current-branch --publish local --reachability --verbose .`

**Expected sequence:**
1. Heidi Fix upgrades Guava to the safe version in `pom.xml`.
2. Heidi Fix builds the project and runs the tests. The build fails, because `Objects.toStringHelper` does not exist in the new version.
3. The advanced fixer starts the agent (Claude Code). The agent gets the failure and changes `Item.java`.
4. Heidi Fix builds the project and runs the tests again. They pass.
5. The verifier checks the fix: the vulnerability is gone, no new vulnerability, and no test is removed.
6. Heidi Fix commits the fix on the current branch, `main`. It pushes nothing.

**Say:**
- "First, Heidi Fix tries the simple fix: it only upgrades the version."
- "The build fails. A simple upgrade is not enough here."
- "Now Heidi Fix gives the task to a coding agent, with the error and a budget."
- "The agent does not decide that the fix is good. Heidi Fix builds, tests, and scans again. Only then does it accept the fix."

**The reachability analysis:** before the baseline, the line
`✔ Analyze reachability (agent)` takes about 20 seconds. Then the plan line shows
`R1 REACHABLE: CVE-2023-2976 Conditionally reachable (High)`.

**Say about the reachability analysis:**
- "Before the fix, a coding agent reads the code and tells which vulnerable code the project reaches."
- "Here it finds the call in `InventoryExport`. The vulnerability is real for this project, not only a version number."
- "It is conditionally reachable: Guava writes the temporary file only when an export is larger than the memory limit."
- "Heidi Fix fixes the reachable vulnerabilities first. It does not skip the others."

**Flags to explain, if somebody asks:**
- `--current-branch`: put the fix on the current branch, not on a new fix branch.
- `--publish local`: push nothing and open no pull request.
- `--verbose`: show the details of each step.
- `--reachability`: ask the agent which vulnerable code the project reaches, and fix those vulnerabilities first.

## Step 5: the fix as uncommitted changes

**The screen shows:**
- The history with the fix commit.
- The script removes the commit and keeps the changes in the files.
- `git status --short`: `pom.xml` and `Item.java` are changed.
- `git diff`: the new Guava version, and the code change in `Item.java`.

**Say:**
- "Here is the complete fix: one line in `pom.xml`, and the code change of the agent."
- "In a normal run, Heidi Fix opens a pull request with this change. A person reviews it."

## Step 6: the fixed project builds and its tests pass

**The screen shows:** `mvn -q test`, and then "Build OK".

**Say:**
- "The project uses the safe version of Guava, and the tests pass."

## Questions from the audience

**"Is the agent safe? Can it do anything on my machine?"**
Heidi Fix runs the agent in the `secure` mode by default. Each agent task has a
budget: 2 US dollars, 5 000 000 tokens, and 20 minutes. One run has a total
budget of 20 US dollars. The verifier shows each change outside the expected files.

**"Which agents are supported?"**
Claude Code and Codex. Use `--agent codex` to select Codex.

**"What does a normal run do?"**
Without the demo flags, Heidi Fix puts each fix on its own branch. With a
remote on GitHub, it opens one pull request for each verified fix.

**"Where is the evidence?"**
The last line of each run gives a folder in `~/.heidi-fix/runs/`. The folder
has the log, the evidence of each step, and the telemetry.

## If something goes wrong

- **Step 4 stops with a login error:** Claude Code is not logged in. Run `claude`, log in, and start `./demo.sh` again.
- **Step 3 or step 4 stops with a network error:** the scan needs the Meterian service. Check the network.
- **The build fails with "release version 17 not supported":** Maven uses an older JDK. Set `JAVA_HOME` to a JDK 17 or later.
- **The agent fails or reaches its budget:** Heidi Fix reports the remediation as not remediated. Explain that Heidi Fix does not accept a fix that does not pass the checks.
- **You want to start again:** run `./demo.sh` again. It creates the project again.
