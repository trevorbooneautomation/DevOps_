#### Trevor Boone Automation Powershell Script - Repo Interactive
#### Date: 4/30/2020
#### Created By: Trevor Boone
#### Reference: https://medium.com/@gmusumeci/how-to-download-files-from-azure-devops-repos-from-a-powershell-script-51b11d2aa7d5 


#### THIS POWERSHELL SCRIPT SHOULD BE RUN FROM AUTOMATE:
#### SCRIPTS --> AZURE --> AZURE REPO DEPLOY

#### $lock = "true" - This will remove all scripts and delete Repos folder
####     ** This is to be adjusted on the CORE config below
#### $TaskRun = "false" - This will prevent task scheduling by default 
####     ** Add this value to the servers.txt file to prevent Task Scheduling
#### $cleanup = "true" - This will delete the script on the server
####     ** Add this value to the servers.txt file to cleanup script invidually
#### $TaskRepair = $true will try to repair any runs by stopping powershell processes and cleaning up files

$TaskIgnoreErrors = "false"
$UpdateUpdater = "true"
$TaskTime = "8am"
$TaskRepair = "false"
$lock = "false"
$TaskRun = "true"
$RepoOrg = ""
$RepoProject = ""
$RepoName = ""
$RepoToken = ""
$maindir = "C:\Azure_Repo"  ## Folder storing CORE scripts
$repodir = "Repo" ## Folder storing functional scripts
$TaskPowershellVersion = "5"
$TaskPowershellURL = "https://go.microsoft.com/fwlink/?linkid=839516"
$dir = "@Module@" ## Location of functional script within the repo i.e. Scripts/Function/function.ps1
$tasktime = "@TaskTime@" ## Time for task to run at i.e 8am  - if TaskRun: False (Within variables.txt) then it won't create a task
$module = $dir -replace '^.+\/','' 
$module = $module -replace '^.+\\',''
$moduledir = $dir.replace($module, "") # "ns_backup.ps1"
# Encode the Personal Access Token (PAT) to Base64 String
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$RepoToken)))
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function cc-error-email {
    param (
        $NHost,
        $Module,
        $Attachment,
        $From,
        $To,
        $User,
        $Pass,
        $Server,
        $Port,
        $AttachmentName,
        $Subject


    )
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
    $Body = "
    Hello See Info Below:
    Host: $NHost
    Module: $Module
    Error Codes Attached.
    Transscript Attached.
    Thanks,
    NWStaff
    "

	$SMTPMessage = New-Object System.Net.Mail.MailMessage($From,$To,$Subject,$Body)
	if($Attachment -eq $true)
		{
            $content1 = ""
            $content2 = ""
            if(Test-Path "$maindir\$repodir\$AttachmentName-transcript.log")
                {
                    try{
                        $SMTPMessage.Attachments.Add("$maindir\$repodir\$AttachmentName-transcript.log")
                    }
                    catch{
                        $Content1 = Get-Content "$maindir\$repodir\$AttachmentName-transcript.log"
                    }
                }
            if(Test-Path "$maindir\$repodir\$AttachmentName-error.log")
                {
                    try{
                        $SMTPMessage.Attachments.Add("$maindir\$repodir\$AttachmentName-error.log")
                    }
                    catch{
                        $Content2 = Get-Content "$maindir\$repodir\$AttachmentName-error.log"
                    }
                }
$Body = "
    Hello See Info Below:
    Host: $NHost
    Module: $Module
    Error Codes Attached.
    Transscript Attached.
    Thanks,
    NWStaff
    $Content1
    -------------
    $Content2
    -------------
    "

            
		}
	$SMTPClient = New-Object Net.Mail.SmtpClient($Server, $Port) 
	$SMTPClient.EnableSsl = $true 
	$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($User, $Pass); 
    try{
	$SMTPClient.Send($SMTPMessage)
    }
    catch{$SMTPClient.EnableSsl = $false
          $SMTPClient.Send($SMTPMessage)
         }


  }

if(!(Test-Path $maindir))
    {
        New-Item $maindir -ItemType Directory -Force
    }


if($lock -eq $true)
{
    if(Test-Path "$maindir\$repodir")
        {
         Remove-Item "$maindir\$repodir" -Recurse -Force
        }
}
else{
    ##TEST IF MORE THAN ONE CONFIG FOR SERVER
    $c = 0
    ##
    do{
    $c++
    try{
            $edit = $env:COMPUTERNAME + "_" + $c
            $urlvar = "https://dev.azure.com/$RepoOrg/$RepoProject/_apis/git/repositories/$RepoName/items?path=$moduledir$edit.txt&download=true&api-version=5.0"
            $urlvarresult = Invoke-RestMethod -Uri $urlvar -Method Get -ContentType "application/text" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ErrorAction SilentlyContinue
        }
    catch{
            $c = $c - 1
            break
         }
    }while($true)
    $error.Clear()
    foreach($config in 0..$c)
    {
        $scriptparams = $null
    if($config -eq 0)
        {
            $servern = $env:COMPUTERNAME
        }
    elseif($config -gt 0)
        {
            $servern = $env:COMPUTERNAME + "_" + $config
        }
    try{
    $urlvar = "https://dev.azure.com/$RepoOrg/$RepoProject/_apis/git/repositories/$RepoName/items?path=$moduledir$servern.txt&download=true&api-version=5.0"
    $savedir = ((($PSCommandPath).replace($PSScriptRoot,"")) -replace "\\") -replace ".ps1",".txt"
	if(!(Test-Path $recoverylocation)){New-Item $recoverylocation -ItemType Directory -Force}
	"https://dev.azure.com/$RepoOrg/$RepoProject/_apis/git/repositories/$RepoName" | Out-File "$recoverylocation\$savedir" -Force
    "$dir" | Out-File "$recoverylocation\$savedir" -Append
    "$RepoToken" | Out-File "$recoverylocation\$savedir" -Append
    $urlvarresult = Invoke-RestMethod -Uri $urlvar -Method Get -ContentType "application/text" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ErrorAction stop
    $newhash = (($urlvarresult.Replace(": "," = ")).replace("\","\\")).split("`n") | select-string "Task" | Out-String
    $newhash = ConvertFrom-StringData $newhash 
    if($PSVersionTable.PSVersion.Major -lt $TaskPowershellVersion)
    {
         $dl = New-Object net.webclient
        $dl.Downloadfile($TaskPowershellURL, "$maindir\PS5.msu")
        Start-Process "wusa.exe" -ArgumentList "$maindir\PS5.msu /quiet /norestart" -Wait

        cc-error-email -NHost $servern -Module $module -Attachment $false -From $newhash.TaskEmailFrom `
                        -To $newhash.TaskEmailTo -User $newhash.TaskEmailFrom  `
                        -Pass $newhash.TaskEmailFromPassword -Server $newhash.TaskSMTPServer `
                        -Port $newhash.TaskSMTPServerPort -Subject "Azure PS - $Servern - $Module - Status: Powershell To Old Please Reboot!"


        exit
    }
    else{
        if(Test-Path "$maindir\PS5.msu")
        {
            Remove-Item "$maindir\PS5.msu" -Force
        }
    }

    if(!(Get-PackageProvider -ListAvailable -Name NuGet))
    {Install-PackageProvider -Name NuGet -Force}

    ##Install Powershell-YAML
    if(!(Get-Module -ListAvailable -Name powershell-yaml))
    {Install-Module powershell-yaml -Force}

    ## Import Module
    Import-Module powershell-yaml -Force

    try{
    $hash = ConvertFrom-Yaml $urlvarresult -ErrorAction Stop
    }
    catch{ 
        $m = $module.replace(".ps1","")
        $error | Out-File "$maindir\$repodir\$m-c-error.log" -Force
        Copy-Item "$maindir\$repodir\$m-c-error.log" -Destination "$maindir\$repodir\$m-error.log" -Force        
        cc-error-email -NHost $servern -Module $module -From $newhash.TaskEmailFrom -To $newhash.TaskEmailTo `
                          -User $newhash.TaskEmailFrom -Pass $Newhash.TaskEmailFromPassword -Server $newhash.TaskSMTPServer `
                          -Port $newhash.TaskSMTPServerPort -Subject "$env:COMPUTERNAME - $module - Failed - YAML ERROR!" `
                          -Attachment $true -AttachmentName $m
        exit
        }

    foreach($m in $hash.keys ){
            if($m -ne "")
                {
                    if($m -notlike "*Task*")
                        {
                        try {

                        if($hash.$m.GetType().Name -like "*List*")
                            {
                                $data = $hash.$m
                                $data = $data -replace "$",","
                                $data1 = $data | select -last 1
                                $data2 = $data1 -replace ".$"
                                $data = $data.replace($data1,$data2)
                                $data = $data -replace ", \r",","
                                $scriptparams = $scriptparams + "-" + $m + ' "' + $data +'" '
                            }
                        else
                            {
                                $scriptparams = $scriptparams + "-" + $m + ' "' + $hash.$m +'" '
                            }
                        }
                        catch{
                                $scriptparams = $scriptparams + "-" + $m + ' '
                            }
                        }
                    if($m -like "Cleanup" -and $hash.$m -eq $true)
                        {
                            $cleantask = $module.Replace(".ps1","")
                            $c2 = Get-ScheduledTask -TaskPath "\" | where {$_.TaskName -like "*$cleantask*"}
                             if($c2 -ne $null)
                                { $c2 | Unregister-ScheduledTask -Confirm:$false }
                            $c3 = Get-ScheduledTask -TaskPath "\" | where {$_.TaskName -like "Azure_Deploy_Updater"}
                             if($c3 -ne $null)
                                { $c3 | Unregister-ScheduledTask -Confirm:$false }

                            $cleanupscript = @"
                            Remove-Item '$maindir\$repodir\$cleantask-error.log' -Force
                            Remove-Item '$maindir\$repodir\$cleantask-transcript.log' -Force
                            Remove-Item '$maindir\$repodir\$cleantask.ps1' -Force
                            Remove-Item '$maindir\azure_$cleantask.ps1' -Force
                            if(Test-Path '$maindir\Azure_Deploy_Updater.ps1')
                                { Remove-Item '$maindir\Azure_Deploy_Updater.ps1' -Force }
                            
"@
                            $cleanupscript | Out-File "C:\Windows\Temp\cleanup_$module" -Force
                            Start-Process "powershell.exe" -Argumentlist "-ExecutionPolicy Bypass -File C:\Windows\Temp\cleanup_$module"
                            #exit
                        }
                }
                 
        }
    }catch{write-host "Error configuration could not contact Azure Repo Variables File $moduledir$servern.txt"}


if($hash.TaskRun -eq $false) 
    {
        $TaskRun = "False"
    }
$taskuser = $newhash.TaskUser
$taskpass = $newhash.TaskPass
$emto     = $newhash.TaskEmailTo
$SServer  = $newhash.TaskSMTPServer
$SPort    = $newhash.TaskSMTPServerPort
$semail   = $newhash.TaskEmailFrom
$spass    = $newhash.TaskEmailFromPassword

if($newhash.TaskTime -ne $null)
    {
        $TaskTime = $newhash.TaskTime
    }

if($newhash.TaskIgnoreErrors -ne $null)
    {
        $TaskIgnoreErrors = $newhash.TaskIgnoreErrors
    }
if($newhash.TaskRepair -ne $null)
    {
        $TaskRepair = $newhash.TaskRepair
    }
if($TaskRepair -eq $true)
    {
        Get-Process | where {$_.ProcessName -like "powershell" -and $_.PID -notlike $PID} | Stop-Process -Force
        Get-ChildItem "$maindir\Repo" | where {$_.Name -like "*.log" -or $_.Name -like "*.txt"} | Remove-Item -Force
        exit
    }

if(!(Test-Path "$maindir\$repodir"))
    {
        $folder1 = $maindir
        $folder2 = "$maindir\$repodir"
        $folders = $folder1,$folder2
        foreach($folder in $folders)
            {
            if(!(Test-Path $folder))
                {
                    New-Item $folder -ItemType Directory -Force | Out-Null
                }
            }
    }

if(!(Test-Path "$maindir\Azure_$module"))
    {
        write-host "You need to save this deploy.ps1 as azure_$module under the $maindir directory" -ForegroundColor Red
        exit
    }

##Updater
$Updater = "Azure_Deploy_Updater"
if(!(Test-Path "$maindir\$Updater.ps1") -or $UpdateUpdater -eq $true)
    {

$Script = @'
function TBA-Email {
    param (
        $NHost,
        $Module,
        $Attachment,
        $From,
        $To,
        $User,
        $Pass,
        $Server,
        $Port,
        $AttachmentName,
        $Subject
    )
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
    $Body = "
    Hello See Info Below:
    Host: $NHost
    Module: $Module
    Thanks,
    NWStaff
    "
	$SMTPMessage = New-Object System.Net.Mail.MailMessage($From,$To,$Subject,$Body)
	$SMTPClient = New-Object Net.Mail.SmtpClient($Server, $Port) 
	$SMTPClient.EnableSsl = $true 
	$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($User, $Pass); 
    try{
	$SMTPClient.Send($SMTPMessage)
    }
    catch{$SMTPClient.EnableSsl = $false
          $SMTPClient.Send($SMTPMessage)
         }
  }
function TBA-DevGrab {
    param (
        $RepoOrg,
        $RepoProject,
        $RepoName,
        $Dir,
        $RepoToken,
        $Filename,
        $Maindir
    )
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Encode the Personal Access Token (PAT) to Base64 String
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f '',$RepoToken)))
# Construct the download URL
$url = "https://dev.azure.com/$RepoOrg/$RepoProject/_apis/git/repositories/$RepoName/items?path=Deploy/Templates/CW_Automate_Deploy_Template.ps1&download=true&api-version=5.0"
# Download the file
try{
$result = Invoke-RestMethod -Uri $url -Method Get -ContentType 'application/text' -Headers @{Authorization=('Basic {0}' -f $base64AuthInfo)} -ErrorAction Stop
$resultstring = $result | select-string '\$dir'
$result = $result -replace '\@\w{6}\@',$Dir
$result | Out-File "$maindir\$Filename.ps1" -Force
}
catch{
       $maindir = $maindir
         $run = (Get-Content "$env:windir\temp\azs_\$filename.txt" -ErrorAction SilentlyContinue)[0]
       if("$dir" -eq "")
        {
           $Dir = (Get-Content "$env:windir\temp\azs_\$filename.txt" -ErrorAction SilentlyContinue)[1]
        }
       if("$RepoToken" -eq "")
        {
           $RepoToken = (Get-Content "$env:windir\temp\azs_\$filename.txt" -ErrorAction SilentlyContinue)[2]
           $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$RepoToken)))
        }
       if("$dir" -ne "")
       {
       $url = "$run/items?path=Deploy/Templates/CW_Automate_Deploy_Template.ps1&download=true&api-version=5.0"
       $result = Invoke-RestMethod -Uri $url -Method Get -ContentType 'application/text' -Headers @{Authorization=('Basic {0}' -f $base64AuthInfo)} -ErrorAction SilentlyContinue
       $resultstring = $result | select-string '\$dir'
       $result = $result -replace '\@\w{6}\@',$Dir
       $result | Out-File "$maindir\$Filename.ps1" -Force
       }
       else{
            $RepoToken = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
            $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$RepoToken)))
            $urlvar = "https://dev.azure.com/$RepoOrg/$RepoProject/_apis/git/repositories/$RepoName/items?path=Deploy/Templates/EmailFormat.txt&download=true&api-version=5.0"
            $result = Invoke-RestMethod -Uri $urlvar -Method Get -ContentType 'application/text' -Headers @{Authorization=('Basic {0}' -f $base64AuthInfo)} -ErrorAction SilentlyContinue
            $newhash = (($result.Replace(": "," = ")).replace("\","\\")).split("`n") | select-string "Task" | Out-String
            $newhash = ConvertFrom-StringData $newhash 
            $emto     = $newhash.TaskEmailTo
            $SServer  = $newhash.TaskSMTPServer
            $SPort    = $newhash.TaskSMTPServerPort
            $semail   = $newhash.TaskEmailFrom
            $spass    = $newhash.TaskEmailFromPassword
             TBA-Email -NHost $env:COMPUTERNAME -Module $filename -Attachment $false -From $semail -To $emto -User $semail  `
				            -Pass $spass -Server $SServer -Port $SPort -Subject "Azure PS - $env:COMPUTERNAME - $filename - Status: Issue - Need reploy"
            
        }
}
}
$scripts = Get-Childitem $maindir | where {$_.Name -like "Azure_*.ps1" -and $_.Name -notlike "Azure_Deploy_Updater.ps1"}
foreach($script in $scripts)
    {
        $Location = ((Get-Content $Script.FullName | select-string -Pattern '^\$dir =') -replace '^\$dir = ') -replace '"'
        $Org = ((Get-Content $Script.FullName | select-string -Pattern '^\$RepoOrg =') -replace '^\$RepoOrg = ') -replace '"'
        $Project = ((Get-Content $Script.FullName | select-string -Pattern '^\$RepoProject =') -replace '^\$RepoProject = ') -replace '"'
        $Name = ((Get-Content $Script.FullName | select-string -Pattern '^\$RepoName =') -replace '^\$RepoName = ') -replace '"'
        $MainDir = ((Get-Content $Script.FullName | select-string -Pattern '^\$maindir =') -replace '^\$maindir = ') -replace '"'
        $Token = ((Get-Content $Script.FullName | select-string -Pattern '^\$RepoToken =') -replace '^\$RepoToken = ') -replace '"'
        TBA-DevGrab -RepoOrg $Org -RepoProject $Project -RepoName $Name `
                    -Dir $Location -TaskTime $Time -RepoToken $Token `
                    -Filename (($Script.Name) -replace ".ps1") -Maindir $MainDir
        sleep 2
    }
'@
$Script | Out-File "$maindir\$Updater.ps1" -Force
}
##Updater Task
$updatetask = Get-ScheduledTask | where {$_.TaskName -like "*$Updater*"}
if(!($updatetask))
    {
        $taskPath = "\"
        $taskName = $Updater
        $program = "C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe"
        $arguments = "-ExecutionPolicy Bypass -File " + '"' + ".\$Updater.ps1" + '"'
        $a = New-ScheduledTaskAction -Execute $program -Argument $arguments -WorkingDirectory $maindir
        $t = New-ScheduledTaskTrigger -Daily -At "4am"
        $p = New-ScheduledTaskPrincipal -UserID $taskuser -LogonType Password -RunLevel Highest
        $s = New-ScheduledTaskSettingsSet -Compatibility Win8
        $d = New-ScheduledTask -Action $A -Principal $p -Trigger $T -Settings $S
        $taskfin = Register-ScheduledTask -InputObject $d -TaskPath $taskPath -TaskName $taskName -User $taskuser -Password $taskpass
        $taskfin.Triggers.Repetition.Duration = "PT16H"
        $taskfin.Triggers.Repetition.Interval = "PT7M"
        $taskfin | Set-ScheduledTask -User $taskuser -Password $taskpass
    } 


$fileo = $module.replace(".ps1","")
if($TaskRun -eq $true)
{
$task = Get-ScheduledTask | where {$_.TaskName -like "*$fileo*"}
if(!($task))
    {
        $taskPath = "\"
        $taskName = "Azure_Module_$fileo"
        $program = "C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe"
        $arguments = "-ExecutionPolicy Bypass -File " + '"' + ".\azure_$module" + '"'
        $a = New-ScheduledTaskAction -Execute $program -Argument $arguments -WorkingDirectory $maindir
        $t = New-ScheduledTaskTrigger -Daily -At $tasktime
        $p = New-ScheduledTaskPrincipal -UserID $taskuser -LogonType Password -RunLevel Highest
        $s = New-ScheduledTaskSettingsSet -Compatibility Win8
        $d = New-ScheduledTask -Action $A -Principal $p -Trigger $T -Settings $S
        $taskfin = Register-ScheduledTask -InputObject $d -TaskPath $taskPath -TaskName $taskName -User $taskuser -Password $taskpass
        if($newash.TaskDuration -ne $null -and $newhash.TaskInterval -ne $null)
            {
                $taskfin.Triggers.Repetition.Duration = ("PT" + $newhash.TaskDuration)
                $taskfin.Triggers.Repetition.Interval = ("PT" + $newhash.TaskInterval)
                $taskfin | Set-ScheduledTask -User $taskuser -Password $taskpass
            }

    }  
}

# Construct the download URL
$url = "https://dev.azure.com/$RepoOrg/$RepoProject/_apis/git/repositories/$RepoName/items?path=$moduledir$module&download=true&api-version=5.0"
# Download the file
$result = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/text" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} | Out-File "$maindir\$repodir\$module" -Force

$script = "$maindir\$repodir\$module"
if($TaskIgnoreErrors -eq $true)
    {
        $trans = Start-Transcript -Path "$maindir\$repodir\$fileo-$servern-transcript.log"
        Invoke-Expression "$script $scriptparams"
        Stop-Transcript   

    }
elseif($TaskIgnoreErrors -eq $false)
    {
try {
        $trans = Start-Transcript -Path "$maindir\$repodir\$fileo-$servern-transcript.log"
        Invoke-Expression "$script $scriptparams"    
}
catch 
 {
     Stop-Transcript
     Sleep 5
 }

if($Error)
{
  $Error | Out-File "$maindir\$repodir\$fileo-c-error.log" -Force
  Copy-Item "$maindir\$repodir\$fileo-c-error.log" -Destination "$maindir\$repodir\$fileo-error.log" -Force
  cc-error-email -NHost $servern -Module $module -Attachment $true -From $semail -To $emto -User $semail  `
				-Pass $spass -Server $SServer -Port $SPort -Subject "Azure PS - $servern - $Module - Status: Issue" -AttachmentName $fileo

  }
    }
    }
}
##TEST
