#!/bin/bash
backupfolder="/var/backups/automatic/"
folders="$@"

if [ ! -d "$backupfolder" ]; then
	mkdir -p "$backupfolder"
fi

for f in $folders
do
	if [ ! -d "$f" ]; then
		echo ERROR: "$f" is not a directory or not existing. Skipping...
		continue
	fi

	bakfilename=$(echo "$f" | sed 's,/,_,g')
	datestring=$(date +%F_%H:%M)

	tar -zcpf "$backupfolder""$bakfilename"_"$datestring".tgz "$f"

done
