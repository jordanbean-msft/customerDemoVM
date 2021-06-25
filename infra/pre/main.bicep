param appName string
param region string
param longRegion string
param environment string

var longName = '${appName}-${region}-${environment}'
var shortName = '${appName}${region}${environment}'

module sharedImageGallery 'sharedImageGallery.bicep' = {
  name: 'sharedImageGalleryDeploy'
  params: {
    longName: longName
    shortName: shortName
    storageAccountName: storageAccount.outputs.storageAccountName
  }  
}

module storageAccount 'storage.bicep' = {
  name: 'storageAccountDeploy'
  params: {
    shortName: appName
  }  
}

module applicationImageTemplate 'applicationImageTemplate.bicep' = {
  name: 'applicationImageTemplate'
  params: {
    imageBuilderUserAssignedIdentityName: sharedImageGallery.outputs.imageBuilderUserAssignedIdentityName
    longName: longName
    longRegion: longRegion
    sharedImageGalleryName: sharedImageGallery.outputs.sharedImageGalleryName
    storageAccountName: storageAccount.outputs.storageAccountName
    imageScriptsContainerName: storageAccount.outputs.storageAccountBlobContainerName
  }  
}
