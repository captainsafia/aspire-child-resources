@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param webpubsub_outputs_name string

param principalId string

resource webpubsub 'Microsoft.SignalRService/webPubSub@2024-03-01' existing = {
  name: webpubsub_outputs_name
}

resource webpubsub_WebPubSubServiceOwner 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(webpubsub.id, principalId, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12cf5a90-567b-43ae-8102-96cf46c7d9b4'))
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12cf5a90-567b-43ae-8102-96cf46c7d9b4')
    principalType: 'ServicePrincipal'
  }
  scope: webpubsub
}