########################################################
# Name: BackupScript.ps1                              
# Creator: Michael Seidl aka Techguy                    
# CreationDate: 21.01.2014                              
# LastModified: 19.02.2019                               
# Version: 1.4
# Doc: http://www.techguy.at/tag/backupscript/
# PSVersion tested: 3 and 4
#
# Description: Copies the Bakupdirs to the Destination
# You can configure more than one Backupdirs, every Dir
# wil be copied to the Destination. A Progress Bar
# is showing the Status of copied MB to the total MB
# Only Change Variables in Variables Section
# Change LoggingLevel to 3 an get more output in Powershell Windows
# 
#
# Beschreibung: Kopiert die BackupDirs in den Destination
# Ordner. Es können mehr als nur ein Ordner angegeben
# werden. Der Prozess wid mit einem Statusbar angezeigt
# diese zeigt die kopieren MB im Vergleich zu den gesamten
# MB an.
# Nur die Werte unter Variables ändern
# Ändere den Logginglevel zu 3 und erhalte die gesamte Ausgabe im PS Fenster
# Version 1.4
#               NEW: 7ZIP Support
#               FIX: Ordering at old Backup deletion
#               FIX: Exclude Dir is now working
#               NEW: Staging folder for ZIP
# Version 1.3 - NEW: Send Mail Function
#               NEW: Backup Destination will be zipped
#               NEW: Exclude Dir
#               FIX: Logging Level
#               FIX: Delete old Folder by CreationTime
#
# Version 1.2 - FIX: Delete last Backup dirs, changed to support older PS Version
#               FIX: Fixed the Count in the Statusbar
#               FIX: Fixed Location Count in Statusbar
#
# Version 1.1 - CHANGE: Enhanced the Logging to a Textfile and write output, copy Log file to Backupdir
#             - FIX: Renamed some Variables an have done some cosmetic changes
#             - CHANGE: Define the Log Name in Variables
#
# Version 1.0 - RTM
########################################################
#
# www.techguy.at                                        
# www.facebook.com/TechguyAT                            
# www.twitter.com/TechguyAT                             
# michael@techguy.at 
########################################################
