#!/bin/bash

CIFS_IP=192.168.1.2 <= EDIT THIS
CIFS_USER=user <= EDIT THIS
CIFS_PASS=your-cifs-password <= EDIT THIS
SUDO_PASS=your-sudo-password <= EDIT THIS
MOUNT_PATH=/mnt/nas/ <= EDIT THIS
MOUNTS=(Media Documents Downloads Uploads Docker) <= EDIT THESE

# Function to check if mounted
function checkMounted {
    if grep -qs "$MOUNT_PATH$1 " /proc/mounts; then
        return 1
    else
        return 0
    fi
}

# Check for mounted folders
for i in "${MOUNTS[@]}";
do
    checkMounted $i
    if [ "$?" -eq 1 ]; then
        LIST="$LIST True $i"
    else
        LIST="$LIST False $i"
    fi
done

# Display GUI
SELECTED=$(zenity --list --checklist --width=256 --height=256 --title="Choose Folder(s) to Mount" --column="" --column="Name" $LIST)

# Check for changes in the selections and either
# mount or unmount
for i in "${MOUNTS[@]}";
do
    checkMounted $i
    SHARE_PATH="$MOUNT_PATH$i "
    if [[ ${SELECTED[*]} =~ ${i} ]]; then
        echo $SUDO_PASS | sudo -S mount -t cifs -o username=$CIFS_USER,password=$CIFS_PASS //$CIFS_IP/$i $SHARE_PATH
    else
        echo $SUDO_PASS | sudo -S umount $SHARE_PATH
    fi

done
