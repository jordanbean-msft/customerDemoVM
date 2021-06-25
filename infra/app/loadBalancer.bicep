param longName string
param vNetName string
param applicationSubnetName string

resource vNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vNetName  
}

resource applicationSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: applicationSubnetName  
}

resource loadBalancerPublicIpAddress 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'pip-lb-${longName}'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

var loadBalancerName = 'lb-${longName}'
var loadBalancerFrontEndName = 'LoadBalancerFrontEnd'
var loadBalancerBackEndName = 'LoadBalancerBackEnd'
var loadBalancerProbeName = 'LoadBalancerProbe'

resource loadBalancer 'Microsoft.Network/loadBalancers@2021-02-01' = {
  name: loadBalancerName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: loadBalancerFrontEndName
        properties: {
          publicIPAddress: {
            id: loadBalancerPublicIpAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: loadBalancerBackEndName
      }
    ]
    loadBalancingRules: [
      {
        name: 'HTTPrule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, loadBalancerFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, loadBalancerBackEndName)
          }
          protocol: 'Tcp'
          loadDistribution: 'Default'
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, loadBalancerProbeName)
          }
          frontendPort: 80
          backendPort: 80
        }
      }
      {
        name: 'HTTPSrule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, loadBalancerFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, loadBalancerBackEndName)
          }
          protocol: 'Tcp'
          loadDistribution: 'Default'
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, loadBalancerProbeName)
          }
          frontendPort: 443
          backendPort: 443
        }
      }
    ]
    probes: [
      {
        name: loadBalancerProbeName
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

output loadBalancerName string = loadBalancer.name
output loadBalancerPublicIpAddressName string = loadBalancerPublicIpAddress.name
output loadBalancerBackendAddressPoolName string = loadBalancerBackEndName
