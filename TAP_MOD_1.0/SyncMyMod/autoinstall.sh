#!/bin/sh
######################################################################################################
#																	Installation Script for TAP 360 Camera MOD      									 #
######################################################################################################
#                                    _        ___  _     _                                           #
#                                   (_)      / _ \(_)   | |                                          #
#                                    _  __ _| | | |_ ___| |_                                         #
#                                   | |/ _` | | | | / __| __|                                        #
#                                   | | (_| | |_| | \__ \ |_                                         #
#                                   |_|\__, |\___/|_|___/\__|                                        #
#                                       __/ |                                                        #
#                                      |___/                                                         #
######################################################################################################

# Mod Name      : TAP 360 Camera MOD
# Author        : ig0ist ( Igor Str.)
# Creation date : 2023-02-21
# Version       : 1.0
# Update date   : 2024-02-21
# Update notes  : Release

#########################################################################################################################################################
#   Environment variables                                                                                                                               #
#########################################################################################################################################################

# Feel free to delete unecessary Env. vars
FILES_DIR="/fs/usb0/SyncMyMod"

PATCH_DIR="${FILES_DIR}/patch"
APP_DIR="${FILES_DIR}/app"

# Minimum Sync 3 compatible version. Uncomment it only if required
SYNC3_MIN_BUILD="3.4.23188"

# Mod Tools string - DO NOT EDIT
MODTOOLS="MODS_TOOLS"

# Your Mod Name (no space or special chars allowed in this var!!
MODNAME="TAP360CAMERA"

#########################################################################################################################################################
#   Functions                                                                                                                                           #
#########################################################################################################################################################

# DO NOT EDIT
POPUP=/tmp/popup.txt
echo "" > $POPUP

function displayMessage {
    echo "${1}" >> $POPUP
    /fs/rwdata/dev/utserviceutility popup $POPUP
}

function reboot {
    /fs/rwdata/dev/utserviceutility reboot
}

function displayImage {
	slay APP_SUM
	slay -s 9 NAV_Manager
	slay -s 9 fordhmi
	slay HMI_AL
	display_image -file=/fs/usb0/SyncMyMod/installation_${1}.png -display=2 &

	while [ -e /fs/usb0 ]; do
		sleep 1
	done

	reboot

	exit 0
}

#########################################################################################################################################################
#   Check if Mods Tools are installed                                                                                                                   #
#########################################################################################################################################################

# DO NOT EDIT
grep -q ${MODTOOLS} /fs/rwdata/dev/mods_tools.txt
if [ $? -ne 0 ]; then
    displayImage "aborted"
fi
chmod a+x /fs/rwdata/dev/*

#########################################################################################################################################################
#   Check if this Mod is already installed                                                                                                              #
#########################################################################################################################################################

# DO NOT EDIT
grep -q ${MODNAME} /fs/mp/etc/installed_mods.txt
if [ $? -eq 0 ]; then
   displayMessage "This mod is already installed in your Sync 3."

   exit 0
fi

#########################################################################################################################################################
#   Check if patch can be applied safely                                                                                                                #
#########################################################################################################################################################

# DO NOT EDIT
/fs/rwdata/dev/patch --ignore-whitespace --dry-run -p0 < ${PATCH_DIR}/master.patch > /fs/usb0/patch.log
if [ "$?" != "0" ]; then
  displayMessage "This mod is not compatible with your Sync 3 version or other patch error!"
	displayMessage ""
	displayMessage "It only support Sync 3 Build ${SYNC3_MIN_BUILD} or higher!"

    exit 0
fi

#########################################################################################################################################################
#																Remount FS as RW																		#
#########################################################################################################################################################

# DO NOT EDIT
. /fs/rwdata/dev/remount_rw.sh
sleep 1

#########################################################################################################################################################
#																Copying new files																		#
#########################################################################################################################################################

# NO NEW

#########################################################################################################################################################
#   Apply Patch and add Mod entry                                                                                                                       #
#########################################################################################################################################################

/fs/rwdata/dev/patch --ignore-whitespace -b -p0 < ${PATCH_DIR}/master.patch

# This is mandatory if your mod use patching system
echo ${MODNAME} >> /fs/mp/etc/installed_mods.txt

#########################################################################################################################################################
#   Remount FS as RO                                                                                                                                    #
#########################################################################################################################################################

# DO NOT EDIT
sleep 1
. /fs/rwdata/dev/remount_ro.sh
sync
sync
sync

#########################################################################################################################################################
#   Display success image and reboot                                                                                                                    #
#########################################################################################################################################################

# DO NOT EDIT
displayImage "completed"
