using System.Text.Json;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Cosmos;

var builder = WebApplication.CreateBuilder(args);
    
builder.AddServiceDefaults();
builder.AddAzureCosmosContainer("appointments");
builder.AddAzureServiceBusClient("appointment-requests");
builder.Services.AddSingleton<ServiceBusSender>(sp =>
{
    var client = sp.GetRequiredService<ServiceBusClient>();
    return client.CreateSender("appointment-requests");
});

builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.MapPost("/appointments", async (AppointmentRequest request, ServiceBusSender sender) =>
{
    await sender.SendMessageAsync(new ServiceBusMessage(JsonSerializer.Serialize(request)));
    return TypedResults.Ok("Appointment request received.");
});

app.MapGet("/appointments", async (Container container) =>
{
    // Fetch all appointments from the CosmosDB container
    var query = new QueryDefinition("SELECT * FROM c");
    var iterator = container.GetItemQueryIterator<Appointment>(query);
    var appointments = new List<Appointment>();
    while (iterator.HasMoreResults)
    {
        var response = await iterator.ReadNextAsync();
        appointments.AddRange(response);
    }
    return TypedResults.Ok(appointments);
});

app.Run();

record AppointmentRequest(string CustomerName, DateTime Time);

class Appointment
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public string CustomerName { get; set; } = string.Empty;
    public DateTime Time { get; set; }
    public string Status { get; set; } = "Pending";
}
