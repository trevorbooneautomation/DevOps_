param(
$domain
)

function cc-mailflow {
param(
    $subject,
    $body

)

$EmailFrom = "notifier@company.com"
$EmailFromPassword = "password"
$EmailTo = "email@company.com"
$SmtpServer = "smtp.office365.com"
if($body -ne $null)
    {
     $body = $body
     }
else{$Body = ""}
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPMessage.IsBodyHtml = $True
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $EmailFromPassword);
$SMTPClient.Send($SMTPMessage)
}

$BlobID = "Azure\blobaccount"
$BlobPassword = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$loc = "\\blob.file.core.windows.net"
net use $loc /u:$BlobID $BlobPassword
$maindir = "C:\Path"
if(!(Test-Path $maindir))
    {
        New-Item $maindir -ItemType Directory -Force
    }

try{
Copy-Item -Path "$loc\devfiles\Automate\$domain.msi" -Destination "$maindir\$domain.msi" -Force -ErrorAction stop
Unblock-File "$maindir\$domain.msi"
    }
catch{cc-mailflow -subject "$env:COMPUTERNAME - Issue copying MSI file!" -body "$error"
      exit}
$c1 = 0
$c2 = 0
$cc = 0
$dc = 0
do{
$c1++
$chkproc = Get-Process | where {$_.Name -like "*LTSVC"}
$chksvc = Get-Service | where {$_.Name -like "LTService"}
if($c1 -eq 1)
    {
        $cc++
        msiexec /I "$maindir\$domain.msi" /QN
    }
sleep 2
 if($c1 -eq 50)
    {
        Get-Process | where {$_.Name -like "*msiexec*"} | Stop-Process -Force
        $c2++
        $c1 = 0
        if($c2 -eq 2)
            {
                $c1 = 0
                if($dc -eq 1)
                    {
                        cc-mailflow -subject "$env:COMPUTERNAME - Automate Failed to Install within Time - Exiting"
                        exit
                    }
                $dc++
            }
    }


}
while(!($chkproc -and $chksvc.StartType -ne "Running"))
cc-mailflow -subject "$env:COMPUTERNAME - Automate Process Running - Exiting"


##Cleanup

 $cleanupscript = @"
                            Remove-Item '$maindir\automate.ps1' -Force
                            Remove-Item '$maindir\$domain.msi' -Force
"@
                            $cleanupscript | Out-File "C:\Windows\Temp\cleanup_automate.ps1" -Force
                            Start-Process "powershell.exe" -Argumentlist "-ExecutionPolicy Bypass -File C:\Windows\Temp\cleanup_automate.ps1"
                            exit
