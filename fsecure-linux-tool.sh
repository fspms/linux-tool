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

     if [ "$OPTION" = "01" ]; then
       # distri=$(lsb_release -is)
	
	filename="/etc/os-release"
        while read -r ligne
        do
        catname=$(echo $ligne|cut -d"=" -f1)
        if [ "$catname" = "ID" ]; then
	distri=$(echo $ligne|cut -d"=" -f2)
	fi
	done < "$filename"
	

        if [ "$distri" = "centos" ] || [ "$distri" = '"centos"' ]
        then
        echo "centoS";
		yum update
		yum install libstd++.i686 -y
		yum install wget -y
		yum install net-tools -y
		cd /tmp/
           	rm -f /tmp/fspm*
           	wget -t 5 $rpmlinkfspmaua
           	wget -t 5 $rpmlinkfspms
              	#check bdd
           	if [ -e /var/opt/f-secure/fspms/data/h2db/fspms.h2.db ]; then
		reup=1
           	/etc/init.d/fspms stop
		NOW=$(date +"%m-%d-%Y-%T")
	   	cp /var/opt/f-secure/fspms/data/h2db/fspms.h2.db /var/opt/f-secure/fspms/data/backup/fspms.$NOW.h2.db
           	/etc/init.d/fspms start
		else
		reup=0
           	fi
           	#install
           	rpm -i /tmp/$vrpmfspmaua
           	rpm -i /tmp/$vrpmfspms
           	#suppression des paquets
           	rm -f /tmp/fspm*  
		if [ "$reup" = 1 ]; then
		/etc/init.d/fspms stop
		/opt/f-secure/fspms/bin/fspms-db-maintenance-tool
		fi
		/etc/init.d/fspms start
		/opt/f-secure/fspms/bin/fspms-config
		
        elif [ "$distri" = "Fedora" ]
        then
        echo "Fedora";
        # Do that
        elif [ "$distri" = "debian" ] || [ "$distri" = "ubuntu" ]
        then
        echo "Debian or Ubuntu";

           apt-get update
           dpkg --add-architecture i386
           apt-get update
           apt-get install libstdc++5 libstdc++5:i386 libstdc++6 libstdc++6:i386
           cd /tmp/
	   rm -f /tmp/fspm*
           wget -t 5 $deblinkfspmaua
           wget -t 5 $deblinkfspms
           #check service fspms
           #check bdd
           if [ -e /var/opt/f-secure/fspms/data/h2db/fspms.h2.db ]; then
	   reup=1
           /etc/init.d/fspms stop
	   NOW=$(date +"%m-%d-%Y-%T")
	   cp /var/opt/f-secure/fspms/data/h2db/fspms.h2.db /var/opt/f-secure/fspms/data/backup/fspms.$NOW.h2.db
           /etc/init.d/fspms start
	   else
	   reup=0
           fi
           #install
           dpkg -i /tmp/fspmaua_*
           dpkg -i /tmp/fspms_*
           #suppression des paquets
           rm /tmp/fspm*  
	   if [ "$reup" = 1 ]; then
	   /etc/init.d/fspms stop
	   /opt/f-secure/fspms/bin/fspms-db-maintenance-tool
	   fi
	   /etc/init.d/fspms start
	   /opt/f-secure/fspms/bin/fspms-config
        else
        echo "Unsupported Operating System";
        fi
    fi



else
sleep 1
exit 0
fi
done
