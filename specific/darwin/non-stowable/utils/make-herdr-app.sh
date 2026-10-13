#!/bin/bash
# Builds ~/Applications/Herdr.app, a launcher that runs herdr-window from .functions
# (herdr in its own Ghostty window), with the herdr logo as its icon. Re-run to rebuild.
set -euo pipefail

app="$HOME/Applications/Herdr.app"
icon="$HOME/.config/herdr/icon.png"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$HOME/Applications"
rm -rf "$app"
osacompile -o "$app" -e 'do shell script "/bin/zsh -ic herdr-window > /dev/null 2>&1"'

mkdir "$tmp/herdr.iconset"
for size in 16 32 128 256 512; do
    sips -z $size $size "$icon" --out "$tmp/herdr.iconset/icon_${size}x${size}.png" > /dev/null
    sips -z $((size * 2)) $((size * 2)) "$icon" --out "$tmp/herdr.iconset/icon_${size}x${size}@2x.png" > /dev/null
done
iconutil -c icns "$tmp/herdr.iconset" -o "$app/Contents/Resources/applet.icns"
# Assets.car holds the default applet icon and wins over applet.icns while CFBundleIconName points at it
rm "$app/Contents/Resources/Assets.car"
/usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" "$app/Contents/Info.plist"
# Swapping resources breaks osacompile's ad-hoc signature, so sign again
codesign --force --sign - "$app"
touch "$app"

echo "built $app"
