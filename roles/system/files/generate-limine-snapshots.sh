#!/bin/bash
# ArchDev 3.0 - Generate Limine Snapshot Entries
# Atualiza o menu do Limine com os snapshots mais recentes do Snapper

CONFIG="/boot/limine/limine.conf"
TEMP="/tmp/limine_snapshot_entries.conf"
MAX_SNAPSHOTS=3

# Detect base entries
BASE_LINUX=$(awk '/\/Arch Linux \(linux\)/,/^$/' "$CONFIG" | head -4)
BASE_LTS=$(awk '/\/Arch Linux \(linux-lts\)/,/^$/' "$CONFIG" | head -4)

if [[ -z "$BASE_LINUX" ]]; then
    echo "Linux base entry not found."
    exit 1
fi

# Get latest snapshots (ignore snapshot 0)
SNAPSHOTS=$(snapper list | awk 'NR>2 && $1 != "0" {print $1}' | sort -nr | head -n $MAX_SNAPSHOTS)

if [[ -z "$SNAPSHOTS" ]]; then
    echo "No snapshots found."
    exit 0
fi

echo "" > "$TEMP"

for SNAP in $SNAPSHOTS; do
    SNAP_PATH="@/.snapshots/$SNAP/snapshot"

    # Linux entry
    NEW_LINUX=$(echo "$BASE_LINUX" | \
        sed "s#/Arch Linux (linux)#/Arch Linux Snapshot $SNAP (linux)#g" | \
        sed "s#rootflags=subvol=@ #rootflags=subvol=$SNAP_PATH #g")

    echo "$NEW_LINUX" >> "$TEMP"
    echo "" >> "$TEMP"

    # LTS entry (if exists)
    if [[ -n "$BASE_LTS" ]]; then
        NEW_LTS=$(echo "$BASE_LTS" | \
            sed "s#/Arch Linux (linux-lts)#/Arch Linux Snapshot $SNAP (linux-lts)#g" | \
            sed "s#rootflags=subvol=@ #rootflags=subvol=$SNAP_PATH #g")

        echo "$NEW_LTS" >> "$TEMP"
        echo "" >> "$TEMP"
    fi
done

# Remove previous snapshot entries
sed -i '/^\/Arch Linux Snapshot /,/^$/d' "$CONFIG"

# Append new entries
cat "$TEMP" >> "$CONFIG"

echo "✅ Snapshots regenerated (latest $MAX_SNAPSHOTS): $SNAPSHOTS"
