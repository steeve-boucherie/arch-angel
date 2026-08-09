#!/bin/bash
folder="/var/backups"
if [ ! -d "$folder" ]; then
	echo "${folder} does not exists. Creating it it."
	mkdir "$folder"
else
	echo "${folder} already exists. All well and good !"
fi

mirror_file=/etc/pacman.d/mirrorlist
today=$(date '+%Y%m%d')
echo "Back up current mirror file."
cp "$mirror_file" "${folder}/mirrorlist-${today}.bak"
echo "Fetching new mirrors"
reflector --latest 5 --sort rate --save mirror_file
echo "Done !"
