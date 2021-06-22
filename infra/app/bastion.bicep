param longName string
param vNetName string
param bastionSubnetName string

var fullyQualifiedBastionSubnetName = '${vNetName}/${bastionSubnetName}'

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: fullyQualifiedBastionSubnetName
}

resource bastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'pip-bastion-${longName}'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: 'bastion-${longName}'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'bastion'
        properties: {
          publicIPAddress: {
            id: bastionPublicIpAddress.id
          }
          subnet: {
            id: bastionSubnet.id
          }
        }
      }
    ]
  }
}
