var builder = DistributedApplication.CreateBuilder(args);

var cosmos = builder.AddAzureCosmosDB("cosmos")
    .RunAsPreviewEmulator();
var database = cosmos.AddCosmosDatabase("appointments-app-db");
var container = database.AddContainer("appointments", "/id");

var serviceBus = builder.AddAzureServiceBus("servicebus")
    .RunAsEmulator();
var queue = serviceBus.AddServiceBusQueue("appointment-requests");

builder.AddProject<Projects.AppointmentProcessor>("appointment-processor")
    .WithReference(database)
    .WithReference(queue);

builder.AddProject<Projects.Api>("api")
    .WithExternalHttpEndpoints()
    .WithReference(container)
    .WithReference(queue);

builder.Build().Run();
