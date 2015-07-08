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

    "$first $last Logon Name : $($first[0]).$last"
    new-aduser -name "$First $last" -GivenName $first -Surname $last -SamAccountName "$($first[0]).$last" -Path $OU 
    
    }
}