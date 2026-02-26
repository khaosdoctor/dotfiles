#!/usr/bin/env bash
# Generates the audio output menu XML and sink mapping file for waybar.
# Run this at login or whenever audio devices change.

DIR="$HOME/.config/waybar"
XML_FILE="$DIR/audio_menu.xml"
MAP_FILE="$DIR/.audio-sinks"

# Collect sinks: name\tdescription
sinks=()
while IFS=$'\t' read -r name desc; do
    sinks+=("$name"$'\t'"$desc")
done < <(pactl list sinks | awk '
    /^\tName:/ { name=$2 }
    /^\tDescription:/ { sub(/^\tDescription: /, ""); print name "\t" $0 }
')

# Write mapping file (one sink name per line, 0-indexed)
: > "$MAP_FILE"
for entry in "${sinks[@]}"; do
    echo "${entry%%$'\t'*}" >> "$MAP_FILE"
done

# Generate XML
cat > "$XML_FILE" <<'HEADER'
<?xml version="1.0" encoding="UTF-8"?>
<interface>
  <object class="GtkMenu" id="menu">
HEADER

for i in "${!sinks[@]}"; do
    IFS=$'\t' read -r name desc <<< "${sinks[$i]}"
    cat >> "$XML_FILE" <<EOF
    <child>
      <object class="GtkMenuItem" id="device${i}">
        <property name="label">${desc}</property>
      </object>
    </child>
EOF
done

cat >> "$XML_FILE" <<'FOOTER'
  </object>
</interface>
FOOTER
