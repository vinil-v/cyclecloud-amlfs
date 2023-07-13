# cyclecloud-amlfs
This Project help you to install Azure Managed Lustre clients and mount Azure Managed Lustre filesystem on your CycleCloud HPC Clusters.

**Table of contents**
- [Pre-Requisites](#pre-requisites)
- [Configuring the Project](#configuring-the-project)
- [Configuring AMLFS in CycleCloud Portal](#configuring-amlfs-in-cyclecloud-portal)
- [Testing the user login](#testing-the-user-login)

## Pre-Requisites ##
1. [CycleCloud](https://learn.microsoft.com/en-us/azure/cyclecloud/qs-install-marketplace?view=cyclecloud-8) must be installed and running (CycleCloud 8.0 or later).
2. [Azure Managed Lustre filesystem](https://learn.microsoft.com/en-us/azure/azure-managed-lustre/amlfs-overview) must be configured and running. 
3. Supported OS versions : CentOS 7 / RHEL7 / Alma Linux 8.x / Ubuntu 18.04 / Ubuntu 20.04

## Configuring the Project ##
1. Open a terminal session in CycleCloud server with the CycleCloud CLI enabled.
2. Clone the cyclecloud-amlfs repo
``` bash
$ git clone https://github.com/vinil-v/cyclecloud-amlfs
```
3. Swtich to `cyclecloud-amlfs` project directory and upload the project to cyclecloud locker.
``` bash
$ cd cyclecloud-amlfs/
$ cyclecloud project upload <locker name>
```
4. Import the required template (Slurm/ OpenPBS or Gridenigne).
please note: if you are using CycleCloud 8.4 with cyclecloud-slurm 3.0.1 version, please use the template named `slurm_301-amlfs.txt`. other releases cyclecloud-slurm releases (2.x) can use `slurm-amlfs.txt`
``` bash
cyclecloud import_template -f templates/slurm_301-amlfs.txt
```

## Configuring AMLFS in CycleCloud Portal ##

The following parameters required for successful configuration.

    1. Lustre Client Version
    2. MGS IP Address
    3. Lustre Mount Point in the compute nodes

Create new cluster from the imported template(Slurm-AMLFS in this case) and in the Azure Managed Lustre FS section, add the above mentioned parameter. 

<img src="https://raw.githubusercontent.com/vinil-v/cyclecloud-amlfs/main/images/amlfs-settings-in-cc.png" width="462" height="236">


Start the cluster. Make sure that the AMLFS is running and MGS IP is reachable to all the nodes.

## Checking the Lustre mounts ##

Login to the node and run `df -t lustre` to check the mounted lustre filesystem
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
[root@s1-scheduler ~]#
```
All the best!