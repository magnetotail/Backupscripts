#!/bin/bash
folders="$@"

for f in $folders
do
	bakfilename=$(echo "$f" | sed 's,/,_,g')
	datestring=$(date +%F)

	tar -zcpf /var/backups/"$bakfilename"_"$datestring".tgz "$f"

done
