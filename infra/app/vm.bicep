param longName string
param customerName string
param vNetName string
param applicationSubnetName string
@secure()
param adminUsername string
@secure()
param adminPassword string
param timeZone string

var fullyQualifiedApplicationSubnetName = '${vNetName}/${applicationSubnetName}'

resource applicationSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: fullyQualifiedApplicationSubnetName
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
        }
      }
    ]
  }
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
        offer: 'WindowsServer'
        publisher: 'MicrosoftWindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
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
