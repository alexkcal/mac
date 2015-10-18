#!/bin/sh

# presentation-mode-disable.sh
# Use this script to disable a Mac that is in presentation mode:
# Removes the configuration profile for presentation mode Energy Saver settings
# Adds back the configuration profile for screen saver settings
# Designed for use with JAMF Casper Suite for Self Service and deploying configuration profiles
# Can be modified to use with locally installed configuration profiles
# Use with presentation-mode-enable.sh before this disable script to enable presentation mode first

# Alex Kim - EEI, UC Berkeley
# 2015.10.16

########## Modify these values to work for your environment ##########

# Modify path to the company plist /PATH/TO/COMPANY/PLIST e.g. /Library/Company/com.company.group
companyPath="/PATH/TO/COMPANY/PLIST"
echo "$companyPath"

# Obtain plist filename from company path. Generally, no modification needed.
companyPlist=`echo ${companyPath##*/}`
echo "$companyPlist"

# Obtain the directory in the company path to confirm the directory exists. Generally, no modification needed.
companyPathDir=`echo $companyPath | sed 's:/[^/]*$::'`
echo "$companyPathDir"

########## End of values to modify ##########

# Message to user that the Mac is in Presentation Mode and is being automatically disabled now
/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "Mac is currently in Presentation Mode and has reached its expiration time. Auto-disabling Presentation Mode." buttons {"OK"} default button 1
			    end tell
			EOF

# Write the value in the plist to disable Presentation Mode
echo "Write value in plist for presentationmode to be disabled"
/usr/bin/defaults write "$companyPath" presentationmode "disabled"

# Run recon to evaluate plist for Casper Extension Attribute for Smart Group changes
echo "Run recon to update inventory for EA and Smart Groups"
/usr/local/bin/jamf recon

# Delete the power management file because it contains the Energy Saver plist values
# Copy the backup power management settings which has the previous user-defined settings
# Delete the backup power management settings file
echo "Remove existing power management plist which contains settings from the configuration profile"
rm -rf "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist"

echo "Copy the backup of the original power management settings to be used by machine again"
/bin/cp -f "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup" "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist"

echo "Remove the backup of the power management settings"
rm -rf "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup"

# Kill cfprefsd to apply power management settings
echo "Kill cfprefsd to apply the original power management settings"
/usr/bin/killall cfprefsd

# Unload and remove the launchdaemon
echo "Disable the launchdaemon"
/usr/bin/defaults write "/Library/LaunchDaemons/"$companyPlist".disablepm.plist" disabled -bool true

echo "Unload the launchdaemon"
/bin/launchctl unload -w "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"

echo "Remove the launchdaemon"
rm -rf "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"

echo "Presentation Mode has been disabled. Original power settings have been restored."

exit 0