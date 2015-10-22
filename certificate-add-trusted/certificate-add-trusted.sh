#!/bin/sh

# certificate-add-trusted.sh

# Used to add a certificate to Keychain as trusted
# Can be ran in a policy in Casper as run once per user, per computer
# Package the certificate and put it in a temporary location such as /private/tmp/

# Alex Kim - EEI, UC Berkeley
# 2015.10.21

# How to use:
# 1. Modify the path to the certificate to import
# 2. Modify the identifying certificate name that would show up in "security dump-keychain" to check if the certificate already exists or not. One can also use any distinct part of the name.
# 3. Change values from 0 to 1 to import to System and/or login Keychain

# Certificate to import
certImport="/PATH/TO/CERT.CER"
echo "$certImport"

# Identifying name or distinct part of the name of certificate
certName="NAME-OF-CERTIFICATE"
echo "$certName"

# Import to System Keychain, change value to 1
importSystem="0"

# Import to logged in user's login Keychain, change value to 1
importLogin="0"

# Get currently logged in user
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
echo "$loggedInUser"

########## IMPORT CERTIFICATE TO SYSTEM KEYCHAIN ##########
# Grep the dump-keychain results of System Keychain to look for certificate to import
systemCertExists=`/usr/bin/security dump-keychain "/Library/Keychains/System.keychain" | grep "$certName"`
echo "$systemCertExists"

# If import System Keychain is set to yes with value 1 AND systemCertExists is null so it does not already exist then import the certificate"
if [[ "$importSystem" = "1" ]] && [[ -z "$systemCertExists" ]];
then
	echo "Import certificate into System Keychain"
	/usr/bin/security add-trusted-cert -d -r trustAsRoot -k "/Library/Keychains/System.keychain" "$certImport"
else
	echo "No import to System Keychain"
fi

########## IMPORT CERTIFICATE TO USER LOGIN KEYCHAIN ##########
# Grep the dump-keychain results of user's login Keychain to look for certificate to import
loginCertExists=`/usr/bin/security dump-keychain "/Users/$loggedInUser/Library/Keychains/login.keychain" | grep "$certName"`
echo "$loginCertExists"

# If import System Keychain is set to yes with value 1 AND systemCertExists is null so it does not already exist then import the certificate"
if [[ "$importLogin" = "1" ]] && [[ -z "$loginCertExists" ]];
then
	echo "Import certificate into user's login Keychain"
	/usr/bin/security add-trusted-cert -d -r trustAsRoot -k "/Users/$loggedInUser/Library/Keychains/login.keychain" "$certImport"
else
	echo "No import to user's login Keychain"
fi

# Delete the certificate from the temporary location
echo "Deleting the certificate from temp location"
rm -f "$certImport"

echo "Finished importing certificate"

exit 0
