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
			if [[ "$marker" == "i" ]]; then
				strategy="Incremental"
				echo "$strategy backup started, but no last backup file with marker $suchmarker found. Searching for last fullbackup."
				suchmarker="f"
				lastbackupfile=$(ls -Art "$backupfolder""$suchmarker"*"$bakfilenamefolder".tgz | tail -n 1)
			else
				strategy="Differential"
			fi
			if [[ ! -f "$lastbackupfile" ]]; then
				echo "ERROR: $strategy backup was started, but no file with marker $suchmarker could be found in directory $backupfolder for folder $folder. Skipping!"
				continue
			else
				echo Found last backup file for "$folder": "$lastbackupfile"
			fi
		fi 
	fi
	if [ ! -d "$folder" ]; then
		echo ERROR: "$folder" is not a directory or not existing. Skipping...
		continue
	fi

	if [[ "$marker" == "f" ]]; then
		find "$folder" -type f > tmp.txt
	else
		find "$folder" -type f -newer "$lastbackupfile" > tmp.txt
	fi
	echo Found $(cat tmp.txt | wc -l) new files.

	datestring=$(date +%F_%H:%M)
	
	absoluteBakFile="$backupfolder$marker"_"$datestring""$bakfilenamefolder".tgz

	echo Saving contents of "$folder" in "$absoluteBakFile"
	
	tar -zcpf "$absoluteBakFile" -T tmp.txt
	
	directorySizeKByte=$(du -cs "$folder" | grep -o -e "^[0-9]*" | tail -n 1)
	directorySizeReadable=$(du -hcs "$folder" | egrep -o -e "^[0-9]*(,[0-9]*)?[KMGTPEZY]" | tail -n 1)
	tarSizeKByte=$(du "$absoluteBakFile" | grep -o -e "^[0-9]*")
	tarSizeReadable=$(du -h "$absoluteBakFile" | egrep -o -e "^[0-9]*(,[0-9]*)?[KMGTPEZY]")

	compression=$(bc -l <<< "scale=2; ($directorySizeKByte*100)/$tarSizeKByte-100")

	echo Directory size: "$directorySizeReadable". Tar size: "$tarSizeReadable". Compression: "$compression"%

	rm tmp.txt
done

