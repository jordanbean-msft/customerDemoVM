param customerName string
param region string
param environment string
@secure()
param vmAdminUsername string
@secure()
param vmAdminPassword string
param vmTimeZone string

var longName = '${customerName}-${region}-${environment}'
var shortName = '${customerName}${region}${environment}'

module vNetModule 'vnet.bicep' = {
  name: 'vNetDeploy'
  params: {
    longName: longName
  }
}

module bastionModule 'bastion.bicep' = {
  name: 'bastionDeploy'
  params: {
    vNetName: vNetModule.outputs.vNetName
    bastionSubnetName: vNetModule.outputs.bastionSubnetName
    longName: longName
  }  
}

module vm 'vm.bicep' = {
  name: 'vmDeploy'
  params: {
    adminPassword: vmAdminPassword
    adminUsername: vmAdminUsername
    vNetName: vNetModule.outputs.vNetName
    applicationSubnetName: vNetModule.outputs.applicationSubnetName
    longName: longName
    customerName: customerName
    timeZone: vmTimeZone
  }
}
