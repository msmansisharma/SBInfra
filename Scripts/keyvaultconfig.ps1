param(
                  [string] [Parameter(Mandatory=$true)] $VaultName,
                  [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
                  [string] [Parameter(Mandatory=$true)] $LocationName
                )
          
                $ErrorActionPreference = 'Stop'
                $DeploymentScriptOutputs = @{}
                $KeyName = 'sb-az-deploy-script-encryption-key'
                $DiskEncryptionSetName = 'sb-az-deploy-script-encryption-set'
                $kekEncryptionUrlSecretName = 'az-disk-key-kek-kid'
                # Get KeyVault
                $kv =  Get-AzKeyVault -Name $VaultName -ResourceGroupName $ResourceGroupName
                
                # Check if Disk Encryption Key exists
                $diskEncrptKey = `
                  (Get-AzKeyVaultKey `
                      -VaultName $VaultName `
                      -Name $KeyName `
                      -ErrorAction SilentlyContinue).Id;
                  
                  # Create New Disk Encryption Key
                  if ($null -eq $diskEncrptKey) {
                    $diskEncrptKey = (Add-AzKeyVaultKey `
                          -VaultName $VaultName `
                          -Name $KeyName `
                          -Destination 'HSM').Id;                                            
                  }
                  
                  # Get Disk Encryption Newly Created Key
                  $diskEncrptKey = (Get-AzKeyVaultKey `
                      -VaultName $VaultName `
                      -Name $KeyName)
                  # Update secret for KeK encryption with KV KeK URL
                    $secretvalue = ConvertTo-SecureString $diskEncrptKey.Key.Kid -AsPlainText -Force
                    $secret = Set-AzKeyVaultSecret -VaultName $VaultName -Name $kekEncryptionUrlSecretName -SecretValue $secretvalue
                  # Create New Disk Encryption Set Config
                  $desConfig = (New-AzDiskEncryptionSetConfig `
                        -Location $LocationName `
                        -SourceVaultId $kv.ResourceId `
                        -KeyUrl $diskEncrptKey.Key.Kid `
                        -IdentityType SystemAssigned)
                      
                  # Create New Disk Encryption Set
                  $desEncrySet = (New-AzDiskEncryptionSet `
                            -Name $DiskEncryptionSetName `
                            -ResourceGroupName $ResourceGroupName `
                            -InputObject $desConfig)
                  # Get newly created disk encryption Set
                  $des = (Get-AzDiskEncryptionSet `
                      -ResourceGroupName $ResourceGroupName `
                      -Name $DiskEncryptionSetName)
                        
                  # Add the Disk Encryption Set Application to Key Vault Access Policy
                  (Set-AzKeyVaultAccessPolicy `
                        -VaultName $VaultName `
                        -ObjectId $des.Identity.PrincipalId `
                        -PermissionsToKeys wrapkey,unwrapkey,get `
                        -BypassObjectIdValidation)