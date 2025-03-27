using Azure.Messaging.WebPubSub;

var builder = WebApplication.CreateBuilder(args);

builder.AddAzureWebPubSubServiceClient("apptnotifications");

var app = builder.Build();

app.MapGet("/", (WebPubSubServiceClient hub) =>
{
    var url = hub.GetClientAccessUri().AbsoluteUri;
    return Results.Content($$"""
    <!DOCTYPE html>
    <html>
    <head>
    <meta charset="UTF-8">
    <title>Azure Web PubSub Client</title>
    <style>
        body {
        font-family: Arial, sans-serif;
        }
        #messages {
        list-style-type: none;
        padding: 0;
        }
        #messages li {
        margin-bottom: 10px;
        border-bottom: 1px solid #ccc;
        padding: 5px;
        }
    </style>
    </head>
    <body>
    <h1>Azure Web PubSub Client</h1>
    <ul id="messages"></ul>
    <script>
        // Update this URL with your actual Web PubSub endpoint.
        // Format: wss://<your-service-name>.webpubsub.azure.com/client/hubs/<hubName>?access_token=<access_token>
        const serviceUrl = "{{url}}";

        // Create a new WebSocket connection to the Web PubSub service.
        const connection = new WebSocket(serviceUrl, 'json.webpubsub.azure.v1');

        // Reference to the HTML element where messages will be displayed.
        const messagesList = document.getElementById('messages');

        // Append a message to the list.
        function addMessage(message) {
            const li = document.createElement('li');
            li.textContent = message;
            messagesList.appendChild(li);
        }

        // Handle the connection opening.
        connection.onopen = function() {
            console.log("Connected to Azure Web PubSub.");
            addMessage("Connected to Azure Web PubSub.");
             connection.send(JSON.stringify({
                type: "joinGroup",
                group: "appointments"
            }));
        };

        // Handle incoming messages.
        connection.onmessage = function(event) {
            console.log("Received message:", event.data);
            addMessage(event.data);
        };

        // Handle any errors that occur.
        connection.onerror = function(error) {
            console.error("WebSocket error:", error);
            addMessage("Error: " + error);
        };

        // Handle the connection closing.
        connection.onclose = function(event) {
            console.log("Connection closed:", event);
            addMessage("Connection closed.");
        };
    </script>
    </body>
    </html>
    """, "text/html");
});

app.Run();
