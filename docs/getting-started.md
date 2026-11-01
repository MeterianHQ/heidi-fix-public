# Get started

Read this page if you want to do a first run of Heidi Fix on your computer.

The steps use Linux x64 and the version `v0.1.0-alpha.9`. Heidi Fix
also has programs for Linux arm64 and macOS arm64. See
[Install the program](command-line.md#install-the-program). Before you
start, read [What you need](command-line.md#what-you-need).

## A first run

1. Download, check, and install the program:

   ```bash
   base=https://github.com/MeterianHQ/heidi-fix-public/releases/download/v0.1.0-alpha.9
   curl --fail --location --remote-name "$base/heidi-fix-linux-x64"
   curl --fail --location --remote-name "$base/heidi-fix-linux-x64.sha256"
   sha256sum -c heidi-fix-linux-x64.sha256 &&
     chmod +x heidi-fix-linux-x64 &&
     mkdir -p ~/.local/bin &&
     mv heidi-fix-linux-x64 ~/.local/bin/heidi-fix
   ```

   If the check of the SHA-256 fails, do not use the program.
   Make sure that `~/.local/bin` is in your `PATH`.

2. Log in to an agent. For Claude Code, run `claude auth login`. For Codex,
   run `codex login`.
3. Go to the directory of your repository. The repository must have no
   changes that are not committed.
4. Run Heidi Fix and keep the fixes on your computer:

   ```bash
   heidi-fix run --publish local
   ```

5. Run `git branch --list 'heidi-fix/*'`.

Each branch is one verified fix. Review each branch, and merge the branches
that you accept.

To see the vulnerable dependencies and the planned fixes without a change,
use the command `plan` in step 4, not `run`. This command needs no agent.

The page [Use Heidi Fix on your computer](command-line.md) gives the details
of each step.

## The bundled program

Each release also has a bundled program for each platform. Its file name is
`heidi-fix-<platform>-bundled`, for example `heidi-fix-linux-x64-bundled`.
The bundled program contains Opengrep, the program for the static analysis
(SAST) of your code. The not-bundled program downloads Opengrep at the first SAST
scan. The bundled program never downloads Opengrep.

Use the bundled program on a machine that cannot download from GitHub at run
time.

To install the bundled program, do these steps. The example uses Linux x64
and the version `v0.1.0-alpha.9`:

1. Download the bundled program and its checksum file:

   ```bash
   base=https://github.com/MeterianHQ/heidi-fix-public/releases/download/v0.1.0-alpha.9
   curl --fail --location --remote-name "$base/heidi-fix-linux-x64-bundled"
   curl --fail --location --remote-name "$base/heidi-fix-linux-x64-bundled.sha256"
   ```

2. Check the SHA-256: run `sha256sum -c heidi-fix-linux-x64-bundled.sha256`.
   If the check fails, do not use the program.
3. Run `chmod +x heidi-fix-linux-x64-bundled`.
4. Move the program to a directory of your `PATH` with the name `heidi-fix`:

   ```bash
   mkdir -p ~/.local/bin && mv heidi-fix-linux-x64-bundled ~/.local/bin/heidi-fix
   ```

For linux-arm64 or macos-arm64, replace `linux-x64` with your platform. On
macOS, run `shasum -a 256 -c` for the check. Read the macOS steps in
[Install the program](command-line.md#install-the-program), because of the
quarantine flag.

The bundled program contains Opengrep, which has the license LGPL-2.1. The
release page has three files for this license:

- `opengrep-LICENSE` is the text of the license.
- `opengrep-NOTICE` gives the version, the copyright, the license, and the
  source address of Opengrep.
- `opengrep-<version>-source.tar.gz` is the complete source code of the
  Opengrep version in the bundled program. Check it with its `.sha256` file.

Run `heidi-fix version` to see the license and the source address. The
bundled program prints both.

## Next steps

- [Use Heidi Fix on your computer](command-line.md)
- [The configuration](configuration.md)
- [Common problems](troubleshooting.md)
- [The home page](../README.md)
