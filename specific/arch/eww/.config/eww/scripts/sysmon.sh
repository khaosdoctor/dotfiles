#!/bin/bash
field="${1:-cpu}"

case "$field" in
  cpu)
    awk '/^cpu / {u=$2+$4; t=$2+$3+$4+$5+$6+$7+$8; printf "%d\n", (u*100/t)}' /proc/stat ;;
  cpu-temp)
    sensors 2>/dev/null | awk '/Tctl/ {gsub(/[+°C]/, "", $2); printf "%.0f°\n", $2}' ;;
  ram)
    free | awk '/Mem:/ {printf "%d\n", ($3/$2)*100}' ;;
  ram-used)
    free -h | awk '/Mem:/ {print $3}' ;;
  ram-total)
    free -h | awk '/Mem:/ {print $2}' ;;
  gpu)
    cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1 || echo "0" ;;
  gpu-temp)
    sensors 2>/dev/null | awk '/edge/ {gsub(/[+°C]/, "", $2); printf "%.0f°\n", $2}' ;;
  gpu-vram)
    used=$(cat /sys/class/drm/card*/device/mem_info_vram_used 2>/dev/null | head -1)
    total=$(cat /sys/class/drm/card*/device/mem_info_vram_total 2>/dev/null | head -1)
    if [ -n "$used" ] && [ -n "$total" ] && [ "$total" -gt 0 ]; then
      printf "%d\n" $(( used * 100 / total ))
    else
      echo "0"
    fi ;;
  disk)
    df / --output=pcent 2>/dev/null | tail -1 | tr -d ' %' ;;
  disk-used)
    df -h / --output=used 2>/dev/null | tail -1 | tr -d ' ' ;;
  disk-total)
    df -h / --output=size 2>/dev/null | tail -1 | tr -d ' ' ;;
  net-name)
    iface=$(ip route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}')
    if [[ "$iface" == wl* ]]; then
      nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '/^yes:/ {print $2}'
    else
      echo "Wired"
    fi ;;
  net-down)
    iface=$(ip route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}')
    r1=$(cat /sys/class/net/"$iface"/statistics/rx_bytes 2>/dev/null)
    sleep 1
    r2=$(cat /sys/class/net/"$iface"/statistics/rx_bytes 2>/dev/null)
    rate=$(( (r2 - r1) / 1024 ))
    if [ "$rate" -ge 1024 ]; then
      awk "BEGIN {printf \"%.1f MB/s\n\", $rate / 1024}"
    else
      printf "%d KB/s\n" "$rate"
    fi ;;
  cpu-temp-num)
    sensors 2>/dev/null | awk '/Tctl/ {gsub(/[+°C]/, "", $2); printf "%.0f\n", $2}' ;;
  gpu-temp-num)
    sensors 2>/dev/null | awk '/edge/ {gsub(/[+°C]/, "", $2); printf "%.0f\n", $2}' ;;
  net-up)
    iface=$(ip route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}')
    t1=$(cat /sys/class/net/"$iface"/statistics/tx_bytes 2>/dev/null)
    sleep 1
    t2=$(cat /sys/class/net/"$iface"/statistics/tx_bytes 2>/dev/null)
    rate=$(( (t2 - t1) / 1024 ))
    if [ "$rate" -ge 1024 ]; then
      awk "BEGIN {printf \"%.1f MB/s\n\", $rate / 1024}"
    else
      printf "%d KB/s\n" "$rate"
    fi ;;
esac
