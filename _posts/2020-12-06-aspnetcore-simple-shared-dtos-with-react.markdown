---
layout: post
title:  "ASP.NET Core: Simple shared DTOs (and Clients) with React"
date:   2020-12-06 13:37:00 +0200
categories: [react]
tags: [dotnet, aspnetcore, react, axios, nswag, swagger, openapi]
comments: true
---

With the recent release of `ASP.NET Core 5`, [OpenAPI documents generation](https://docs.microsoft.com/en-us/aspnet/core/release-notes/aspnetcore-5.0?WT.mc_id=DOP-MVP-5003680&view=aspnetcore-5.0#openapi-specification-on-by-default) for describing our Web API is now included by default when we create a new Web API project.

This is definitely a great news as I always considered the addition of this feature (*mainly by adding the `Swashbuckle.AspNetCore` nuget package*) as a "must have" for all Web API projects.

Now let's not stop at documenting our Web API only, and let's go one step further:  
What if we could generate **automatically** some boilerplate code such as our `DTOs` used in our APIs, and even better, generate our `TypeScript` web `Clients` **automatically**?

Well yes we can obviously as described in the [official documention](https://docs.microsoft.com/en-us/aspnet/core/tutorials/getting-started-with-nswag?WT.mc_id=DOP-MVP-5003680&view=aspnetcore-5.0&tabs=visual-studio#code-generation), but let me walk through you an example.

# Start generating the code

As described in the documentation, many tools are at our disposal to generate our `TypeScript` boilerplate code.

To start with, I highly recommend playing with the graphical tool [NSwagStudio](https://github.com/RicoSuter/NSwag/wiki/NSwagStudio)

Once installed, you can first define where is located your `OpenAPI` document (*or more historically called `swagger` document*):  
![01-nswag-studio-define-your-open-api-swagger-url](/assets/2020-12-06/01-nswag-studio-define-your-open-api-swagger-url.png)

And then configure your preferences of how your `DTOs` and `Clients` will be generated. Here is an example of the configuration I use:
![02-nswag-configuration-for-typescript-code-generation-using-axios](/assets/2020-12-06/02-nswag-configuration-for-typescript-code-generation-using-axios.png)

As described in the previous articles, I use `axios` Clients even though the generation is still in preview as described in the [documentation](https://github.com/RicoSuter/NSwag).  
I also set the `Generation Mode` to `MultipleClientsFromFirstTagAndOperationId`, which, by looking at the [OpenAPI specification](https://swagger.io/specification/#operation-object) and how the [Tag](https://github.com/domaindrivendev/Swashbuckle.AspNetCore/blob/master/README.md#add-tag-metadata) and the [OperationId](https://github.com/domaindrivendev/Swashbuckle.AspNetCore/blob/master/README.md#assign-explicit-operationids) are generated, should produce 1 client per `Controller` (*by default*) and 1 method by `Endpoint`.

![03-nswag-typescript-client-code-generation](/assets/2020-12-06/03-nswag-typescript-client-code-generation.png)

I also specify to produce `DTOs` as `TypeScript` interfaces and also an output file name that I will be able to use in my application.

# Use the produced code in our app

This part should be pretty straightforward.  
First, we can remove our manually written `DTOs` in the `useAxios` custom hook to use the `DTOs` produced by nswag:

![04-use-nswag-produced-dtos](/assets/2020-12-06/04-use-nswag-produced-dtos.png)

Then in our components, we will be able to use the generated strongly typed `TypeScript Clients`

![05-use-nswag-produced-strongly-typed-typescript-clients](/assets/2020-12-06/05-use-nswag-produced-strongly-typed-typescript-clients.png)

And that's all. Using APIs in the future should be much easier as the strongly typed `TypeScript Clients` should guide us pretty well in calling correctly the APIs using the right URLs and parameters.

# NSWAG Clients automated generation

Alright, another very complicated part. Now that we could check our process, let's see how to update our generated `Clients`, and of course, how to do it `automatically`.

Fortunately, if you installed `NSwagStudio` (*using [chocolatey](https://chocolatey.org/) for instance*), the `nswag.exe` command line tool is probably already installed and available in your `PATH`, so the only things we need to do is to make sure that our `nswag definition` is saved in a file called `nswag.json` for instance:  
![06-save-nswag-definition-file](/assets/2020-12-06/06-save-nswag-definition-file.png)

Start our api (*using `dotnet run` for instance*) and then we just need to execute the following command line:

`nswag run /runtime:NetCore31`

![07-update-nswag-generated-clients-and-dtos](/assets/2020-12-06/07-update-nswag-generated-clients-and-dtos.gif)

> *Note: NetCore31 being the default runtime selected when creating the `nswag.json` file.*

And that's all!

# In conclusion
I hope this simple article gave you some hints about leveraging your `OpenAPI` documentations and hopefully save some time creating and maintaining manually all of the `DTOs` and `Clients`.

While this scenario was ok for me as I wanted a kind of "update when you decide" scenario, having to start the API everytime you want to update your `TypeScript Clients` might not be ideal and you might want to have a look to referencing directly the produced `ASP.NET Core assemblies` instead of referencing the `OpenAPI document` (*more info in the [Github documentation](https://github.com/RicoSuter/NSwag/wiki/NSwagStudio)*)

As usual, feel free to react in the comments or reply to me on Twitter [@vivienfabing](https://twitter.com/vivienfabing).

May the code be with you!