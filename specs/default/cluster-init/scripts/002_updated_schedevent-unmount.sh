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

#umounting the lustre filesystem on terminate event
cat >> /opt/cycle/jetpack/scripts/onTerminate.sh << 'EOF'
#!/bin/sh
LOGFILE=/sched/unmount_lustre.log
MOUNTPOINT=$(jetpack config amlfs.mount_point)
echo "`date "+%D %T"`[INFO] Starting unmount process for $MOUNTPOINT from `hostname`" | tee -a "$LOGFILE"

while mountpoint -q $MOUNTPOINT; do
    echo "`date "+%D %T"` [WARNING] $MOUNTPOINT is still mounted on `hostname`. Checking processes..." | tee -a "$LOGFILE"
    /sbin/fuser -vm $MOUNTPOINT 2>&1 | tee -a "$LOGFILE"
    echo "`date "+%D %T"` [INFO] Sending TERM signal to processes..." | tee -a "$LOGFILE"
    /sbin/fuser -kMm -TERM $MOUNTPOINT
    /bin/sleep 5
    echo "`date "+%D %T"` [INFO] Sending KILL signal to remaining processes..." | tee -a "$LOGFILE"
    /sbin/fuser -kMm -KILL $MOUNTPOINT
    /bin/sleep 5
    echo "`date "+%D %T"` [INFO] Attempting to unmount $MOUNTPOINT from `hostname`" | tee -a "$LOGFILE"
    /bin/umount $MOUNTPOINT
    /bin/sleep 5
done

echo "`date "+%D %T"` [SUCCESS] $MOUNTPOINT successfully unmounted from `hostname`." | tee -a "$LOGFILE"
EOF
# unmounting the lustre filesystem on preempt event (spot instance)
cat >>/opt/cycle/jetpack/scripts/onPreempt.sh << 'EOF'
#!/bin/sh
LOGFILE=/sched/unmount_lustre.log
MOUNTPOINT=$(jetpack config amlfs.mount_point)
echo "`date "+%D %T"`[INFO] Starting unmount process for $MOUNTPOINT from `hostname`" | tee -a "$LOGFILE"

while mountpoint -q $MOUNTPOINT; do
    echo "`date "+%D %T"` [WARNING] $MOUNTPOINT is still mounted on `hostname`. Checking processes..." | tee -a "$LOGFILE"
    /sbin/fuser -vm $MOUNTPOINT 2>&1 | tee -a "$LOGFILE"
    echo "`date "+%D %T"` [INFO] Sending TERM signal to processes..." | tee -a "$LOGFILE"
    /sbin/fuser -kMm -TERM $MOUNTPOINT
    /bin/sleep 5
    echo "`date "+%D %T"` [INFO] Sending KILL signal to remaining processes..." | tee -a "$LOGFILE"
    /sbin/fuser -kMm -KILL $MOUNTPOINT
    /bin/sleep 5
    echo "`date "+%D %T"` [INFO] Attempting to unmount $MOUNTPOINT from `hostname`" | tee -a "$LOGFILE"
    /bin/umount $MOUNTPOINT
    /bin/sleep 5
done

echo "`date "+%D %T"` [SUCCESS] $MOUNTPOINT successfully unmounted from `hostname`." | tee -a "$LOGFILE"
EOF

# unmounting the lustre filesystem on reboot event

cat >>/opt/cycle/jetpack/scripts/onReboot.sh << 'EOF'
#!/bin/sh
LOGFILE=/sched/unmount_lustre.log
MOUNTPOINT=$(jetpack config amlfs.mount_point)
echo "`date "+%D %T"`[INFO] Starting unmount process for $MOUNTPOINT from `hostname`" | tee -a "$LOGFILE"

while mountpoint -q $MOUNTPOINT; do
    echo "`date "+%D %T"` [WARNING] $MOUNTPOINT is still mounted on `hostname`. Checking processes..." | tee -a "$LOGFILE"
    /sbin/fuser -vm $MOUNTPOINT 2>&1 | tee -a "$LOGFILE"
    echo "`date "+%D %T"` [INFO] Sending TERM signal to processes..." | tee -a "$LOGFILE"
    /sbin/fuser -kMm -TERM $MOUNTPOINT
    /bin/sleep 5
    echo "`date "+%D %T"` [INFO] Sending KILL signal to remaining processes..." | tee -a "$LOGFILE"
    /sbin/fuser -kMm -KILL $MOUNTPOINT
    /bin/sleep 5
    echo "`date "+%D %T"` [INFO] Attempting to unmount $MOUNTPOINT from `hostname`" | tee -a "$LOGFILE"
    /bin/umount $MOUNTPOINT
    /bin/sleep 5
done

echo "`date "+%D %T"` [SUCCESS] $MOUNTPOINT successfully unmounted from `hostname`." | tee -a "$LOGFILE"
EOF

# unmounting the lustre filesystem on redeploy event
cat >>/opt/cycle/jetpack/scripts/onRedeploy.sh << 'EOF'
#!/bin/sh
LOGFILE=/sched/unmount_lustre.log
MOUNTPOINT=$(jetpack config amlfs.mount_point)
echo "`date "+%D %T"`[INFO] Starting unmount process for $MOUNTPOINT from `hostname`" | tee -a "$LOGFILE"

while mountpoint -q $MOUNTPOINT; do
    echo "`date "+%D %T"` [WARNING] $MOUNTPOINT is still mounted on `hostname`. Checking processes..." | tee -a "$LOGFILE"
    /sbin/fuser -vm $MOUNTPOINT 2>&1 | tee -a "$LOGFILE"
    echo "`date "+%D %T"` [INFO] Sending TERM signal to processes..." | tee -a "$LOGFILE"
    /sbin/fuser -kMm -TERM $MOUNTPOINT
    /bin/sleep 5
    echo "`date "+%D %T"` [INFO] Sending KILL signal to remaining processes..." | tee -a "$LOGFILE"
    /sbin/fuser -kMm -KILL $MOUNTPOINT
    /bin/sleep 5
    echo "`date "+%D %T"` [INFO] Attempting to unmount $MOUNTPOINT from `hostname`" | tee -a "$LOGFILE"
    /bin/umount $MOUNTPOINT
    /bin/sleep 5
done

echo "`date "+%D %T"` [SUCCESS] $MOUNTPOINT successfully unmounted from `hostname`." | tee -a "$LOGFILE"
EOF

# Unmounting the Lustre filesystem on Freeze event
cat >>/opt/cycle/jetpack/scripts/onFreeze.sh << 'EOF'
#!/bin/sh
LOGFILE=/sched/unmount_lustre.log
MOUNTPOINT=$(jetpack config amlfs.mount_point)
echo "`date "+%D %T"`[INFO] Starting unmount process for $MOUNTPOINT from `hostname`" | tee -a "$LOGFILE"

while mountpoint -q $MOUNTPOINT; do
    echo "`date "+%D %T"` [WARNING] $MOUNTPOINT is still mounted on `hostname`. Checking processes..." | tee -a "$LOGFILE"
    /sbin/fuser -vm $MOUNTPOINT 2>&1 | tee -a "$LOGFILE"
    echo "`date "+%D %T"` [INFO] Sending TERM signal to processes..." | tee -a "$LOGFILE"
    /sbin/fuser -kMm -TERM $MOUNTPOINT
    /bin/sleep 5
    echo "`date "+%D %T"` [INFO] Sending KILL signal to remaining processes..." | tee -a "$LOGFILE"
    /sbin/fuser -kMm -KILL $MOUNTPOINT
    /bin/sleep 5
    echo "`date "+%D %T"` [INFO] Attempting to unmount $MOUNTPOINT from `hostname`" | tee -a "$LOGFILE"
    /bin/umount $MOUNTPOINT
    /bin/sleep 5
done

echo "`date "+%D %T"` [SUCCESS] $MOUNTPOINT successfully unmounted from `hostname`." | tee -a "$LOGFILE"
EOF


# Setting the permissions for the scripts

chmod +x /opt/cycle/jetpack/scripts/onTerminate.sh
chmod +x /opt/cycle/jetpack/scripts/onPreempt.sh
chmod +x /opt/cycle/jetpack/scripts/onReboot.sh
chmod +x /opt/cycle/jetpack/scripts/onRedeploy.sh
chmod +x /opt/cycle/jetpack/scripts/onFreeze.sh 