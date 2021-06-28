param centralStorageAccountName string
param vmUserAssignedIdentityName string
param targetResourceGroupName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: centralStorageAccountName
}

resource vmUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: vmUserAssignedIdentityName
  scope: resourceGroup(targetResourceGroupName)
}

var storageBlobDataReaderRoleDefinition = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'

resource vmUserAssignedIdentityStorageBlobDataReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid(vmUserAssignedIdentity.id, targetResourceGroupName, storageBlobDataReaderRoleDefinition)
  properties: {
    principalId: vmUserAssignedIdentity.properties.principalId
    roleDefinitionId: storageBlobDataReaderRoleDefinition
  } 
}
