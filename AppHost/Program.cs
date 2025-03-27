using Azure.Provisioning.ServiceBus;

var builder = DistributedApplication.CreateBuilder(args);

builder.AddAzureContainerAppsInfrastructure();

var cosmos = builder.AddAzureCosmosDB("cosmos")
    .RunAsPreviewEmulator();
var database = cosmos.AddCosmosDatabase("appointments-app-db");
var container = database.AddContainer("appointments", "/id");

var serviceBus = builder.AddAzureServiceBus("servicebus");
var queue = serviceBus.AddServiceBusQueue("appointment-requests");

var webpubsub = builder.AddAzureWebPubSub("webpubsub");
var hub = webpubsub.AddHub("apptnotifications");

builder.AddProject<Projects.AppointmentProcessor>("appointment-processor")
    .WithReference(database)
    .WithReference(queue)
    .WithReference(hub)
    .WithRoleAssignments(serviceBus, ServiceBusBuiltInRole.AzureServiceBusDataReceiver);

builder.AddProject<Projects.Api>("api")
    .WithExternalHttpEndpoints()
    .WithReference(container)
    .WithReference(queue)
    .WithReference(hub)
    .WithRoleAssignments(serviceBus, ServiceBusBuiltInRole.AzureServiceBusDataSender);

builder.AddProject<Projects.AdminPanel>("admin-panel")
    .WithExternalHttpEndpoints()
    .WithReference(hub);

builder.Build().Run();
