param customerName string
param region string
param environment string
@secure()
param vmAdminUsername string
@secure()
param vmAdminPassword string
param vmTimeZone string
param sharedImageGalleryName string
param demoApplicationImageDefinitionName string
param demoApplicationImageVersion string

var longName = '${customerName}-${region}-${environment}'

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

module vmModule 'vm.bicep' = {
  name: 'vmDeploy'
  params: {
    adminPassword: vmAdminPassword
    adminUsername: vmAdminUsername
    vNetName: vNetModule.outputs.vNetName
    applicationSubnetName: vNetModule.outputs.applicationSubnetName
    longName: longName
    customerName: customerName
    timeZone: vmTimeZone
    sharedImageGalleryName: sharedImageGalleryName
    demoApplicationImageDefinitionName: demoApplicationImageDefinitionName
    demoApplicationImageVersion: demoApplicationImageVersion
    loadBalancerName: loadBalancerModule.outputs.loadBalancerName
    loadBalancerBackendAddressPoolName: loadBalancerModule.outputs.loadBalancerBackendAddressPoolName
  }
}

module loadBalancerModule 'loadBalancer.bicep' = {
  name: 'loadBalancerDeploy'
  params: {
    applicationSubnetName: vNetModule.outputs.applicationSubnetName
    longName: longName
    vNetName: vNetModule.outputs.vNetName
  }  
}

module frontDoorModule 'frontDoor.bicep' = {
  name: 'frontDoorModule'
  params: {
    loadBalancerPublicIpAddressName: loadBalancerModule.outputs.loadBalancerPublicIpAddressName
    longName: longName
  }
}
