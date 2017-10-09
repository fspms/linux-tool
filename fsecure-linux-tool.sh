#!/bin/bash

#Variable
hotfix1240="https://download.f-secure.com/corpro/pm_linux/current/fspm-12.40-linux-hotfix-1.zip"

#FSPMS DEB / RPM
deblinkfspmaua="https://download.f-secure.com/corpro/pm_linux/current/fspmaua_9.01.3_amd64.deb"
deblinkfspms="https://download.f-secure.com/corpro/pm_linux/current/fspms_12.40.81151_amd64.deb"
rpmlinkfspmaua="https://download.f-secure.com/corpro/pm_linux/current/fspmaua-9.01.3-1.x86_64.rpm"
rpmlinkfspms="https://download.f-secure.com/corpro/pm_linux/current/fspms-12.40.81151-1.x86_64.rpm"

vdebfspmaua=$(echo $deblinkfspmaua|cut -d"/" -f7)
vrpmfspmaua=$(echo $rpmlinkfspmaua|cut -d"/" -f7)
vrpmfspms=$(echo $rpmlinkfspms|cut -d"/" -f7)


FILE="/tmp/out.$$"
GREP="/bin/grep"
# Only root can use this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

##auto update## 

DIR="$( cd "$( dirname "$0" )" && pwd )"
configfile=$(cat $DIR/.git/config | grep "https://github.com/fspms/linux-tool")

if [ ${#configfile} -gt "1" ]
then

   autoupdate=$(git diff)
   pid=${$}

   ##check update on github##
   gitpull=$(git pull)
   if [ "$gitpull" != "Already up-to-date." ] && [ ${#gitpull} != 0 ]
     then
      whiptail --title "Example Dialog" --msgbox "The script was updated succefully" 8 78
      kill $pid
     fi

   #check if the script has different (local edit)
   if [ -z "$autoupdate" ]
     then
      echo "Up to date"
     else
      whiptail --title "Update" --msgbox "Update available, OK to start" 8 78
      git reset --hard origin/master
      whiptail --title "Update" --msgbox "Mise à jour terminé, le script va s'arrêter" 8 78
      kill $pid
   fi
else
    whiptail --title "Update" --msgbox "You can use this script without Github but updates are disable" 8 78
fi

while [ "$menu" != 1 ]; do

OPTION=$(whiptail --title "F-Secure Linux Tool" --menu "Manage F-Secure Policy Manager for Linux" --fb --cancel-button "Exit" 30 70 10 \
"01" "Install/Reinstall/Update" \
"02" "Port Used" \
"03" "Install HotFix" \
"04" "Check F-secure communication" \
"5" "Database tool (backup, recover and maintenance)"\
"6" "Reset admin password" \
"7" "Check and force database update" \
"8" "FSDIAG" \
"9" "Check services" 3>&1 1>&2 2>&3)
#clear
exitstatus=$?
if [ $exitstatus = 0 ]; then

     
echo "test"

else
sleep 1
exit 0
fi
done
