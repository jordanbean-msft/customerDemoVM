param longName string
param shortName string
param storageAccountName string

resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' = {
  name: 'sig${shortName}'
  location: resourceGroup().location
}

resource imageBuilderUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'mi-${longName}'
  location: resourceGroup().location
}

//Too many role assignments to create this in default tenant, uncomment if in a different tenant
// var imageBuilderServiceImageCreationRoleName = 'Azure Image Builder Service Image Creation Role'

// resource imageBuilderServiceImageCreationRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
//   name: guid(subscription().id, imageBuilderServiceImageCreationRoleName)
//   properties: {
//     roleName: imageBuilderServiceImageCreationRoleName
//     type: 'customRole'
//     permissions: [
//       {
//         actions: [
//           'Microsoft.Compute/galleries/read'
//           'Microsoft.Compute/galleries/images/read'
//           'Microsoft.Compute/galleries/images/versions/read'
//           'Microsoft.Compute/galleries/images/versions/write'
//           'Microsoft.Compute/images/read'
//           'Microsoft.Compute/images/write'
//           'Microsoft.Compute/images/delete'
//         ]
//       }
//     ]
//     assignableScopes: [
//       '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}'
//     ]
//   }
// }

var contributorRoleDefinition = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

resource imageBuilderUserAssignedIdentityContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid(imageBuilderUserAssignedIdentity.id, contributorRoleDefinition)
  properties: {
    principalId: imageBuilderUserAssignedIdentity.properties.principalId
    //roleDefinitionId: imageBuilderServiceImageCreationRole.id
    roleDefinitionId: contributorRoleDefinition
  } 
}

var storageBlobDataReaderRoleDefinition = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource imageBuilderUserAssignedIdentityStorageBlobDataReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid(imageBuilderUserAssignedIdentity.id, storageBlobDataReaderRoleDefinition)
  scope: storageAccount
  properties: {
    principalId: imageBuilderUserAssignedIdentity.properties.principalId
    //roleDefinitionId: imageBuilderServiceImageCreationRole.id
    roleDefinitionId: storageBlobDataReaderRoleDefinition
  } 
}


output sharedImageGalleryName string = sharedImageGallery.name
output imageBuilderUserAssignedIdentityName string = imageBuilderUserAssignedIdentity.name
