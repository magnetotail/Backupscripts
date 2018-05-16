#!/bin/bash
logfile="/var/log/autobkp.log"
backupfolder="/var/backups/automatic/"
suchmarker="f"
marker="f"
argCount=0
diffCronTabFile="/etc/cron.d/diffhnbkbackup"
incCronTabFile="/etc/cron.d/inchnbkbackup" 

if [ "$EUID" -ne "0" ]
then
	echo "Please run as root"
	exit
fi

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

croncommand="30 10 * * 1 root bash /usr/bin/hnbkbackupscript.sh"
cronparms=" "

# copy a file to /etc/cron.d


exit
