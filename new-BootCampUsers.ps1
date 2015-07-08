#BootCamp new users
$names = import-csv C:\powershell\usernames.csv

if ($OUs -eq $null){
    "making OUs"
    $OUs = "Accounting","IT","Engineering","Marketing" | % {New-ADOrganizationalUnit $_ -PassThru }
    }

ForEach ($OU in $Ous) {

     1..15 | ForEach { 
        $first = Get-Random $names.First_Name
        $last  = Get-Random $names.Last_Name

    "$first $last"
    new-aduser -name "$First $last" -Path $OU -WhatIf
    
    }
}