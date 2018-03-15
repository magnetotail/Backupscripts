#!/bin/bash
backupfolder="/var/backups/automatic/"
argCount=0
while getopts ":o:" opts; do
	case ${opts} in
		o) if [ ! -d "$OPTARG" ]; then
				echo ERROR: $OPTARG is not a directory or not existing. Exiting..
				exit
		fi
		((argCount++))
		backupfolder=${OPTARG};;

	esac
done

shift $(($argCount * 2))
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
