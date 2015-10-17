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

### Modify these values to work for your environment ###
# Path to the Company plist PATH/TO/COMPANY/PLIST e.g. /Library/Company/com.company.group
companyPath="/Library/EEI/edu.berkeley.eei"
echo "$companyPath"

# Obtain plist filename from companyPlist path
companyPlist="echo ${companyPath##*/}"
echo "$companyPlist"

# Time in seconds to automatically disable Presentation Mode. Default is 24 hours or 86400 seconds
disableTime="86400"

### End of values to modify ###

# Message to user that the Mac is in Presentation Mode and is being automatically disabled now
/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "Mac is currently in Presentation Mode and has reached its expiration time. Auto-disabling Presentation Mode." buttons {"OK"} default button 1
			    end tell
			EOF

# Write the value in the plist to disable Presentation Mode
/usr/bin/defaults write "$companyPath" presentationmode "disabled"

# Run recon to evaluate plist for Casper Extension Attribute for Smart Group changes
/usr/local/bin/jamf recon

# Delete the power management file because it contains the Energy Saver plist values
# Copy the backup power management settings which has the previous user-defined settings
# Delete the backup power management settings file
rm -rf "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist"

/bin/cp -f "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup" "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist"

rm -rf "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup"

# Kill cfprefsd to apply power management settings
/usr/bin/killall cfprefsd

# Delete the launchdaemon
rm -rf "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"

exit 0