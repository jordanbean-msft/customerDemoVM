param longName string

var azureBastionSubnetAddressPrefix = '10.0.1.0/27'
var azureBastionSubnetName = 'AzureBastionSubnet'
var appSubnetAddressPrefix = '10.0.2.0/24'
var appSubnetName = 'app'

resource vNet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'vnet-${longName}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: azureBastionSubnetName
        properties: {
          addressPrefix: azureBastionSubnetAddressPrefix
          networkSecurityGroup: {
            id: bastionNsg.id
          }
        }  
      }
      {
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetAddressPrefix
          networkSecurityGroup: {
            id: applicationNsg.id
          }
        }  
      }
    ]
  }
}


resource applicationNsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'nsg-app-${longName}'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowFrontDoorInbound'
        properties: {
          access: 'Allow'
          description: 'Allow FrontDoor inbound'
          direction: 'Inbound'
          protocol: 'Tcp'
          priority: 100
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: appSubnetAddressPrefix
          destinationPortRanges: [
            '80'
            '443'
          ]
        }
      }
      {
        name: 'AllowBastionInbound'
        properties: {
          access: 'Allow'
          description: 'Allow from Bastion subnet'
          direction: 'Inbound'
          protocol: 'Tcp'
          priority: 150
          sourceAddressPrefix: azureBastionSubnetAddressPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: appSubnetAddressPrefix
          destinationPortRanges: [
            '22'
            '3389'
          ]
        }
      }
      {
        name: 'DenyAllOthersInbound'
        properties: {
          access: 'Deny'
          description: 'Deny all others'
          direction: 'Inbound'
          protocol: '*'
          priority: 200
          sourceAddressPrefix: '*' 
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource bastionNsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'nsg-bastion-${longName}'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          access: 'Allow'
          description: 'Allow from Internet Inbound'
          direction: 'Inbound'
          protocol: 'Tcp'
          priority: 120
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          access: 'Allow'
          description: 'Allow GatewayManager Inbound'
          direction: 'Inbound'
          protocol: 'Tcp'
          priority: 130
          sourceAddressPrefix: 'GatewayManager' 
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          access: 'Allow'
          description: 'Allow LoadBalancer Inbound'
          direction: 'Inbound'
          protocol: 'Tcp'
          priority: 140
          sourceAddressPrefix: 'AzureLoadBalancer' 
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowBastionHostCommunication'
        properties: {
          access: 'Allow'
          description: 'Allow Bastion Host Communication Inbound'
          direction: 'Inbound'
          protocol: '*'
          priority: 150
          sourceAddressPrefix: 'VirtualNetwork' 
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          access: 'Allow'
          description: 'Allow Ssh Rdp Outbound'
          direction: 'Outbound'
          protocol: '*'
          priority: 100
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges:[
            '22'
            '3389'
          ]
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          access: 'Allow'
          description: 'Allow Azure Cloud Outbound'
          direction: 'Outbound'
          protocol: 'Tcp'
          priority: 110
          sourceAddressPrefix: '*' 
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureCloud'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowBastionommunication'
        properties: {
          access: 'Allow'
          description: 'Allow Bastion Communication Outbound'
          direction: 'Outbound'
          protocol: '*'
          priority: 120
          sourceAddressPrefix: 'VirtualNetwork' 
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties: {
          access: 'Allow'
          description: 'Allow Get Session'
          direction: 'Outbound'
          protocol: '*'
          priority: 130
          sourceAddressPrefix: '*' 
          sourcePortRange: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
        }
      }
    ]
  }
}

output vNetName string = vNet.name
output applicationSubnetName string = appSubnetName
output bastionSubnetName string = azureBastionSubnetName
