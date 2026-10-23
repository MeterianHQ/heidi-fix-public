# Demos

Each demo runs Heidi Fix on a small project on your computer. A script shows
each step and stops after it, so you can explain the step to an audience.

| Demo | Command | What it shows |
|---|---|---|
| [maven](maven/README.md) | `heidi-fix run` | A Guava upgrade breaks the build of a Java project. The agent changes the code. The reachability analysis finds the vulnerable code that the project calls. |
| [npm](npm/README.md) | `heidi-fix run` | Heidi Fix fixes 12 vulnerable dependencies of a Node.js service, one by one. The Express upgrade breaks the test, and the agent changes the code. |
| [maven-repair](maven-repair/README.md) | `heidi-fix repair` | A pull request upgrades the corporate parent POM. The code does not compile any more. The agent repairs the code of the branch. |

Each demo folder also has `presenter-notes.md`: what to say at each step, the
questions of the audience, and what to do when something goes wrong.

## What you need

- Linux or macOS, with Bash and Git.
- The Heidi Fix program on the `PATH`. See
  [Install the program](../docs/command-line.md#install-the-program).
- Claude Code, logged in. See
  [Log in to an agent](../docs/command-line.md#log-in-to-an-agent).
- The build tools of the demo: a JDK 17 or later and Maven 3.9 for `maven`
  and `maven-repair`, or Node.js 18 or later and npm for `npm`.
- A network connection. The build tools download the libraries. The scan of
  `maven` and `npm` gets the vulnerability data from the public Meterian
  service. The scan needs no account and no token.

To use another Heidi Fix program, give its path in the variable
`HEIDI_FIX_PROGRAM`, for example
`HEIDI_FIX_PROGRAM=~/bin/heidi-fix ./demo.sh`.

## How the demos work

Each demo folder has these files:

| File | Content |
|---|---|
| `README.md` | What the demo shows, the steps, and the expected result. |
| `presenter-notes.md` | The notes for the person who gives the demo. |
| `demo.sh` | The script of the demo. |
| `project/` | The files of the demo project. |

The files in `project/` have hidden names, for example `pom.xml.sample` and
`dot-gitignore`. So the tools that read the manifests of this repository do
not see the vulnerable dependencies of the demos.

At each start, `demo.sh` deletes the folder `demo-repository/` and creates it
again from `project/`. The script restores the real file names, and makes a
new Git repository with the commits of the demo. So each run starts from the
same state. Git ignores `demo-repository/`.

Heidi Fix puts each fix as a commit in `demo-repository/`. It pushes nothing,
because the demos use `--publish local`.

To start a demo, go to its folder and run the script:

```bash
cd demos/maven
./demo.sh
```

Press Enter to go to the next step.

## The cost

The agent of a demo uses your Claude Code login. With a subscription, the
demo uses a part of your plan. With an API key, it costs money. Each demo
README gives the cost of a test run, as Claude Code reports it. Each agent
task has a limit of 2 US dollars, and one run has a limit of 20 US dollars.
