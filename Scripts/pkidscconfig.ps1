param (
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName
    )
#Start-Sleep 1800

$VMResourceGroupName = "**"
$vm = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMResourceGroupName).Name
$ca0 = $vm[3]

$aaname = (Get-AzAutomationAccount -ResourceGroupName $ResourceGroupName).AutomationAccountName
# Register PKI
Register-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -AzureVMName $ca0 -ConfigurationMode 'ApplyAndAutoCorrect' -ConfigurationModeFrequencyMins 30
Start-Sleep 20

# Get the ID of the DSC node
$pkinode = Get-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -Name $ca0
# Assign the node configuration to the DSC node
Set-AzAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $aaname -NodeConfigurationName 'DscConfPKI.PKI' -NodeId $pkinode.Id -Force
Start-Sleep 120

