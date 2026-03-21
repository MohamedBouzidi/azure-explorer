targetScope = 'resourceGroup'

@description('Path to SSH public key data')
param sshKeyData string

var env = 'dev'
var location = resourceGroup().location

module network './network.bicep' = {
	name: 'networkDeploy'
	params: {
		env: env
		location: location
	}
}

module web './web/main.bicep' = {
  name: 'webDeploy'
  params: {
    env: env
    location: location
    vmSubnetId: network.outputs.privateSubnetId
    vmNSGId: network.outputs.privateNSGId
    bastionSubnetId: network.outputs.bastionSubnetId
    sshKeyData: sshKeyData
  }
}

module app './app/main.bicep' = {
  name: 'appDeploy'
  params: {
    env: env
    location: location
    appServicePlanSKU: 'Basic'
  }
}
