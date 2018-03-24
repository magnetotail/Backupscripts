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

lastbackupfile=$(ls -Art "$backupfolder""$suchmarker"* | tail -n 1)

for f in $folders
do
	if [ ! -d "$f" ]; then
		echo ERROR: "$f" is not a directory or not existing. Skipping...
		continue
	fi

	find "$f" -type f -newer "$lastbackupfile" > tmp.txt

	datestring=$(date +%F_%H:%M)
	
	bakfilename=$(echo "$f" | sed 's,/,_,g')
	
	tar -zcpf "$backupfolder""$marker"_"$datestring"_"$bakfilename".tgz -T tmp.txt
	
	rm tmp.txt
done

