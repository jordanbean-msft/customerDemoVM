param longName string
param shortName string

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

resource imageBuilderUserAssignedIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid(imageBuilderUserAssignedIdentity.id, contributorRoleDefinition)
  properties: {
    principalId: imageBuilderUserAssignedIdentity.properties.principalId
    //roleDefinitionId: imageBuilderServiceImageCreationRole.id
    roleDefinitionId: contributorRoleDefinition
  } 
}

output sharedImageGalleryName string = sharedImageGallery.name
output imageBuilderUserAssignedIdentityName string = imageBuilderUserAssignedIdentity.name
