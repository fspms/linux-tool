#!/bin/bash

#Variable
hotfix1240="https://download.f-secure.com/corpro/pm_linux/current/fspm-12.40-linux-hotfix-1.zip"

#FSPMS DEB / RPM
deblinkfspmaua="https://download.f-secure.com/corpro/pm_linux/pm_linux12.40/fspmaua_9.01.3_amd64.deb"
deblinkfspms="https://download.f-secure.com/corpro/pm_linux/pm_linux12.40/fspms_12.40.81151_amd64.deb"

deblinkfspms13="https://download.f-secure.com/corpro/pm_linux/current/fspms_13.10.84021_amd64.deb"

rpmlinkfspmaua="https://download.f-secure.com/corpro/pm_linux/pm_linux12.40/fspmaua-9.01.3-1.x86_64.rpm"
rpmlinkfspms="https://download.f-secure.com/corpro/pm_linux/pm_linux12.40/fspms-12.40.81151-1.x86_64.rpm"


rpmlinkfspms13="https://download.f-secure.com/corpro/pm_linux/current/fspms-13.10.84021-1.x86_64.rpm"

vdebfspmaua=$(echo $deblinkfspmaua|cut -d"/" -f7)
vdebfspms=$(echo $deblinkfspms|cut -d"/" -f7)
vdebfspms13=$(echo $deblinkfspms13|cut -d"/" -f7)
vrpmfspmaua=$(echo $rpmlinkfspmaua|cut -d"/" -f7)
vrpmfspms=$(echo $rpmlinkfspms|cut -d"/" -f7)
vrpmfspms13=$(echo $rpmlinkfspms13|cut -d"/" -f7)




lastversion=$(echo $vdebfspms|cut -d"_" -f2)

FILE="/tmp/out.$$"
GREP="/bin/grep"
# Only root can use this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

##auto update## 
#
#DIR="$( cd "$( dirname "$0" )" && pwd )"
DIR="/opt/fspms"
configfile=$(cat $DIR/.git/config | grep "https://github.com/fspms/linux-tool")

#if [ ${#configfile} -gt "1" ]
#then
   
   autoupdate=$(git --work-tree=/opt/fspms/ --git-dir=/opt/fspms/.git diff)
   pid=${$}
	
   #testr=$(git --work-tree=/opt/fspms/ --git-dir=/opt/fspms/.git pull origin master)
   #testrr=$(testr |grep "Already up-to-date")
   #echo $testrr
   
   
   ##check update on github##
gitpull=$(git --work-tree=$DIR --git-dir=$DIR/.git pull origin master)
flag=`echo $gitpull|awk '{print match($0,"fsecure-linux-tool.sh")}'`;
if [ $flag -gt 0 ]; then
        whiptail --title "Auto Update" --msgbox "The script was updated successfully" 8 78
        kill $pid;
else
    echo "fail";
fi

 ##Reset local change
 
#git reset --hard origin/master

   #check if the script has different (local edit)
  # if [ -z "$autoupdate" ]
  #   then
  #    echo "Up to date"
  #   else
  #    whiptail --title "Update" --msgbox "Update available, OK to start" 8 78
	  
  #    cd $DIR && git reset --hard origin/master
   #   whiptail --title "Update" --msgbox "Update successfull, the script will stop" 8 78
   #   kill $pid
  # fi
#else
#    whiptail --title "Update" --msgbox "You can use this script without Github but updates are disable" 8 78
#fi

while [ "$menu" != 1 ]; do

OPTION=$(whiptail --title "F-Secure Linux Tool" --menu "Manage F-Secure Policy Manager for Linux" --fb --cancel-button "Exit" 30 70 10 \
"1" "Install / Update" \
"2" "Port Used" \
"3" "Install HotFix" \
"4" "Check F-secure communication" \
"5" "Database tool" \
"6" "Reset admin password" \
"7" "Check and force database update" \
"8" "FSDIAG" \
"9" "Check services" 3>&1 1>&2 2>&3)
#clear
exitstatus=$?
if [ $exitstatus = 0 ]; then

     
if [ "$OPTION" = "1" ]; then
       
	   chooseVersion=$(whiptail --title "Choose version" --menu "Choose version of Policy Manager" 15 80 5 \
                        "1" "Policy Manager 13.01" \
                        "2" "Policy Manager 12.40 with AUA"$hostweb2 3>&1 1>&2 2>&3)
                        #exitpara=$?
                        #if [ $exitpara = 0 ]; then
	   
	   
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
				if [ $chooseVersion = "1" ]; then
					wget -t 5 $rpmlinkfspms13
				fi
				if [ $chooseVersion = "2" ]; then
					wget -t 5 $rpmlinkfspmaua
					wget -t 5 $rpmlinkfspms
				fi
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
			
			if [ $chooseVersion = "1" ]; then
                rpm -i /tmp/$vrpmfspms13
			fi
			if [ $chooseVersion = "2" ]; then
				rpm -i /tmp/$vrpmfspmaua
                rpm -i /tmp/$vrpmfspms
			fi
			
           	#suppression des paquets
           	rm -f /tmp/fspm*  
		if [ "$reup" = 1 ]; then
		/etc/init.d/fspms stop
		/opt/f-secure/fspms/bin/fspms-db-maintenance-tool
		fi
		/etc/init.d/fspms start
		/opt/f-secure/fspms/bin/fspms-config
		
		#check SE LINUX
		
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
			if [ $chooseVersion = "1" ]; then
					wget -t 5 $deblinkfspms13
				fi
				if [ $chooseVersion = "2" ]; then
					wget -t 5 $deblinkfspmaua
					wget -t 5 $deblinkfspms
				fi
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
		   if [ $chooseVersion = "1" ]; then
					dpkg -i /tmp/$vdebfspms13
				fi
				if [ $chooseVersion = "2" ]; then
					dpkg -i /tmp/$vdebfspmaua
					dpkg -i /tmp/$vdebfspms
				fi

           #suppression des paquets
           rm /tmp/fspm*  
	   if [ "$reup" = 1 ]; then
	   /etc/init.d/fspms stop
	   /opt/f-secure/fspms/bin/fspms-db-maintenance-tool
	   fi
	   chmod +x /etc/init.d/fspms
	   /etc/init.d/fspms start
	   /opt/f-secure/fspms/bin/fspms-config
        else
        echo "Unsupported Operating System";
        fi
    fi





if [ "$OPTION" = "2" ]; then
        echo "======================================="
        echo "====== PORTS F-SECURE FSPMS ==========="
        echo "======================================="
        echo ""

        filename="/etc/opt/f-secure/fspms/fspms.conf"
        while read -r ligne
        do
        NomProtocole=$(echo $ligne|cut -d"=" -f1)

        if [ $NomProtocole = hostModuleHttpsPort ]; then
		hosthttpscp=$ligne
        hosthttps=$NomProtocole
        hosthttps2=$(echo $ligne|cut -d'"' -f2)
        echo "Active HTTPS port : "$hosthttps2
		fi

        if [ $NomProtocole = hostModulePort ]; then
        hostportcp=$ligne
        hostport=$NomProtocole
        hostport2=$(echo $ligne|cut -d'"' -f2)
        echo "Active HTTP port : "$hostport2
		fi

        if [ $NomProtocole = adminModulePort ]; then
        hostadmincp=$ligne
		hostadmin=$NomProtocole
        hostadmin2=$(echo $ligne|cut -d'"' -f2)
        echo "Active admin port (console): "$hostadmin2
		fi

        if [ $NomProtocole = adminExtensionLocalhostRestricted ]; then
        hostrestrictcp=$ligne
		hostrestrict=$NomProtocole
        hostrestrict2=$(echo $ligne|cut -d'"' -f2)
	echo "Local host restricted : "$hostrestrict2
        fi
		
        if [ $NomProtocole = webReportingPort ]; then
        hostwebcp=$ligne
		hostweb=$NomProtocole
        hostweb2=$(echo $ligne|cut -d'"' -f2)
        echo "Active Web Reporting port : "$hostweb2
		fi
        
		done < "$filename"
        echo ""
                        modifpara=$(whiptail --title "Check port" --menu "Choose the port" 15 80 5 \
                        "1" "HTTP port: "$hostport2 \
                        "2" "HTTPS port : "$hosthttps2 \
                        "3" "Admin port : "$hostadmin2 \
                        "4" "Local host restricted : "$hostrestrict2 \
                        "5" "Web Reporting port : "$hostweb2 3>&1 1>&2 2>&3)
                        exitpara=$?
                        if [ $exitpara = 0 ]; then
                           if [ "$modifpara" = "1" ]; then
                                Rehostport=$(whiptail --title "Change config" --inputbox "Choose a new HTTP port : " 10 60 $hostport2 3>&1 1>&2 2>&3)
                                exits=$?
                                if [ $exits = 0 ]; then
                                        remplace=$hostport"="'"'$Rehostport'"'
										sed -i 's/'$hostportcp'/'$remplace'/g' $filename
										/etc/init.d/fspms stop
										/etc/init.d/fspms start
                                else
                                echo "Cancel"
                                fi
							fi
						if [ "$modifpara" = "2" ]; then
                                Rehosthttps=$(whiptail --title "Change HTTPS" --inputbox "Choose a new HTTPS port : " 10 60 $hosthttps2 3>&1 1>&2 2>&3)
                                exits=$?
                                if [ $exits = 0 ]; then
                                        remplace=$hosthttps"="'"'$Rehosthttps'"'
                                        sed -i 's/'$hosthttpscp'/'$remplace'/g' $filename
										/etc/init.d/fspms stop
										/etc/init.d/fspms start
                                else
                                echo "Cancel"
                                fi
                        fi
						if [ "$modifpara" = "3" ]; then
                                Rehostadmin=$(whiptail --title "Change port" --inputbox "Choose a new admin port " 10 60 $hostadmin2 3>&1 1>&2 2>&3)
                                exits=$?
                                if [ $exits = 0 ]; then
                                        remplace=$hostadmin"="'"'$Rehostadmin'"'
										sed -i 's/'$hostadmincp'/'$remplace'/g' $filename
										/etc/init.d/fspms stop
										/etc/init.d/fspms start
                                else
                                echo "Cancel"
                                fi
						fi
						if [ "$modifpara" = "4" ]; then
                                Rehostrestrict=$(whiptail --title "Check port" --menu "Choose the port" 15 80 5 \
						"False" " - You can connect with the remote console" \
						"True" " - You can only use the local console" 3>&1 1>&2 2>&3)
                                exits=$?
                               	if [ $exits = 0 ]; then
									if [ "$Rehostrestrict" = "False" ]; then
                                        remplace=$hostrestrict"="'"false"'
										sed -i 's/'$hostrestrictcp'/'$remplace'/g' $filename
									fi	
										
									if [ "$Rehostrestrict" = "True" ]; then
                                        	remplace=$hostrestrict"="'"true"'
											sed -i 's/'$hostrestrictcp'/'$remplace'/g' $filename
									fi
											/etc/init.d/fspms stop
											/etc/init.d/fspms start
                                else
                                echo "Cancel"
                               	fi
						fi
						if [ "$modifpara" = "5" ]; then
                                Rehostweb=$(whiptail --title "Change port" --inputbox "Choose a new web reporting port " 10 60 $hostweb2 3>&1 1>&2 2>&3)
                                exits=$?
                                if [ $exits = 0 ]; then
                                        remplace=$hostweb"="'"'$Rehostweb'"'
										sed -i 's/'$hostwebcp'/'$remplace'/g' $filename
										/etc/init.d/fspms stop
										/etc/init.d/fspms start
                                else
                                echo "Cancel"
                                fi
						fi
						
                        else
                          echo "Cancel"
                        fi

    fi
if [ "$OPTION" = "4" ]; then
        echo "======================================="
        echo "========== CHECK SERVRS =============="
        echo "======================================="
        echo ""
    echo 'please wait'

     xmlshavlik=$(host -W1 xml.shavlik.com)
     xmlshavlikf=$(echo $xmlshavlik |grep "NXDOMAIN\|timed out")

     avanti=$(host -W1 xml.avanti.com)
     avantif=$(echo $avanti | grep "NXDOMAIN\|timed out")

     orsp=$(host -W1 orsp.f-secure.com)
     orspf=$(echo $orsp | grep "NXDOMAIN\|timed out")

     fsecure=$(host -W1 f-secure.com)
     fsecuref=$(echo $fsecure | grep "NXDOMAIN\|timed out")


     if [ ${#orspf} -gt 1 ]
     then
	 orspchk="ERROR"
     echo  "Check orsp.f-secure.com = ERROR"
     else
	 orspchk="OK"
     echo  "Check orsp.f-secure.com = OK"
     fi


     if [ ${#xmlshavlikf} -gt 1 ] || [ ${#avantif} -gt 1 ]
     then
	 swupchk="ERROR"
     echo  "Check xml.shavlik.com and avanti = ERROR"
     else
	 swupchk="OK"
     echo  "Check xml.shavlik.com and avanti = OK"
     fi

     if [ ${#fsecuref} -gt 1 ]
     then
	 bddchk="ERROR"
     echo  "Check f-secure.com = ERROR"
     else
	 bddchk="OK"
     echo  "Check f-secure.com = OK"
     fi

	#whiptail --title "Check F-Secure Servers" --msgbox "Software updater : $swupchk "\n" pdates servers : $bddchk \n"	10 60
	
						modifchk=$(whiptail --title "Check F-secure Servers" --menu "Choose the port" --nocancel 15 80 5 \
                        "1" "Software updater : "$swupchk \
                        "2" "Updates servers : "$bddchk \
                        "3" "ORSP : "$orspchk 3>&1 1>&2 2>&3)
                        exitchk=$?
                        if [ $exitchk = 0 ]; then
							echo "add check information"
						else
                          echo "return"
                        fi
fi
 



if [ "$OPTION" = "3" ]; then
        echo "======================================="
        echo "============ HOTFIX INSTALL ==========="
        echo "======================================="
        echo ""

   if [ -e "/opt/f-secure/fspms/version.txt" ]
   then
      version=$(cat /opt/f-secure/fspms/version.txt)

	if [ "$version" = "12.40.81151" ]
   	then
		echo "installation hotfixe"
	   	#Install unzip
	   	apt-get install unzip -y
   		#download hotfix for 12.40.81151
   		cd /tmp
   		wget $hotfix1240
   		#unzip on /tmp
   		unzip fspm*.zip
	   	#stop service
	   	/etc/init.d/fspms stop
	   	#copy hotfix
	   	cp -f /tmp/fspm*/fspms-webapp-1-SNAPSHOT.jar /opt/f-secure/fspms/lib/
	    	#delete zip and unzip folder
	   	rm -f /tmp/fspm*.zip
	   	rm -rf /tmp/fspm*
		
		#add new version information
		#echo "12.40.81153" > /opt/f-secure/fspms/version.txt
		
	   	#start service
	   	/etc/init.d/fspms start
	else
           whiptail --title "Hotfix" --msgbox "Hotfix not available for this version of Policy Manager Server" 8 78
	fi
   else
      whiptail --title "Hotfix" --msgbox "Please install Policy Manager server first" 8 78
   fi
fi


if [ "$OPTION" = "5" ]; then
	databasemenu=$(whiptail --title "Database tool" --menu "" 15 80 5 \
                 "1" "Backup Database" \
                 "2" "Maintenance tool database" \
                 "3" "Recover Database" 3>&1 1>&2 2>&3)
                 exitdata=$?
                 if [ $exitdata = 0 ]; then
							if [ "$databasemenu" = "1" ]; then
							/etc/init.d/fspms stop
							NOW=$(date +"%m-%d-%Y-%T")
							cp /var/opt/f-secure/fspms/data/h2db/fspms.h2.db /var/opt/f-secure/fspms/data/backup/fspms.$NOW.h2.db
							/etc/init.d/fspms start
							whiptail --title "Backup" --msgbox "The backup file is in /var/opt/f-secure/fspms/data/backup/" 8 78
							fi
							if [ "$databasemenu" = "2" ]; then
							/etc/init.d/fspms stop
							/opt/f-secure/fspms/bin/fspms-db-maintenance-tool
							/etc/init.d/fspms start	
							fi
							if [ "$databasemenu" = "3" ]; then
							DISTROS=$(whiptail --title "Database recover" --checklist \
									"Choose options for recover tool" 15 60 4 \
									"1" "Without scanning Alerts" OFF \
									"2" "Without scanning Repport" OFF \
									"3" "Change destination folder /var/opt/" ON \
									"4" "Stop fspms service before recover database" OFF 3>&1 1>&2 2>&3)

							exitstatus=$?
							if [ $exitstatus = 0 ]; then

							Noalert=`echo ${DISTROS} | grep "1" | wc -l`
							if [ $Noalert = 0 ]; then
								Noalertcl=""
							else
								Noalertcl=" -noAlerts"
							fi

							Noreport=`echo ${DISTROS} | grep "2" | wc -l`
							if [ $Noreport = 0 ]; then
								Noreportcl=""
							else
								Noreportcl=" -noReports"
							fi

							currupted=$(whiptail --title "Currupted database" --inputbox "Corrupted database d " 10 60 /var/opt/f-secure/fspms/data/h2db --nocancel 3>&1 1>&2 2>&3)


							Destination=`echo ${DISTROS} | grep "3" | wc -l`
							if [ $Destination = 0 ]; then
							desti="/tmp"
							else
							desti=$(whiptail --title "Change dest dir" --inputbox "Destination folder " 10 60 /tmp --nocancel 3>&1 1>&2 2>&3)
							fi
							
							servicec=`echo ${DISTROS} | grep "4" | wc -l`
							if [ $servicec = 0 ]; then
								servicecl="0"
							else
								servicecl="1"
								/etc/init.d/fspms stop
							fi

							commandline="/opt/f-secure/fspms/bin/fspms-db-recover"$Noalertcl$Noreportcl" -curDir="$currupted" "$desti

							$commandline
							
							if [ $servicecl = 1 ]; then
								servicecl="0"
							/etc/init.d/fspms start
							fi
							
							whiptail --title "Recover" --msgbox "The recover database is in "$desti 8 78
							
							else
							echo "Back"
							fi	

							fi
							
				 fi
fi

if [ "$OPTION" = "6" ]; then
	/etc/init.d/fspms stop
	/opt/f-secure/fspms/bin/fspms-reset-admin-account
	/etc/ini.d/fspms start
fi

if [ "$OPTION" = "8" ]; then
desti=$(whiptail --title "Change destination fsdiag folder" --inputbox "Destination folder " 10 60 /opt/f-secure/fspms/bin/ --nocancel 3>&1 1>&2 2>&3)
/opt/f-secure/fspms/bin/fsdiag
	if [ $desti = "/opt/f-secure/fspms/bin/" ]; then
	    echo "ok"
	else
	mv /opt/f-secure/fspms/bin/fsdiag.tar.gz $desti
	fi
fi



else
sleep 1
exit 0
fi
done
