      ###############################################
    ##  By: Trevor Boone                          ##
  ##  Date: 9/1/20                              ##
##  https://github.com/trevorbooneautomation  ##
##############################################

param (
    ##Variables
    $FileLocation = "C:\Compass\test.log"
)

function TBA-Events($eventid,$state) {
$Eventid = [int]$eventid * 3
$EventValue = New-Object -TypeName PSObject -Property @{State="";Message="";Resolution=""}

#########################################################################################
$Events = ` ##   Syntax - Lets describe the events happening in this script!
            ##  "Success", "Failed", "Resolution"
            "This Event 0 is successful", ## Success
                 "This event 0 is a filure", ## Failed
                     "Lets try 0 to do this as a resolution", ##Resolution

            "This Event 1 is successful", ## Success
                 "This event 1 is a filure", ## Failed
                     "Lets try 1 to do this as a resolution", ##Resolution

            "This Event 2 is successful", ## Success
                 "This event 2 is a filure", ## Failed
                     "Lets try 2 to do this as a resolution", ##Resolution

            "This Event 3 is successful", ## Success
                 "This event 3 is a filure", ## Failed
                     "Lets try 3 to do this as a resolution" ##Resolution

##########################################################################################

        if($state -eq "Success")
            {
                $EventValue.Message = $Events[$eventid]
                $EventValue.State = "Success"
                $EventValue.Resolution = "None"
                return $EventValue
            }
        elseif($state -eq "Failed")
            {
                $EventValue.State = "Failed"
                [int]$eventid++
                $EventValue.Message = $Events[$eventid]
                [int]$eventid++
                $EventValue.Resolution = $Events[$eventid]
                return $EventValue
            }

}

function TBA-Write-Log {
    param (
        [string]$Event,

        [ValidateSet("Success", "Failed", IgnoreCase = $true)]
        [string]$State,

        [string]$Reason,
        [string]$Resolution,
        [string]$FileLocation,
        [switch]$SendEmail
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
        "Send Email" : "$SentMail",

    }

"@
      $Output | Out-File $FileLocation -Append

}


#### Event 0
{
    $EventID = 0
    $Result = "Success"

    $EventResults = TBA-Events $EventID $Result
    TBA-Write-Log -State ($EventResults.State) -Reason ($EventResults.Message) -Resolution ($EventResults.Resolution) `
                  -Event $EventID -FileLocation $FileLocation -SendEmail
}
#### Event 1
{

    $Result = "Success"


    $EventID++
    $EventResults = TBA-Events $EventID $Result
    TBA-Write-Log -State ($EventResults.State) -Reason ($EventResults.Message) -Resolution ($EventResults.Resolution) `
                  -Event $EventID -FileLocation $FileLocation -SendEmail
}
