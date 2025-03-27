@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2024-08-15' = {
  name: take('cosmos-${uniqueString(resourceGroup().id)}', 44)
  location: location
  properties: {
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    databaseAccountOfferType: 'Standard'
    disableLocalAuth: true
  }
  kind: 'GlobalDocumentDB'
  tags: {
    'aspire-resource-name': 'cosmos'
  }
}

resource appointments_app_db 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-08-15' = {
  name: 'appointments-app-db'
  location: location
  properties: {
    resource: {
      id: 'appointments-app-db'
    }
  }
  parent: cosmos
}

resource appointments 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-08-15' = {
  name: 'appointments'
  location: location
  properties: {
    resource: {
      id: 'appointments'
      partitionKey: {
        paths: [
          '/id'
        ]
      }
    }
  }
  parent: appointments_app_db
}

output connectionString string = cosmos.properties.documentEndpoint

output name string = cosmos.name