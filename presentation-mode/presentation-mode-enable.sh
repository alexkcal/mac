#!/bin/sh

# presentation-mode-enable.sh
# Use this script to configure and enable a Mac for presentation mode:
# Removes the configuration profile for a default screensaver lock time
# Deploys a configuration profile to change power settings to not sleep, hibernate, or turn off the screen
# Designed for use with JAMF Casper Suite for Self Service and deploying configuration profiles
# Can be modified to use with locally installed configuration profiles
# Use with presentation-mode-disable.sh to disable presentation mode

# Alex Kim - EEI, UC Berkeley
# 2015.10.16

### Modify these values to work for your environment ###
# Path to the Company plist PATH/TO/COMPANY/PLIST e.g. /Library/Company/com.company.group
companyPath="/Library/EEI/edu.berkeley.eei"
echo "$companyPath"

# Obtain plist filename from companyPlist path
companyPlist=`echo ${companyPath##*/}`
echo "$companyPlist"

# Obtain the directory in the company path to confirm the directory exists
companyPathDir=`echo $companyPath | sed 's:/[^/]*$::'`
echo "$companyPathDir"

# If the directory in the company path does not exist, then create it so we can write the plist to it
# Modify chmod permissions and check of directory path if needed
if [ ! -d "$companyPathDir" ];
then
	echo "$companyPathDir does not exist. Make the directory."
	/bin/mkdir "$companyPathDir"
	/bin/chmod 755 "$companyPathDir"
fi

# Time in seconds to automatically disable Presentation Mode. Default is 24 hours or 86400 seconds
disableTime="86400"

### End of values to modify ###

# Backup the current power settings plist. Delete the backup file if it exists
if [ -f "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup"];
then
	rm -rf "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup"
fi

/bin/cp "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist" "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup"

# Write the value in the plist to enable Presentation Mode
/usr/bin/defaults write "$companyPath" presentationmode "enabled"

# Run recon to evaluate plist for Casper Extension Attribute for Smart Group changes
/usr/local/bin/jamf recon

# Message to user that the Mac is in Presentation Mode and to disable in SS or auto-disable in 24 hours
/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "Mac is now in Presentation Mode. Please disable Presentation Mode using Self Service when you done. Presentation Mode will be automatically disabled in 24 hours" buttons {"OK"} default button 1
			    end tell
			EOF

# Create launchdaemon to 
echo "<?xml version="1.0" encoding="UTF-8"?> 
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> 
<plist version="1.0"> 
<dict>
	<key>Disabled</key>
	<true/>
	<key>Label</key> 
	<string>"$companyPlist".disablepm</string> 
	<key>ProgramArguments</key> 
	<array> 
		<string>/usr/local/jamf/bin/jamf</string>
		<string>policy</string>
		<string>-event</string>
		<string>disablePM</string>
	</array>
	<key>StartInterval</key>
	<integer>"$disableTime"</integer> 
</dict> 
</plist>" > /Library/LaunchDaemons/"$companyPlist".disablepm.plist

# Kill cfprefsd to apply new settings
# /usr/bin/killall cfprefsd

exit 0