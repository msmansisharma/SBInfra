Configuration DscConfPKI
{

    
    Import-DscResource -ModuleName xAdcsDeployment
    Import-DSCResource -ModuleName xTimeZone
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $dscDomainAdmin = Get-AutomationPSCredential -Name "DomainAdmin"
	$dscDomainName = Get-AutomationVariable -Name "DomainDN"
	$dscDomainJoinAdminUsername = $dscDomainAdmin.UserName
	$dscDomainJoinAdmin = new-object -typename System.Management.Automation.PSCredential -argumentlist "$dscDomainName\$dscDomainJoinAdminUsername", $dscDomainAdmin.Password
    
    Node PKI {

        # Install the ADCS Certificate Authority
        WindowsFeature ADCSCA {
            Name = 'ADCS-Cert-Authority'
            Ensure = 'Present'
        }

            WindowsFeature RSAT-ADCS 
        { 
            Ensure = 'Present' 
            Name = 'RSAT-ADCS' 
            DependsOn = '[WindowsFeature]ADCSCA' 
        } 
        WindowsFeature RSAT-ADCS-Mgmt 
        { 
            Ensure = 'Present' 
            Name = 'RSAT-ADCS-Mgmt' 
            DependsOn = '[WindowsFeature]ADCSCA' 
        } 

          # Configure the CA as Standalone Root CA
        xADCSCertificationAuthority ConfigCA
        {
            Ensure = 'Present'
            Credential = $dscDomainJoinAdmin
            CAType = 'EnterpriseRootCA'
			CACommonName = $Node.CACommonName
            CADistinguishedNameSuffix = $Node.CADistinguishedNameSuffix
            ValidityPeriod = 'Years'
            ValidityPeriodUnits = 20
            CryptoProviderName = 'RSA#Microsoft Software Key Storage Provider'
            HashAlgorithmName = 'SHA256'
            KeyLength = 4096
            DependsOn = '[WindowsFeature]ADCSCA' 
        }

        xTimeZone TimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone         = 'W. Europe Standard Time'
        }



     }


  
  }
 