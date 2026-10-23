# Demo: an upgrade breaks a Maven build

## What the demo shows

Heidi Fix finds a vulnerable dependency in a Java project and upgrades it.
The upgrade breaks the build. A coding agent then changes the code, and the
build passes again.

The demo also shows the reachability analysis. Before the fix, the agent
reads the code and tells which vulnerable code the project calls.

Heidi Fix uses the coding agent only for the tasks that need one. An
algorithm, not the agent, decides if a fix is verified.

## The project

| Item | Value |
|---|---|
| Project | A small Java library: the classes `Item` and `InventoryExport`, and their tests |
| Vulnerable dependency | `com.google.guava:guava` 20.0 |
| Vulnerability | CVE-2023-2976 (HIGH) |
| Safe version | 33.7.2-jre, or the safe version that the scan gives on the day of the demo |
| Why the upgrade breaks the build | Guava 21 removed `Objects.toStringHelper`, and `Item.java` uses it |
| Expected code change | `Objects.toStringHelper` becomes `MoreObjects.toStringHelper` |
| Reachable vulnerable code | `InventoryExport.java` writes the CSV export to a `FileBackedOutputStream`, the class of CVE-2023-2976 |

## What you need

See [What you need](../README.md#what-you-need): Heidi Fix, Git, Claude Code,
a JDK 17 or later, and Maven 3.9.

## Run the demo

```bash
./demo.sh
```

To skip the reachability analysis, and make the run shorter:

```bash
./demo.sh --no-reachability
```

## The steps

| Step | Command | Expected result |
|---|---|---|
| 1 | `git log`, `grep` | One commit. Guava 20.0 in `pom.xml`. `Objects.toStringHelper` on line 25 of `Item.java`. |
| 2 | `mvn -q test` | The build and the tests pass. |
| 3 | `heidi-fix plan .` | One remediation, R1: Guava, HIGH, CVE-2023-2976. `plan` changes nothing. |
| 4 | `heidi-fix run --current-branch --publish local --reachability --verbose .` | R1 is reachable. The upgrade breaks the build. The agent changes `Item.java`. The build passes, and the verifier accepts the fix. |
| 5 | `git reset`, `git diff` | The fix as uncommitted changes: the new version in `pom.xml`, and the change in `Item.java`. |
| 6 | `mvn -q test` | The fixed project builds, and its tests pass. |

In step 4, Heidi Fix does these steps:

1. It asks the agent which vulnerable code the project reaches. The plan line
   shows `R1 REACHABLE: CVE-2023-2976 Conditionally reachable (High)`.
2. It upgrades Guava in `pom.xml`.
3. It builds the project and runs the tests. The build fails.
4. The advanced fixer gives the failure to the agent, Claude Code. The agent
   changes `Item.java`.
5. Heidi Fix builds the project and runs the tests again. They pass.
6. The verifier scans the project again. The vulnerability is gone, no new
   vulnerability comes, and no test is removed.
7. Heidi Fix commits the fix on the current branch, `main`.

The results of the scan come from the vulnerability data of the day. Another
day can give other numbers.

## Duration and cost

The demo takes approximately 10 minutes. Step 4 takes the most time.

Step 4 calls Claude two times: one time for the reachability analysis and one
time for the code change. A test run of 2026-10-23 cost about 0.2 US dollars.
With `--no-reachability`, it cost about 0.06 US dollars.

## Notes for the presenter

See [presenter-notes.md](presenter-notes.md).
