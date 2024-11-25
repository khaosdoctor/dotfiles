#!/bin/bash
#
# if [ "$1" == "check" ]; then
#     makoctl mode
# elif [ "$1" == "toggle" ]; then
#     # Toggle DND
#     if [ "$(makoctl mode)" == "dnd" ]; then
#         # OFF
#     makomakoctl mode -s default >/dev/null
#         echo '{ \"text\": \"DND OFF\", \"alt\": \"disabled\", \"class\": \"disabled\" }'
#     else
#         # ON
#     makomakoctl mode -s dnd > /dev/null
#         echo '{ \"text\": \"DND ON\", \"alt\": \"enabled\", \"class\": \"enabled\" }'
#     fi
# fi

# Function to get current DND status
get_status() {
    if [ "$(makoctl mode)" == "dnd" ]; then
        echo "enabled"
    else
        echo "disabled"
    fi
}

# Function to toggle DND mode
toggle_dnd() {
    if [ "$(makoctl mode)" == "dnd" ]; then
        makoctl mode -s default >/dev/null
    else
        makoctl mode -s dnd >/dev/null
    fi
}

# Main logic
if [ "$1" == "toggle" ]; then
    toggle_dnd
    pkill -SIGRTMIN+10 waybar # Replace 10 with your chosen signal number
else
    status=$(get_status)
    echo "{\"text\": \"\", \"tooltip\": \"DND $status\", \"alt\": \"$status\", \"class\": \"dnd-$status\"}" | jq --unbuffered --compact-output
fi
