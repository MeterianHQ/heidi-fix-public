# Get started

Read this page if you want to do a first run of Heidi Fix on your computer.

The steps use Linux x64 and the version `v0.1.0-alpha.7`. Heidi Fix
also has programs for Linux arm64 and macOS arm64. See
[Install the program](command-line.md#install-the-program). Before you
start, read [What you need](command-line.md#what-you-need).

## A first run

1. Download, check, and install the program:

   ```bash
   base=https://github.com/MeterianHQ/heidi-fix-public/releases/download/v0.1.0-alpha.7
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

## Next steps

- [Use Heidi Fix on your computer](command-line.md)
- [The configuration](configuration.md)
- [Common problems](troubleshooting.md)
- [The home page](../README.md)
