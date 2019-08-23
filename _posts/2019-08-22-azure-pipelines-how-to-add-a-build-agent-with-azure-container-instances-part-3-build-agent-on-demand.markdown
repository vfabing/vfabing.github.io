---
layout: post
title:  "Azure Pipelines: How to add a build agent with Azure Container Instances - part 3 : Build agent on demand"
date:   2019-08-22 13:37:00 +0200
categories: [azure-devops]
tags: [azure-pipelines, azure-container-instances, azure-functions, azure, docker, dotnetcore]
comments: true
---

## To the "Build agent on demand"
In the previous articles, we have seen [how to start an additional build agent using Azure Container Instances in minutes](https://www.vivienfabing.com/azure-devops/2019/05/14/azure-pipelines-how-to-add-a-build-agent-with-azure-container-instances.html), and then [how to use our own custom build agent](https://www.vivienfabing.com/azure-devops/2019/06/20/azure-pipelines-how-to-add-a-build-agent-with-azure-container-instances-part-2-custom-agent.html).

In this article, let's see now how to create a Build agent "on-the-fly" when a build is requested, and how to destroy it right after using `Azure Container Instances`, `Azure Functions` and the `agentless phase` of `Azure Pipelines`.

## Workflow for a build agent on demand

For those already familiar with Azure Pipelines, the following screenshot might be more comprehensive than words:

![01-build-agent-on-demand-using-agentless-job-and-azure-function](/assets/2019-08-22/01-build-agent-on-demand-using-agentless-job-and-azure-function.png)

The important things to notice in this picture is that there are 3 phases:
- The first and the last being "Run on server", or also called "agentless phase" because they are executed directly from `Azure DevOps` and do not require any build agent. They are calling an `Azure Function`, which is in charge of creating and starting / destroying our custom Build agent, hosted on `Azure Container Instances`.
- The second phase being our usual build workflow, such as building a dotnet app, etc.

That means that by using this workflow, we really have our own "Build agent as a Service", paying only by Build requested, and being able to scale as many as we have `parallel jobs` available!

## Setting up an Azure Function in charge of Creating / Deleting the Azure Container Instance

You can start creating an `Azure Function`, directly from the Azure Portal, by following the [official documentation](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-azure-function) which is the easiest and simplest way to begin.

Then to be able to interact with Azure Container Instances, we can use the `Microsoft.Azure.Management.Fluent` NuGet package and then modify the `run.csx` with the following lines :
``` diff
#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;
+ using Microsoft.Azure.Management.Fluent;
+ using Microsoft.Azure.Management.ResourceManager.Fluent;
+ using Microsoft.Azure.Management.ResourceManager.Fluent.Authentication;
+ using System;
+ using System.Collections.Generic;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");

    string name = req.Query["name"];

    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    dynamic data = JsonConvert.DeserializeObject(requestBody);
    name = name ?? data?.name;

+     // Azure Settings
+     var tenantId = "MY_TENANT_ID";
+     var clientId = "MY_CLIENT_ID";
+     var clientSecret = "MY_CLIENT_SECRET";
+     var subscriptionId = "MY_SUBSCRIPTION_ID";
+     var resourceGroup = "MY_RESOURCE_GROUP";
+     var agentName = name;
+ 
+     // Azure DevOps settings
+     var imageName = "vfabing/azure-pipelines-agent-dotnet-core-sdk:latest";
+     var envConfig = new Dictionary<string, string> {
+         { "AZP_URL", "https://dev.azure.com/MY_AZUREDEVOPS_ACCOUNT" },
+         { "AZP_TOKEN", "MY_PERSONAL_ACCESS_TOKEN" },
+         { "AZP_AGENT_NAME", $"{agentName}" },
+     };
+ 
+     var sp = new ServicePrincipalLoginInformation { ClientId = clientId, + ClientSecret = clientSecret };
+     var azure = Azure.Authenticate(new AzureCredentials(sp, tenantId, + AzureEnvironment.AzureGlobalCloud)).WithSubscription(subscriptionId);
+     var rg = azure.ResourceGroups.GetByName(resourceGroup);
+ 
+     // Azure Container Instance Creation
+     new Thread(() => azure.ContainerGroups.Define(agentName)
+         .WithRegion(rg.RegionName)
+         .WithExistingResourceGroup(rg)
+         .WithLinux()
+         .WithPublicImageRegistryOnly()
+         .WithoutVolume()
+         .DefineContainerInstance(agentName)
+             .WithImage(imageName)
+             .WithoutPorts()
+             .WithEnvironmentVariables(envConfig)
+             .Attach()
+         .Create()).Start();
+ 
+     // Azure Container Instance Deletion
+     // new Thread(() => azure.ContainerGroups.DeleteByResourceGroup(resourceGroup, agentName)).Start();
        
    return name != null
        ? (ActionResult)new OkObjectResult($"Hello, {name}")
        : new BadRequestObjectResult("Please pass a name on the query string or in the request body");
}
```

These few lines should enable us to start a build agent on `Azure Container Instances`.

For the deletion of the container, create another Azure Function and comment the `Creation` and uncomment the `Deletion` part :)

You can check the file directly on a [Gist](https://gist.github.com/vfabing/1c3eb93f21e6bc1610e0737646628af8/revisions?diff=unified)

> Note: The code of the `Azure Function` above is very simple on purpose (*Configuration should be better passed using Environment variables, etc.*)

> Note 2: You might have noticed that the creation/deletion of the container is done in a new thread. This is made to comply with `agentless jobs` being required to finish in less than 20 seconds. In our case it is a simple way to address this prerequisites (because the agent job is "waiting" for our container to be subscribed). However if you also want to make sure that the creation of the container went alright, you should check the [Callback](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/utility/azure-function?view=azure-devops#where-should-a-task-signal-completion-when-callback-is-chosen-as-the-completion-event) Completion event of this task.

Then you also need to add a `function.proj` file to enable the restoration of the `Microsoft.Azure.Management.Fluent` NuGet package.

![02-add-function-proj-file-to-restore-nuget-package](/assets/2019-08-22/02-add-function-proj-file-to-restore-nuget-package.png)

```xml
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <TargetFramework>netstandard2.0</TargetFramework>
    </PropertyGroup>

    <ItemGroup>
        <PackageReference Include="Microsoft.Azure.Management.Fluent" Version="1.24.1" />
    </ItemGroup>
</Project>
```

The content of this file is also on [Gist](https://gist.github.com/vfabing/1c3eb93f21e6bc1610e0737646628af8/revisions?diff=unified) (You can find more info about using NuGet Packages in `Azure Functions` on the [official documentation](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-csharp#using-nuget-packages))

Alright, so you can start to test your `Azure Function` directly from the [Azure Portal](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-azure-function#test-the-function), which should be able to create / delete the container of your build agent, and successfully be added to your `Agent Pool`.

## Call an Azure Function from an agentless job in Azure Pipelines

Now that we have a simple way to manager our container, let's see how to integrate it in our `Azure Pipeline`, more precisely at the beginning and at the end of our pipeline.

Let's create a new `Azure Pipeline`, and to keep things simple, let's use the visual designer:

![03-use-azure-pipelines-visual-designer](/assets/2019-08-22/03-use-azure-pipelines-visual-designer.png)

After choosing the template for your application (ASP.NET Core for instance), make sure that the self-hosted agent pool where your build agent will be registered is selected.

![04-select-azure-pipelines-agent-pool](/assets/2019-08-22/04-select-azure-pipelines-agent-pool.png)

Let's then add 2 agentless jobs, at the start of the pipeline to create and start the container, and at the end of the pipeline to delete it, each with a `Invoke Azure Function` task inside.

![05-call-azure-function-from-azure-pipelines-agentless-task](/assets/2019-08-22/05-call-azure-function-from-azure-pipelines-agentless-task.png)

The task configuration needs:
- The `Azure function URL` and the `Function key` which can be found from the [Get function URL](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-azure-function#test-the-function) button,
- The Method `GET` or `POST` (*Get in my example*), and the `Container Name` value passed by parameter.
> *You can add the `$(Build.BuildId)` variable to its name to make sure it is unique for every job*,
- The `ApiResponse` Completion event, to continue the pipeline without checking if our container was successfully started (*See [Callback](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/utility/azure-function?view=azure-devops#where-should-a-task-signal-completion-when-callback-is-chosen-as-the-completion-event) Completion event if you want to check it also*).

And that's it! Let's try to run our pipeline now:

![06-build-agent-on-demand-successfully-completed](/assets/2019-08-22/06-build-agent-on-demand-successfully-completed.png)

And boom, we manage to **build a dotnet core application with an ephemeral build agent, for an uptime of 2m 36s, equivalent to less than 1 cent** (*if you check the [calculation](https://www.vivienfabing.com/azure-devops/2019/05/14/azure-pipelines-how-to-add-a-build-agent-with-azure-container-instances.html#pricing) made previously*)

Pretty cool isn't it ? :)

That's all for this `Azure Pipelines` x `Azure Container Instances` serie at the moment. If you have any feedback or any question, feel free to send me a comment or tweet.

May the code be with you!
