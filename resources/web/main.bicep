metadata description = 'Deploy a load-balanced NGINX web layer'

@description('Project environment')
@allowed([
  'dev'
  'prod'
  'sbx'
])
param env string

@description('Project location')
param location string

@description('Path to SSH public key data')
param sshKeyData string

var locationLabel = take(location, 6)

resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: 'vnet-explorer-${env}-${locationLabel}-001'
}

resource vmSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  parent: vnet
  name: 'snet-explorer-${env}-${locationLabel}-private-001'
}

resource vmNSG 'Microsoft.Network/networkSecurityGroups@2025-05-01' existing = {
  name: 'nsg-explorer-${env}-${locationLabel}-private-001'
}

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  parent: vnet
  name: 'AzureBastionSubnet'
}

module loadBalancer './loadbalancer.bicep' = {
	name: 'loadBalancerDeploy'
	params: {
		env: env
		location: location
	}
}

module vmss './vmss.bicep' = {
	name: 'vmDeploy'
	params: {
		env: env
		location: location
		vmCount: 2
		vmNSGId: vmNSG.id
		vmSubnetId: vmSubnet.id
		lbBackendPoolId: loadBalancer.outputs.lbBackendPoolId
		sshKeyData: sshKeyData
	}
}

module bastion './bastion.bicep' = {
	name: 'bastionDeploy'
	params: {
		env: env
		location: location
		bastionSubnetId: bastionSubnet.id
	}
}

