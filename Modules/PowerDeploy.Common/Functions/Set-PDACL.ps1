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

function Set-PDACL {
    <#
  .DESCRIPTION
  Simple function to set Read/Modify/FullControl on file/folders
  .EXAMPLE
  Set-PDACL -Permission Modify -Group 'FileAcc-Missions' -Path 'D:\Data\Missions'
   
  .PARAMETER Permission
  Permission: Read, ReadRootOnly, Modify of FullControl

  .PARAMETER Group
  AD-Group to target

  .PARAMETER Path
  Path to target
  #>      
    [CmdletBinding()]
    param(
        [parameter(mandatory = $true)]
        [validateset("Read", "ReadRootOnly", "Modify", "FullControl")]
        $Permission,

        [parameter(mandatory = $true)]
        $Group,

        [parameter(mandatory = $true)]
        $Path         
    )
      
       
    switch ($Permission) {
        'FullControl' {
            $PermissionsName = 'FullControl'
            $inheritance = 'ContainerInherit, ObjectInherit'
            $var = 'None' 
        }

        'Read' {
            $PermissionsName = 'ReadAndExecute'
            $inheritance = 'ContainerInherit, ObjectInherit'
            $var = 'None'
        }

        'ReadRootOnly' {
            $PermissionsName = 'ReadAndExecute'
            $inheritance = 'None, None'
            $var = 'None'           
        }

        'Modify' {
            $PermissionsName = 'Modify'
            $inheritance = 'ContainerInherit, ObjectInherit'
            $var = 'InheritOnly'        
        }        
    }

    Function Set-PDACLApply ($PermissionsName, $inheritance, $var) {    
        try {
            $acl = Get-Acl -Path $Path
            $ace = New-Object Security.AccessControl.FileSystemAccessRule($Group, $PermissionsName, $inheritance, $var, 'Allow')
            $acl.AddAccessRule($ace)
            $acl.SetAccessRuleProtection($true, $true)
            Set-Acl -AclObject $acl -Path $Path
        }
        catch [Exception] {Write-Output "Something went wrong"}
    }

    
    If ($Permission -eq 'Modify') { 
        # Set only read access to root folder, prevents accidental drag n drop
        Set-PDACLApply -PermissionsName 'ReadAndExecute' -inheritance 'None, None' -var 'None'  
    }

    Set-PDACLApply -PermissionsName  $PermissionsName -inheritance $inheritance -var  $var
}