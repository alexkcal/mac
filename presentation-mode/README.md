This ReadMe file is horribly written, probably too wordy, maybe not enough info, grammatically incorrect, and needs revision. However, it should be accurate enough to get Presentation Mode setup in your Casper JSS. It will be revised to make more sense later. Signed, author.

Please open issues in GitHub or contact me if you notice errors or other problems, which there may be and probably could be.

October 19, 2015 - Successfully tested in Mac OS X Yosemite and El Capitan using Casper version 9.81

- All examples are using the default setup and values in the script:
   - Company's plist is in a company directory in /Library, e.g. /Library/Company/com.company.group
   - Automatic disabling of presentation mode is 24 hours, or 86400 seconds
- If your setup is the same, then you probably only need to modify the first variable "companyPath" in both the enable and disable script. Change the value "/PATH/TO/COMPANY/PLIST" to your company's plist.
- If you would like to change the automatic disable timeout from 24 hours, or 86400 seconds, then change the value of the variable "disableTime" in the enable script to whatever amount of time you would like in seconds.

###Creating Presentation Mode in Self Service in Casper's JSS###

1. Create a new Extension Attribute for a value in your company's plist. If you do not use a company plist, then you may target a dummy file or create a new plist anywhere. The script is written for the plist though, so modify the script if you change the EA.

Example of Extension Attribute
Display Name: Presentation Mode
Data Type: String
Inventory Display: Extension Attributes (or wherever you would like it to be displayed)
Input Type: Script
Script:

```
#!/bin/sh
pmMode=`defaults read /Library/EEI/edu.berkeley.eei presentationmode`

if [ $pmMode == "" ]; then
	echo "<result>No Value</result>"
else
	echo "<result>$pmMode</result>"
fi
```

2. Create a new Smart Group with the criteria of your production Smart Group AND looking for the desired 

value of the EA created in the last step.

Example of Criteria
Name: Presentation Mode
Computer Group member of Production-Macs
and
Presentation Mode is enabled

3. If not done so already, create a Configuration Profile with your desired Screen Saver settings if not 

already done. Scope it to your existing Smart Group that you would like it to apply to, such as your 

production Mac group. Add the Presentation Mode Smart Group into the Exclusions list

4. Create a new Configuration Profile to change the power settings on AC Power and Battery to full and no 

hibernation and sleep

Example of Configuration Profile
Name: Presentation Mode Energy Saver Settings
Distribution Method: Install Automatically
Level: Computer Level

Energy Saver Payload - Modify as needed
Desktop Tab
Uncheck both Sleep Options - Sets it to never Sleep
Uncheck Put the hard disk(s) to sleep whenever possible - Sets to never sleep the HD
Keep Wake for Ethernet and Allow power button both checked
Uncheck Start up automatically after a power failire

Do the same on the Portable tab, but you must configure the settings for both Battery and Power Adapter sub-tabs

Schedule Tab - leave both unchecked

Scope
Add the Smart Group Presentation Mode
No exclusions


6. Upload the two scripts: presentation-mode-enable.sh and presentation-mode-disable to the JSS

- Modify the variables to match your company's environment (e.g. plist location, automatic disable timeout, 

etc)
- You will need to modify the plist location in both the enable and disable scripts



6. Create a new Self Service policy to enable Presentation Mode

General Tab

Policy Name: Presentation Mode Enable (or whatever you would like to call it)

Execution Frequency: Ongoing
Add Payload Scripts: Add presentation-mode-enable.sh
Add Payload Maintance: Update Inventory
- this is used to apply the new config profiles and for SS to auto update after running

Optional: Remove Payload Restart Options if you would like

Scope Tab
Target your production group. Probably target your test group first for testing. Then add the production 

group.
Exclusions: Add the Presentation Mode Smart Group that was created above so that the Self Service offer to 

enable Presentation Mode does not display when it is already enabled.

Self Service Tab
Make it available in Self Service.
Button Name: Enable
Type a description and select an icon, such as the Keynote icon.



7. Create another new Self Service policy to disable Presentation Mode
General Tab

Policy Name: Presentation Mode Disable (or whatever you would like to call it)

Execution Frequency: Ongoing

IMPORTANT: Check the box "Custom" to add a custom trigger. The default custom trigger is "disablePM". You can modify this in the enable script, but the script and JSS must match for the automatic disable to work from the launchdaemon.
Optional: Check the box "Make Available Offline" if you would like to cache the disable script so that the 

automatic disable will still run even if the computer goes offline.

Add Payload Scripts: Add presentation-mode-disable.sh

Add Payload Maintance: Update Inventory
- this is used to apply the new config profiles and for SS to auto update after running

Optional: Remove Payload Restart Options if you would like

Scope Tab
Target the Presentation Mode Smart Group that was created above.

Self Service Tab
Make it available in Self Service.
Button Name: Disable
Type a description and select an icon, such as the Keynote icon.



8. Test the Self Service Offer to enable Presentation Mode. Test the Self Service offer to disable 

Presentation Mode. It should appear in Self Service only after enabling Presentation Mode. If you would like 

to test the automatic disable timeout, temporarily change the "disableTime" in the enable script to 

something shorter like "60" seconds.

9. If testing is successful, send to production. Receive flowers from your Presenters.
