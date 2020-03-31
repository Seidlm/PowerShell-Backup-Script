# Name: BackupScript.ps1
    Creator: Michael Seidl aka Techguy
    CreationDate: 21.01.2014
    LastModified: 31.03.2020
    Version: 1.5
    Doc: http://www.techguy.at/tag/backupscript/
    GitHub: https://github.com/Seidlm/PowerShell-Backup-Script
    PSVersion tested: 3 and 4


# PowerShell Self Service Web Portal at www.au2mator.com/PowerShell


# Description: 
Copies the Bakupdirs to the Destination
You can configure more than one Backupdirs, every Dir
wil be copied to the Destination. A Progress Bar
is showing the Status of copied MB to the total MB
Only Change Variables in Variables Section
Change LoggingLevel to 3 an get more output in Powershell Windows
 
# Version 1.5 (31.03.2020)
    FIX: Github: Symbolic Links are now supported
    FIX: Github: Sibling Folders
    FIX: Github: Backup Duration
    NEW: Rewrite Loggign Function
    DIF: Some Code write ups
# Version 1.4
    NEW: 7ZIP Support
    FIX: Ordering at old Backup deletion
    FIX: Exclude Dir is now working
    NEW: Staging folder for ZIP
# Version 1.3
    NEW: Send Mail Function
    NEW: Backup Destination will be zipped
    NEW: Exclude Dir
    FIX: Logging Level
    FIX: Delete old Folder by CreationTime

# Version 1.2
    FIX: Delete last Backup dirs, changed to support older PS Version
    FIX: Fixed the Count in the Statusbar
    FIX: Fixed Location Count in Statusbar

# Version 1.1 
    CHANGE: Enhanced the Logging to a Textfile and write output, copy Log file to Backupdir
    FIX: Renamed some Variables an have done some cosmetic changes
    CHANGE: Define the Log Name in Variables

# Version 1.0 - RTM

# Notes
    www.techguy.at
    www.facebook.com/TechguyAT
    www.twitter.com/TechguyAT
    michael@techguy.at
