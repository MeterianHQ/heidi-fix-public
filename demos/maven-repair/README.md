# Demo: repair a pull request after an upgrade

> **This demo needs the command `heidi-fix repair`.** The first release after
> 0.1.0-alpha.7 has it. With an older program, `demo.sh` stops and tells you
> to install a newer release.

## What the demo shows

A pull request upgrades a library, and the code does not compile any more.
The upgrade is not in the project: the pull request changes the version of
the corporate parent POM, and the new parent manages a new Guava version. The
diff of the pull request shows no library.

The command `heidi-fix repair` repairs the code on the branch of the pull
request. The base branch is the baseline for the build and the tests. A coding
agent changes the code. An algorithm, not the agent, decides if the repair is
verified.

## The project

| Item | Value |
|---|---|
| Project | A small Java library: the class `Item` and its test |
| Base branch | `main`: the parent `com.example:corporate-parent` 1.0.0 |
| Branch of the pull request | `upgrade-corporate-parent`: the parent 2.0.0 |
| Corporate Maven repository | `repository/`, a file repository with the two parent POMs |
| Upgraded library | `com.google.guava:guava` 20.0 → 33.7.2-jre, managed by the parent |
| Why the build fails | Guava 21 removed `Objects.toStringHelper`, and `Item.java` uses it |
| Expected code change | `Objects.toStringHelper` becomes `MoreObjects.toStringHelper` |

`demo.sh` makes the commit of `main` from `project/`. Then it makes the branch
`upgrade-corporate-parent`, with the change of `upgrade.patch`: one line in
`pom.xml`.

## What you need

See [What you need](../README.md#what-you-need): Heidi Fix with the command
`repair`, Git, Claude Code, a JDK 17 or later, and Maven 3.9. The command
`repair` does not use the Meterian service. Maven reads the dependency trees
on your computer.

## Run the demo

```bash
./demo.sh
```

## The steps

| Step | Command | Expected result |
|---|---|---|
| 1 | `git log`, `git diff main` | Two commits. The pull request changes only the parent version, 1.0.0 → 2.0.0. |
| 2 | `grep` | The parent 1.0.0 manages Guava 20.0. The parent 2.0.0 manages Guava 33.7.2-jre. Line 17 of `Item.java` uses `Objects.toStringHelper`. |
| 3 | `mvn -q test` | The build of the branch fails: `Item.java:[17,23] cannot find symbol`. |
| 4 | `heidi-fix repair --base main --publish local --verbose .` | Heidi Fix finds the Guava upgrade. The agent changes `Item.java`. The verifier accepts the repair. |
| 5 | `git log`, `git show` | The repair is one commit on top of the commit of the pull request. |
| 6 | `mvn -q test` | The repaired branch builds, and its tests pass. |

In step 4, Heidi Fix does these steps:

1. It finds the base: the merge base of the branch with `main`.
2. It builds `main` and runs its tests. This is the baseline.
3. It reads the resolved dependency trees of `main` and of the branch, and
   compares them. It finds `guava: 20.0 → 33.7.2-jre`, and the new libraries
   that Guava 33 brings. So a change in a parent POM is not a problem.
4. It builds the branch without a change. The build fails.
5. The advanced fixer gives the failure and the upgrade to the agent, Claude
   Code. The agent changes `Item.java`.
6. Heidi Fix builds the branch and runs the tests again. They pass.
7. The verifier checks the repair. No test is removed. Guava stays at the new
   version. The line that the pull request adds to `pom.xml` does not change.
8. Heidi Fix commits the repair on the branch of the pull request.

When the branch already passes, no agent runs. The console shows "The branch
passes. Nothing to repair", and the exit code is 0.

## Duration and cost

The demo takes approximately 5 minutes. Step 4 takes less than 1 minute.

Step 4 calls Claude one time. A test run of 2026-10-23 cost about 0.07 US
dollars.

## If step 3 shows "Build OK"

Maven keeps a copy of the parent POM in
`~/.m2/repository/com/example/corporate-parent`. An old copy can give another
Guava version. Delete this folder, and start `./demo.sh` again.

## Notes for the presenter

See [presenter-notes.md](presenter-notes.md).
