@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param admin_panel_identity_outputs_id string

param admin_panel_identity_outputs_clientid string

param admin_panel_containerport string

param webpubsub_outputs_endpoint string

param outputs_azure_container_apps_environment_id string

param outputs_azure_container_registry_endpoint string

param outputs_azure_container_registry_managed_identity_id string

param admin_panel_containerimage string

resource admin_panel 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'admin-panel'
  location: location
  properties: {
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: admin_panel_containerport
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
          image: admin_panel_containerimage
          name: 'admin-panel'
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
              value: admin_panel_containerport
            }
            {
              name: 'ConnectionStrings__apptnotifications'
              value: 'Endpoint=${webpubsub_outputs_endpoint};Hub=apptnotifications'
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: admin_panel_identity_outputs_clientid
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
      '${admin_panel_identity_outputs_id}': { }
      '${outputs_azure_container_registry_managed_identity_id}': { }
    }
  }
}