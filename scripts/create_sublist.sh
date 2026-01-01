#!/bin/bash

html_path=$1
list_path=$2

input="$(find "${html_path}" -type f -name "*.html" -exec readlink -f {} \;)"

echo "Found html in: " $input

array=$(grep "http" "$input" | grep "id" | cut -f2 -d'?' | cut -f1 -d'"' | sed -e "s/id=//")

echo "${array}" >> "$list_path"

sort -u "$list_path" -o "$list_path.tmp"
mv "$list_path.tmp" "$list_path"

echo "Sublist $input created."