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

Function Test-PDADGroupMembership {
    <#
  .DESCRIPTION
  Checks if a user is a member in an AD-Group
  .EXAMPLE
   Test-PDADGroupMembership -UserName JamBon -GroupName 'Missions'  
  .PARAMETER UserName
  UserName
  .PARAMETER GroupName
  Groupname
  #>

    [CmdletBinding()]
    [OutputType([bool])]
    Param
    (
        # AD Object
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]$UserName,

        # Group to check
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]$GroupName
    )

    $GroupList = @{}
    # Retrieve tokenGroups attribute, which is operational (constructed).

    try {
       
        $strFilter = "(&(objectCategory=User)(samAccountName=$UserName))"
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
        $objSearcher.Filter = $strFilter
        $objPath = $objSearcher.FindOne()
        $objUser = $objPath.GetDirectoryEntry()
        $objUser.psbase.RefreshCache("tokenGroups")
        $SIDs = $objUser.psbase.Properties.Item("tokenGroups")
        
        # Populate hash table with security group memberships.
        ForEach ($Value In $SIDs) {
            $SID = New-Object System.Security.Principal.SecurityIdentifier $Value, 0
            $Group = $SID.Translate([System.Security.Principal.NTAccount])
            $GroupList.Add($Group.Value.Split("\")[1], $True)
        }
    }
    catch [Exception] {  }
     

    If ($GroupList.ContainsKey($GroupName)) {
        Return $True
    }
    Else {
        Return $False
    } 
}