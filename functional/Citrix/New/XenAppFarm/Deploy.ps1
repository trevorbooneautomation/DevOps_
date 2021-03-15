      ###############################################
    ##  By: Trevor Boone                          ##
  ##  Date: 9/1/20                              ##
##  https://github.com/trevorbooneautomation  ##
##############################################

param (
    ##Variables
    [Parameter(Mandatory=$True)]$FileLocation,

    [Parameter(Mandatory=$True)]$DomainAccount,
    [Parameter(Mandatory=$True)]$DomainPassword,
    [Parameter(Mandatory=$True)]$CitrixDatabaseServer,
    [Parameter(Mandatory=$True)]$CitrixAdmins,
    [Parameter(Mandatory=$True)]$CitrixLicenseServer,
    [Parameter(Mandatory=$True)]$CitrixLicenseServerPort,
    [Parameter(Mandatory=$True)]$CitrixProductCode,
    [Parameter(Mandatory=$True)]$CitrixProductEdition,
    [Parameter(Mandatory=$True)]$CitrixLicenseServerURLCertHash,
    [Parameter(Mandatory=$True)]$CitrixCatalogName,
    [Parameter(Mandatory=$True)]$CitrixCatalogDescription,
    [Parameter(Mandatory=$True)]$CitrixCatalogAllocationType,
    [Parameter(Mandatory=$True)]$CitrixCatalogMinFunctionalLevel,
    [Parameter(Mandatory=$True)]$CitrixCatalogPersistUserChanges,
    [Parameter(Mandatory=$True)]$CitrixCatalogProvisioningType,
    [Parameter(Mandatory=$True)]$CitrixCatalogSessionSupport,
    [Parameter(Mandatory=$True)]$CitrixSiteName,
    [Parameter(Mandatory=$True)]$CitrixVDAServers,
    [Parameter(Mandatory=$True)]$SMTPServer,
    [Parameter(Mandatory=$True)]$SMTPServerPort,
    [Parameter(Mandatory=$True)]$SMTPEmailFrom,
    [Parameter(Mandatory=$True)]$SMTPEmailFromPassword,
    [Parameter(Mandatory=$True)]$SMTPEmailTo,
    [Parameter(Mandatory=$True)]$Components,
    [Parameter(Mandatory=$True)]$fileurl,
    [Parameter(Mandatory=$True)]$ISO,
    [Parameter(Mandatory=$True)]$VDAInstall,
    [Parameter(Mandatory=$True)]$Netscaler,
    $NetscalerIP,
    $NetscalerVIP,
    $NetscalerVIPHostname,
    $CitrixDeliveryControllerIP,
    $SSMSInstall,
    $SSMSurl,
    $SSMSfile

)

function TBA-Events {
    param (
        [int]$EventID,
        [string]$State,
        [switch]$Fail,
        [switch]$Final
        )

$EventidX = [int]$eventid * 3
$EventValue = New-Object -TypeName PSObject -Property @{State="";Message="";Resolution=""}

#########################################################################################
$Events = ` ##   Syntax - Lets describe the events happening in this script!  ##
            ##               "Success", "Failed", "Resolution"                ##
            ####################################################################

            "Ran Pre-Assignment Variables Successfully!", ## Success 0
                 "Failed to apply pre assignment variables!", ## Failed
                     "Review script and assignments section for errors!", ##Resolution

            "Downloaded XenApp.iso File No Problem!", ## Success 1
                 "You failed to download the XenApp.iso", ## Failed
                     "Make sure your Variable 'FileURL' has a valid link from today! Redownload to get new link!", ##Resolution

            "Downloaded and Installed SSMS!", ## Success 2
                 "Failed to download or install SSMS", ## Failed
                     "Install SSMS!", ##Resolution

            "Mount XenApp ISO and Install XenApp Part 1 Success", ## Success 3
                 "Failed to Install XenApp Part 1", ## Failed
                     "Confirm you have proper Administrator rights!", ##Resolution

            "Mount XenApp ISO and Install XenApp Part 2 Success", ## Success 4
                 "Failed to Install XenApp Part 2", ## Failed
                     "Possible Mounting Issue or Installation Invalid Issue", ##Resolution

            "Installing StoreFront Functionality Successful", ## Success 5
                 "Failed to install StoreFront Functionality", ## Failed
                     "Confirm StoreFront Installation is allowed in current setup", ##Resolution

            "Installing VDA Functionality Part 1 Successful", ## Success 6
                 "Failed to Install VDA Functionality Part 1", ## Failed
                     "Confirm you have proper permissions and environment makes sense", ##Resolution

            "Installing VDA Functionality Part 2 Successful", ## Success 7
                 "Failed to Install VDA Functionality Part 2", ## Failed
                     "Confirm you have proper permissions and environment makes sense", ##Resolution

            "Prepared configuration. Deployed New PS Script. Ran Successfully!", ## Success 8
                 "Tried running final script, Cleanup, XenApp Configuration, But Failed!", ## Failed
                     "Confirm you have proper permissions and run again" ##Resolution

##########################################################################################

        if($state -eq "Success")
            {
                $EventValue.Message = $Events[$EventidX]
                $EventValue.State = "Success"
                $EventValue.Resolution = "None"
            }
        elseif($state -eq "Failed")
            {
                $EventValue.State = "Failed"
                [int]$EventidX++
                $EventValue.Message = $Events[$EventidX]
                [int]$EventidX++
                $EventValue.Resolution = $Events[$EventidX]
            }
        if(!($Fail))
        {
            if($Final)
                {
                TBA-Write-Log -State ($EventValue.State) -Reason ($EventValue.Message) -Resolution ($EventValue.Resolution) `
                -Event $EventID -Final  
            }else{
                TBA-Write-Log -State ($EventValue.State) -Reason ($EventValue.Message) -Resolution ($EventValue.Resolution) `
                -Event $EventID
            }
        }
        else{
        TBA-Write-Log -State ($EventValue.State) -Reason ($EventValue.Message) -Resolution ($EventValue.Resolution) `
                -Event $EventID -SendEmail -Fail
        }

        return $EventValue

}

function TBA-Write-Log {
    param (
        [string]$Event,

        [ValidateSet("Success", "Failed", IgnoreCase = $true)]
        [string]$State,

        [string]$Reason,
        [string]$Resolution,
        [switch]$SendEmail,
        [switch]$Fail,
        [switch]$Final
    )

    if($SendEmail -eq $true){$SentMail = $true}
    else{$SentMail = $false}

    $DateT = Get-Date -Format "MM-dd-yyyy HH:mm:ss"
    if($State -eq $null -or $Reason -eq $null -or $Resolution -eq $null -or $Event -eq $null)
        {
            $_ = 'No Input'
        }
    $Output = @"
    {
        "Date"       : "$DateT",
        "Event"      : "$Event",
        "State"      : "$State",
        "Reason"     : "$Reason",
        "Resolution" : "$Resolution",
        "Send Email" : "$SentMail"
    }!
"@
$hname = ((($PSCommandPath -replace '^.+\\') -replace '.ps1') | Out-String)
      if(!(Test-Path $global:FileLocation))
        {
            "[" | Out-File $global:FileLocation -Force
        }

        if(!($Fail))
        {
            $File = (Get-Content $global:FileLocation).replace("}]","},") | Out-File $global:FileLocation -Force
            $File = (Get-Content $global:FileLocation).replace("}!","},") | Out-File $global:FileLocation -Force
            $Output | Out-File $global:FileLocation -Append
        }else{
            $File = (Get-Content $global:FileLocation).replace("}]","},") | Out-File $global:FileLocation -Force
            $File = (Get-Content $global:FileLocation).replace("}!","},") | Out-File $global:FileLocation -Force
            $Output | Out-File $global:FileLocation -Append
            $File = (Get-Content $global:FileLocation).replace("}!","}]") | Out-File $global:FileLocation -Force
        }
    if($SendEmail)
        {
            TBA-Email -Server $SMTPServer -ServerPort $SMTPServerPort -EmailFrom $SMTPEmailFrom -EmailFromPassword $SMTPEmailFromPassword -EmailTo $SMTPEmailTo `
            -Subject "$env:COMPUTERNAME - $hname - EventID $Event - $State" -Body "$Reason"
        }
    if($Final)
        {
            TBA-Email -Server $SMTPServer -ServerPort $SMTPServerPort -EmailFrom $SMTPEmailFrom -EmailFromPassword $SMTPEmailFromPassword -EmailTo $SMTPEmailTo `
            -Subject "$env:COMPUTERNAME - $hname - EventID $Event - $State" -Body "$Reason" -Attach $global:FileLocation
        }
        
}

function TBA-Install {
    param (
        [Parameter(Mandatory=$True)]
        [ValidateSet("VDA", "XENDESKTOP", "STOREFRONT", IgnoreCase = $true)]
        [string]$Function
    )
$FunctionValue = New-Object -TypeName PSObject -Property @{Process="";Parameter=""}
$Components = ($global:Components).Replace(", ",",")
$FQDN = [System.Net.Dns]::GetHostByName(($env:computerName))
$FQDN = $FQDN.HostName
$ImagePath = Get-DiskImage -ImagePath $global:ISO
if($ImagePath.Attached -eq $False)
    {
        $mount = Mount-DiskImage -ImagePath $global:ISO
        $DriveLetter = ($mount | Get-Volume).DriveLetter
    }elseif($ImagePath.Attached -eq $True){
        $DriveLetter = ($ImagePath | Get-Volume).DriveLetter
    }
if($Function -eq "VDA")
    {
        $FunctionValue.Process = $DriveLetter + ":\x64\XenDesktop Setup\XenDesktopVDASetup.exe"
        $FunctionValue.Parameter = @("/COMPONENTS VDA,PLUGINS /CONTROLLERS $FQDN " +
                         "/ENABLE_HDX_UDP_PORTS /ENABLE_HDX_PORTS /ENABLE_REAL_TIME_TRANSPORT " +
                         "/OPTIMIZE /QUIET /REMOTEPC /LOGPATH $global:CitrixLogPath")
    }
if($Function -eq "XenDesktop")
    {
        $FunctionValue.Process = $DriveLetter + ":\x64\XenDesktop Setup\XenDesktopServerSetup.exe"
        $FunctionValue.Parameter = @("/COMPONENTS $Components /QUIET /CONFIGURE_FIREWALL /LOGPATH $global:CitrixLogPath")
    }
if($Function -eq "StoreFront")
    {
        $FunctionValue.Process = $DriveLetter + ":\x64\Storefront\CitrixStoreFront-x64.exe"
        $FunctionValue.Parameter = @("-silent")
    }
return $FunctionValue
}

function TBA-LogCheck {
    param (
        [string]$LogPath,
        [string]$LogSearch,
        [string]$EventID
    )

$Log = Get-ChildItem $LogPath -Recurse | Where-Object {$_.Name -like "*.log"}
write-host Childitem - $Log
if($Log -eq $Null)
    {
        TBA-Write-Log -Event $EventID -Reason "No log file found" -Fail `
        -Resolution "Confirm Log file location is correct and that a file is generating"
}else{
    $Log = Get-Content $Log.FullName | Select-Object -Last 15
    $Log = $Log | Select-String -Pattern "$LogSearch" -AllMatches | Select-Object -Last 1
    write-host Content - $Log
    $LogTime = $Log -replace "[^\d\d:\d\d:\d\d].+$"
    write-host LOGTIME - $LogTime
    try{
        $LTime = (Get-Date -Date $LogTime -ErrorAction Stop).ToLongTimeString()
        write-host LTIME - $LTime
        if($global:LastLogTime -eq $Null)
            {
                $global:LastLogTime = $LTime
        }else{
                if($global:LastLogTime -ge $LTime)
                    {
                        $Log = "Existing"
                        return $Log
                    }
                elseif($global:LastLogTime -lt $LTime)
                    {
                        $global:LastLogTime = $LTime
                        return $log
                    }
        }
    }catch{
        write-host failed
    }
  }
}

function TBA-EventRun {
    param (
        [int]$EventID,
        [int]$Count,
        [string]$SoftwareSearch,
        [string]$LogSearch,
        [ValidateSet("VDA", "XENDESKTOP", "STOREFRONT", IgnoreCase = $true)]
        [string]$InstallFunction,
        [string]$DownloadURL,
        [string]$InstallPath,
        [switch]$Install,
        [switch]$Critical,
        [switch]$Reboot
    )

if($count -ge $global:countx)
    {
      TBA-Write-Log -Event $EventID -State Failed -Reason "Task became looped" -Resolution "Look at Event: $EventID" -Fail -SendEmail
      exit
    }
if($SoftwareSearch -and $Logsearch -and $InstallFunction)
    {
$check = (gp HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -like $SoftwareSearch
if($check){
        write-host "Event $EventID Already completed!"
        TBA-Write-Log -Event $EventID -State Success -Reason "This event has already completed!" -Resolution "None"
}else{
        try{
            $CitrixInstaller = TBA-Install -Function $InstallFunction
            Start-Process ($CitrixInstaller.Process) -ArgumentList ($CitrixInstaller.Parameter) -Verb runAs -Wait -ErrorAction Stop
            $LogChecker = TBA-LogCheck -LogPath $global:CitrixLogPath -LogSearch $LogSearch -EventID $EventID
            if($LogChecker)
            {
                TBA-Write-Log -Event $EventID -State Failed -Reason "$LogChecker" -Resolution "Review Output Above" -Fail -SendEmail
                exit
            }else{
                $Result = "Success"
                $EventResults = TBA-Events -EventID $EventID -State $Result
                Write-Host "Event $EventID Completed!"
                if($Reboot)
                    {
                        $error.clear()
                        & shutdown -r -t 0
                        exit
                    }
            }
        }catch{
            $Result = "Failed"
            $EventResults = TBA-Events -EventID $EventID -State $Result
            exit
        }
    }
  }
elseif($DownloadURL -or $InstallPath)
    {
        try{
            if(!(Test-Path $DownloadURL))
                {
                $dl = New-Object net.webclient
                $dl.Downloadfile($DownloadURL, $InstallPath)
            }
                if($Install)
                    {
                        $FileType = (Get-ItemProperty $InstallPath).Extension
                        switch($filetype) {
                            .exe {$InstallArguments = "/quiet /install /norestart"}
                            .msi {$InstallArguments = "/qn"}
                        }
                        Start-Process $InstallPath -ArgumentList $InstallArguments -Wait -ErrorAction stop
                    }
            $Result = "Success"
            $EventResults = TBA-Events -EventID $EventID -State $Result
        }catch{
            $Result = "Failed"
            TBA-Write-Log -Event $EventID -State $Result -Reason ($error | select -last 1) -Resolution "NA" -Fail -SendEmail
            write-host $error
            exit
        if($Critical)
                {
                    exit
                }
        }
              
    }
}

function TBA-LastEvent() {
    $ReturnLastInfo = New-Object -TypeName PSObject -Property @{EventID="";SwitchID=""}
    if(Test-Path $global:FileLocation)
    {
        $LastEvent = Get-Content $global:FileLocation | select-string "Event" | select -last 1
        $LastEvent = (($LastEvent | Out-String).split('"')) | Select-String -Pattern "\d" | Out-String
        if($LastEvent -ne $Null)
            {
                $SwitchIDState = Get-Content $global:FileLocation | select-string "State" | select -last 1
                $SwitchIDState = (($SwitchIDState | Out-String).split('"')) | Select-String -Pattern "\w{6,7}"
                if($SwitchIDState -like "Failed")
                    {
                        $SwitchID = [int]$LastEvent
                        $EventID  = $SwitchID - 1
                    }
                elseif($SwitchIDState -like "Success")
                    {
                        $SwitchID = [int]$LastEvent
                        $SwitchID++ 
                        $EventID  = $SwitchID - 1         
                    }      
            }
    Write-Host "Return to Last Running Event - Event: $SwitchID"
    }else{$SwitchID = 0}
    $ReturnLastInfo.EventID = $EventID
    $ReturnLastInfo.SwitchID = $SwitchID
    return $ReturnLastInfo
}

function TBA-AutoLogin {
    param (
        [string]$DomainAdmin,
        [string]$DomainPassword,
        [switch]$Enable,
        [switch]$Disable

    )
if($Enable -and $DomainAdmin -and $DomainPassword)
    {
    $Time = New-ScheduledTaskTrigger -AtLogOn
    $autologinsplit = $DomainAdmin.split("\")
    Set-ScheduledTask -TaskName "Azure_Module_XenAppDeploy" -Trigger $Time -user $DomainAdmin -Password $DomainPassword
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value $autologinsplit[0]
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value $autologinsplit[1]
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $DomainPassword
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1"
    }
if($Disable)
    {
    Remove-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Force
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "0"
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value ""
    Get-ScheduledTask | Where-Object {$_.TaskName -like (($PSCommandPath -replace '^.+\\','Azure_Module_').replace(".ps1",""))} | Unregister-ScheduledTask -Confirm:$false
    }
}

Function TBA-Email {

    param(
        [Parameter(Mandatory=$True)]$Server,
        [Parameter(Mandatory=$True)]$ServerPort,
        [Parameter(Mandatory=$True)]$EmailFrom,
        [Parameter(Mandatory=$True)]$EmailFromPassword,
        [Parameter(Mandatory=$True)]$EmailTo,
        [Parameter(Mandatory=$True)]$Subject,
        [Parameter(Mandatory=$True)]$Body,
        [string]$Attach
    )

    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
    if($Attach)
        {
            $SMTPMessage.Attachments.Add($Attach)
        }
    $SMTPMessage.IsBodyHtml = $True
    $SMTPClient = New-Object Net.Mail.SmtpClient($Server, $ServerPort) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $EmailFromPassword);
    $SMTPClient.Send($SMTPMessage)   

    }
#region - Global Varriables
$global:FileLocation = $FileLocation
$global:ISO = $ISO
$global:Components = $Components
$global:MainDirectory = $PSScriptRoot -replace "\\Repo"
$global:CitrixLogPath = "$global:MainDirectory\log"
$global:LastLogTime = "$null"
$global:countx = 20
#endregion

#region - Neccessary Script Variables and Tasks
$count = 0
$ExeComponent = @("$Components")
$ExeParamS = $ExeComponent.Replace(", ",",")
$DomainPw = ConvertTo-SecureString -String $DomainPassword -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainAccount, $DomainPw
Write-Host "Run global script variables / tasks"
#endregion

#region - Return to last running event
$LastEventPull = TBA-LastEvent
$SwitchID = $LastEventPull.SwitchID
$EventID = $LastEventPull.EventID
#endregion

#region - Switch Loop
$cycle = 0
do 
{
    $cycle++
    if($cycle -ge 30)
        {
            TBA-Write-Log -Reason "DO LOOP  FAILED - Looped Infinitely in DO UNTIL" -Fail -Resolution "Review Script Entirely" `
                          -State "Failed" -Event "$EventID" -SendEmail
            exit
        }
write-host "SwitchID: $SwitchID - EventID: $EventID"

switch($SwitchID)
    {
0{
#region - Pre Script Assignments
$EventID = 0
$count++
if($count -ge $countx)
    {
      TBA-Write-Log -Event $EventID -State Failed -Reason "Task became looped" -Resolution "Look at Event: $EventID" -Fail -SendEmail
      exit
    }
    if(Test-Path $global:FileLocation){Remove-Item $global:FileLocation -Force}
    TBA-AutoLogin -DomainAdmin $DomainAccount -DomainPassword $DomainPassword -Enable
TBA-Events -Event $EventID -State Success
$SwitchID = [int]$EventID + 1
}
#endregion
1{
#region - Event 1
$EventID++
$count++
##Download XenApp ISO
if(!(Test-Path $iso))
    {
        TBA-EventRun -Event $EventID -Count $Count -DownloadURL $FileURL -InstallPath $ISO
    }
$SwitchID = [int]$EventID + 1
}
#endregion
2{
#region - Event 2
$EventID++
$count++
    if($SSMSInstall -eq $true)
        {if(!(Test-Path $ssmsfile))
                {TBA-EventRun -Event $EventID -Count $Count -DownloadURL $SSMSurl -InstallPath $SSMSfile -Install}    
         }
$SwitchID = [int]$EventID + 1
}
#endregion
3{
#region - Event 3
    $EventID++
    $count++
    TBA-EventRun -Event $EventID -Count $Count -SoftwareSearch "*Citrix*XenDesktop*" -LogSearch '\$ERR\$' -InstallFunction XENDESKTOP -Reboot
    $SwitchID = [int]$EventID + 1
}
#endregion
4{
#region - Event 4
    $EventID++
    $count++
    TBA-EventRun -Event $EventID -Count $Count -SoftwareSearch "*Citrix*XenDesktop*" -LogSearch '\$ERR\$' -InstallFunction XENDESKTOP -Reboot
    $SwitchID = [int]$EventID + 1
}
#endregion
5{
#region - Event 5
    $EventID++
    $count++
    TBA-EventRun -Event $EventID -Count $Count -SoftwareSearch "*Citrix*Storefront*" -LogSearch '\$ERR\$' -InstallFunction STOREFRONT -Reboot
    $SwitchID = [int]$EventID + 1
}
#endregion
6{
#region - Event 6
    $EventID++
    $count++
    TBA-EventRun -Event $EventID -Count $Count -SoftwareSearch "*Citrix*VDA*" -LogSearch '\$ERR\$' -InstallFunction VDA -Reboot
    $SwitchID = [int]$EventID + 1
}
#endregion
7{
#region - Event 7
    $EventID++
    $count++
    TBA-EventRun -Event $EventID -Count $Count -SoftwareSearch "*Citrix*VDA*" -LogSearch '\$ERR\$' -InstallFunction VDA -Reboot
    $SwitchID = [int]$EventID + 1
}
#endregion
8{
#region - Event 8
$EventID++
$count++
if($count -ge $countx)
    {
      TBA-Write-Log -Event $EventID -State Failed -Reason "Task became looped" -Resolution "Look at Event: $EventID" -Fail -SendEmail
      exit
    }

    if("$Components" -like "*CONTROLLER*")
        {
$CitrixVDAServersList = '$CitrixVDAServersList'
$vda = '$vda'
$CatalogUid = '$CatalogUid'
$CertHash = '$CertHash'
$fa = '$false'
$tr = '$true'
if($Netscaler -eq $True)
    {
        $NSR = $tr
    }
elseif($Netscaler -eq $False)
    {
        $NSR = $fa
    }
$DG = '$DG'
$o = '$_'
$newline = '`'
$Phase = '$Phase'
$number = '$number'
$NS = '$NS'
$Store = '$Store'
$Ica = '$Ica'
$ipinfo = '$ipinfo'
$EmailFunction = '
Function TBA-Email {

    param(
        [Parameter(Mandatory=$True)]$Server,
        [Parameter(Mandatory=$True)]$ServerPort,
        [Parameter(Mandatory=$True)]$EmailFrom,
        [Parameter(Mandatory=$True)]$EmailFromPassword,
        [Parameter(Mandatory=$True)]$EmailTo,
        [Parameter(Mandatory=$True)]$Subject,
        [Parameter(Mandatory=$True)]$Body,
        [string]$Attach
    )

    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
    if($Attach)
        {
            $SMTPMessage.Attachments.Add($Attach)
        }
    $SMTPMessage.IsBodyHtml = $True
    $SMTPClient = New-Object Net.Mail.SmtpClient($Server, $ServerPort) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $EmailFromPassword);
    $SMTPClient.Send($SMTPMessage)   

    }
'
$domainscript = @"
Start-Transcript '$maindir\Step8.txt'
Import-Module 'C:\Program Files\Citrix\XenDesktopPoshSdk\Module\Citrix.XenDesktop.Admin.V1\Citrix.XenDesktop.Admin'
Add-PSSnapin Citrix*
$EmailFunction
function TBA-Citrix-Configuration([int]$Phase) {
switch($Phase)
    {
        0 { ## Create new databases and Site
            New-XDDatabase -SiteName '$CitrixSiteName' -DatabaseServer '$CitrixDatabaseServer' -DatabaseName ('$CitrixSiteName' + '_SiteConfig') -DataStore Site
            New-XDDatabase -SiteName '$CitrixSiteName' -DatabaseServer '$CitrixDatabaseServer' -DatabaseName ('$CitrixSiteName' + '_Logging') -DataStore Logging
            New-XDDatabase -SiteName '$CitrixSiteName' -DatabaseServer '$CitrixDatabaseServer' -DatabaseName ('$CitrixSiteName' + '_Monitoring') -DataStore Monitor
            New-XDSite     -SiteName '$CitrixSiteName' -DatabaseServer '$CitrixDatabaseServer' -SiteDatabaseName ('$CitrixSiteName' + '_SiteConfig') -LoggingDatabaseName ('$CitrixSiteName' + '_Logging') -MonitorDatabaseName ('$CitrixSiteName' + '_Monitoring')
            }
        1 { ## Create Administrators
            New-AdminAdministrator '$CitrixAdmins'
            Add-AdminRight -Administrator '$CitrixAdmins' -Role 'Full Administrator' -Scope All
            }
        2 { ## Configure Licensing
            Set-XDLicensing -LicenseServerAddress '$CitrixLicenseServer' -LicenseServerPort '$CitrixLicenseServerPort' -ProductCode '$CitrixProductCode' -ProductEdition '$CitrixProductEdition' -Force
            $CertHash = (Get-LicCertificate -AdminAddress '$CitrixLicenseServerURLCertHash').CertHash
            Set-ConfigSiteMetaData -Name CertificateHash -Value $CertHash
            }
        3 { ## Configure Analytics, Broker Site, Broker Catalog
            Set-AnalyticsSite -Enabled $fa
            Set-BrokerSite -TrustRequestsSentToTheXmlServicePort $tr
            ##Catalog
            New-BrokerCatalog -Name '$CitrixCatalogName' -Description '$CitrixCatalogDescription' -AllocationType '$CitrixCatalogAllocationType' -MachinesArePhysical $tr -MinimumFunctionalLevel '$CitrixCatalogMinFunctionalLevel' -PersistUserChanges '$CitrixCatalogPersistUserChanges' -ProvisioningType '$CitrixCatalogProvisioningType' -SessionSupport '$CitrixCatalogSessionSupport'
            }
        4 { ## Broker Catalog and VDA Assignemnts - Add Broker Machine
            $CatalogUid = Get-BrokerCatalog | where {$o.Name -like '$CitrixCatalogName'} | Select -ExpandProperty Uid
            $DG = New-BrokerDesktopGroup -DesktopKind Shared -DeliveryType DesktopsAndApps -Enabled 1 -Name ('$CitrixCatalogName' + '_DG') -LicenseModel Concurrent -MinimumFunctionalLevel $CitrixCatalogMinFunctionalLevel -SessionSupport $CitrixCatalogSessionSupport -ShutdownDesktopsAfterUse 0 -TimeZone 'Pacific Standard Time'
            $CitrixVDAServersList = '$CitrixVDAServers'
            $CitrixVDAServersList = ($CitrixVDAServersList.split(',')) -replace "^\s"
            foreach($vda in $CitrixVDAServersList)
                {
                    New-BrokerMachine -MachineName $vda -CatalogUid $CatalogUid
                    Add-BrokerMachine -MachineName $vda -DesktopGroup $DG.Name
                }    
            }
        5 {
            sleep 5
            Get-Childitem '$PSScriptRoot' | where {$o.Name -like '*XenAppDeploy*'} | Remove-Item -Force
            Remove-Item '$global:MainDirectory\azure_XenAppDeploy.ps1' -Force
            Get-Childitem '$global:CitrixLogPath' | Remove-Item -Force -Confirm:$fa -Recurse
            }
        6 {
            $NS = $NSR
            $ipinfo = Invoke-RestMethod 'http://ipinfo.io/json'
            $ipinfo = $ipinfo.ip
            if($NS)
                {
                    $Store = Get-STFStoreService 
                    Add-STFRoamingGateway -Name 'NS_GW' -LogonType GatewayKnows -Version Version10_0_69_4 -GatewayUrl '$NetscalerVIPHostname' -SessionReliability  -SecureTicketAuthorityUrls 'https://$CitrixDeliveryControllerIP' | Get-STFRoamingGateway | Register-STFStoreGateway  -StoreService $store -DefaultGateway
                    Set-STFDeployment -HostBaseUrl "https://az$NetscalerVIPHostname" -SiteId 1 -Confirm:$fa
                }else{

                $Ica = (Get-Childitem 'C:\inetpub\wwwroot' -Recurse | where {$o.Name -like "default.ica"}).FullName
                (Get-Content $Ica).replace("TransportDriver=TCP/IP",("IPAddress=$NetscalerVIPHostname" + ":1494" + "$newline" + "TransportDriver=TCP/IP")) | Set-Content $Ica -Force
                }
            TBA-Email -Server '$SMTPServer' -ServerPort '$SMTPServerPort' -EmailFrom '$SMTPEmailFrom' -EmailFromPassword '$SMTPEmailFromPassword' -EmailTo '$SMTPEmailTo' -Subject "$env:COMPUTERNAME - XenApp - PublicIP" -Body "$ipinfo"
            }
        7 {
            exit
            }
    }
}


$number = 0
while($tr)
    {
        TBA-Citrix-Configuration -Phase $number
        $number++
    }

"@
        $scriptloc = "C:\Windows\Temp\domainscript.ps1"
        $domainscript | Out-File $scriptloc -Force
        try{
            Start-Process "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File $scriptloc" -verb runAs -ErrorAction Stop
            $Result = "Success"
            $EventResultsEND = TBA-Events -EventID $EventID -State $Result -Final
            TBA-AutoLogin -Disable
        }catch{
            $Result = "Failed"
            $EventResultsEND = TBA-Events -EventID $EventID -State $Result -Fail
        }
        }
exit
}
#endregion
    }
}until($EventResultsEND)
#endregion
