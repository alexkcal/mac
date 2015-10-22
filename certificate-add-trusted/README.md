##Adding a Trusted Certificate

Used this script to add a certificate as trusted to the System Keychain and/or the logged in user's login keychain.  

######Modifying the Variables in the Script######
- Certificate name and location: directory path and certificate name, e.g. /private/tmp/certificate.cer
- Certificate identifier name or some distinct part of the name:
 - view the certificate's details or use the command "security dump-keychain" after the cert has been added on a test machine to get this info
- Changes one or both values from 0 to 1 to enable adding it to the System and/or login keychain

######Method 1: Standalone Install Package######
1. Obtain the certificate you would to deploy. Place it in a temporary location such as /private/tmp/
2. Use a packaging application such as JAMF Composer or WhiteBox Packages and package the certificate. Do not build the package yet until adding the postflight script next.
3. Add the updated script as a postflight script to the package

######Method 2: Using JAMF Casper Suite######
1. Obtain the certificate you would to deploy. Place it in a temporary location such as /private/tmp/
2. Use a packaging application such as JAMF Composer or WhiteBox Packages and package the certificate. Build the package now.
3. Create a new policy in Casper
4. Add the certificate package as one payload
5. Add script as another payload
6. Deploy