param (
    $ResourceGroupName
    )

$RGName = $ResourceGroupName
$AAccName = (get-azautomationaccount -ResourceGroupName $($RGName)).AutomationAccountName
$deps1 = @("Az.Accounts","Az.Profile","ActiveDirectoryDsc","ComputerManagementDsc","PSDscResources","SecurityPolicyDsc","xActiveDirectory","xAdcsDeployment","xPendingReboot","xTimeZone","xStorage","xPSDesiredStateConfiguration")
$deps2 = "Az.Blueprint"

foreach($dep in $deps1){
    $module = Find-Module -Name $dep
    $link = $module.RepositorySourceLocation + "/package/" + $module.Name + "/" + $module.Version
    New-AzAutomationModule -AutomationAccountName $AAccName -Name $module.Name -ContentLinkUri $link -ResourceGroupName $RGName
    Start-Sleep 2
}

Start-Sleep 5

$module = Find-Module -Name $deps2
$link = $module.RepositorySourceLocation + "/package/" + $module.Name + "/" + $module.Version
New-AzAutomationModule -AutomationAccountName $AAccName -Name $module.Name -ContentLinkUri $link -ResourceGroupName $RGName

Start-Sleep 5

$AzMods = Find-Module -Name Az.*
ForEach ($AzMod in $AZMods){

    if($AzMod.Name -ne 'Az.Accounts' -and $AzMod.Name -ne 'Az.Profile' -and $AzMod.Name -ne 'Az.Blueprint'){
        $link = $AzMod.RepositorySourceLocation + "/package/" + $AzMod.Name + "/" + $AzMod.Version
        New-AzAutomationModule -AutomationAccountName $AAccName -Name $AzMod.Name -ContentLinkUri $link -ResourceGroupName $RGName
        Start-Sleep 2
    }
}