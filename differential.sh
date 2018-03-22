#!/bin/bash
#TODO
# Skript schreiben
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
if [[ argCount -gt 0 ]]; then
	shift "(($argCount * 2))"
fi

folders="$@"

lastbackupfile=$(ls -Art "$backupfolder" | tail -n 1)

for f in $folders
do
	if [ ! -d "$f" ]; then
		echo ERROR: "$f" is not a directory or not existing. Skipping...
		continue
	fi

	find "$f" -type f -newer "$backupfolder""$lastbackupfile" > tmp.txt
done

datestring=$(date +%F_%H:%M)

bakfilename=$(echo "$f" | sed 's,/,_,g')

tar -zcpf "$backupfolder""d_""$datestring"_"$bakfilename".tgz -T tmp.txt


