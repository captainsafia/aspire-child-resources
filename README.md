# Aspire Child Resource Integrations Demo

This repository demonstrates Aspire 9.2's child resource integrations via an appointment book app that takes a dependency on Azure Service Bus queues and Azure CosmosDB containers.

### Service Overview

```mermaid
graph TB
    subgraph Azure Resources
        cosmos(Azure CosmosDB Emulator)
        serviceBus(Azure Service Bus Emulator)
        
        subgraph CosmosDB Resources
            database(appointments-app-db)
            container(appointments container)
        end
        
        subgraph Service Bus Resources
            queue(appointment-requests queue)
        end
    end
    
    subgraph Application Services
        processor(Appointment Processor)
        api(API)
    end
    
    cosmos --> database
    database --> container
    serviceBus --> queue
    
    api --> container
    api --> queue
    
    processor --> database
    processor --> queue
    
    client(Client) --> api
    
    classDef azure fill:#0072C6,color:white;
    classDef service fill:#68217A,color:white;
    classDef client fill:#00BCF2,color:white;
    
    class cosmos,serviceBus,database,container,queue azure;
    class processor,api service;
    class client client;
```