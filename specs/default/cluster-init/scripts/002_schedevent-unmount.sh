#!/bin/sh
# Author - Vinil Vadakkepurakkal
# This script will umount the AMLFS for any schedule event for the VM.
# The following Scheduled events are supported.
# Freeze: The Virtual Machine is scheduled to pause for a few seconds. CPU and network connectivity may be suspended, but there's no impact on memory or open files.
# Reboot: The Virtual Machine is scheduled for reboot (non-persistent memory is lost).
# Redeploy: The Virtual Machine is scheduled to move to another node (ephemeral disks are lost).
# Preempt: The Spot Virtual Machine is being deleted (ephemeral disks are lost). This event is made available on a best effort basis
# Terminate: The virtual machine is scheduled to be deleted.


mkdir -p /opt/cycle/jetpack/scripts
cat >>/opt/cycle/jetpack/scripts/onTerminate.sh << EOF
#!/bin/sh
MOUNT_POINT=$(jetpack config amlfs.mount_point)
echo "unmounting Lustre filesystem $MOUNTPOINT from `hostname` | logger
/usr/bin/fuser -ku $MOUNTPOINT
/usr/bin/sleep 5
/usr/bin/umount -l $MOUNTPOINT
echo "Lustre filesystem unmounted from `hostname`" | logger
EOF
chmod +x /opt/cycle/jetpack/scripts/onTerminate.sh


