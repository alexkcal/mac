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

if [ -f "/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.backup" ];
then
	# Unload and remove the launchdaemon
	echo "Disable the launchdaemon"
	/usr/bin/defaults write "/Library/LaunchDaemons/"$companyPlist".disablepm.plist" disabled -bool true
	
	echo "Unload the launchdaemon"
	/bin/launchctl unload -w "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"
	
	echo "Remove the launchdaemon"
	rm -f "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"
	
	echo "Presentation Mode launchdaemon unladed and removed"
fi

# Commented out. Run recon in JSS policy payload to update inventory.
# Run recon again to apply configuration profiles, such as screen saver, after Smart Group changes
#echo "Run recon to apply configuration profiles"
#/usr/local/bin/jamf recon

exit 0
