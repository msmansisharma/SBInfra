Param(
	[Parameter(Mandatory=$true)]
    [string] $ResourceGroupName
)

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "FirstDC"
            PSDscAllowPlainTextPassword = $True
			PSDscAllowDomainUser = $True
        },
        @{
            NodeName = "AdditionalDC"
            PSDscAllowPlainTextPassword = $True
			PSDscAllowDomainUser = $True
        }
         @{
            NodeName = "RODC"
            PSDscAllowPlainTextPassword = $True
			PSDscAllowDomainUser = $True
        }
    )
}

$automationAccountName = (get-azautomationaccount -ResourceGroupName $ResourceGroupName).AutomationAccountName
$DscSourcePath = './Scripts/DscConfDomainController.ps1'
 
Import-AzAutomationDscConfiguration -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -SourcePath $DscSourcePath -Published -Force
Start-AzAutomationDscCompilationJob -ResourceGroupName $resourceGroupName  -AutomationAccountName $automationAccountName  -ConfigurationName 'DscConfDomainController' -ConfigurationData $ConfigData -Verbose
