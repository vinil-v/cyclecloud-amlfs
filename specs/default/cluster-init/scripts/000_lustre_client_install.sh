#!/bin/sh
#Author : Vinil Vadakkepurakkal
# Integrating Azure Managed Lustre filesystem in CycleCloud
#OS Tested : CentOS 7 / RHEL7 / Alma Linux 8 / Ubuntu 18.04 / Ubuntu 20.04
#Env - Azure CycleCloud 8.x

OS_FAMILY=$(jetpack config platform_family)
OS_VER=$(jetpack config platform_version | cut -d "." -f1)
LUSTRE_VER=$(jetpack config amlfs.client_ver)
case $OS_FAMILY in 
rhel)
        if [[ $OS_VER == 7 ]]; then
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
                sudo yum install amlfs-lustre-client-$LUSTRE_VER-$(uname -r | sed -e "s/\.$(uname -p)$//" | sed -re 's/[-_]/\./g')-1 -y
        elif [[ $OS_VER == 8 ]]; then
                rpm --import https://packages.microsoft.com/keys/microsoft.asc
                DISTRIB_CODENAME=el8
                REPO_PATH=/etc/yum.repos.d/amlfs.repo
                echo -e "[amlfs]" > ${REPO_PATH}
                echo -e "name=Azure Lustre Packages" >> ${REPO_PATH}
                echo -e "baseurl=https://packages.microsoft.com/yumrepos/amlfs-${DISTRIB_CODENAME}" >> ${REPO_PATH}
                echo -e "enabled=1" >> ${REPO_PATH}
                echo -e "gpgcheck=1" >> ${REPO_PATH}
                echo -e "gpgkey=https://packages.microsoft.com/keys/microsoft.asc" >> ${REPO_PATH}
                dnf clean all
                sudo dnf install amlfs-lustre-client-$LUSTRE_VER-$(uname -r | sed -e "s/\.$(uname -p)$//" | sed -re 's/[-_]/\./g')-1 -y
        fi
        ;;


debian)
                export DEBIAN_FRONTEND=noninteractive
                apt update && apt install -y ca-certificates curl apt-transport-https lsb-release gnupg
                . /etc/lsb-release
                echo "deb [arch=amd64] https://packages.microsoft.com/repos/amlfs-$DISTRIB_CODENAME/ $DISTRIB_CODENAME main" | tee /etc/apt/sources.list.d/amlfs.list
                curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
                apt update
                sudo apt install amlfs-lustre-client-$LUSTRE_VER=$(uname -r) -y
        ;;
esac