#!/bin/bash

if [ -z "$1" ]; then
    echo "Fehler: Kein Argument Uebergeben."
    echo "Verwendung: $0 <path_to_html> <config_path>"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Fehler: Kein Argument Uebergeben."
    echo "Verwendung: $0 <path_to_html> <config_path>"
    exit 1
fi

html_path="$1"
config_path="$2"

input="$(find "${html_path}" -type f -name "*.html" -exec readlink -f {} \;)"

array=$(grep 'http' "$input" | grep 'id' | cut -f2 -d'?' | cut -f1 -d'"' | sed -e 's/id=//' | sed -e 's/^/mods\//g' | sed -e 's/$/\\;/g' | tr -d '\n' | sed -e 's/\\;$//g')

echo 'mods=''"'"${array}"'"' > "$config_path"

echo "Modlist $input set for server $2."
