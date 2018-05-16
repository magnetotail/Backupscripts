#!/bin/bash
logfile="/var/log/autobkp.log"
backupfolder="/var/backups/automatic/"
suchmarker="f"
marker="f"
argCount=0
CronTabFile="/etc/cron.d/hnbkbackup" 
backupExecutable="/usr/bin/hnbkbackupscript"

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

cronparms="-o=${backupfolder} ${folders}"
basecroncommand="30 10 * * 1 root bash ${backupExecutable}"
fullcron="${basecroncommand} -f ${cronparms}"
basecroncommand="35 10 * * * root bash ${backupExecutable}"
diffinccroncommand="${basecroncommand} -${marker} ${cronparms}"

echo "${fullcron}" > ${CronTabFile}
echo "${diffinccroncommand}" >> ${CronTabFile}

tee -a $logfile <<<  "[$(date +%F_%H:%M:%S)] Writing crontab entries."

cp ./hnbkbackupscript.sh $backupExecutable
chmod +x /usr/bin/hnbkbackupscript

exit
