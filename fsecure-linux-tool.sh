#!/bin/bash

#Variable
#FSPMS DEB / RPM

deblinkfspms="https://download.f-secure.com/corpro/pm_linux/current/fspms_14.10.88509_amd64.deb"
rpmlinkfspms="https://download.f-secure.com/corpro/pm_linux/current/fspms-14.10.88509-1.x86_64.rpm"

vdebfspms=$(echo $deblinkfspms|cut -d"/" -f7)
vrpmfspms=$(echo $rpmlinkfspms|cut -d"/" -f7)


#TreatShield DEB
deblinkthreat="https://download.f-secure.com/corpro/threatshield/current/f-secure-threatshield_6.0.6-1_amd64.deb"
vrdebthreat=$(echo $deblinkthreat|cut -d"/" -f7)



#FSPMP DEB/RPM

deblinkpmp="https://download.f-secure.com/corpro/pm_linux/current/fspmp_14.10.88509_amd64.deb"
rpmlinkpmp="https://download.f-secure.com/corpro/pm_linux/current/fspmp-14.10.88509-1.x86_64.rpm"
vrpmpmp=$(echo $rpmlinkpmp|cut -d"/" -f7)
vdebpmp=$(echo $deblinkpmp|cut -d"/" -f7)


lastversion=$(echo $vdebfspms|cut -d"_" -f2)


#RadarScannode
RadarScanNodeLink="https://updates-api.radar.f-secure.com/api/1.1/ProductUpdates/Components/ScanNodeAgent/Releases/4.0.0.0/Download"
RadarScanNodeMicrosoft="https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb"



################################################################################################################
check_os () {

DistriOS="/etc/os-release"
		distri=$(cat /etc/os-release | grep  ID= | grep -v VERSION_ID |  cut -d"=" -f2)
		distri_version=$(cat /etc/os-release | grep  VERSION_ID= | cut -d"=" -f2 | sed 's/\"//g' | sed 's/\.//g')
        #while read -r ligne
        #do
        #catname=$(echo $ligne|cut -d"=" -f1)
		#	if [ "$catname" = "ID" ]; then
		#	distri=$(echo $ligne|cut -d"=" -f2)
		#	fi
			
		#done < "$DistriOS"
}


change_fspms_conf () {
echo "hostModulePort=\"${hostModulePort}\""                                        > ${new_settings_file}
echo "hostModuleHttpsPort=\"${hostModuleHttpsPort}\""                             >> ${new_settings_file}
echo "adminModulePort=\"${adminModulePort}\""                                     >> ${new_settings_file}
echo "adminExtensionLocalhostRestricted=\"${adminExtensionLocalhostRestricted}\"" >> ${new_settings_file}
echo "webReportingEnabled=\"${webReportingEnabled}\""                             >> ${new_settings_file}
echo "webReportingPort=\"${webReportingPort}\""                                   >> ${new_settings_file}
echo "ausPort=\"${ausPort}\""                                                     >> ${new_settings_file}
echo "jettyStopPort=\"${jettyStopPort}\""                                         >> ${new_settings_file}
echo "upstreamPmHost=\"${upstreamPmHost}\""                                       >> ${new_settings_file}
echo "upstreamPmPort=\"${upstreamPmPort}\""                                       >> ${new_settings_file}
echo "additional_java_args=\"${additional_java_args}\""                           >> ${new_settings_file}

mv -f ${new_settings_file} ${settings_file}
}


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
"4" "Check F-secure communication" \
"5" "Database tool" \
"6" "Reset admin password" \
"7" "FSDIAG" \
"8" "Install PM Proxy" \
"9" "Install Radar Scan Node" 3>&1 1>&2 2>&3)


#clear
exitstatus=$?
if [ $exitstatus = 0 ]; then

     
	if [ "$OPTION" = "1" ]; then
          
		check_os
	

        if [ "$distri" = "centos" ] || [ "$distri" = '"centos"' ]
        then
        echo "centoS";
		yum update
		yum install libstd++.i686 -y
		yum install wget -y
		yum install net-tools -y
		cd /tmp/
           	rm -f /tmp/fspm*
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
			
            rpm -i /tmp/$vrpmfspms
		
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
           apt-get install libstdc++5 libstdc++5:i386 libstdc++6 libstdc++6:i386 -y
           cd /tmp/
		   rm -f /tmp/fspm*
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
			dpkg -i /tmp/$vdebfspms

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

     ivanti=$(host -W1 xml.ivanti.com)
     ivantif=$(echo $ivanti | grep "NXDOMAIN\|timed out")

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


     if [ ${#xmlshavlikf} -gt 1 ] || [ ${#ivantif} -gt 1 ]
     then
	 swupchk="ERROR"
     echo  "Check xml.shavlik.com and ivanti = ERROR"
     else
	 swupchk="OK"
     echo  "Check xml.shavlik.com and ivanti = OK"
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

if [ "$OPTION" = "7" ]; then
desti=$(whiptail --title "Change destination fsdiag folder" --inputbox "Destination folder " 10 60 /opt/f-secure/fspms/bin/ --nocancel 3>&1 1>&2 2>&3)
/opt/f-secure/fspms/bin/fsdiag
	if [ $desti = "/opt/f-secure/fspms/bin/" ]; then
	    echo "ok"
	else
	mv /opt/f-secure/fspms/bin/fsdiag.tar.gz $desti
	fi
fi


if [ "$OPTION" = "8" ]; then


chooseVersion=$(whiptail --title "Choose proxy mode" --menu "Choose the mode of Policy Manager Proxy" 15 80 5 \
"1" "Autonome - without PM Server" \
"2" "Reverse - download on PM Server" \
"3" "Normal - download on internet" \
"4" "Chaining - download on another PMP" 3>&1 1>&2 2>&3)
exitpara=$?
if [ $exitpara = 0 ]; then
	   
   
	filename="/etc/os-release"
        
		check_os

        if [ "$distri" = "centos" ] || [ "$distri" = '"centos"' ]
        then
        echo "centoS";
		yum update
		yum install libstd++.i686 -y
		yum install wget -y
		yum install net-tools -y
		cd /tmp/
			if [ -f "/tmp/$vrpmpmp" ]
			then
			rm -f /tmp/fspmp*
			fi
           	
					wget -t 5 $rpmlinkpmp
				
           	
           	#install
			
				rpm -i /tmp/$vrpmpmp
			
           	#suppression des paquets
           	rm -f /tmp/$vrpmpmp
			
			chmod +x /etc/init.d/fspms

		
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
		   if [ -f "/tmp/$vrpmpmp" ]
			then
			rm -f /tmp/fspmp*
		   fi
					wget -t 5 $deblinkpmp
	
           #install
					dpkg -i /tmp/$vdebpmp

           #suppression des paquets
           rm /tmp/$vdebpmp  
		   
	       chmod +x /etc/init.d/fspms
	   
	   fi
	   
	   
	   filebinfsconf="/opt/f-secure/fspms/bin/fspms-config"
	   
	   if [ $chooseVersion = "1" ]; then
					whiptail --title "Mode autonome" --msgbox "To install the autnome mode, please check if IP address [0.0.0.0] is present to the next question (Server Adresse) and press ENTER" 15 60 5	
					
					
					#Read conf file
					settings_file="/etc/opt/f-secure/fspms/fspms.conf"
					. ${settings_file}

					additional_java_args=""
					upstreamPmHost="0.0.0.0"
                    new_settings_file=${settings_file}.$$

					change_fspms_conf

					/opt/f-secure/fspms/bin/fspms-config
					/etc/init.d/fspms start

				
	   fi
	   
	   if [ $chooseVersion = "2" ]; then
					pmsip=$(whiptail --title "Mode reverse" --inputbox "To install reverse mode PMP, need to download admin.pub on Policy Manager Server. Please insert the Policy Manager Server IP Address " 10 60 3>&1 1>&2 2>&3)
					wget --no-check-certificate -O /var/opt/f-secure/fspms/data/admin.pub https://$pmsip/fsms/fsmsh.dll?FSMSCommand=GetPublicKey
				if [ $? -eq 0 ]
				then
					#pmsipqu='"'$pmsip'"'
					# Check if custom upsteam exist
					#checkline=$(grep -n "upstreamPmHost=$pmsipqu" $filebinfsconf | cut -d: -f 1)
					#if [ ${#checkline} -gt 1 ]
					#then 
					#sed -i "/upstreamPmHost=$pmsipqu/d" $filebinfsconf
					#fi
					#linesa=$(grep -n 'ask_input "Server address"' $filebinfsconf | cut -d: -f 1)
					#sed -i "$linesa i upstreamPmHost=$pmsipqu" $filebinfsconf
					
					#add argument reverse + server add
					argdgut2="-DreverseProxy=true"
					
					#add server address
					settings_file="/etc/opt/f-secure/fspms/fspms.conf"
					. ${settings_file}

					additional_java_args=$argdgut2
					upstreamPmHost=$pmsip
                    new_settings_file=${settings_file}.$$

					change_fspms_conf
					
			
					/opt/f-secure/fspms/bin/fspms-config
					
					/etc/init.d/fspms start
				else
					whiptail --title "Mode autonome" --msgbox "Policy Manager Server is unavailable or the IP address is wrong, please retry" 15 60 5
				fi	
					
					
	   fi
	   
	   if [ $chooseVersion = "3" ]; then
					pmsip=$(whiptail --title "Normal Mode" --inputbox "To install normal mode PMP, need to download admin.pub on Policy Manager Server. Please insert the Policy Manager Server IP Address " 10 60 3>&1 1>&2 2>&3)
					wget --no-check-certificate -O /var/opt/f-secure/fspms/data/admin.pub https://$pmsip/fsms/fsmsh.dll?FSMSCommand=GetPublicKey
				if [ $? -eq 0 ]
				then
	
					settings_file="/etc/opt/f-secure/fspms/fspms.conf"
					. ${settings_file}

					additional_java_args=""
					upstreamPmHost=$pmsip
                    new_settings_file=${settings_file}.$$

					change_fspms_conf
					
					/opt/f-secure/fspms/bin/fspms-config
					
					/etc/init.d/fspms start
				else
					whiptail --title "Mode autonome" --msgbox "Policy Manager Server is unavailable or the IP address is wrong, please retry" 15 60 5
				fi	
	   fi
	   
	   
	   if [ $chooseVersion = "4" ]; then
					pmsip=$(whiptail --title "Chaining mode" --inputbox "To install PMP in chaining mode, need the IP address of PMP source. Please insert the Policy Manager Proxy IP Address " 10 60 3>&1 1>&2 2>&3)
					argdgut2="-Dguts2ServerUrl=http://$pmsip/guts2"
					
					#add server address
					settings_file="/etc/opt/f-secure/fspms/fspms.conf"
					. ${settings_file}

					additional_java_args=$argdgut2
                    new_settings_file=${settings_file}.$$

					change_fspms_conf

					
					/opt/f-secure/fspms/bin/fspms-config
					
					/etc/init.d/fspms start						
	   fi
	   

	 else
		echo "cancel"
       
    fi

fi

################################################################################################################################################################

if [ "$OPTION" = "9" ]; then

#GESTION CA

RadarMenu=$(whiptail --title "Radar Scan Node" --menu "Choose a option for your certificate" 15 80 5 \
                        "1" "Installation" \
                        "2" "Logs" \
						"3" "Services" \
						"4" "Updating scan engines manually" \
						"5" "Resetting Scan engines" \
						"6" "Uninstalling scan nodes" 3>&1 1>&2 2>&3)
exitpara=$?
if [ $exitpara = 0 ]; then

						
	if [ $RadarMenu = "1" ]; then
	LicenceRadarScanNode=$(whiptail --title "Import License" --inputbox "Import license Radar Scan Node (.fsrl)" 10 60 /tmp/license.fsrl --nocancel 3>&1 1>&2 2>&3)
        if [ -e "$LicenceRadarScanNode" ]; then
		
		check_os
	     
			if [ "$distri" = "ubuntu" ]
			then
			echo "Ubuntu"
			cp $LicenceRadarScanNode /root/license.fsrl
			cp $LicenceRadarScanNode /opt/f-secure/radar-scannodeagent/license.fsrl
			
			cd /tmp/
			wget -q -t 5 $RadarScanNodeMicrosoft
			sudo dpkg -i /tmp/packages-microsoft-prod.deb
			apt-get update
			apt-get install libcurl4:amd64 libc-dev-bin libc6-dev linux-libc-dev manpages-dev aspnetcore-runtime-2.2 dialog dotnet-host dotnet-hostfxr-2.2 dotnet-runtime-2.2 dotnet-runtime-deps-2.2 liblttng-ust-ctl4 liblttng-ust0 liburcu6 powershell -y
			rm -f /tmp/f-secure-radar-scannodeagent-installer*
			wget -P /tmp/ --content-disposition $RadarScanNodeLink
			whiptail --title "License" --msgbox "Fill in the following path : /root/license.fsrl" 10 60
			dpkg -i /tmp/f-secure-radar-scannodeagent-installer*
			fi
		
		else
		whiptail --title "Import License" --msgbox "You need a license file to install the Radar Scan Node agent. Please connect to your Radar Portal" 10 60
		fi
	
	
	fi
	
	if [ $RadarMenu = "2" ]; then
		tail -f /opt/f-secure/radar-scannodeagent/logs/sn-agent-current.log
		
	fi
	
	
	if [ $RadarMenu = "7" ]; then
		##Applying new license manually## 
		#Install SDK requierements
		sudo apt install software-properties-common
		sudo add-apt-repository universe
		sudo apt-get update
		sudo apt-get install apt-transport-https
		sudo apt-get update
		sudo apt-get install dotnet-sdk-3.0
	
	fi
fi

	

fi

else
sleep 1
exit 0
fi
done
