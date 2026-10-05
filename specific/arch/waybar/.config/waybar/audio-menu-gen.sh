#!/usr/bin/env bash
# Generates the audio menu XML (outputs + inputs) and output/input mapping files for waybar.
# The current default output and input are shown with a radio marker.
# audio-menu-watch.sh runs this whenever audio devices change.

DIR="$HOME/.config/waybar"
XML_FILE="$DIR/audio_menu.xml"

# Prints name\tdescription for each sink/source, skipping sink monitors
list_devices() {
    pactl list "$1" | awk '
        /^\tName:/ { name=$2 }
        /^\tDescription:/ { sub(/^\tDescription: /, ""); if (name !~ /\.monitor$/) print name "\t" $0 }
    '
}

label() {
    cat >> "$XML_FILE" <<EOF
    <child>
      <object class="GtkMenuItem">
        <property name="label">$1</property>
        <property name="sensitive">False</property>
      </object>
    </child>
EOF
}

# Writes menu items with ids <kind>0..N and the 0-indexed .audio-<kind>s mapping file
items() {
    local kind="$1" pactl_kind="$2" i=0 active
    local map_file="$DIR/.audio-${kind}s"
    local default
    default=$(pactl "get-default-${pactl_kind}")
    : > "$map_file"
    while IFS=$'\t' read -r name desc; do
        echo "$name" >> "$map_file"
        active=False
        [[ "$name" == "$default" ]] && active=True
        cat >> "$XML_FILE" <<EOF
    <child>
      <object class="GtkCheckMenuItem" id="${kind}${i}">
        <property name="label">${desc}</property>
        <property name="draw-as-radio">True</property>
        <property name="active">${active}</property>
      </object>
    </child>
EOF
        i=$((i + 1))
    done < <(list_devices "${pactl_kind}s")
}

cat > "$XML_FILE" <<'HEADER'
<?xml version="1.0" encoding="UTF-8"?>
<interface>
  <object class="GtkMenu" id="menu">
HEADER

label "Outputs"
items output sink

cat >> "$XML_FILE" <<'SEPARATOR'
    <child>
      <object class="GtkSeparatorMenuItem"/>
    </child>
SEPARATOR

label "Inputs"
items input source

cat >> "$XML_FILE" <<'FOOTER'
  </object>
</interface>
FOOTER
