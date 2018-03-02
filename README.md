# F-Secure linux-tool
 Script to automated the management of F-Secure Policy Manager for linux


This script allows :

 - Automatic installation of Policy Manager server on Linux (Debian, Ubuntu and CentOS atm)
 - Install HotFix
 - Check and modify the ports used
 - Check communication with F-Secure servers
 - Policy Manager Database maintenance
 - Create backup
 - Reset admin password
 - Check and force database update (Dropped with v13)
 - Create a FSDIAG package for support
 - Install PMP (New)
 

#### INSTALLATION

Download setup.sh and execute it

```
wget https://raw.githubusercontent.com/fspms/linux-tool/master/setup.sh && sh setup.sh
```

If install is complete you can execute linux-tool when type "fspms"


#### SCRIPT MENUS


Main menu : 

![alt text](https://image.ibb.co/bJyuYH/2018_03_02_09_53_09_fsecure_debian.png)

Database tool menu :

![alt text](https://image.ibb.co/nAfGDH/2018_03_02_10_00_01_fsecure_debian.png)

PM Proxy install menu :

![alt text](https://image.ibb.co/c37DtH/2018_03_02_10_01_59_fsecure_debian.png)

#### Roadmap

- Add Linux Security Setup
- Add IGK Setup and automatique configuration 
