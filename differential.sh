#!/bin/bash
backupfolder="/var/backups/automatic/"
suchmarker="f"
marker="f"
argCount=0
while getopts "o:idf" opts; do
	case ${opts} in
		o) if [ ! -d "$OPTARG" ]; then
				echo ERROR: $OPTARG is not a directory or not existing. Exiting..
				exit
		fi
		backupfolder=${OPTARG};
		;;
		f) marker="f";
		;;
		i) suchmarker="i";
		marker="i";
		;;
		d) suchmarker="f";
		marker="d";
		;;
	esac
done

if [ -w $backupfolder ]; then
	echo Write permissions are present.
else
	echo No Write permissions for the target folder. Exiting!
	exit
fi

length=${#backupfolder}
last_char=${backupfolder:length-1:1}
[[ $last_char != "/" ]] && backupfolder="$backupfolder/"; :

shift $(($OPTIND-1))
folders="$@"


for folder in $folders
do
	bakfilenamefolder=$(echo "$folder" | sed 's,/,_,g')
	if [[ "$marker" != "f" ]]; then
		lastbackupfile=$(ls -Art "$backupfolder""$suchmarker"*"$bakfilenamefolder".tgz | tail -n 1)
		if [[ ! -f "$lastbackupfile" ]]; then
			success=false
			if [[ "$marker" == "i" ]]; then
				strategy="Incremental"
				echo "$strategy backup started, but no last backup file with marker $suchmarker found. Searching for last fullbackup."
				suchmarker="f"
				lastbackupfile=$(ls -Art "$backupfolder""$suchmarker"*"$bakfilenamefolder".tgz | tail -n 1)
				if [[ -f "$lastbackupfile" ]]; then
					success=true
				fi
			else
				strategy="Differential"
			fi
			if [[ ! $success ]]; then
				echo "ERROR: $strategy backup was started, but no file with marker $suchmarker could be found in directory $backupfolder for folder $folder. Skipping!"
				continue
			fi
		fi 
	fi
	echo Found last backup file for "$folder": "$lastbackupfile"
	if [ ! -d "$folder" ]; then
		echo ERROR: "$folder" is not a directory or not existing. Skipping...
		continue
	fi

	if [[ "$marker" == "f" ]]; then
		find "$folder" -type f > tmp.txt
	else
		find "$folder" -type f -newer "$lastbackupfile" > tmp.txt
	fi
	echo found $(cat tmp.txt | wc -l) new files.

	datestring=$(date +%F_%H:%M)
	

	echo Saving contents of "$folder" in "$backupfolder$marker"_"$datestring"_"$bakfilenamefolder".tgz
	
	tar -zcpf "$backupfolder""$marker"_"$datestring"_"$bakfilenamefolder".tgz -T tmp.txt
	
	rm tmp.txt
done

