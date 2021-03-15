param (
    [Parameter(Mandatory=$True)]$MainDirectory,
    [Parameter(Mandatory=$True)]$Websites,
    [Parameter(Mandatory=$True)]$WebsiteRoot,
    [Parameter(Mandatory=$True)]$ValidationMode,
    [Parameter(Mandatory=$True)]$Validation,
    [Parameter(Mandatory=$True)]$Configuration,
    $DefaultWebsite,
    $AzureEnabled,
    $AzureTenantId,
    $AzureClientId,
    $AzureSecret,
    $AzureSubscriptionId,
    $AzureResourceGroupName,
    $SMTPEmailTo,
    $SMTPEmailFrom,
    $SMTPEmailFromPassword,
    $SMTPServer,
    $SMTPServerPort
)

function TBA-WebRequest {
    param (
        [switch]$Azure,
        [switch]$Acme
    )
  $Site = "https://github.com"
  $SitePath = "win-acme/win-acme/releases"
  $URL = (Invoke-WebRequest -Uri "$Site/$SitePath" -UseBasicParsing).Links | where {$_ -like "*$SitePath/download/*"}
  if($azure)
    {
      $Search = "*dns.azure*"
    }
  if($acme)
    {
      $Search = "*x64.pluggable*"
    }
$ReturnURL = $URL | where {$_ -like $Search} | select -ExpandProperty href -First 1
$ReturnURL = $Site + $ReturnURL
return $ReturnURL
}

function TBA-OrganizeSites {
    param (
        [array]$Sites 
    )
    $Default  = "Default Web Site"
    if($Sites -like "*$Default*")
        {
        $Sites = $Sites.split(",")
        $Sites = $Sites -replace "^\s"
    }else{
        $Sites = $Sites.split(" ")
        $Sites = $Sites -replace ","

    }
return $Sites
}

function TBA-Certificate {
    param (
        [ValidateSet("IIS", "Manual", IgnoreCase = $True)]
        [string]$Target,
        [switch]$Azure
    )
if($Azure)
    {
        & "$MainDirectory\wacs.exe" --target "iis" `
                                    --accepttos `
                                    --emailaddress "$SMTPEmailTo" `
                                    --host "$website" `
                                    --commonname "$website" `
                                    --validation "$validation" `
                                    --validationmode "$validationmode" `
                                    --installation "iis" `
                                    --sslipaddress "$IP" `
                                    --sslport "443" `
                                    --azuretenantid "$AzureTenantId" `
                                    --azureclientid "$AzureClientId" `
                                    --azuresecret "$AzureSecret" `
                                    --azuresubscriptionid "$AzureSubscriptionId" `
                                    --azureresourcegroupname "$AzureResourceGroupName" `
    }else{
        & "$MainDirectory\wacs.exe" --target "iis" `
                                    --host "$website" `
                                    --validation "$validation" `
                                    --validationmode "$validationmode" `
                                    --installation "iis" `
                                    --sslport "443" `
                                    --accepttos `
                                    --emailaddress "$SMTPEmailTo" 

    }

}

function TBA-Endpoint {
    param (
    [switch]$Azure,
    [switch]$Acme,
    [switch]$Update

    )
if($Azure)
    {
        $WebRequest = TBA-WebRequest -Azure
        if($Update)
        {
        $AzurePluginReplace = $WebRequest -replace "^.+dns.azure.v"
        $AzurePluginReplace = $AzurePluginReplace -replace ".zip$"
        $AzureIP = Get-Childitem $MainDirectory | where {$_.Name -like "*.zip"} | select -ExpandProperty Name
        $AzureIP = $AzureIP -replace "^.+dns.azure.v"
        $AzureIP = $AzureIP -replace ".zip$"
        if("$AzureIP" -notlike "$AzurePluginReplace")
            {
                Get-Childitem $MainDirectory | where {$_.Name -like "*.zip"} | Remove-Item -Force
                $dl = New-Object net.webclient
                $dl.Downloadfile($WebRequest, "$MainDirectory\$AzurePluginReplace.zip")
                $AzurePath = Get-Childitem $MainDirectory | where {$_.Name -like "*.zip"}
                Expand-Archive -LiteralPath $AzurePath.FullName -DestinationPath $MainDirectory -Force  
            }
        }else{
        $dl = New-Object net.webclient
        $dl.Downloadfile($WebRequest, "$MainDirectory\$AzurePluginReplace.zip")
        $AzurePath = Get-Childitem $MainDirectory | where {$_.Name -like "*.zip"}
        Expand-Archive -LiteralPath $AzurePath.FullName -DestinationPath $MainDirectory -Force
        }
    }
if($Acme)
    {
        $WebRequest = TBA-WebRequest -Acme
        if($Update)
        {
        $Fileversion = (Get-ItemProperty "$MainDirectory\wacs.exe").VersionInfo.FileVersion
        $FileURLVersion = $WebRequest -replace "^.+win-acme.v" -replace ".x64.+$"
        if($FileVersion -notlike $FileURLVersion)
            {
            Remove-Item $MainDirectory -Recurse -Force
            $dl = New-Object net.webclient
            $dl.Downloadfile($WebRequest, "$MainDirectory\ACME.zip")
            Expand-Archive -LiteralPath "$MainDirectory\ACME.ZIP" -DestinationPath $MainDirectory -Force
            Remove-Item "$MainDirectory\ACME.zip" -Force
            }
        }else{
        $dl = New-Object net.webclient
        $dl.Downloadfile($WebRequest, "$MainDirectory\ACME.zip")
        Expand-Archive -LiteralPath "$MainDirectory\ACME.ZIP" -DestinationPath $MainDirectory -Force
        Remove-Item "$MainDirectory\ACME.zip" -Force
        }
    }
}

function TBA-GetIP {
    param (
    [string]$Site
    )

if((Get-Command "Get-IISSite") -ne $Null)
{
    $IP = Get-IISSite | where {$_.Name -like $Site}
    $IP = ($IP.bindings | select -ExpandProperty bindingInformation) -replace ":.+" | select -last 1
}
else
{
    try{
    $I = Get-Childitem "IIS:\Sites" -ErrorAction SilentlyContinue
        if($I)
        {
            $IP = Get-ChildItem -Path IIS:\Sites | where {$_.Name -like $Site}
            $IP = ((($IP.bindings.Collection[0]).bindingInformation) -split ":")[0]
        }
    }catch{break}
}
return $IP
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
            -Subject "$env:COMPUTERNAME - (($PSCommandPath -replace '^.+\\') -replace '.ps1') - EventID $Event - $State" -Body "$Reason"
        }
    if($Final)
        {
            TBA-Email -Server $SMTPServer -ServerPort $SMTPServerPort -EmailFrom $SMTPEmailFrom -EmailFromPassword $SMTPEmailFromPassword -EmailTo $SMTPEmailTo `
            -Subject "$env:COMPUTERNAME - (($PSCommandPath -replace '^.+\\') -replace '.ps1') - EventID $Event - $State" -Body "$Reason" -Attach $global:FileLocation
        }
        
}
#region - Main
$global:filelocation = $FileLocation
Import-Module Webadministration
$TestMainDirectory = Test-Path "$MainDirectory\wacs.exe"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#endregion - Main
#region - Create Folder and Install ACME if new installation
if(!($TestMainDirectory))
    {
    if(!(Test-Path $MainDirectory))
        {New-Item $MainDirectory -ItemType Directory -Force | Out-Null}
    TBA-Endpoint -Acme
    }
#endregion - Create Folder and Install ACME 
#region - Azure Install
if($AzureEnabled -eq $true)
    {TBA-Endpoint -Azure -Update}
TBA-Endpoint -Acme -Update
#endregion - Azure Install
#region - Website Prep
$ListWebsites = & "$MainDirectory\wacs.exe" --list
$Websites = TBA-OrganizeSites -Sites $Websites
#endregion - Website Prep
foreach($website in $websites)
    {
        $ListWebsite = $ListWebsites | Select-String ($website.replace('*',''))
        $IP = TBA-GetIP -Site $Website

        ## Azure DNS Configuration
        if($ListWebsite -eq $null -and $Configuration -like "azure-dns")
            {
                if($DefaultWebsite)
                    {
                        if(!(Get-WebBinding -Name "Default Web Site" -Protocol https -Port 443) -eq $true)
                        {New-WebBinding -Name "Default Web Site" -IPAddress "*" -Port 443 -HostHeader $website -Protocol https}
                        $IP = (Get-NetIPConfiguration).IPv4Address.IPAddress
                        TBA-Certificate -Target IIS -Azure
                 }else{
                        TBA-Certificate -Target IIS -Azure
                }
            }
        ## IIS HTTPS Configuration
        elseif($ListWebsite -eq $null -and $Configuration -like "iis-https")
            {
                if(!(Test-Path "$MainDirectory\Validate"))
                    {
                        New-Item "$MainDirectory\Validate" -ItemType Directory -Force
                    }
                    TBA-Certificate -Target IIS
            }
    }
#region - Renew Certificates that are expiring
& "$MainDirectory\wacs.exe" --renew --baseuri "https://acme-v02.api.letsencrypt.org/"
#endregion
