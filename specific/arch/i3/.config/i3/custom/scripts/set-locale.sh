#!/bin/bash

if [ command -v setxkbmap &>/dev/null ]; then
    echo "[i3-custom-scripts][set-locale] setting keyboard locale to US-INTL"|systemd-cat -p info
    setxkbmap -layout us -var
fi

COMPOSE_FILE='/usr/share/X11/locale/en_US.UTF-8/Compose'
GTK2_FILE='/usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules.cache'
GTK3_FILE='/usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache'
ENV_FILE='/etc/environment'

# Fixing cedilla in Compose
if [ -f $COMPOSE_FILE ]; then
    echo "[i3-custom-scripts][set-locale] found .XCompose file, fixing ç" | systemd-cat -p info
    sudo cp ${COMPOSE_FILE} ${COMPOSE_FILE}.bak
    sudo sed --in-place -e 's/ć/ç/g' ${COMPOSE_FILE}
    sudo sed --in-place -e 's/Ć/Ç/g' ${COMPOSE_FILE}
fi

GTK_FILE_SEARCH_FOR='^"cedilla".*:en'
GTK_FILE_SED_EXP='s/^\(\"cedilla\".*:wa\)/\1:en/g'
# Fixing cedilla in GTK files
if [ -f $GTK2_FILE ]; then
    echo "[i3-custom-scripts][set-locale] found GTK2 file, fixing ç" | systemd-cat -p info
    sudo cp ${GTK2_FILE} ${GTK2_FILE}.bak
    grep -q ${GTK_FILE_SEARCH_FOR} ${GTK2_FILE}
    [ $? -eq 1 ] && sudo sed --in-place -e ${GTK_FILE_SED_EXP} ${GTK2_FILE}
fi

if [ -f $GTK3_FILE ]; then
    echo "[i3-custom-scripts][set-locale] found GTK3 file, fixing ç" | systemd-cat -p info
    sudo cp ${GTK3_FILE} ${GTK3_FILE}.bak
    grep -q ${GTK_FILE_SEARCH_FOR} ${GTK3_FILE}
    [ $? -eq 1 ] && sudo sed --in-place -e ${GTK_FILE_SED_EXP} ${GTK3_FILE}
fi

# Fixing cedilla in environment file
ENV_FILE_GTK_LINE='GTK_IM_MODULE=cedilla'
ENV_FILE_QT_LINE='QT_IM_MODULE=cedilla'

grep -q ${ENV_FILE_GTK_LINE} ${ENV_FILE}
[ $? -eq 1 ] && echo ${ENV_FILE_GTK_LINE} | sudo tee -a ${ENV_FILE} > /dev/null
grep -q ${ENV_FILE_QT_LINE} ${ENV_FILE}
[ $? -eq 1 ] && echo ${ENV_FILE_QT_LINE} | sudo tee -a ${ENV_FILE} > /dev/null

