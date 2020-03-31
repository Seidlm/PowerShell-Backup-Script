########################################################
# Name: BackupScript.ps1                              
# Creator: Michael Seidl aka Techguy                    
# CreationDate: 21.01.2014                              
# LastModified: 31.03.2020                               
# Version: 1.5
# Doc: http://www.techguy.at/tag/backupscript/
# GitHub: https://github.com/Seidlm/PowerShell-Backup-Script
# PSVersion tested: 3 and 4
#
# PowerShell Self Service Web Portal at www.au2mator.com/PowerShell
#
#
# Description: Copies the Bakupdirs to the Destination
# You can configure more than one Backupdirs, every Dir
# wil be copied to the Destination. A Progress Bar
# is showing the Status of copied MB to the total MB
# Only Change Variables in Variables Section
# Change LoggingLevel to 3 an get more output in Powershell Windows
# 
#
########################################################
#
# www.techguy.at                                        
# www.facebook.com/TechguyAT                            
# www.twitter.com/TechguyAT                             
# michael@techguy.at 

#
#
########################################################

#Variables, only Change here
$Destination = "\\SVATHOME002\Backup$\NB BaseIT" #Copy the Files to this Location
$Staging = "C:\Users\seimi\Downloads\Staging"
$ClearStaging = $true # When $true, Staging Dir will be cleared
$Versions = "15" #How many of the last Backups you want to keep
$BackupDirs = "C:\Users\seimi\Documents" #What Folders you want to backup

$ExcludeDirs = #This list of Directories will not be copied
($env:SystemDrive + "\Users\.*\AppData\Local")
#($env:SystemDrive + "\Users\.*\AppData\LocalLow"),
#"C:\Users\seimi\OneDrive - Seidl Michael\0-Temp",
#"C:\Users\seimi\OneDrive - Seidl Michael\0-Temp\Dir2"

$LogfileName = "Log" #Log Name
$LoggingLevel = "3" #LoggingLevel only for Output in Powershell Window, 1=smart, 3=Heavy
$Zip = $true #Zip the Backup Destination
$Use7ZIP = $false #Make sure it is installed
$RemoveBackupDestination = $true #Remove copied files after Zip, only if $Zip is true
$UseStaging = $false #only if you use ZIP, than we copy file to Staging, zip it and copy the ZIP to destination, like Staging, and to save NetworkBandwith



#Send Mail Settings
$SendEmail = $false                    # = $true if you want to enable send report to e-mail (SMTP send)
$EmailTo = 'test@domain.com'              #user@domain.something (for multiple users use "User01 &lt;user01@example.com&gt;" ,"User02 &lt;user02@example.com&gt;" )
$EmailFrom = 'from@domain.com'   #matthew@domain 
$EmailSMTP = 'smtp.domain.com' #smtp server adress, DNS hostname.


#STOP-no changes from here
#STOP-no changes from here
#Settings - do not change anything from here

$ExcludeString = ""
foreach ($Entry in $ExcludeDirs) {
    #Exclude the directory itself
    $Temp = "^" + $Entry.Replace("\", "\\") + "$"
    $ExcludeString += $Temp + "|"

    #Exclude the directory's children
    $Temp = "^" + $Entry.Replace("\", "\\") + "\\.*"
    $ExcludeString += $Temp + "|"
}
$ExcludeString = $ExcludeString.Substring(0, $ExcludeString.Length - 1)
[RegEx]$exclude = $ExcludeString

if ($UseStaging -and $Zip) {
    #Logging "INFO" "Use Temp Backup Dir"
    $Backupdir = $Staging + "\Backup-" + (Get-Date -format yyyy-MM-dd) + "-" + (Get-Random -Maximum 100000) + "\"
}
else {
    #Logging "INFO" "Use orig Backup Dir"
    $Backupdir = $Destination + "\Backup-" + (Get-Date -format yyyy-MM-dd) + "-" + (Get-Random -Maximum 100000) + "\"
}



#$BackupdirTemp=$Temp +"\Backup-"+ (Get-Date -format yyyy-MM-dd)+"-"+(Get-Random -Maximum 100000)+"\"
$logPath = $Backupdir

$Items = 0
$Count = 0
$ErrorCount = 0
$StartDate = Get-Date #-format dd.MM.yyyy-HH:mm:ss

#FUNCTION
#Logging

function Write-au2matorLog {
    [CmdletBinding()]
    param
    (
        [ValidateSet('DEBUG', 'INFO', 'WARNING', 'ERROR')]
        [string]$Type,
        [string]$Text
    )
       
    # Set logging path
    if (!(Test-Path -Path $logPath)) {
        try {
            $null = New-Item -Path $logPath -ItemType Directory
            Write-Verbose ("Path: ""{0}"" was created." -f $logPath)
        }
        catch {
            Write-Verbose ("Path: ""{0}"" couldn't be created." -f $logPath)
        }
    }
    else {
        Write-Verbose ("Path: ""{0}"" already exists." -f $logPath)
    }
    [string]$logFile = '{0}\{1}_{2}.log' -f $logPath, $(Get-Date -Format 'yyyyMMdd'), $LogfileName
    $logEntry = '{0}: <{1}> <{2}> {3}' -f $(Get-Date -Format dd.MM.yyyy-HH:mm:ss), $Type, $PID, $Text
    
    try { Add-Content -Path $logFile -Value $logEntry }
    catch {
        Start-sleep -Milliseconds 50
        Add-Content -Path $logFile -Value $logEntry
    }
    if ($LoggingLevel -eq "3") { Write-Host $Text }
    
    
}


#Create Backupdir
Function New-Backupdir {
    New-Item -Path $Backupdir -ItemType Directory | Out-Null
    Start-sleep -Seconds 5
    Write-au2matorLog -Type Info -Text "Create Backupdir $Backupdir"
}

#Delete Backupdir
Function Remove-Backupdir {
    $Folder = Get-ChildItem $Destination | where { $_.Attributes -eq "Directory" } | Sort-Object -Property CreationTime -Descending:$false | Select-Object -First 1

    Write-au2matorLog -Type Info -Text "Remove Dir: $Folder"
    
    $Folder.FullName | Remove-Item -Recurse -Force 
}


#Delete Zip
Function Remove-Zip {
    $Zip = Get-ChildItem $Destination | where { $_.Attributes -eq "Archive" -and $_.Extension -eq ".zip" } | Sort-Object -Property CreationTime -Descending:$false | Select-Object -First 1

    Write-au2matorLog -Type Info -Text "Remove Zip: $Zip"
    
    $Zip.FullName | Remove-Item -Recurse -Force 
}

#Check if Backupdirs and Destination is available
function Check-Dir {
    Write-au2matorLog -Type Info -Text "Check if BackupDir and Destination exists"
    if (!(Test-Path $BackupDirs)) {
        return $false
        Write-au2matorLog -Type Error -Text "$BackupDirs does not exist"
    }
    if (!(Test-Path $Destination)) {
        return $false
        Write-au2matorLog -Type Error -Text "$Destination does not exist"
    }
}

#Save all the Files
Function Make-Backup {
    Write-au2matorLog -Type Info -Text "Started the Backup"
    $BackupDirFiles = @{ } #Hash of BackupDir & Files
    $Files = @()
    $SumMB = 0
    $SumItems = 0
    $SumCount = 0
    $colItems = 0
    Write-au2matorLog -Type Info -Text "Count all files and create the Top Level Directories"

    foreach ($Backup in $BackupDirs) {
        # Get recursive list of files for each Backup Dir once and save in $BackupDirFiles to use later.
        # Optimize performance by getting included folders first, and then only recursing files for those.
        # Use -LiteralPath option to work around known issue with PowerShell FileSystemProvider wildcards.
        # See: https://github.com/PowerShell/PowerShell/issues/6733

        $Files = Get-ChildItem -LiteralPath $Backup -recurse -Attributes D+!ReparsePoint, D+H+!ReparsePoint -ErrorVariable +errItems -ErrorAction SilentlyContinue | 
        ForEach-Object -Process { Add-Member -InputObject $_ -NotePropertyName "ParentFullName" -NotePropertyValue ($_.FullName.Substring(0, $_.FullName.LastIndexOf("\" + $_.Name))) -PassThru -ErrorAction SilentlyContinue } |
        Where-Object { $_.FullName -notmatch $exclude -and $_.ParentFullName -notmatch $exclude } |
        Get-ChildItem -Attributes !D -ErrorVariable +errItems -ErrorAction SilentlyContinue | Where-Object { $_.DirectoryName -notmatch $exclude }
        $BackupDirFiles.Add($Backup, $Files)

        $colItems = ($Files | Measure-Object -property length -sum) 
        $Items = 0
        Copy-Item -LiteralPath $Backup -Destination $Backupdir -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch $exclude }
        $SumMB += $colItems.Sum.ToString()
        $SumItems += $colItems.Count
    }

    $TotalMB = "{0:N2}" -f ($SumMB / 1MB) + " MB of Files"
    Write-au2matorLog -Type Info -Text "There are $SumItems Files with  $TotalMB to copy"

    #Log any errors from above from building the list of files to backup.
    [System.Management.Automation.ErrorRecord]$errItem = $null
    foreach ($errItem in $errItems) {
        Write-au2matorLog -Type ERROR -Text ("Skipping `"" + $errItem.TargetObject + "`" Error: " + $errItem.CategoryInfo)
    }
    Remove-Variable errItem
    Remove-Variable errItems

    foreach ($Backup in $BackupDirs) {
        $Index = $Backup.LastIndexOf("\")
        $SplitBackup = $Backup.substring(0, $Index)
        $Files = $BackupDirFiles[$Backup]

        foreach ($File in $Files) {
            $restpath = $file.fullname.replace($SplitBackup, "")
            try {
                # Use New-Item to create the destination directory if it doesn't yet exist. Then copy the file.
                New-Item -Path (Split-Path -Path $($Backupdir + $restpath) -Parent) -ItemType "directory" -Force -ErrorAction SilentlyContinue | Out-Null
                Copy-Item -LiteralPath $file.fullname $($Backupdir + $restpath) -Force -ErrorAction SilentlyContinue | Out-Null
                Write-au2matorLog -Type Info -Text $("'" + $File.FullName + "' was copied")
            }
            catch {
                $ErrorCount++
                Write-au2matorLog -Type Error -Text $("'" + $File.FullName + "' returned an error and was not copied")
            }
            $Items += (Get-item -LiteralPath $file.fullname).Length
            $status = "Copy file {0} of {1} and copied {3} MB of {4} MB: {2}" -f $count, $SumItems, $file.Name, ("{0:N2}" -f ($Items / 1MB)).ToString(), ("{0:N2}" -f ($SumMB / 1MB)).ToString()
            $Index = [array]::IndexOf($BackupDirs, $Backup) + 1
            $Text = "Copy data Location {0} of {1}" -f $Index , $BackupDirs.Count
            Write-Progress -Activity $Text $status -PercentComplete ($Items / $SumMB * 100)  
            if ($File.Attributes -ne "Directory") { $count++ }
        }
    }
    $SumCount += $Count
    $SumTotalMB = "{0:N2}" -f ($Items / 1MB) + " MB of Files"
    Write-au2matorLog -Type Info -Text "----------------------"
    Write-au2matorLog -Type Info -Text "Copied $SumCount files with $SumTotalMB"
    Write-au2matorLog -Type Info -Text "$ErrorCount Files could not be copied"


    # Send e-mail with reports as attachments
    if ($SendEmail -eq $true) {
        $EmailSubject = "Backup Email $(get-date -format MM.yyyy)"
        $EmailBody = "Backup Script $(get-date -format MM.yyyy) (last Month).`nYours sincerely `Matthew - SYSTEM ADMINISTRATOR"
        Write-au2matorLog -Type Info -Text "Sending e-mail to $EmailTo from $EmailFrom (SMTPServer = $EmailSMTP) "
        ### the attachment is $log 
        Send-MailMessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -Body $EmailBody -SmtpServer $EmailSMTP -attachment $Log 
    }
}

#create Backup Dir

New-Backupdir
Write-au2matorLog -Type Info -Text "----------------------"
Write-au2matorLog -Type Info -Text "Start the Script"

#Check if Backupdir needs to be cleaned and create Backupdir
$Count = (Get-ChildItem $Destination | where { $_.Attributes -eq "Directory" }).count
Write-au2matorLog -Type Info -Text "Check if there are more than $Versions Directories in the Backupdir"

if ($count -gt $Versions) {
    Write-au2matorLog -Type Info -Text "Found $count Backups"
    Remove-Backupdir
}


$CountZip = (Get-ChildItem $Destination | where { $_.Attributes -eq "Archive" -and $_.Extension -eq ".zip" }).count
Write-au2matorLog -Type Info -Text "Check if there are more than $Versions Zip in the Backupdir"

if ($CountZip -gt $Versions) {

    Remove-Zip 

}

#Check if all Dir are existing and do the Backup
$CheckDir = Check-Dir

if ($CheckDir -eq $false) {
    Write-au2matorLog -Type Error -Text "One of the Directories are not available, Script has stopped"
}
else {
    Make-Backup

    $Enddate = Get-Date #-format dd.MM.yyyy-HH:mm:ss
    $span = $EndDate - $StartDate
    $Duration = $("Backup duration " + $span.Hours.ToString() + " hours " + $span.Minutes.ToString() + " minutes " + $span.Seconds.ToString() + " seconds")

    Write-au2matorLog -Type Info -Text "$Duration"
    Write-au2matorLog -Type Info -Text "----------------------"
    Write-au2matorLog -Type Info -Text "----------------------" 

    if ($Zip) {
        Write-au2matorLog -Type Info -Text "Compress the Backup Destination"
        
        if ($Use7ZIP) {
            Write-au2matorLog -Type Info -Text "Use 7ZIP"
            if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) { Write-au2matorLog -Type Warning -Text "7Zip not found" } 
            set-alias sz "$env:ProgramFiles\7-Zip\7z.exe" 
            #sz a -t7z "$directory\$zipfile" "$directory\$name"    
                    
            if ($UseStaging -and $Zip) {
                $Zip = $Staging + ("\" + $Backupdir.Replace($Staging, '').Replace('\', '') + ".zip")
                sz a -t7z $Zip $Backupdir
                
                Write-au2matorLog -Type Info -Text "Move Zip to Destination"
                Move-Item -Path $Zip -Destination $Destination

                if ($ClearStaging) {
                    Write-au2matorLog -Type Info -Text "Clear Staging"
                    Get-ChildItem -Path $Staging -Recurse -Force | remove-item -Confirm:$false -Recurse -force
                }

            }
            else {
                sz a -t7z ($Destination + ("\" + $Backupdir.Replace($Destination, '').Replace('\', '') + ".zip")) $Backupdir
            }
                
        }
        else {
            Write-au2matorLog -Type Info -Text "Use Powershell Compress-Archive"
            Compress-Archive -Path $Backupdir -DestinationPath ($Destination + ("\" + $Backupdir.Replace($Destination, '').Replace('\', '') + ".zip")) -CompressionLevel Optimal -Force

        }

        If ($RemoveBackupDestination) {
            Write-au2matorLog -Type Info -Text "$Duration"

            #Remove-Item -Path $BackupDir -Force -Recurse 
            get-childitem -Path $BackupDir -recurse -Force | remove-item -Confirm:$false -Recurse
            get-item -Path $BackupDir | remove-item -Confirm:$false -Recurse
        }
    }
}

Write-Host "Press any key to close ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
