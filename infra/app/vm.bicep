param longName string
param customerName string
param vNetName string
param applicationSubnetName string
@secure()
param adminUsername string
@secure()
param adminPassword string
param timeZone string
param sharedImageGalleryName string
param demoApplicationImageDefinitionName string
param demoApplicationImageVersion string
param loadBalancerName string
param loadBalancerBackendAddressPoolName string

var fullyQualifiedApplicationSubnetName = '${vNetName}/${applicationSubnetName}'

resource applicationSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: fullyQualifiedApplicationSubnetName
}

resource loadBalancerBackendAddressPool 'Microsoft.Network/loadBalancers/backendAddressPools@2021-02-01' existing = {
  name: '${loadBalancerName}/${loadBalancerBackendAddressPoolName}'
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'nic-${longName}'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          subnet: {
            id: applicationSubnet.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancerBackendAddressPool.id
            }
          ]
        }
      }
    ]
  }
}

resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' existing = {
  name: sharedImageGalleryName  
}

resource vmImage 'Microsoft.Compute/galleries/images/versions@2020-09-30' existing = {
  name: '${sharedImageGallery.name}/${demoApplicationImageDefinitionName}/${demoApplicationImageVersion}'
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: 'vm-${longName}'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    osProfile: {
      computerName: 'vm${customerName}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        timeZone: timeZone
        enableAutomaticUpdates: true
        provisionVMAgent: true
      } 
    }
    storageProfile: {
      imageReference: {
        id: vmImage.id
      }
      osDisk: {
        osType: 'Windows'
        name: 'os'
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          lun: 0
          name: 'data'
          createOption: 'Empty'
          diskSizeGB: 10
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    
  }  
}

resource vmAutoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vm.name}'
  location: resourceGroup().location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1700' 
    }
    timeZoneId: timeZone
    targetResourceId: vm.id
  } 
}
