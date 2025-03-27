@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param sku string = 'Free_F1'

param capacity int = 1

resource webpubsub 'Microsoft.SignalRService/webPubSub@2024-03-01' = {
  name: take('webpubsub-${uniqueString(resourceGroup().id)}', 63)
  location: location
  sku: {
    name: sku
    capacity: capacity
  }
  tags: {
    'aspire-resource-name': 'webpubsub'
  }
}

resource apptnotifications 'Microsoft.SignalRService/webPubSub/hubs@2024-03-01' = {
  name: 'apptnotifications'
  parent: webpubsub
}

output endpoint string = 'https://${webpubsub.properties.hostName}'

output name string = webpubsub.name