param longName string
param longRegion string
param imageBuilderUserAssignedIdentityName string
param sharedImageGalleryName string
param storageAccountName string
param imageScriptsContainerName string
param baseTime string = utcNow('u')

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

var imageScriptsContainerSasProperties = {
  signedServices: 'b'
  signedPermission: 'r'
  signedExpiry: dateTimeAdd(baseTime, 'P30D')
  signedResourceTypes: 'o'
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
      osDiskSizeGB: 0
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
        name: 'InstallIIS'
        runElevated: true
        scriptUri: 'https://${storageAccountName}.blob.${environment().suffixes.storage}/${imageScriptsContainerName}/installIIS.ps1'
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: demoApplicationImageDefinition.id
        runOutputName: 'runOutput'
        replicationRegions: [
          longRegion
        ]
      }
    ]
  }
}
