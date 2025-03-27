@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param api_identity_outputs_id string

param api_identity_outputs_clientid string

param api_containerport string

param cosmos_outputs_connectionstring string

param servicebus_outputs_servicebusendpoint string

param webpubsub_outputs_endpoint string

param outputs_azure_container_apps_environment_id string

param outputs_azure_container_registry_endpoint string

param outputs_azure_container_registry_managed_identity_id string

param api_containerimage string

resource api 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'api'
  location: location
  properties: {
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: api_containerport
        transport: 'http'
      }
      registries: [
        {
          server: outputs_azure_container_registry_endpoint
          identity: outputs_azure_container_registry_managed_identity_id
        }
      ]
    }
    environmentId: outputs_azure_container_apps_environment_id
    template: {
      containers: [
        {
          image: api_containerimage
          name: 'api'
          env: [
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_EMIT_EXCEPTION_LOG_ATTRIBUTES'
              value: 'true'
            }
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_EMIT_EVENT_LOG_ATTRIBUTES'
              value: 'true'
            }
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_RETRY'
              value: 'in_memory'
            }
            {
              name: 'ASPNETCORE_FORWARDEDHEADERS_ENABLED'
              value: 'true'
            }
            {
              name: 'HTTP_PORTS'
              value: api_containerport
            }
            {
              name: 'ConnectionStrings__appointments'
              value: 'AccountEndpoint=${cosmos_outputs_connectionstring};Database=appointments-app-db;Container=appointments'
            }
            {
              name: 'ConnectionStrings__appointment-requests'
              value: 'Endpoint=${servicebus_outputs_servicebusendpoint};EntityPath=appointment-requests'
            }
            {
              name: 'ConnectionStrings__apptnotifications'
              value: 'Endpoint=${webpubsub_outputs_endpoint};Hub=apptnotifications'
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: api_identity_outputs_clientid
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${api_identity_outputs_id}': { }
      '${outputs_azure_container_registry_managed_identity_id}': { }
    }
  }
}