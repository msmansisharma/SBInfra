This pipeline steps
- Create RG if not already created otherwise skip
- Laydown netowrk VNET and SUBNETS
- Deploy AZCOMP JSON will cover below
    1. Storage account creation
    2. Automation account creation
    3. LA workspace creation
    4. Enable update mgmt in LA
    5. Link AA and LA
    6. Create managed Identity will be used in disk encryption
    7. Assign role of contributer to managed identity
    8. Create Keyvault
    9. Create deployment script for disk encryption
- Secure file to upload secrets in keyvault in bulk
- Add modules in the automation account
IN_BETWEEN - ADD creds in AA and vars
- Onboard DSC configuration in AA
- Deploy DC's VM which can be Primary DC, Additional DC and RODC
- Onboard PKI conf in AA
- Deploy PKI VM and MGMT or any other VM
- Onboard PKI DSC
VARIABLES LIST IN PIPELINE

NSGname                 Global-NSG
NSGnameDev              NSG-Global-DEV
resourceGroupName       azureInfraRG
resourceGroupNameDev    azureInfraRGDev
subnt1add               10.0.1.0/24
subnt1adddev            10.0.1.0/24
subnt1name              SubnetSB-DC
subnt1namedev           SubnetSB-DC-DEV
subnt2add               10.0.2.0/24
subnt2adddev            10.0.2.0/24
subnt2name              SubnetSB-RODC
subnt2namedev           SubnetSB-RODC-DEV
subnt3add               10.0.3.0/24
subnt3adddev            10.0.3.0/24
subnt3name              SubnetSB-CA
subnt3namedev           SubnetSB-CA-DEV
subnt4add               10.0.4.0/24
subnt4adddev            10.0.4.0/24
subnt4name              SubnetSB-MGMT
subnt4namedev           SubnetSB-MGMT-DEV
vnetadd                 10.0.0.0/16
vnetadddev              10.0.0.0/16
vnetName                Azure-Vnet-SB
vnetNamedev             Azure-Vnet-SB
