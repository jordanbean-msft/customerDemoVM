param shortName string

resource imageStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: toLower('sa${shortName}')
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'BlobStorage'
  properties: {
    accessTier: 'Hot'
  } 
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${imageStorageAccount.name}/default/imagescripts'
}
