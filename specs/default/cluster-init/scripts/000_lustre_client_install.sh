#!/bin/sh
#Author : Vinil Vadakkepurakkal
# Integrating Azure Managed Lustre filesystem in CycleCloud
#OS Tested : CentOS 7 / RHEL7 / Alma Linux 8 / Ubuntu 18.04
#Env - Azure CycleCloud

OS_VER=$(jetpack config platform_family)
LUSTRE_VER=$(jetpack config amlfs.client_ver)
case $OS_VER in 
rhel)
   
        rpm --import https://packages.microsoft.com/keys/microsoft.asc  
        DISTRIB_CODENAME=el7
        REPO_PATH=/etc/yum.repos.d/amlfs.repo
        echo -e "[amlfs]" > ${REPO_PATH}
        echo -e "name=Azure Lustre Packages" >> ${REPO_PATH}
        echo -e "baseurl=https://packages.microsoft.com/yumrepos/amlfs-${DISTRIB_CODENAME}" >> ${REPO_PATH}
        echo -e "enabled=1" >> ${REPO_PATH}
        echo -e "gpgcheck=1" >> ${REPO_PATH}
        echo -e "gpgkey=https://packages.microsoft.com/keys/microsoft.asc" >> ${REPO_PATH}
        yum clean all
        sudo yum install amlfs-lustre-client-$(LUSTRE_VER)-$(uname -r | sed -e "s/\.$(uname -p)$//" | sed -re 's/[-_]/\./g')-1
        ;;
esac