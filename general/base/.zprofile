# Linuxes
if [[ $(uname -s) == "Linux" ]]; then
  # Depending on the session type we change GNOME's drun command
  if [ "$XDG_SESSION_TYPE" = "wayland" ] && [ -x "$(command -v dconf)" ]; then
      # Wofi does not open in wayland
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'wofi --show drun'"
  elif [ "$XDG_SESSION_TYPE" = "x11" ] && [ -x "$(command -v dconf)" ]; then
      # Rofi opens in Wayland but bugs out
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'rofi -show combi'"
  fi

fi
