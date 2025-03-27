@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

resource admin_panel_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: take('admin_panel_identity-${uniqueString(resourceGroup().id)}', 128)
  location: location
}

output id string = admin_panel_identity.id

output clientId string = admin_panel_identity.properties.clientId

output principalId string = admin_panel_identity.properties.principalId

output principalName string = admin_panel_identity.name