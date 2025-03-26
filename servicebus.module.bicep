@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param sku string = 'Standard'

param principalType string

param principalId string

resource servicebus 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: take('servicebus-${uniqueString(resourceGroup().id)}', 50)
  location: location
  properties: {
    disableLocalAuth: true
  }
  sku: {
    name: sku
  }
  tags: {
    'aspire-resource-name': 'servicebus'
  }
}

resource servicebus_AzureServiceBusDataOwner 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(servicebus.id, principalId, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '090c5cfd-751d-490a-894a-3ce6f1109419'))
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '090c5cfd-751d-490a-894a-3ce6f1109419')
    principalType: principalType
  }
  scope: servicebus
}

resource appointment_requests 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = {
  name: 'appointment-requests'
  parent: servicebus
}

output serviceBusEndpoint string = servicebus.properties.serviceBusEndpoint

output name string = servicebus.name