# cyclecloud-amlfs
This Project help you to automate the installation of Azure Managed Lustre clients and mount Azure Managed Lustre filesystem on your CycleCloud HPC Clusters.

**Table of contents**
- [Pre-Requisites](#pre-requisites)
- [Configuring the Project](#configuring-the-project)
- [Configuring AMLFS in CycleCloud Portal](#configuring-amlfs-in-cyclecloud-portal)
- [Testing](#testing)
- [Unmounting AMLFS using Schedule Events](#unmounting-amlfs-using-schedule-events)

## Pre-Requisites ##
1. [CycleCloud](https://learn.microsoft.com/en-us/azure/cyclecloud/qs-install-marketplace?view=cyclecloud-8) must be installed and running (CycleCloud 8.0 or later).
2. [Azure Managed Lustre filesystem](https://learn.microsoft.com/en-us/azure/azure-managed-lustre/amlfs-overview) must be configured and running. 
3. Supported OS versions : 
    1. CentOS 7 / RHEL7 
    2. Alma Linux 8.5 / 8.6  
    3. Ubuntu 18.04 LTS
    4. Ubuntu 20.04 LTS
4. Supported cyclecloud templates.
    1. Slurm
    2. PBSpro
    3. Grid Engine

## Configuring the Project ##
1. Open a terminal session in CycleCloud server with the CycleCloud CLI enabled.
2. Clone the cyclecloud-amlfs repo
``` bash
git clone https://github.com/vinil-v/cyclecloud-amlfs
```
3. Swtich to `cyclecloud-amlfs` project directory and upload the project to cyclecloud locker.
``` bash
cd cyclecloud-amlfs/
cyclecloud project upload <locker name>
```
4. Import the required template (Slurm/ OpenPBS or Gridenigne).

Please note: if you are using cyclecloud-slurm 3.0.1 version (Comes with CycleCloud 8.4), please use the template named `slurm_301-amlfs.txt`. other cyclecloud-slurm releases (2.x) can use `slurm-amlfs.txt` template.

``` bash
cyclecloud import_template -f templates/slurm_301-amlfs.txt
```

## Configuring AMLFS in CycleCloud Portal ##

The following parameters required for successful configuration.
Please refer [Install Clients](https://learn.microsoft.com/en-us/azure/azure-managed-lustre/client-install) document to check the pre-built AMLFS client version for the selected OS. 

At the time of writing this document, the AMLFS Client version is `2.15.1_29_gbae0ab`. Ubuntu version has hyphen ( - ) and EL version has underscores ( _ ). Ubuntu version: `2.15.1-29-gbae0abe` & RedHat/ AlmaLinux / Centos : `2.15.1_29_gbae0ab`.

   1. Lustre Client Version.
   2. MGS IP Address
   3. Name of the Lustre Mount Point in the compute nodes

Create new cluster from the imported template(Slurm-AMLFS in this case) and in the Azure Managed Lustre FS section, add the above mentioned parameter. 

<img src="https://raw.githubusercontent.com/vinil-v/cyclecloud-amlfs/main/images/amlfs-settings-in-cc.png" width="753" height="250">


Start the cluster. Make sure that the AMLFS is running and MGS IP is reachable to all the nodes.

## Testing  ##

Login to the node and run `df -t lustre` to check the mounted lustre filesystem. the following output from CycleCloud 8.4, cyclecloud-slurm 3.0.1 and Almalinux 8.6.
``` bash
[root@s1-scheduler ~]# jetpack config cyclecloud.cluster_init_specs --json | egrep 'project\"|version'
            "project": "slurm",
            "version": "3.0.1"
            "project": "cyclecloud-amlfs",
            "version": "1.0.0"
            "project": "slurm",
            "version": "3.0.1"
[root@s1-scheduler ~]# df -t lustre
Filesystem                  1K-blocks  Used   Available Use% Mounted on
10.222.1.62@tcp:/lustrefs 17010128952  1264 16151959984   1% /lustre
[root@s1-scheduler ~]# lfs df
UUID                   1K-blocks        Used   Available Use% Mounted on
lustrefs-MDT0000_UUID   628015712        5872   574901108   1% /lustre[MDT:0]
lustrefs-OST0000_UUID 17010128952        1264 16151959984   1% /lustre[OST:0]

filesystem_summary:  17010128952        1264 16151959984   1% /lustre

```

## Unmounting AMLFS using Schedule Events ##
There is a known behaviour in Lustre if a VM has the Lustre mounted and it gets evicted or deleted as part of workflow without releasing the filesystem lock. Lustre will keep the lock for next 10 – 15 minutes before it releases.  Lustre has a ~10-minute timeout period to release the LOCK. The other VMs (Lustre clients) using the same Lustre mount point might experience intermittent hung mounts for 10-15 mins.

The blog [How to unmount Azure Managed Lustre filesystem using Azure Scheduled Events](https://techcommunity.microsoft.com/t5/azure-high-performance-computing/how-to-unmount-azure-managed-lustre-filesystem-using-azure/ba-p/3917814) discuss about how we can use Azure Schedule Events to unmount Azure Managed Lustre cleanly in a VMSS or a SPOT VM to avoid the similar issue explained above.

As of 8.2.2, CycleCloud can take advantage of Scheduled Events for VMs. This feature lets you put a script on your VM that will be automatically executed when one of the supported events occurs.
You can refer to the following information in the below link:
https://learn.microsoft.com/en-us/azure/cyclecloud/how-to/scheduled-events?view=cyclecloud-8

First, we need to enable the terminate notification for Node Array. We need to update the cyclecloud slurm or pbs template and add `EnableTerminateNotification = true` and `TerminateNotificationTimeout = 10m`

The templates available in this project has this feature available.

``` bash
   [[nodearray hpc]]
    Extends = nodearraybase
    MachineType = $HPCMachineType
    ImageName = $HPCImageName
    MaxCoreCount = $MaxHPCExecuteCoreCount
    Azure.MaxScalesetSize = $HPCMaxScalesetSize
    AdditionalClusterInitSpecs = $HPCClusterInitSpecs

    EnableTerminateNotification = true
    TerminateNotificationTimeout = 10m
```

Import the template into the cyclecloud and start a new cluster.
This project will automatically enable the Schedule Event and umount the AMLFS incase there is a SPOT eviction or terminate/scale down nodes in a VMSS. so that the AMLFS will have a clean umount always. 

All the best!