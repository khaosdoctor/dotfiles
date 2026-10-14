# macOS non-stowable scripts

These scripts run on macOS but are never linked into `$HOME`. The installer skips every folder named `non-stowable` when it stows packages (`installer/main.go`).

## one-time-commands

These set macOS defaults you only need once per machine. `run-one-time-commands.sh` runs them all and then creates `~/.one-time-commands-run`, so it exits right away on later runs. `.zshrc` calls it on every macOS shell start, and the installer offers to run it too. If you want to apply them again, delete `~/.one-time-commands-run`.

| Script | Does |
| --- | --- |
| `default-screenshots-jpg.sh` | Saves screenshots as JPG instead of PNG |
| `disable-disk-warning.sh` | Turns off the "disk not ejected properly" notification (needs `sudo`) |
| `link-1password-agent-socket.sh` | Symlinks the 1Password SSH agent socket to `~/.1password/agent.sock`, the path `.exports` uses for `SSH_AUTH_SOCK` and git signing |
| `make-dock-instant-appear.sh` | Removes the Dock autohide delay and speeds up its animation |
| `make-hidden-transparent.sh` | Shows hidden apps as translucent icons in the Dock |

To add a one-time command, write its script here and call it from `run-one-time-commands.sh`.

## utils

You run these by hand whenever you need them. [utils/README.md](utils/README.md) lists them.
