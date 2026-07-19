#!/usr/bin/env bash
# GPU stats for Waybar, emitted as JSON so the module gets a hover tooltip.
# Addressed by PCI slot rather than /sys/class/drm/cardN, whose numbering isn't
# guaranteed stable across reboots; the hwmon dir under it is globbed for the
# same reason.
set -euo pipefail

dev=/sys/bus/pci/devices/0000:2d:00.0
hwmon=("$dev"/hwmon/hwmon*)

busy=$(< "$dev/gpu_busy_percent")
vram_used=$(< "$dev/mem_info_vram_used")
vram_total=$(< "$dev/mem_info_vram_total")
temp=$(< "${hwmon[0]}/temp1_input")
power=$(< "${hwmon[0]}/power1_average")
clock=$(< "${hwmon[0]}/freq1_input")

# Raw sysfs units: bytes, millidegrees C, microwatts, Hz.
awk -v busy="$busy" -v vu="$vram_used" -v vt="$vram_total" \
    -v t="$temp" -v p="$power" -v c="$clock" 'BEGIN {
    printf "{\"text\":\"%s\",\"tooltip\":\"Radeon RX 6900 XT\\nUsage: %s%%\\nVRAM: %.1f / %.1f GiB\\nTemp: %.0f°C\\nPower: %.0f W\\nClock: %.0f MHz\"}\n", \
        busy, busy, vu/1073741824, vt/1073741824, t/1000, p/1000000, c/1000000
}'
