param appName string
param region string
param environment string

var longName = '${appName}-${region}-${environment}'
var shortName = '${appName}${region}${environment}'

module sharedImageGallery 'sharedImageGallery.bicep' = {
  name: 'sharedImageGalleryDeploy'
  params: {
    longName: longName
    shortName: shortName
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
    region: region
    sharedImageGalleryName: sharedImageGallery.outputs.sharedImageGalleryName
  }  
}
