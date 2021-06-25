Param(
	[Parameter(Mandatory=$true)]
    [string] $ResourceGroupName
)


$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "PKI"
            PSDscAllowPlainTextPassword = $True
			PSDscAllowDomainUser = $True
        }
    )
}



$automationAccountName = (get-azautomationaccount -ResourceGroupName $ResourceGroupName).AutomationAccountName
$DscSourcePath = './Scripts/DscConfPKI.ps1'
 
Import-AzAutomationDscConfiguration -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -SourcePath $DscSourcePath -Published -Force
Start-AzAutomationDscCompilationJob -ResourceGroupName $resourceGroupName  -AutomationAccountName $automationAccountName  -ConfigurationName 'DscConfPKI' -ConfigurationData $ConfigData -Verbose
