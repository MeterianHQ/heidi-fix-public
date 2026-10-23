# Presenter notes: Heidi Fix repairs a pull request (Maven)

## The message of the demo

A pull request upgrades a library. Here the upgrade is not in the project: the
pull request changes the version of the corporate parent POM, and the new
parent manages a new Guava. The code does not compile any more.

`heidi-fix repair` repairs the code on the branch of the pull request. The
default branch is the baseline for the build and the tests. A coding agent
changes the code. An algorithm, not the agent, makes the final decision to
accept the repair.

## The project

| Item | Value |
|---|---|
| Project | `project/`: a small Java library with one class and its test |
| Base branch | `main`: the parent `com.example:corporate-parent` 1.0.0 |
| Branch of the pull request | `upgrade-corporate-parent`: the parent 2.0.0 |
| Corporate Maven repository | `repository/`: a file repository with the two parent POMs |
| Upgraded library | `com.google.guava:guava` 20.0 → 33.7.2-jre, managed by the parent |
| Why the build fails | Guava 21 removed `Objects.toStringHelper`, and `Item.java` uses it |
| Expected code change | `Objects.toStringHelper` becomes `MoreObjects.toStringHelper` |

## Before the demo

1. Make sure that Claude Code is logged in. Run `claude` and check that it starts without a login prompt.
2. Do one full run of the demo before the audience arrives. The script resets the project at each start.
3. Open a terminal with a large font. Make the window wide, because the run output has long lines.
4. Go to the folder of the demo: `cd demos/maven-repair`.

Duration: approximately 5 minutes. Step 4 takes the most time.

Cost: step 4 calls Claude one time. A test run of 2026-10-23 cost about 0.07
US dollars.

The command `repair` does not use the Meterian service. It reads the
dependency trees with Maven on this machine.

## Start

```bash
./demo.sh
```

The script checks the tools and creates the project again in
`demo-repository/`, with the branch of the pull request. Then it stops after each step. Press Enter to
go to the next step.

## Step 1: a pull request upgrades the corporate parent POM

**The screen shows:**
- Two commits: `Inventory library` on `main`, and `Upgrade the corporate parent to 2.0.0` on the branch.
- The diff of the pull request: one line in `pom.xml`, the parent version 1.0.0 → 2.0.0.

**Say:**
- "This pull request changes one line: the version of the corporate parent POM."
- "The diff does not show a library. The parent is not part of this repository."

## Step 2: the new parent manages a new Guava version

**The screen shows:** the Guava version in the two parent POMs (20.0 and 33.7.2-jre), and line 17 of `Item.java`: `Objects.toStringHelper(this)`.

**Say:**
- "The parent 2.0.0 manages Guava 33.7.2. So the pull request upgrades Guava from 20.0, but nobody sees it in the diff."
- "Look at line 17. The code uses `Objects.toStringHelper`. Guava 21 removed it."

## Step 3: on the branch, the build fails

**The screen shows:** `mvn -q test`, the error `Item.java:[17,23] cannot find symbol`, and then "Build FAILED".

**Say:**
- "This is the situation in the pipeline of the pull request: the build is red."

## Step 4: Heidi Fix repairs the code of the branch

**The screen shows:** `heidi-fix repair --base main --publish local --verbose .`

**Expected sequence:**
1. `Preflight (base)`: the base is `main`, at the merge base with the branch.
2. `Validate (test-suite)`: the baseline. Heidi Fix builds `main` and runs its tests: 1 test.
3. `Read dependencies` two times, then `1 upgraded, 5 new, 0 removed`. Heidi Fix compares the resolved dependency trees of `main` and of the branch. It finds the Guava upgrade, and the new libraries that Guava 33 brings.
4. `R1 repair ...`: attempt 1 validates the branch without a change. The build fails.
5. The advanced fixer starts the agent (Claude Code). The agent gets the failure and the upgrade, and changes `Item.java`.
6. Heidi Fix builds the project and runs the tests again. They pass.
7. The verifier checks the repair: the build and the tests pass, no test is removed, the upgraded Guava stays, and the lines of the pull request in `pom.xml` do not change.
8. Heidi Fix commits the repair on the branch of the pull request. It pushes nothing.

**Say:**
- "Heidi Fix finds the upgrade itself. It compares the resolved dependencies, so a change in a parent POM is not a problem."
- "The default branch is the baseline: the same tests must pass after the repair."
- "The agent cannot accept its own work. Heidi Fix builds, tests, and checks the repair. The repair cannot go back to the old Guava, and cannot change the line of the pull request."

**Flags to explain, if somebody asks:**
- `--base main`: the base branch. Without it, Heidi Fix uses `GITHUB_BASE_REF`, else the default branch of the remote.
- `--publish local`: push nothing and open no pull request. With `--publish git-push`, Heidi Fix pushes the commit to the branch of the pull request. With `--publish github`, it opens a pull request into that branch.
- `--verbose`: show the details of each step.
- `--upgrade maven:com.google.guava:guava:33.7.2-jre`: give the upgraded library, in place of the comparison of the trees.

## Step 5: the repair is one commit on the branch of the pull request

**The screen shows:**
- The history: the repair commit on top of the commit of the pull request.
- `git show --stat HEAD`: normally only `Item.java` changes.
- The diff: the code change of the agent.

**Say:**
- "The repair is one commit on the branch of the pull request. The reviewer of the pull request sees it."
- "The pull request keeps its upgrade. Only the code changes."

## Step 6: the repaired branch builds and its tests pass

**The screen shows:** `mvn -q test`, and then "Build OK".

**Say:**
- "The branch uses the new parent and the new Guava, and the build is green again."

## Questions from the audience

**"What if the branch already passes?"**
No agent runs. The console shows "The branch passes. Nothing to repair", and the exit code is 0.

**"Is the agent safe? Can it do anything on my machine?"**
Heidi Fix runs the agent in the `secure` mode by default. Each agent task has a
budget: 2 US dollars, 5 000 000 tokens, and 20 minutes.

**"What if the pull request removes tests?"**
A repair that runs fewer tests than the base branch is rejected. The setting
`verifier.allow-test-removal: true` in `~/.heidi-fix/config.yml` allows it.

**"Where is the evidence?"**
The last line of the run gives a folder in `~/.heidi-fix/runs/`. The folder
has the log, the report, `base.txt`, `upgrades.json`, and the evidence of each step.

## If something goes wrong

- **Step 3 shows "Build OK":** Maven uses an old copy of the parent in `~/.m2/repository/com/example/corporate-parent`. Delete this folder and start `./demo.sh` again.
- **Step 4 stops with a login error:** Claude Code is not logged in. Run `claude`, log in, and start `./demo.sh` again.
- **The build fails with "release version 17 not supported":** Maven uses an older JDK. Set `JAVA_HOME` to a JDK 17 or later.
- **The agent fails or reaches its budget:** Heidi Fix reports the repair as not remediated, and the exit code is 1. Explain that Heidi Fix does not accept a repair that does not pass the checks.
- **You want to start again:** run `./demo.sh` again. It creates the project again.
