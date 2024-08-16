param resourceGroupLocation string = resourceGroup().location
param storageAccountName string = 'store${uniqueString(resourceGroup().id)}'
param vnetName string = 'vnet${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: storageAccountName
  location: resourceGroupLocation
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: resourceGroupLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  name: 'subnet1'
  parent: virtualNetwork
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  name: 'subnet2'
  parent: virtualNetwork
  properties: {
    addressPrefix: '10.0.1.0/24'
  }
}

output storageAccountId string = storageAccount.id
output vnetId string = virtualNetwork.id
