#!/bin/sh

# Use this script in the JSS as a separate policy with a custom trigger that gets called in the disable presentation mode script. It will unload and remove the launchdaemon that automatically disables presentation mode.

# Unload and remove the launchdaemon
echo "Disable the launchdaemon"
/usr/bin/defaults write "/Library/LaunchDaemons/"$companyPlist".disablepm.plist" disabled -bool true
	
echo "Unload the launchdaemon"
/bin/launchctl unload -w "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"
	
echo "Remove the launchdaemon"
rm -f "/Library/LaunchDaemons/"$companyPlist".disablepm.plist"
	
echo "Presentation Mode launchdaemon unloaded and removed"

exit 0
