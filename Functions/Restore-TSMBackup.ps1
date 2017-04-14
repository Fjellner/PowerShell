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

[CmdletBinding()]
param(
    [parameter(mandatory = $true, Position = 1)]
    [string]$From,
    [parameter(mandatory = $true, Position = 2)]
    [string]$To,
    [parameter(mandatory = $false, Position = 4)]
    [string]$PointInTime = "false"
)


<#
    .Synopsis
    Wrapper for DSMC.exe

    .EXAMPLE
    Restore-TSMBackup.ps1 -From -From "E:\HomeFolder\JamesBond\Missions" -To "E:\Restore"
    Restores all files and subfolders in Missions from latest backup to E:\Restore 

    .EXAMPLE
    Restore-TSMBackup.ps1 -From "E:\HomeFolder\JamesBond\Missions" -To "E:\Restore"  -PointInTime "07/25/2016"
    Restores all files and subfolders in Missions from 07/25/2016 to E\Restore

    .PARAMETER From
    Path to folder to restore

    .PARAMETER To
    Where to restore data, dosent allow spaces in path

    .PARAMETER PointInTime
    Point In Time to restore from, has to be in format '07/25/2016'

    #>

If ($To -match '\s') { 

    Write-Warning "No spaces allowed in restore path"  
    break
}

$totalTime = New-Object System.Diagnostics.Stopwatch
$totalTime.Start()

if ($PointInTime -ne "false") {
    $cmd = "/c dsmc restore -inactive -subdir=yes -pitd=$PointInTime ""$From\*"" $To\"
}
else {
    $cmd = "/c dsmc restore -inactive -subdir=yes ""$From\*""  $To\"
}
    
$guid = [GUID]::NewGuid().Guid
$file = New-item -Path "$env:temp\$guid.txt" -ItemType file

Write-Output "Start-Process  'cmd.exe' -ArgumentList $cmd -WorkingDirectory 'c:\Program Files\Tivoli\TSM\baclient' -Wait -RedirectStandardOutput $($file.FullName)"
Start-Process  'cmd.exe' -ArgumentList $cmd -WorkingDirectory 'c:\Program Files\Tivoli\TSM\baclient' -Wait -RedirectStandardOutput $($file.FullName)
                    
Write-Output "Logfile: $($file.FullName)" 
Get-Content $file.FullName -Tail 9


$totalTime.Stop()
$ts = $totalTime.Elapsed
$totalTime = [system.String]::Format("{0:00}:{1:00}:{2:00}", $ts.Hours, $ts.Minutes, $ts.Seconds)
Write-Host "Process time: $totalTime" -ForegroundColor Yellow




