@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param sku string = 'Standard'

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

resource appointment_requests 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = {
  name: 'appointment-requests'
  parent: servicebus
}

output serviceBusEndpoint string = servicebus.properties.serviceBusEndpoint

output name string = servicebus.name