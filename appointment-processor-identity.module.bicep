@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

resource appointment_processor_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: take('appointment_processor_identity-${uniqueString(resourceGroup().id)}', 128)
  location: location
}

output id string = appointment_processor_identity.id

output clientId string = appointment_processor_identity.properties.clientId

output principalId string = appointment_processor_identity.properties.principalId

output principalName string = appointment_processor_identity.name