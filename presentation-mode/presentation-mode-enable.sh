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

########## MODIFY FOR YOUR COMPANY ENVIRONMENT ##########

# Modify path to the company plist /PATH/TO/COMPANY/PLIST e.g. /Library/Company/com.company.group
companyPath="/PATH/TO/COMPANY/PLIST"
echo "$companyPath"

# Obtain plist filename from company path. Generally, no modification needed.
companyPlist=`echo ${companyPath##*/}`
echo "$companyPlist"

# Obtain the directory in the company path to confirm the directory exists. Generally, no modification needed.
companyPathDir=`echo $companyPath | sed 's:/[^/]*$::'`
echo "$companyPathDir"

# If the directory in the company path does not exist, then create it so we can write the plist to it
# Modify chmod permissions if needed
if [ ! -d "$companyPathDir" ];
then
	echo "$companyPathDir does not exist. Make the directory."
	/bin/mkdir "$companyPathDir"
	/bin/chmod 755 "$companyPathDir"
fi

# Time in seconds to automatically disable Presentation Mode. Default is 24 hours or 86400 seconds
disableTime="86400"

########## END OF MODIFY ##########

# Backup the current power settings plist. Delete the backup file if it exists
if [ -f "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup" ];
then
	rm -rf "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup"
fi

echo "Backing up power management settings"
/bin/cp "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist" "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup"

# Write the value in the plist to enable Presentation Mode
echo "Write value in plist for presentationmode to be enabled"
/usr/bin/defaults write "$companyPath" presentationmode "enabled"

# Run recon to evaluate plist for Casper Extension Attribute for Smart Group changes
echo "Run recon to update inventory for EA and Smart Groups"
/usr/local/bin/jamf recon

########## CREATE LAUNCHDAEMON ##########

# Check if launchdaemon exists and delete it if it does
if [ -f "/Library/LaunchDaemons/$companyPlist.disablepm.plist" ];
then 
	echo "Deleting disablepm LaunchDaemon"
	rm -f "/Library/LaunchDaemons/$companyPlist.disablepm.plist"
fi

# Create launchdaemon to automatically disable presentation mode at desired time limit
echo "Create the launchdaemon to disable presentation mode"
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
		<string>/bin/sh</string>
		<string>"$companyPathDir"/disablePM.sh</string>
	</array>
	<key>StartInterval</key>
	<integer>"$disableTime"</integer> 
</dict> 
</plist>" > /Library/LaunchDaemons/"$companyPlist".disablepm.plist

# Set permissions on the launchdaemon plist
echo "Set permissions on the launchdaemon"
/usr/sbin/chown root:wheel "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"
/bin/chmod 644 "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"
/usr/bin/defaults write "/Library/LaunchDaemons/"$companyPlist".disablepm.plist" disabled -bool false

# Load the launchdaemon
echo "Load the launchdaemon"
/bin/launchctl load -w "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"

########## END LAUNCHDAEMON ##########

########## CREATE AUTO DISABLE PM SCRIPT ##########

# Check if disablePM script exists and delete it if it does
if [ -f "$companyPathDir/disablePM.sh" ];
then 
	echo "Deleting disablePM script"
	rm -f "$companyPathDir/disablePM.sh"
fi

echo "Create the auto disable presentation mode script on the local drive"
echo "#!/bin/sh
# Automatically Disables Presentation Mode
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
rm -f "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist"
echo "Copy the backup of the original power management settings to be used by machine again"
/bin/cp -f "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup" "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist"
echo "Remove the backup of the power management settings"
rm -f "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup"
# Kill cfprefsd to apply power management settings
echo "Kill cfprefsd to apply the original power management settings"
/usr/bin/killall cfprefsd
# Unload and remove the launchdaemon
echo "Disable the launchdaemon"
/usr/bin/defaults write "/Library/LaunchDaemons/"$companyPlist".disablepm.plist" disabled -bool true
echo "Unload the launchdaemon"
/bin/launchctl unload -w "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"
echo "Remove the launchdaemon"
rm -f "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"
echo "Presentation Mode launchdaemon unloaded and removed"
# Message to user that the Mac is in Presentation Mode and is being automatically disabled now
/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "Presentation Mode is being disabled either through Self Service, or it has reached the automatic disable timeout. Thank you for using Presentation Mode!" buttons {"OK"} default button 1
			    end tell
			EOF
echo "Presentation Mode has been disabled. Original power settings have been restored."
rm -f "$companyPathDir/disablePM.sh"
exit 0" > "$companyPathDir/disablePM.sh"

# Set permissions on the auto disable PM script
echo "Set permissions on the auto disable presentation mode script"
/usr/sbin/chown root:wheel "$companyPathDir/disablePM.sh"
/bin/chmod 644 "$companyPathDir/disablePM.sh"

########## END AUTO DISABLE PM SCRIPT ##########

# Message to user that the Mac is in Presentation Mode and to disable in SS or auto-disable in 24 hours
/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "Mac is now in Presentation Mode. Please disable Presentation Mode using Self Service when you are done. Presentation Mode will be automatically disabled in 24 hours." buttons {"OK"} default button 1
			    end tell
			EOF

# Quit System Preferences in case it is currently open
/usr/bin/osascript -e 'quit app "System Preferences"'

# Get the logged in user to set the screen saver settings to Never with value of 0 to disable the screen saver
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
su -l "$loggedInUser" -c "defaults -currentHost write com.apple.screensaver idleTime 0"

# Kill cfprefsd to apply new settings
/usr/bin/killall cfprefsd

# Commented out. Run recon in JSS policy payload to update inventory.
# Run recon again to apply configuration profiles, such as energy saver settings, after Smart Group changes
#echo "Run recon to apply configuration profiles"
#/usr/local/bin/jamf recon

echo "Presentation Mode set to enabled. Launchdaemon created to automatically disable Presentation Mode in $disableTime seconds"

exit 0
