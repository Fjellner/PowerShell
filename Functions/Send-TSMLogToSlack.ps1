#------------------------------------------------------------------------------------------------
#
#   Author:         Andreas Fjellner
#   Twitter:        @andreasfjellner
#   Blog:           PowerDeploy.com
#   Source Control: github.com/fjellner
#   Version:        1.0.0.0
#   
#   Disclaimer: This script is provided "AS IS" with no warranties, confers no rights and is not supported by the author.
#------------------------------------------------------------------------------------------------

# All servers to monitor
$server = "SERVER1", "SERVER2", "SERVER3"

# Slacks url
$webhook = "https://hooks.slack.com/services/YOURKEY"

foreach ($s in $server) {
    
    $StartRow = 0
    
    # Get DSM Scheduler log
    $row = Get-Content "\\$s\c$\Program Files\Tivoli\TSM\baclient\dsmsched.log" -Tail 200

    foreach ($r in $row) {
        # Get the rows starting and ending with this
        if ($r -like "*--- SCHEDULEREC STATUS BEGIN*") { $StartRow = $r.ReadCount - 1 }
        if ($r -like "*--- SCHEDULEREC STATUS END*") { $EndRow = $r.ReadCount}
    }

    # If '--- SCHEDULEREC STATUS BEGIN' not found, eather backup is still running or something is wrong
    if ($StartRow -eq 0 ) {
 
        $body = @{
            channel = "#logs"
            username = "$s TSM Log"
            text = "Something went wrong or backup is still running, check dsmsched.log"
            icon_emoji = ":exclamation:"
        }  
    }
    else {
        # Get the summary
        $message = $row[$StartRow..$EndRow] -join "`n"

        $body = @{
            channel = "#logs"
            username = "$s TSM Log"
            types = "snippets"
            text = "$message"
            icon_emoji = ":floppy_disk:"
        }  
    }

    # Post message
    Invoke-RestMethod -Method Post -Body (ConvertTo-Json $body) -Uri $webhook
}