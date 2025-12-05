#!/bin/bash

steamcmd=$1
modlistpath=$2
user=$3
pass=$4
echo ""
echo "=== Updating Mods ==="

# Alle Mod-IDs in einem einzigen SteamCMD-Aufruf!
mapfile -t mods < "$modlistpath"

# Baue den Befehl dynamisch auf
cmd=( "$steamcmd" +login "$user" "$pass" )
for mod in "${mods[@]}"; do
    [[ -z "$mod" ]] && continue
    cmd+=( +workshop_download_item 107410 "$mod" validate )
done
cmd+=( +quit )

echo "Starte Download von ${#mods[@]} Mod(s) in einem Rutsch..."
"${cmd[@]}"

echo "Download complete!"