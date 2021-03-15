
param(
[Parameter(Mandatory=$True)]$QBBackupDir,
[Parameter(Mandatory=$True)]$QBDataDir,
[Parameter(Mandatory=$True)]$BackupDays,
[Parameter(Mandatory=$True)]$AutoBackup,
[Parameter(Mandatory=$True)]$SMTPServer,
[Parameter(Mandatory=$True)]$SMTPServerPort,
[Parameter(Mandatory=$True)]$EmailFrom,
[Parameter(Mandatory=$True)]$EmailFromPassword,
[Parameter(Mandatory=$True)]$ReportEmailTo,
[Parameter(Mandatory=$True)]$ReportEmailSubject,
[Parameter(Mandatory=$True)]$AlertEmailTo,
[Parameter(Mandatory=$True)]$SendReport,
[Parameter(Mandatory=$True)]$ReportEmailBody
)

   Function CC-SendMail {

    param(
        [Parameter(Mandatory=$False)]
        $SMTPServer,
        $SMTPServerPort,
        $EmailFrom,
        $EmailFromPassword,
        $EmailTo,
        $Subject,
        $Body
    )

    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
    $SMTPMessage.IsBodyHtml = $True
    $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPServerPort) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $EmailFromPassword);
    $SMTPClient.Send($SMTPMessage)   

    }
    Function Set-AlternatingRows {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory,ValueFromPipeline)]
            [string]$Line,
           
            [Parameter(Mandatory)]
            [string]$CSSEvenClass,
           
            [Parameter(Mandatory)]
            [string]$CSSOddClass
        )
        Begin {
            $ClassName = $CSSEvenClass
        }
        Process {
            If ($Line.Contains("<tr><td>"))
            {   $Line = $Line.Replace("<tr>","<tr class=""$ClassName"">")
                If ($ClassName -eq $CSSEvenClass)
                {   $ClassName = $CSSOddClass
                }
                Else
                {   $ClassName = $CSSEvenClass
                }
            }
            Return $Line
        }
    }

$QBBackupDir = $QBBackupDir.split(",")
$QBBackupDir = $QBBackupDir -replace "^\s"
$QBDataDir = $QBDataDir.split(",")
$QBDataDir = $QBDataDir -replace "^\s"

$QBBackupArray = @()
$QBDataArray = @()
$BackupFileList = @()

$Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;width: 95%}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
.odd { background-color:#ffffff; }
.even { background-color:#dddddd; }
</style>
"@

#Check QB Data Dir
foreach($datalocation in $QBDataDir)
    {
        $datalocation = Get-Childitem $datalocation -Include "*.QBW" -Recurse | select -ExpandProperty Name
        
        foreach($datafile in $datalocation)
            {
                $datafilenew = $datafile | Out-String
                $datafilenew = $datafilenew.Replace(".qbw","")
                $datafilenew = $datafilenew.Replace("`n","")

               
                $QBDataArray += $datafilenew
                
            }
    }
#Check QB Backup / Count
$date = [datetime]::Today.AddDays($BackupDays)
foreach($backuplocation in $QBBackupDir)
    {
     $blocmain = Get-Childitem $backuplocation -Include "*.QBB" -Recurse
     foreach($i in $blocmain)
        {
                $backupffile = $i.Name -replace '\s\w{1,3}\s\d{1,2},\d{1,4}\s{1,3}\d{1,2}\s\d{1,2}\s\w{1,2}'
                $backupffile = $backupffile -replace '\w{1,3}_\d_'
                $backupffile = $backupffile -replace  '\s\(\w{1,6}\)'
                $backupffile = $backupffile -replace  '\.\w{3}'
                $backupfdate = $i.Name -match '\w{3}\s\d{2},\d{4}'
                $backupfdate = $Matches[0]
                $Obj = New-Object System.Object
                $Obj | Add-Member -type NoteProperty -name Name -Value $backupffile
                $Obj | Add-Member -type NoteProperty -name Date -Value $backupfdate
                $Obj | Add-Member -type NoteProperty -name FilePath -Value ($i.FullName)
                $BackupFileList += $Obj
        }
     $bloc = $blocmain | where {$_.LastWriteTime -gt $date} 
          foreach($backupitem in $bloc)
            {
                $backupitem1 = $backupitem.Name -replace '\s\w{1,3}\s\d{1,2},\d{1,4}\s{1,3}\d{1,2}\s\d{1,2}\s\w{1,2}'
                $backupitem1 = $backupitem1 -replace '\w{1,3}_\d_'
                $backupitem1 = $backupitem1 -replace '\s\(\w{1,6}\)'
                $backupitem1 = $backupitem1 -replace '\.\w{3}'
                $backupitemdate = $backupitem.Name -match '\w{3}\s\d{2},\d{4}'
                $backupitemdate = $Matches[0]
                $Obj = New-Object System.Object
                if("$QBDataArray" -like "*$backupitem1*")
                    {
                        $Obj | Add-Member -type NoteProperty -name CompanyFile -Value $backupitem1
                        $Obj | Add-Member -type NoteProperty -name Result -Value "Success"
                        $Obj | Add-Member -type NoteProperty -name LastBackup -Value $backupitemdate
                        $Obj | Add-Member -type NoteProperty -name FilePath -Value ($backupitem.FullName)
                    }
                else{
                        $Obj | Add-Member -type NoteProperty -name CompanyFile -Value $backupitem1
                        if($AutoBackup -eq $true)
                        {
                        $RunTask = Get-ScheduledTask -TaskPath "\" | where {$_.TaskName -like "*$backupitem1*"}
                        if($RunTask -notlike $Null)
                            {
                                $RunTask | Start-ScheduledTask
                                $c = 0
                                do{
                                    $c++
                                    sleep 2
                                    $RunTask = Get-ScheduledTask -TaskPath "\" | where {$_.TaskName -like "*$backupitem1*"}
                                    $loopdir = Get-Childitem $backuplocation -Include "*.QBB" | where {$_.Name -like "*$backupitem1*.QBB"} | select -first 1
                                    if($RunTask.State -like "Ready" -and $loopdir.LastWriteTime -ge $date)
                                        {
                                            $TaskRunItem = $loopdir.Name -replace '\s\w{1,3}\s\d{1,2},\d{1,4}\s{1,3}\d{1,2}\s\d{1,2}\s\w{1,2}'
                                            $TaskRunItem = $TaskRunItem -replace '\w{1,3}_\d_'
                                            $TaskRunItem = $backupitem1 -replace '\s\(\w{1,6}\)'
                                            $TaskRunItem = $TaskRunItem -replace '\.\w{3}'
                                            $TaskRunItemDate = $Loopdir.Name -match '\w{3}\s\d{2},\d{4}'
                                            $TaskRunItemDate = $Matches[0]
                                            $State = "Success"
                                            $backupitemdate = $TaskRunItemDate
                                        }
                                }while($c -le 60)
                            }
                            else{ $state = "Failed" }
                        }
                        $Obj | Add-Member -type NoteProperty -name Result -Value $state
                        $Obj | Add-Member -type NoteProperty -name LastBackup -Value $backupitemdate
                        $Obj | Add-Member -type NoteProperty -name FilePath -Value ($loopdir.FullName)

                        $lastbackupitem = $backupitem1 -replace '\n',''
                        $lastbackupitem = $lastbackupitem -replace '\r',''
                        if(!($AlertEmailTo -eq $false -or $AlertEmailTo -eq ""))
                        {
                        CC-SendMail -Body "Failed $lastbackupitem" -SMTPServer $SMTPServer -SMTPServerPort $SMTPServerPort -EmailFrom $EmailFrom -EmailFromPassword $EmailFromPAssword -Emailto $AlertEmailTo -Subject "Quickbooks Backup - $lastbackupitem - Failed!"
                        }
                    }

                $QBBackupArray += $Obj
            
        }

        
}

$p = $QBBackupArray | select -ExpandProperty CompanyFile
 foreach($t in $QBDataArray ){
            $t = $t -replace '\n',''
            $t = $t -replace '\r',''
            if("$p" -notlike "*$t*")
                {
                 $scount = 0
                    foreach($backuplocation in $QBBackupDir)
                    {
                    $NCheck = Get-Childitem $backuplocation -Include "*.QBB" -Recurse | where {$_.Name -like "*$t*"} | Sort-Object LastWriteTime -Descending | select -first 1
                    $Obj = New-Object System.Object
                    $Obj | Add-Member -type NoteProperty -name CompanyFile -Value "$t"
                    $State = "Failed"
                    $scount++
                    if($NCheck -ne $Null)
                        {
                        if($AutoBackup -eq $true)
                        {
                        $RunTask = Get-ScheduledTask -TaskPath "\" | where {$_.TaskName -like "*$t*"}
                        if($RunTask -notlike $Null)
                            {
                                $RunTask | Start-ScheduledTask
                                $c = 0
                                do{
                                    $c++
                                    sleep 2
                                    $RunTask = Get-ScheduledTask -TaskPath "\" | where {$_.TaskName -like "*$t*"}
                                    $loopdir = Get-Childitem $backuplocation -Include "*.QBB" | where {$_.Name -like "*$t*.QBB"} | select -first 1
                                    if($RunTask.State -like "Ready" -and $loopdir.LastWriteTime -ge $date)
                                        {
                                            $TaskRunItem = $loopdir.Name -replace '\s\w{1,3}\s\d{1,2},\d{1,4}\s{1,3}\d{1,2}\s\d{1,2}\s\w{1,2}'
                                            $TaskRunItem = $TaskRunItem -replace '\w{1,3}_\d_'
                                            $TaskRunItem = $backupitem1 -replace '\s\(\w{1,6}\)'
                                            $TaskRunItem = $TaskRunItem -replace '\.\w{3}'
                                            $TaskRunItemDate = $Loopdir.Name -match '\w{3}\s\d{2},\d{4}'
                                            $TaskRunItemDate = $Matches[0]
                                            $State = "Success"
                                            $backupitemdate = $TaskRunItemDate
                                            $NCheck = $loopdir
                                            break
                                        }
                                }while($c -le 60)
                            }
                        }
                        if($State -eq "Failed")
                        {
                        $TaskRunItemDate = $NCheck.Name -match '\w{3}\s\d{2},\d{4}'
                        $TaskRunItemDate = $Matches[0] 
                        }
                        $Obj | Add-Member -type NoteProperty -name Result -Value $state 
                        $Obj | Add-Member -type NoteProperty -name LastBackup -Value $TaskRunItemDate #$lastbackup
                        $Obj | Add-Member -type NoteProperty -name FilePath -Value ($NCheck.FullName)  #($backupitem.FullName)                        
                        $AlertSubject = "Quickbooks Backup -$t - $State!"
                        }
                    else {
                        $Obj | Add-Member -type NoteProperty -name Result -Value $State
                        $Obj | Add-Member -type NoteProperty -name LastBackup -Value "None" #$lastbackup
                        $Obj | Add-Member -type NoteProperty -name FilePath -Value "None"  #($backupitem.FullName)
                        $AlertSubject = "Quickbooks Backup -$t - Not Found!"
                        }

                        if($scount -eq 1)
                        {
                            if(!($AlertEmailTo -eq $false -or $AlertEmailTo -eq ""))
                            {
                            CC-SendMail -Body "$state $t" -SMTPServer $SMTPServer -SMTPServerPort $SMTPServerPort -EmailFrom $EmailFrom -EmailFromPAssword $EmailFromPassword -Emailto $AlertEmailTo -Subject $AlertSubject
                            }
                        }
                        elseif($scount -gt 1 -and $NCheck -ne $null )
                         {
                            if(!($AlertEmailTo -eq $false -or $AlertEmailTo -eq ""))
                            {
                            CC-SendMail -Body "$state $t" -SMTPServer $SMTPServer -SMTPServerPort $SMTPServerPort -EmailFrom $EmailFrom -EmailFromPAssword $EmailFromPassword -Emailto $AlertEmailTo -Subject $AlertSubject
                            }
                         }
                        $QBBackupArray += $Obj
         }
    }

 }

$message = ($QBBackupArray | sort -Unique CompanyFile) | sort Result,CompanyFile
$count = $QBBackupArray.count
$precontent = "<h2>Quickbooks Backup Report - <b>Files: " + $count + "</b> - <b>Backups From: " + $date +"</b></h2>"
$message = $message | ConvertTo-Html -head $header -Title "Quickbooks Backup Report" -PreContent $precontent | Set-AlternatingRows -CSSEvenClass even -CSSOddClass odd
$ReportEmailBody = $ReportEmailBody.replace("<br><br><br><br><br><br>","<br><br><br>$message<br><br><br>")
if($sendreport -eq $true)
    {
        CC-SendMail -Body $ReportEmailBody -SMTPServer $SMTPServer -SMTPServerPort $SMTPServerPort -EmailFromPassword $EmailFromPassword -EmailFrom $EmailFrom -Emailto $ReportEmailTo -Subject $ReportEmailSubject
    }
