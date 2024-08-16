targetScope = 'subscription'

param rgName string = 'stack-demo-${uniqueString(subscription().id)}rg'
param resourceGroupLocation string = deployment().location
param storageAccountName string = 'store${uniqueString(rgName)}'
param vnetName string = 'vnet${uniqueString(rgName)}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: resourceGroupLocation
}

module resources 'resources.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-resources'
  params: {
    resourceGroupLocation: resourceGroupLocation
    storageAccountName: storageAccountName
    vnetName: vnetName
  }
}

output storageAccountId string = resources.outputs.storageAccountId
output vnetId string = resources.outputs.vnetId
