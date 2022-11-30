<#
.Synopsis
   Script to Automated Active Directory change of custom attribute based on an API response.
.DESCRIPTION
   Version 3.0 November 2022
   Requires: Windows PowerShell Module for Active Directory

   Author: Victor Menezes (MCP)
#>
#
### Creating a .Net ArrayList
$CADLoopNames = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$CADLoopNames= @()
#
## Using Invoke-RestMethod to obtain from API the list of users within "F" status
$ApiUsersData = Invoke-RestMethod -Uri "http://url.example.com/rest/api/status?situation=F"
#
## Storing results for accounts with 'userlogin' and 'matricula'
$CADusers = ($ApiUsersData | where-object {$_.userlogin -ne $null -and $_.matricula -ne $null})
#
## Routine to define when or not change the "userMatricula" attribute
$CADusers | ForEach-Object {
#
$CADLoop = Get-ADUser -Identity $_.userlogin –Properties userMatricula
#
if ($CADLoop.userMatricula -ne $_.matricula) {
#
## Adding to array userlogins that has cheanged the "userMatricula" attribute
$CADLoopNames.Add($CADLoop.SamAccountName) > $null
## Setting the "userMatricula" attribute
Set-ADUser -Identity $_.userlogin -Replace @{userMatricula=$_.matricula}
}
}
#
## Showing results for users with 'userMatricula' attibute
if ($CADLoopNames -ne $null) {
Write-Output "Os seguintes usuários tiveram o atributo de Matricula alterado:"
$CADLoopNames | ForEach-Object {Get-ADUser -Identity $_ –Properties userMatricula} | FT Name, userMatricula -Autosize
}
## When nothing needs to be done
else {
Write-Output "Nenhum usuário precisou ter sua matricula modificada nesse momento."
}