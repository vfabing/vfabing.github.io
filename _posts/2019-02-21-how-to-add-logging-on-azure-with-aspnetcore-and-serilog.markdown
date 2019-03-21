---
layout: post
title:  "How to add logging on azure with aspnetcore and serilog"
date:   2019-02-21 13:37:00 +0200
categories: [aspnetcore]
tags: [aspnetcore, azure, azure-log-analytics]
comments: true
---
## Logging as a Service in Azure
Have you ever wished you could get a powerful logging service such as `ELK` (*`Elasticsearch`, `Logstash`, `Kibana`*), but as a service in `Azure` ?  
Well, you can rejoice and see in this blog post how to use `Azure Log Analytics`, the logging as a service in Azure in an AspNetCore application in just **2 Nuget packages and 5 lines of code** :)

## Creating the Azure Log Analytics Service from Azure Portal
Let's start by creating an Azure Log Analytics workspace from the [Azure Portal](https://portal.azure.com):

![01-create-azure-log-analytics-workspace](/assets/2019-02-21/01-create-azure-log-analytics-workspace.jpg)
> ***Note** The 5 first GB per month of logging are free*

Then once the service is created, navigate to the `Advanced settings` panel and grab your `WORKSPACE ID` and your `PRIMARY KEY`

![02-get-azure-log-analytics-workspace-id-and-authentication-id-primary-key](/assets/2019-02-21/02-get-azure-log-analytics-workspace-id-and-authentication-id-primary-key.jpg)

Alright, that's all for the Azure part!
## Add Serilog and configure Serilog.Sinks.AzureAnalytics

First of all, and the 2 following Nuget packages to your aspnetcore projet:  
- [`Serilog.AspNetCore`](https://github.com/serilog/serilog-aspnetcore) which will be used to simplify the configuration of Serilog in an AspNetCore app,   
- [`Serilog.Sinks.AzureAnalytics`](https://github.com/saleem-mirza/serilog-sinks-azure-analytics) which will enable you to send your logs directly to your `Azure Log Analytics` workspace.

Then in your aspnetcore app, locate the `Main` method in `Program.cs`, and configure the Serilog logger by setting the value of the `Log.Logger` with a `new LoggerConfiguration()`, and also by using the `WriteTo.AzureAnalytics` method which will require the two previous settings, retrieved from your `Azure Log Analytics`.

```csharp
public static void Main(string[] args)
{
    Log.Logger = new LoggerConfiguration()
        .WriteTo.AzureAnalytics(workspaceId: "WORKSPACE ID", 
                                authenticationId: "PRIMARY KEY")
        .CreateLogger();

    CreateWebHostBuilder(args).Build().Run();
}

public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
    WebHost.CreateDefaultBuilder(args)
        .UseStartup<Startup>()
        .UseSerilog();
```

The last peace of the puzzle will be to add a call to the method `UserSerilog()` right after your `UseStartup<Startup>()` method, and that's all folks!

## Browse your logs from the Azure Portal

Navigate to your Azure Log Analytics service, and go to the `Logs` panel.   
You should now see that a `Custom Logs` section has appeared, and inside the default log type name `DiagnosticsLog` (*that you can change by [configuration](https://github.com/saleem-mirza/serilog-sinks-azure-analytics#getting-started) of course*).   
Select your query, click Run and "Voilà", congratulations you can see your logs in your `Azure Log Analytics` workspace :) 

![03-visualize-azure-log-analytics-logs-from-azure-portal](/assets/2019-02-21/03-visualize-azure-log-analytics-logs-from-azure-portal.PNG)

I hope you are convinced to start trying using this service :)

May the code be with you!