using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Cosmos;

var builder = Host.CreateApplicationBuilder(args);

builder.AddServiceDefaults();

builder.AddAzureServiceBusClient("appointment-requests");
builder.Services.AddSingleton(sp =>
{
    var client = sp.GetRequiredService<ServiceBusClient>();
    return client.CreateProcessor("appointment-requests");
});
builder.AddAzureCosmosDatabase("appointments-app-db", configureClientOptions: options =>
{
    options.SerializerOptions = new CosmosSerializationOptions()
    {
        PropertyNamingPolicy = CosmosPropertyNamingPolicy.CamelCase
    };
})
.AddKeyedContainer("appointments");
builder.AddAzureWebPubSubServiceClient("apptnotifications");

builder.Services.AddHostedService<AppointmentProcessor>();

var host = builder.Build();
host.Run();
