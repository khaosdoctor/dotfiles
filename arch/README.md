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

You can also use `gnome-tweaks` and `lxappearance` packages to set the themes for the GTK-* functions

## Fallbacks

If there are any apps that do not follow the icon, you can always take a look at the `/usr/share/icons/default/index.theme` to check whether the theme is inheriting from one of the themes you set. And if you installed the theme globally as well.
