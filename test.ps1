$SubscriptionId = 123456789
 
Connect-AzureRmAccount -Subscription $SubscriptionId

$resourceGroup = Get-AzureRmResourceGroup `
  -Name 'new-resource-group' `
  -Location 'centralus'

$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
  -Name 'new-subnet-config' `
  -AddressPrefix '10.2.1.0/24'

$vnet = New-AzureRmVirtualNetwork `
  -ResourceGroupName $resourceGroup.ResourceGroupName `
  -Location $resourceGroup.Location `
  -Name 'new-vnet' `
  -AddressPrefix '10.2.0.0/16' `
  -Subnet $subnetConfig

$publicIp = New-AzureRmPublicIpAddress `
  -ResourceGroupName $resourceGroup.ResourceGroupName `
  -Location $resourceGroup.Location `
  -Name 'new-public-ip' `
  -AllocationMethod Static

$networkSecRuleConfig = New-AzureRmNetworkSecurityRuleConfig `
  -Name 'network-sec-rule-config' `
  -Description 'Allow SSH' `
  -Access Allow `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 100 `
  -SourceAddressPrefix 'Internet' `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 22


# With Azure CLI, the port had to be opened manually, but not with this
# Priority is sequential (100 gets executed before 101)

$networkSecGroup = New-AzureRmNetworkSecurityGroup `
  -ResourceGroupName $resourceGroup.ResourceGroupName `
  -Location $resourceGroup.Location `
  -Name 'new-network-sec-group' `
  -SecurityRules $networkSecRuleConfig `

$subnet = $vnet.Subnets | Where-Object { $_.Name -eq $subnetConfig.Name }

$nic = New-AzureRmNetworkInterface `
  -ResourceGroupName $resourceGroup.ResourceGroupName `
  -Location $resourceGroup.Location `
  -Name 'new-nic' `
  -Subnet $subnet `
  -PublicIpAddress $publicIp `
  -NetworkSecurityGroup $networkSecGroup

$vmConfig = New-AzureRmVMConfig `
  -VMName 'name-of-new-vm' `
  -VMSize 'Standard_D1'

$password = ConvertTo-SecureString 'password1234' `
  -AsPlainText `
  -Force

$credential = New-Object System.Management.Automation.PSCredential ('demoadmin', $password)

$vmConfig = Set-AzureRmVMOperatingSystem `
  -VM $vmConfig `
  -Linux `
  -ComputerName 'vm-computer-name' `
  -DisablePasswordAuthentication `
  -Credential $credential

$sshPublicKey = Get-Content "~/.ssh/id_rsa.pub"

Add-AzureRmVMSshPublicKey `
  -VM $vmConfig `
  -KeyData $sshPublicKey `
  -Path "/home/demoadmin/.ssh/authorized_keys"

$vmConfig = Set-AzureRmVMSourceImage `
  -VM $vmConfig `
  -PublisherName 'Redhat' `
  -Offer 'rhel' `
  -Skus '7.4' `
  -Version 'latest'

# Assign NIC
$vmConfig = Add-AzureRmVMNetworkInterface `
  -VM $vmConfig `
  -Id $nic.Id

New-AzureRmVM `
  -ResourceGroupName $resourceGroup.ResourceGroupName `
  -Location $resourceGroup.Location `
  -VM $vmConfig

$IpOfVm = Get-AzureRmPublicIpAddress `
  -ResourceGroupName $resourceGroup.ResourceGroupName `
  -Location $resourceGroup.Location | Select-Object -ExpandProperty -PublicIpAddress

$IpOfVm