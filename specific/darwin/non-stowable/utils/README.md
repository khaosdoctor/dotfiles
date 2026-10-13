# macOS utils

You run these by hand, as often as you need. Nothing runs them automatically.

| Script | Does |
| --- | --- |
| `add-spacer.sh` | Adds a full-width spacer to the Dock's app section and restarts the Dock |
| `add-small-spacer.sh` | Adds a half-width spacer the same way |
| `add-index-to-folders.sh` | Prefixes every folder in the current directory with a number (`1 - name`, `2 - name`, ...) in the order the shell lists them |
| `make-herdr-app.sh` | Builds `~/Applications/Herdr.app`, which opens herdr in its own Ghostty window |

## make-herdr-app.sh

The app runs `zsh -ic herdr-window`, a function from `general/base/.functions`, and uses `~/.config/herdr/icon.png` (stowed from `general/herdr`) as its icon. Run the script again after you change the icon:

```bash
./specific/darwin/non-stowable/utils/make-herdr-app.sh
```
