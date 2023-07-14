#!/bin/sh
#Author : Vinil Vadakkepurakkal
# Integrating Azure Managed Lustre filesystem in CycleCloud
#OS Tested : CentOS 7 / RHEL7 / Alma Linux 8 / Ubuntu 18.04 / Ubuntu 20.04
#Env - Azure CycleCloud
MOUNT_POINT=$(jetpack config amlfs.mount_point)
MGS_IP=$(jetpack config amlfs.mgs_ip)
mkdir -p $MOUNT_POINT
sudo mount -t lustre -o noatime,flock $MGS_IP@tcp:/lustrefs $MOUNT_POINT