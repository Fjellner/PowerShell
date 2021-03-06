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

function Copy-PDData {
    <#
  .DESCRIPTION
  Copy files from A to B using RoboCopy, keep timestamps and discard ACL's
  .EXAMPLE
  Copy-Data -From \\domain\dfs\folder1\FoldertoCopy -Destination c:\temp -Logpath 'c:\temp\CopyFolder.log
  
  .PARAMETER Source
  Path to source

  .PARAMETER Destination
  Path to destination

  .PARAMETER LogPath
  Full path to logfile (c:\logs\copy.log), default ($env:TEMP\Copy-PDData.log)
  #>        
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Source,
        [Parameter(Mandatory = $true)]
        [string[]]$Destination,
        [Parameter(Mandatory = $false)]
        [string[]]$LogPath = "$($env:TEMP)\Copy-PDData.log"
    )      
        
    Write-Host -ForegroundColor Yellow "Copy data from $Source to $Destination"
    Write-Host -ForegroundColor Yellow "enter Y to continue"     
    $continue = Read-Host
    If ($continue -ne "Y") {break}
      
    # Köra robocopy här
    Start-Process -FilePath 'C:\Windows\System32\robocopy.exe' -ArgumentList """$Source"" ""$Destination"" /e /B /W:5 /copy:DAT /MT /dcopy:T /r:10 /log:$LogPath"  -Wait
  
}
