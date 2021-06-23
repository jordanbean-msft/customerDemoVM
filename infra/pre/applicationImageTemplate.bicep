param longName string
param region string
param imageBuilderUserAssignedIdentityName string
param sharedImageGalleryName string

resource imageBuilderUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: imageBuilderUserAssignedIdentityName
}

resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' existing = {
  name: sharedImageGalleryName
}

var demoApplicationImageDefinitionName = 'img-demoApp'

resource demoApplicationImageDefinition 'Microsoft.Compute/galleries/images@2020-09-30' = {
  name: '${sharedImageGallery.name}/${demoApplicationImageDefinitionName}'
  location: resourceGroup().location
  properties: {
    osType: 'Windows'
    osState: 'Generalized'
    identifier: {
      offer: 'DemoApp'
      publisher: 'DemoApp_Inc'
      sku: '1.0.0'
    }
  }
}

resource applicationImageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2020-02-14' = {
  name: 'it-${longName}'
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${imageBuilderUserAssignedIdentity.id}': {}
    }
  }
  properties: {
    vmProfile: {
      osDiskSizeGB: 100
    }
    source: {
      type: 'PlatformImage'
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-Datacenter'
      version: 'latest'
    }
    customize: [
      {
        type: 'PowerShell'
        name: 'settingUpMgmtAgtPath'
        runElevated: false
        inline: [
          'mkdir c:\\buildActions'
          'echo Azure-Image-Builder-Was-Here  > c:\\buildActions\\buildActionsOutput.txt'
        ]
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/galleries/${sharedImageGallery.name}/images/${demoApplicationImageDefinitionName}'
        runOutputName: 'runOutput'
        replicationRegions: [
          region
        ]
      }
    ]
  }
}
