param longName string
param loadBalancerPublicIpAddressName string

var frontDoorName = 'fd-${longName}'
var frontDoorFrontEndName = 'FrontDoorFrontEnd'
var frontDoorBackEndName = 'FrontDoorBackEnd'
var frontDoorHealthProbeSettingsName = 'FrontDoorHealthProbeSettings'
var frontDoorLoadBalancingSettingsName = 'FrontDoorLoadBalancingSettings'

resource loadBalancerPublicIpAddress 'Microsoft.Network/publicIPAddresses@2021-02-01' existing = {
  name: loadBalancerPublicIpAddressName  
}

resource frontDoor 'Microsoft.Network/frontDoors@2020-05-01' = {
  name: frontDoorName
  location: 'global'
  properties: {
    enabledState: 'Enabled'
    frontendEndpoints: [
      {
        name: frontDoorFrontEndName
        properties: {
          hostName: '${frontDoorName}.azurefd.net'
          sessionAffinityEnabledState: 'Disabled'
          webApplicationFirewallPolicyLink: {
            id: frontDoorWebApplicationFirewallPolicy.id
          }
        }
      }
    ]
    backendPools: [
      {
        name: frontDoorBackEndName
        properties: {
          backends: [
            {
              address: loadBalancerPublicIpAddress.properties.ipAddress
              backendHostHeader: loadBalancerPublicIpAddress.properties.ipAddress
              httpPort: 80
              httpsPort: 443
              weight: 100
              priority: 1
              enabledState: 'Enabled'
            }
          ]
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoorName, frontDoorLoadBalancingSettingsName)
          }
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoorName, frontDoorHealthProbeSettingsName)
          }
        }
      }
    ]
    healthProbeSettings: [
      {
        name: frontDoorHealthProbeSettingsName
        properties: {
          enabledState: 'Enabled'
          path: '/'
          protocol: 'Http'
          intervalInSeconds: 120
        }
      }
    ]
    loadBalancingSettings: [
      {
        name: frontDoorLoadBalancingSettingsName
        properties: {
          sampleSize: 4
          successfulSamplesRequired: 2
        }
      }
    ]
    routingRules: [
      {
        name: 'routingRule1'
        properties: {
          acceptedProtocols: [
            'Http'
            'Https'
          ]
          enabledState: 'Enabled'
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontendEndpoints', frontDoorName, frontDoorFrontEndName)
            }
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'MatchRequest'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backendPools', frontDoorName, frontDoorBackEndName)
            }
          }
        }
      }
    ]
  } 
}

resource frontDoorWebApplicationFirewallPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: 'frontDoorWafPolicy'
  location: resourceGroup().location
  sku: {
    name: 'Classic_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '1.1'
        }
      ]
    }
  }
}
