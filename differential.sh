#!/bin/bash
logfile="/var/log/autobkp.log"
backupfolder="/var/backups/automatic/"
suchmarker="f"
marker="f"
argCount=0
while getopts "o:idf" opts; do
	case ${opts} in
		o) if [ ! -d "$OPTARG" ]; then
				tee -a $logfile <<<  "[$(date +%F_%H:%M:%S)] ERROR: $OPTARG is not a directory or not existing. Exiting.."
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
	tee -a $logfile <<<  "[$(date +%F_%H:%M:%S)] Write permissions are present."
else
	tee -a $logfile <<<  "[$(date +%F_%H:%M:%S)] No Write permissions for the target folder. Exiting!"
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
			if [[ "$marker" == "i" ]]; then
				strategy="Incremental"
				tee -a $logfile <<<  "[$(date +%F_%H:%M:%S)] $strategy backup started, but no last backup file with marker $suchmarker found. Searching for last fullbackup."
				suchmarker="f"
				lastbackupfile=$(ls -Art "$backupfolder""$suchmarker"*"$bakfilenamefolder".tgz | tail -n 1)
			else
				strategy="Differential"
			fi
			if [[ ! -f "$lastbackupfile" ]]; then
				tee -a $logfile <<<  "[$(date +%F_%H:%M:%S)] ERROR: $strategy backup was started, but no file with marker $suchmarker could be found in directory $backupfolder for folder $folder. Skipping!"
				continue
			else
				tee -a $logfile <<<  "[$(date +%F_%H:%M:%S)] Found last backup file for $folder: $lastbackupfile"
			fi
		fi 
	fi
	if [ ! -d "$folder" ]; then
		tee -a $logfile <<<  "[$(date +%F_%H:%M:%S)] ERROR: $folder is not a directory or not existing. Skipping..."
		continue
	fi

	if [[ "$marker" == "f" ]]; then
		find "$folder" -type f > tmp.txt
	else
		find "$folder" -type f -newer "$lastbackupfile" > tmp.txt
	fi
	tee -a $logfile <<< "[$(date +%F_%H:%M:%S)] Found $(cat tmp.txt | wc -l) new files."

	datestring=$(date +%F_%H:%M)
	
	absoluteBakFile="$backupfolder$marker"_"$datestring""$bakfilenamefolder".tgz

	tee -a $logfile <<< "[$(date +%F_%H:%M:%S)] Saving contents of $folder in $absoluteBakFile"
	
	tar -zcpf "$absoluteBakFile" -T tmp.txt
	
	directorySizeKByte=$(du -cs "$folder" | grep -o -e "^[0-9]*" | tail -n 1)
	directorySizeReadable=$(du -hcs "$folder" | egrep -o -e "^[0-9]*((.|,)[0-9]*)?[KMGTPEZY]" | tail -n 1)
	tarSizeKByte=$(du "$absoluteBakFile" | grep -o -e "^[0-9]*")
	tarSizeReadable=$(du -h "$absoluteBakFile" | egrep -o -e "^[0-9]*((.|,)[0-9]*)?[KMGTPEZY]")

	compression=$(bc -l <<< "scale=2; ($tarSizeKByte*100)/$directorySizeKByte")

	tee -a $logfile <<< "[$(date +%F_%H:%M:%S)] Directory size: $directorySizeReadable. Tar size: $tarSizeReadable. Compression: $compression%"

	rm tmp.txt
done

