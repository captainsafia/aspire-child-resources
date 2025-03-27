@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param servicebus_outputs_name string

param principalId string

resource servicebus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: servicebus_outputs_name
}

resource servicebus_AzureServiceBusDataReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(servicebus.id, principalId, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'))
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0')
    principalType: 'ServicePrincipal'
  }
  scope: servicebus
}