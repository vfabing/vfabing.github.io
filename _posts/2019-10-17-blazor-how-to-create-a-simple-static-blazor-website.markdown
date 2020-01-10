---
layout: post
title:  "Blazor - Part 2: How to create a simple static Blazor SPA"
date:   2019-10-17 13:37:00 +0200
categories: [blazor]
tags: [blazor, webassembly, spa, docker, nginx]
comments: true
---

> *This article is part of a serie. You can jump to other articles here:*
> - [*Part 1: What is Blazor*](https://www.vivienfabing.com/blazor/2019/10/10/blazor-what-is-blazor.html)
> - [*Part 2: How to create a simple static Blazor SPA*](https://www.vivienfabing.com/blazor/2019/10/17/blazor-how-to-create-a-simple-static-blazor-website.html)
> - [*Part 3: Hosting of a Blazor webapp*](https://www.vivienfabing.com/blazor/2019/10/24/blazor-how-to-host-a-blazor-app.html)
> - [*Part 4: How to get a Blazor PWA using Workbox*](https://www.vivienfabing.com/blazor/2019/10/31/blazor-how-to-get-a-blazor-pwa-using-workbox.html)
> - [*Part 5: Show our Blazor webassembly app faster by using server prerendering*](https://www.vivienfabing.com/blazor/2019/11/14/blazor-how-to-show-faster-a-blazor-webassembly-app-with-server-prerendering.html)

## Start writing a Blazor app in seconds

As of today, if you want to start writing a Blazor app in just few seconds, you can follow the official [get started](https://docs.microsoft.com/en-us/aspnet/core/blazor/get-started?view=aspnetcore-3.0&tabs=netcore-cli) guide which requires mainly 3 points:
- Install the latest [.NET Core 3.0 SDK](https://dotnet.microsoft.com/download/dotnet-core/3.0) release
- Install the latest `Blazor` template by running `dotnet new -i Microsoft.AspNetCore.Blazor.Templates::3.0.0-*`
- Create a new `Blazor WebAssembly` project by running:
  - `dotnet new blazorwasm -o MyBlazorWebAssemblyProject`,
  - then `cd MyBlazorWebAssemblyProject`
  - and finally `dotnet run`

That's all, you get a running `Blazor WebAssembly` web app that you can start developping/debugging.

If you want to publish it, just run `dotnet publish -c release` and copy the content of the `publish/dist` folder to your favourite static files hosting platform, and you are done!

And if like me, you don't like when too much magic is done for you, keep reading the following sections :)

## Smallest publishable static Blazor project

To create the smallest client side `Blazor` app possible, we will need first a `.csproj` file at it is a C# project. Inside we will be able to reference the `Blazor` specific tooling, as well as mandatory dependencies (3 exactly: `Microsoft.AspNetCore.Blazor`, `Microsoft.AspNetCore.Blazor.Build` and `Microsoft.AspNetCore.Blazor.HttpClient`)

Then like any classic `ASP.NET core` project, you will need a `Program.cs` file which will be calling the `Startup.cs` file. The latest will be in charge of referencing you root `Blazor` component.

Then for the real `Blazor` stuff, you will need your root `Blazor` component file, usually named `App.razor` by convention, and also your default page usually called `Index.razor`, placed inside a `Pages` folder.

To glue all of that stuff, you will also need to create an `index.html` file inside the `wwwroot` folder. In this file, you will find a reference to the `blazor.webassembly.js` framework which will be in charge of loading the `mono` webassembly runtime, as well as your project assemblies which need to be defined inside a `blazor.boot.json` file (*You can have a look at the schema described in [What is Blazor](https://www.vivienfabing.com/blazor/2019/10/10/blazor-what-is-blazor.html#blazor-webassembly)*).

You can find below a small recap list of the mentionned files:
- A C# project `.csproj` file,
- A entry `Program.cs` file,
- A `Startup.cs` file following the startup pattern,
- An `App.razor` root Blazor component,
- An `Index.razor` page inside of a `Pages` folder (*by convention*),
- And finally an `index.html` file inside of the `wwwroot` folder, which will be the starting point.

You can have a look at the content of all these files on my Github commit [#ADD smallest publishable static Blazor project](https://github.com/vfabing/SimpleStaticBlazor/commit/81d915a1a52d039e8a5e40ac38c1bce81a78803e), but at this level, they are pretty much empty.

Now you should have a deployable project, for which you can run `dotnet publish -c release` and browse into the folder `./bin/release/netstandard2.0/publish/MyBlazorWebAssemblyProject/dist` to find all the static files you need to run your Blazor app (We will see in future articles how to host)

![01-blazor-smallest-publishable-project](/assets/2019-10-17/01-blazor-smallest-publishable-project.png)

We still get to download 5.1MB to display our `Blazor` app, mainly due to the size of the `mono.wasm` and the `mscorlib.dll` files which weight 1.8MB and 1.3MB respectively.

But like most SPA app, since these files are static files, they should ideally be downloaded only once, keeping the reload of the web page to only a few KB fortunately :)

## In conclusion

Well, I hope this article helped you to get a better understanding of what is really needed to get a simple `Blazor` app without any magic!

In the next article, I plan on writing about hosting this small `Blazor` app (in a Docker container for instance :))

Feel free to reach me out on Twitter [@vivienfabing](https://twitter.com/vivienfabing) or anywhere else, and may the code be with you!
