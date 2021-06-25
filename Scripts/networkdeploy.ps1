param (
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $NSGname,
    [string] [Parameter(Mandatory=$true)] $vnetName,
    [string] [Parameter(Mandatory=$true)] $vnetAdd,
    [string] [Parameter(Mandatory=$true)] $subnt1name,
    [string] [Parameter(Mandatory=$true)] $subnt1add,
    [string] [Parameter(Mandatory=$true)] $subnt2name,
    [string] [Parameter(Mandatory=$true)] $subnt2add,
    [string] [Parameter(Mandatory=$true)] $subnt3name,
    [string] [Parameter(Mandatory=$true)] $subnt3add,
    [string] [Parameter(Mandatory=$true)] $subnt4name,
    [string] [Parameter(Mandatory=$true)] $subnt4add
    )

$Location = az group show --name $ResourceGroupName --query 'location'

# Create a network security group
az network nsg create --name $NSGname `
                      --resource-group $ResourceGroupName `
                      --location $Location

# Create a network security group rule for port 3389.
az network nsg rule create --name PermitRDP `
                           --nsg-name $NSGname `
                           --priority 1000 `
                           --resource-group $ResourceGroupName `
                           --access Allow `
                           --source-address-prefixes VirtualNetwork `
                           --destination-address-prefixes VirtualNetwork `
                           --source-port-ranges "*" `
                           --direction Inbound `
                           --destination-port-ranges 3389
 
# Create a virtual network.
az network vnet create --name $VNetName `
                       --resource-group $ResourceGroupName `
                       --address-prefixes $vnetAdd `
                       --location $Location

# Create a subnet for DC
az network vnet subnet create --address-prefix $subnt1add `
                              --name $subnt1Name `
                              --resource-group $ResourceGroupName `
                              --vnet-name $VNetName -n $subnt1Name `
                              --network-security-group $NSGname

# Create a subnet for RODC
az network vnet subnet create --address-prefix $subnt2add `
                              --name $subnt2name `
                              --resource-group $ResourceGroupName `
                              --vnet-name $VNetName -n $subnt2name `
                              --network-security-group $NSGname

# Create a subnet for MGMT
az network vnet subnet create --address-prefix $subnt3add `
                              --name $subnt3name `
                              --resource-group $ResourceGroupName `
                              --vnet-name $VNetName -n $subnt3name `
                              --network-security-group $NSGname

# Create a subnet for ADCS
az network vnet subnet create --address-prefix $subnt4add `
                              --name $subnt4name `
                              --resource-group $ResourceGroupName `
                              --vnet-name $VNetName -n $subnt4name `
                              --network-security-group $NSGname
