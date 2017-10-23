#!/bin/bash

# Only root can use this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

	
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
				yum install git -y
				git clone https://github.com/fspms/linux-tool /opt/fspms
				rm /sbin/fspms
				echo "sh /opt/fspms/fsecure-linux-tool.sh" > /sbin/fspms
				#ln -s /opt/fspms/fsecure-linux-tool.sh /sbin/fspms
				chmod +x /sbin/fspms
		
		
        elif [ "$distri" = "Fedora" ]
			then
				echo "Fedora";
				# Do that
        elif [ "$distri" = "debian" ] || [ "$distri" = "ubuntu" ]
			then
				echo "Debian or Ubuntu";
				apt-get update
				apt-get install git -y
				git clone https://github.com/fspms/linux-tool /opt/fspms
				rm /sbin/fspms
				echo "sh /opt/fspms/fsecure-linux-tool.sh" > /sbin/fspms
				chmod +x /sbin/fspms
        fi  
		
echo "==========================================="
echo "========= INSTALL COMPLETE ================"
echo "==========================================="
echo ""
echo "Type fspms for execute F-secure Linux Tool"
