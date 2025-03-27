@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param appointment_processor_identity_outputs_id string

param appointment_processor_identity_outputs_clientid string

param cosmos_outputs_connectionstring string

param servicebus_outputs_servicebusendpoint string

param webpubsub_outputs_endpoint string

param outputs_azure_container_apps_environment_id string

param outputs_azure_container_registry_endpoint string

param outputs_azure_container_registry_managed_identity_id string

param appointment_processor_containerimage string

resource appointment_processor 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'appointment-processor'
  location: location
  properties: {
    configuration: {
      activeRevisionsMode: 'Single'
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
          image: appointment_processor_containerimage
          name: 'appointment-processor'
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
              name: 'ConnectionStrings__appointments-app-db'
              value: 'AccountEndpoint=${cosmos_outputs_connectionstring};Database=appointments-app-db'
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
              value: appointment_processor_identity_outputs_clientid
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
      '${appointment_processor_identity_outputs_id}': { }
      '${outputs_azure_container_registry_managed_identity_id}': { }
    }
  }
}