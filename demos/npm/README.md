# Demo: many npm fixes, and one code change

## What the demo shows

Heidi Fix finds the vulnerable dependencies of a Node.js service and fixes
them one by one. Most fixes are a simple upgrade. One upgrade breaks the test.
A coding agent then changes the code, and the test passes again.

Heidi Fix checks the project after each fix. When a fix also removes other
vulnerable packages, Heidi Fix sees it and does not do the work again.

## The project

| Item | Value |
|---|---|
| Project | A small Express service with one endpoint and one test |
| Main vulnerable dependency | `express` 3.21.2 |
| Safe version of Express | 5.3.0, or the safe version that the scan gives on the day of the demo |
| Why the upgrade breaks the test | Express 4 removed `express.bodyParser()`, and `app.js` uses it |
| Expected code change | `express.bodyParser()` becomes `express.json()` and `express.urlencoded()` |
| Other remediations | Approximately 11, mostly old dependencies of Express 3, for example `qs`, `morgan`, and `body-parser` |

## What you need

See [What you need](../README.md#what-you-need): Heidi Fix, Git, Claude Code,
Node.js 18 or later, and npm.

## Run the demo

```bash
./demo.sh
```

The demo has no reachability analysis by default, so each login gives the
same run. To add the analysis, start the demo with:

```bash
./demo.sh --reachability
```

With the analysis, Heidi Fix fixes the reachable dependencies first. Express
comes early, so its upgrade removes most of the other vulnerable packages. A
test run of 2026-10-23 gave "3 published, 9 fixed by an earlier fix". The
analysis took 2.5 minutes.

## The steps

| Step | Command | Expected result |
|---|---|---|
| 1 | `git log`, `grep` | One commit. Express 3.21.2 in `package.json`. `express.bodyParser()` on line 5 of `app.js`. |
| 2 | `npm ci`, `npm test` | The test passes. |
| 3 | `heidi-fix plan .` | Approximately 12 remediations, the most urgent first. `plan` changes nothing. |
| 4 | `heidi-fix run --current-branch --publish local --reachability=off --verbose .` | Each remediation is fixed. The Express upgrade breaks the test, and the agent changes `app.js`. |
| 5 | `git reset`, `git diff` | The fixes as uncommitted changes: the new versions in `package.json`, and the change in `app.js`. |
| 6 | `npm ci`, `npm test` | The fixed service passes its test. |

For each remediation in step 4, Heidi Fix does these steps:

1. It upgrades the dependency.
2. It runs the tests.
3. When the tests pass, the verifier checks the fix, and Heidi Fix commits it.
4. When the tests fail, the advanced fixer starts the agent, Claude Code. The
   agent changes the code. Then Heidi Fix runs the tests again.

The upgrade of Express also removes old packages, for example `body-parser`
and `multiparty`. Heidi Fix sees this in the scan after the Express fix. The
console shows these remediations as "fixed by an earlier fix". A test run of
2026-10-23 gave "10 published, 2 fixed by an earlier fix".

The results of the scan come from the vulnerability data of the day. Another
day can give other numbers and another order of the remediations.

## Duration and cost

The demo takes approximately 10 minutes. Step 4 takes 1 to 2 minutes.

Step 4 calls Claude one time, for Express. A test run of 2026-10-23 cost
about 0.05 US dollars. With `--reachability`, it cost about 0.8 US dollars.

## Notes for the presenter

See [presenter-notes.md](presenter-notes.md).
