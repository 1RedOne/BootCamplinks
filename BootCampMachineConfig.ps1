$secpasswd = ConvertTo-SecureString 'IWouldLiketoRecoverPlease1!' -AsPlainText -Force
$SafeModePW = New-Object System.Management.Automation.PSCredential ('guest', $secpasswd)
 
$secpasswd = ConvertTo-SecureString 'IveGot$kills!' -AsPlainText -Force
$localuser = New-Object System.Management.Automation.PSCredential ('guest', $secpasswd)
 
configuration TestLab
{
     param
    (
        [string[]]$NodeName ='localhost',
        #[Parameter(Mandatory)][string]$MachineName,  
        $firstDomainAdmin,
        [Parameter(Mandatory)][string]$DomainName,
        [Parameter()]$SafeModePW,
        [Parameter()]$Password
    ) 
 
    #Import the required DSC Resources
    Import-DscResource -Module xActiveDirectory
    Import-DscResource -Module xComputerManagement 
 
    Node $NodeName
    { #ConfigurationBlock 
 
        <#
        xComputer NewNameAndWorkgroup
            {
                Name          = $MachineName
 
            }
            #>
 
        WindowsFeature ADDSInstall
        { 
 
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
            IncludeAllSubFeature = $true
        }
 
        WindowsFeature RSATTools
        {
            DependsOn= '[WindowsFeature]ADDSInstall'
            Ensure = 'Present'
            Name = 'RSAT-AD-Tools'
            IncludeAllSubFeature = $true
        }
 
        
        <#
        xIPAddress NewIPAddress
        {
            IPAddress      = "10.20.30.1"
            InterfaceAlias = "Ethernet"
            SubnetMask     = 24
            AddressFamily  = "IPV4"
 
        }
        
        WindowsFeature DHCP {
            DependsOn = '[xIPAddress]NewIpAddress'
            Name = 'DHCP'
            Ensure = 'PRESENT'
            IncludeAllSubFeature = $true                                                                                                                              
 
        }  
 
        WindowsFeature DHCPTools
        {
            DependsOn= '[WindowsFeature]DHCP'
            Ensure = 'Present'
            Name = 'RSAT-DHCP'
            IncludeAllSubFeature = $true
        }  
        #>
 
        xADDomain SetupDomain {
            DomainAdministratorCredential= $firstDomainAdmin
            DomainName= $DomainName
            SafemodeAdministratorPassword= $SafeModePW
            DependsOn='[WindowsFeature]RSATTools'
            DomainNetbiosName = $DomainName.Split('.')[0]
        }
        <#Commented out for later
        xDhcpServerScope Scope
        {
         DependsOn = '[WindowsFeature]DHCP'
         Ensure = 'Present'
         IPEndRange = '10.20.30.250'
         IPStartRange = '10.20.30.5'
         Name = 'PowerShellScope'
         SubnetMask = '255.255.255.0'
         LeaseDuration = '00:08:00'
         State = 'Active'
         AddressFamily = 'IPv4'
        } 
 
        xDhcpServerOption Option
     {
         Ensure = 'Present'
         ScopeID = '10.20.30.0'
         DnsDomain = 'fox.test'
         DnsServerIPAddress = '10.20.30.1'
         AddressFamily = 'IPv4'
     }
     #>
 
    #End Configuration Block
    }
}
 
$configData = 'a'
 
$configData = @{
                AllNodes = @(
                              @{
                                 NodeName = 'localhost';
                                 PSDscAllowPlainTextPassword = $true
                                    }
                    )
               }

if (-not(test-path C:\PowerShell)){mkdir C:\PowerShell }
Set-Location C:\PowerShell

Write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Write-host " FOXDeploy One Click Domain Controller "
Write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

write-warning "Domain names must end in .local or .test"
$userDomain =  read-host "Specify your desired domain name, you'll use this the next time you login"
"user specified domain name of $userDomain" >> c:\powershell\DSCBuild.log
TestLab -DomainName $userDomain -Password $localuser `
    -SafeModePW $SafeModePW -firstDomainAdmin (Get-Credential -UserName "$userDomain\FoxDeploy" -Message 'Specify Credentials for first domain admin' | tee -filePath  c:\powershell\DSCBuild.log -append) `
    -ConfigurationData $configData
 
Start-DscConfiguration -ComputerName localhost -Wait -Force -Verbose -path .\TestLab -Debug

1..10 | % {Write-warning "Time to reboot the machine!"; start-sleep -Milliseconds 400}
