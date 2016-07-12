#!/bin/sh

# mac-config-default.sh
# Alex Kim

# Example of a default configuration for a new install of Mac OS X

#####
# Bonjour Protocol
#####
# Disable Bonjour so it does not advertise or broadcast available services on the network
/usr/libexec/PlistBuddy -c "Add :ProgramArguments: string '-NoMulticastAdvertisements'" /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist

# Enable Bonjour to advertise services on the network
# /usr/libexec/PlistBuddy -c "Delete :ProgramArguments:2" /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist

# Unload and Load the LaunchDaemon for Bonjour
launchctl unload /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
launchctl load /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist

exit 0
