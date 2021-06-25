Configuration DscConfDomainController
{
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xStorage
    Import-DscResource -ModuleName xDSCDomainjoin
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DSCResource -ModuleName xTimeZone
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $dscDomainAdmin = Get-AutomationPSCredential -Name "DomainAdmin"
	$dscDomainName = Get-AutomationVariable -Name "DomainDN"
    $dscDomainNetbiosName = Get-AutomationVariable -Name "NetBiosName"
	$dscSafeModePassword = $dscDomainAdmin
	$DomainRoot = "DC=$($dscDomainAdmin -replace '\.',',DC=')"
	$dscDomainJoinAdminUsername = $dscDomainAdmin.UserName
	$dscDomainJoinAdmin = new-object -typename System.Management.Automation.PSCredential -argumentlist "$dscDomainName\$dscDomainJoinAdminUsername", $dscDomainAdmin.Password
    

    node FirstDC
    {

	    WindowsFeature DNS 
        { 
            Ensure = "Present" 
            Name = "DNS"		
        }

	    WindowsFeature DnsTools
	    {
	        Ensure = "Present"
            Name = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
	    }

        xWaitforDisk Disk3
        {
            DiskId = 3
            RetryIntervalSec = 20
            RetryCount = 30
        }

        xDisk ADDataDisk {
            DiskId = 3
            DriveLetter = "F"
            DependsOn = "[xWaitForDisk]Disk3"
        }

        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
	        DependsOn="[WindowsFeature]DNS" 
        } 

        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        WindowsFeature ADAdminCenter
        {
            Ensure = "Present"
            Name = "RSAT-AD-AdminCenter"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }
         
        xADDomain FirstDS 
        {
            DomainName = $dscDomainName
            DomainAdministratorCredential = $dscDomainAdmin
            SafemodeAdministratorPassword = $dscSafeModePassword
            DomainNetBIOSName = $dscDomainNetbiosName
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
	        DependsOn = "[xDisk]ADDataDisk"
        } 

        xADUser FirstUser 
        { 
            DomainName = $dscDomainName 
            UserName = $dscDomainAdmin.Username 
            Password = $dscDomainAdmin
			PasswordNeverExpires = $true
            Ensure = "Present" 
            DependsOn = "[xADDomain]FirstDS" 
        } 
		
        xADGroup DomainAdmins
        {
            GroupName = 'Domain Admins'
            MembersToInclude = $dscDomainAdmin.Username
			DependsOn = "[xADUser]FirstUser" 
		}
        xTimeZone TimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone         = 'W. Europe Standard Time'
        }
    }      

    
     node AdditionalDC
    {

	    WindowsFeature DNS 
        { 
            Ensure = "Present" 
            Name = "DNS"		
        }

	    WindowsFeature DnsTools
	    {
	        Ensure = "Present"
            Name = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
	    }

        xWaitforDisk Disk3
        {
            DiskId = 3
            RetryIntervalSec = 20
            RetryCount = 30
			DependsOn = "[WindowsFeature]ADAdminCenter" 
        }

        xDisk ADDataDisk {
            DiskId = 3
            DriveLetter = "F"
            DependsOn = "[xWaitForDisk]Disk3"
        }

        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
	        DependsOn="[WindowsFeature]DNS" 
        } 

        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        WindowsFeature ADAdminCenter
        {
            Ensure = "Present"
            Name = "RSAT-AD-AdminCenter"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }
		
		xWaitForADDomain DscForestWait
        {
            DomainName = $dscDomainName
            DomainUserCredential = $dscDomainAdmin
            RetryCount = 15
            RetryIntervalSec = 30
            DependsOn = "[xDisk]ADDataDisk"
        }
		
        xADDomainController SecondDC
        {
            DomainName = $dscDomainName
            DomainAdministratorCredential = $dscDomainJoinAdmin
            SafemodeAdministratorPassword = $dscDomainJoinAdmin
			DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
			DependsOn = "[xWaitForADDomain]DscForestWait" 
        }
        xTimeZone TimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone         = 'W. Europe Standard Time'
        }

    }        
 
    node RODC
    {

        WindowsFeature DNS
        { 
            Ensure = "Present" 
            Name = "DNS" 
        } 

        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
	        DependsOn="[WindowsFeature]DNS" 
        } 

        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        WindowsFeature ADAdminCenter
        {
            Ensure = "Present"
            Name = "RSAT-AD-AdminCenter"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }
        xWaitforDisk Disk3
        {
            DiskId = 3
            RetryIntervalSec = 20
            RetryCount = 30
			DependsOn = "[WindowsFeature]ADAdminCenter" 
        }

        xDisk ADDataDisk {
            DiskId = 3
            DriveLetter = "F"
            DependsOn = "[xWaitForDisk]Disk3"
        }
        
       
		
		xWaitForADDomain DscForestWait
        {
            DomainName = $dscDomainName
            DomainUserCredential = $dscDomainAdmin
            RetryCount = 15
            RetryIntervalSec = 60
            DependsOn = "[xDisk]ADDataDisk"
        }
		

        
        ADDomainController RODC
        {
            DomainName                         = $dscDomainName
            Credential                         = $dscDomainJoinAdmin
            SafemodeAdministratorPassword      = $dscDomainJoinAdmin
            DatabasePath                       = 'F:\NTDS'
            LogPath                            = 'F:\NTDS'
            SysvolPath                         = 'F:\SYSVOL'
            ReadOnlyReplica                    = $true
            SiteName                           = 'Default-First-Site-Name'
            DenyPasswordReplicationAccountName = "Denied RODC Password Replication Group"
        }
        xTimeZone TimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone         = 'W. Europe Standard Time'
        }
    }     
}