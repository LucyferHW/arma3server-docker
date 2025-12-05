#!/bin/bash

mods_directory=$1

# Wechsel in das Zielverzeichnis
cd ${mods_directory} || { echo "Fehler: Verzeichnis nicht gefunden!"; exit 1; }

# Umbenennen von Dateien und Ordnern (Großbuchstaben → Kleinbuchstaben)
find . -depth -name '*[A-Z]*' | while IFS= read -r file; do
    new_name="$(dirname "$file")/$(basename "$file" | tr 'A-Z' 'a-z')"

    # Falls der Name sich nicht ändert, überspringen
    if [ "$file" != "$new_name" ]; then
        # Falls die Datei mit Kleinbuchstaben bereits existiert, löschen
        [ -e "$new_name" ] && rm -rf "$new_name"
        mv -v "$file" "$new_name"
    fi
done

cd "/home/arma3server"