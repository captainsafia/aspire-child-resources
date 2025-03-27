using System.Text.Json;
using Azure.Messaging.ServiceBus;
using Azure.Messaging.WebPubSub;
using Microsoft.Azure.Cosmos;

public class AppointmentProcessor(ServiceBusProcessor processor, [FromKeyedServices("appointments")] Container container, WebPubSubServiceClient webpubsub) : BackgroundService
{
    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        processor.ProcessMessageAsync += async args =>
        {
            var json = args.Message.Body.ToString();
            var request = JsonSerializer.Deserialize<AppointmentRequest>(json);
            if (request is not null)
            {
                var appointment = new Appointment
                {
                    Id = Guid.NewGuid().ToString(),
                    CustomerName = request.CustomerName,
                    Time = request.Time,
                    Status = "Confirmed"
                };

                await container.CreateItemAsync(appointment, new PartitionKey(appointment.Id));
                await webpubsub.SendToGroupAsync("appointments", JsonSerializer.Serialize(new { appointment.Id, appointment.Status }));
            }

            await args.CompleteMessageAsync(args.Message);
        };

        processor.ProcessErrorAsync += args =>
        {
            Console.WriteLine($"Error processing message: {args.Exception}");
            return Task.CompletedTask;
        };

        return processor.StartProcessingAsync(stoppingToken);
    }
}

record AppointmentRequest(string CustomerName, DateTime Time);

class Appointment
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public string CustomerName { get; set; } = string.Empty;
    public DateTime Time { get; set; }
    public string Status { get; set; } = "Pending";
}