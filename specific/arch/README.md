# Important things

## Changing the default cursor and icons

When changing the default cursors, you can refer to [this](https://wiki.archlinux.org/title/Cursor_themes#Create_links_to_missing_cursors) article on the Arch wiki on how to download and install themes

> Most likely all the themes exist on AUR with yay but you might find some of them are difficult to install because they take a lot of time (like Colloid) then you can download them from GNOME Look.

After installed, they will be in one of those folders

- If installed with YAY: `/usr/share/icons`
- If manually installed locally: `~/.local/share/icons`
- If manually installed for all users (recommended): `/usr/share/icons`

The cursor name can be found on the `index.theme` file in the root folders of each theme in the locations above.

### Setting the themes

You can then set the theme and icons manually by stowing the files inside the `gtk` directory here or manually setting:

```
// ~/.gtkrc2-0
gtk-cursor-theme-name="cursor-theme"
gtk-icon-theme-name="icon-theme"
```

And for GTK 3:

```
// ~/.config/gkt-3.0/settings.ini
[Settings]
gtk-cursor-theme-name="cursor-theme"
gtk-icon-theme-name="icon-theme"
```

#### For QT

For QT applications (telegram, zapzap, others...) there's no way to manually set as they'll fallback to the default one, but there's a way to make it happen with the `.Xresources` file which is also here:

```
! This file controls the theme and sizes of resouces in X server
! such as icons, cursors and so on
! it is loaded in /etc/X11/xinit/xinitrc under $userresources
Xcursor.size: 24
Xcursor.theme: "cursor-name"
```

Then use `xrdb ~/.Xresources`

#### For GNOME and other environments

Set the GNOME icon using XSETTINGS:

```
gsettings set org.gnome.desktop.interface cursor-theme cursor_theme_name
gsettings set org.gnome.desktop.interface icon-theme icon-theme-name
gsettings set org.mate.preripherals-mouse cursor-theme cursor_theme_name
```

You can also use `gnome-tweaks` and `lxappearance` packages to set the themes for the GTK-\* functions

### Fallbacks

If there are any apps that do not follow the icon, you can always take a look at the `/usr/share/icons/default/index.theme` to check whether the theme is inheriting from one of the themes you set. And if you installed the theme globally as well.

## Resetting pipewire and pulse

If you stow the files in the `pipewire` module, you will need to run `systemctl
--user restart pipewire pipewire-pulse wireplumber` to reset the server and then
reopen any clients

## Electron missing input fix

> Wayland only

In some cases, when you have multiple monitors (especially when they use
different DPI settings), Electron has a bug where it cannot communicate with
Wayland due to some `XWayland` black magic. There are [some people](https://askubuntu.com/a/1393619)
who have reported this type of behavior.

Symptoms are:

- Applications that are Electron-based (Code, Discord, Spotify, 1Password,
  Obsidian) will work normally on the main monitor
- When those are moved to the secondary monitor, two things can happen:
  - They will not respond to any input at all
  - They will respond to inputs just on a specific part of the screen

This happens, at least as much as I could research, because of a communication
problem between `XWayland` and Electron. The solution is to force Electron to
use Wayland natively, this is done through either a file in `.config` which
works 50% of the time, but the most effective way is to use [this environment
variable](https://www.electronjs.org/blog/electron-28-0#new-features) called
`ELECTRON_OZONE_PLATFORM_HINT` and set it to either `wayland` or `auto`.

### Env method

The env method is the simplest, and the easiest. You can set them directly in
the `.desktop` files present in `/usr/share/applications`:

1. Copy the `.desktop` for the faulty application from `/usr/share/applications/` to the local user's home in `~/.local/share/applications` (or whatever `XDG_DATA_DIR` is set to your distro)
2. Change the line that says `Exec=<some binary command>` and change to `env
ELECTRON_OZONE_PLATFORM_HINT=wayland <some binary command>`
3. Save and close

You'll need to reopen the apps for this to work.

This is an example desktop file from Code:

```ini
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=env ELECTRON_OZONE_PLATFORM_HINT=auto /usr/bin/discord
Icon=discord
Type=Application
Categories=Network;InstantMessaging;
Path=/usr/bin
```

### Flags

You can set Electron flags in applications that support it as [defined in section 5.9](https://wiki.archlinux.org/title/Wayland#GUI_libraries) of the wiki. Either start the application with the following flags:

```sh
--enable-features=WaylandWindowDecorations
--ozone-platform-hint=auto
```

You can also change the desktop entry of the app to contain these flags. In the `Exec` section, use: `Exec= <the command> --enable-features=WaylandWindowDecorations --ozone-platform=wayland`

#### File

Or create a file under `.config` called `electron-flags.conf` with the same contents:

```sh
--enable-features=WaylandWindowDecorations
--ozone-platform-hint=auto
```

For specific versions of Electron, you can add `electron<version>-flags.conf` instead of omitting the version.

However, this seems not to work in applications that bundle their own electron version, which is pretty hard to figure out.

## Systemd Units

There are a few Systemd units in
[base/.config/systemd/user](./base/.config/systemd/user) that needs to be
enabled. They will all be registered automatically when the dotfiles are
symlinked but they won't be enabled.

You can use `systemctl-tui` to manually enable them all or the traditional
`systemctl --user --enable --now <name>`
