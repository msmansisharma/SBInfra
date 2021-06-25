param (
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName
    )
$VMResourceGroupName = "**"
$vm = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMResourceGroupName).Name
$DC0 = $vm[0]
$DC1 = $VM[1]
$RODC = $vm[4]

$aaname = (Get-AzAutomationAccount -ResourceGroupName $ResourceGroupName).AutomationAccountName
# Register all three DC
Register-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -AzureVMName $dc0 -ConfigurationMode 'ApplyAndAutoCorrect' -ConfigurationModeFrequencyMins 30
Register-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -AzureVMName $dc1 -ConfigurationMode 'ApplyAndAutoCorrect' -ConfigurationModeFrequencyMins 30
Register-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -AzureVMName $rodc -ConfigurationMode 'ApplyAndAutoCorrect' -ConfigurationModeFrequencyMins 30

Start-Sleep 10

# Get the ID of the DSC node
$dcnode0 = Get-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -Name $dc0
# Assign the node configuration to the DSC node
Set-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -NodeConfigurationName 'DscConfDomainController.FirstDC' -NodeId $dcnode0.Id -Force
Start-Sleep 60

$dcnode1 = Get-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -Name $DC1
# Assign the node configuration to the DSC node
Set-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -NodeConfigurationName 'DscConfDomainController.AdditionalDC' -NodeId $dcnode1.Id -Force
Start-Sleep 60

$rodcnode = Get-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -Name $rodc
# Assign the node configuration to the DSC node
Set-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -NodeConfigurationName 'DscConfDomainController.RODC' -NodeId $rodcnode.Id -Force
Start-Sleep 60
