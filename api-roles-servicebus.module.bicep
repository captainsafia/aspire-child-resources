@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param servicebus_outputs_name string

param principalId string

resource servicebus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: servicebus_outputs_name
}

resource servicebus_AzureServiceBusDataSender 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(servicebus.id, principalId, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'))
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')
    principalType: 'ServicePrincipal'
  }
  scope: servicebus
}