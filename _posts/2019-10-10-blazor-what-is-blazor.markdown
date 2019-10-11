---
layout: post
title:  "Blazor - Part 1: What is Blazor"
date:   2019-10-10 13:37:00 +0200
categories: [blazor]
tags: [blazor, webassembly, spa, server-side, pwa, electron]
comments: true
---

## Write a SPA in C#!

Imagine being able to leverage your knowledge on .NET, and especially C#, to a build a Web application, and more specifically a Single Page Application?  
Well this dream is now reality thanks to the arrival of `Blazor WebAssembly`, provided by the aspnetcore team !

Leveraging the recent arrival of the `Web Assembly` standard, `Blazor` (*the abreviation of `Browser` + `Razor`*) is currently built on top of the [Mono](https://github.com/migueldeicaza/mono-wasm) port.

> If you are not familiar with `Web Assembly`, my colleague Jérôme wrote a great [article](https://jeromegiacomini.net/Blog/2018/09/21/quest-que-webassembly/) [](https://blogs.infinitesquare.com/posts/web/qu-est-ce-que-webassembly) about it (*in French though*).

Let's discover together more about this new world.

## Multiple Blazor versions?

`Blazor`, `Blazor Server`, `Blazor WebAssembly`, etc... We didn't even write a single line of code that we already need to choose between different versions of Blazor!

Generally, `Blazor` refers to `Blazor WebAssembly`, the version of `Blazor` which is executing C# in your browser as a `SPA (Single Page Application)`, similarly to other JavaScript SPA Framework such as `React`, `Angular`, `Vue.js`, etc.

In this version, your .NET dlls are going to be shipped to your browser and interpreted directly, like any other static file.

The `Blazor WebAssembly` version is currently available in `Preview` in the .NET Core 3.0 release.

On the other hand, you can also hear about `Blazor Server`, which is based on [SignalR](https://docs.microsoft.com/en-us/aspnet/core/signalr/introduction?view=aspnetcore-3.0) technology, and offers to compute everything server side (thus not exposing your dlls)

The `Blazor Server` version is currently available in the .NET Core 3.0 release, and is already production ready and fully supported!

## Blazor WebAssembly

First let's see more precisly what is `Blazor WebAssembly`.
As it's name implies, `Blazor` is relying on `Razor` syntax to generate your web application.
As such, you will find yourself writing `.cshtml` and `.cs` files, as well as classical `.css` file for design.

An example of a `Blazor` component:

```csharp
<div>
    <h1>@Title</h1>

    @ChildContent

    <button @onclick="OnYes">Yes!</button>
</div>

@code {
    [Parameter]
    public string Title { get; set; }

    [Parameter]
    public RenderFragment ChildContent { get; set; }

    private void OnYes()
    {
        Console.WriteLine("Write to the console in C#! 'Yes' button was selected.");
    }
}
```

Your files will then be compiled using `MSBuild` to generate `.css` and `.dll` files, which will rely on `Mono` and `WebAssembly` to manipulate the DOM and render your app.
You can find below a simple schema of this behaviour:

![01-blazor-webassembly-architecture](/assets/2019-10-10/01-blazor-webassembly-architecture.png)

Note that the light blue parts are the infrastructure parts that you, ideally, should not have to worry about :)

Once you managed to compile your Blazor app, let's move on to the best part of all of this stuff: `Hosting`!

Why hosting? Well because at the end, what you get is a bunch of static files that you can host on any static file server, like you would do for any simple static HTML, css, JavaScript app!
From there, anything is possible: from `Azure Blob storage` to a simple `Nginx` container, passing through the standard aspnetcore server, you will not lack of choices!

Want more greatness? As a simple static Web app, you get access to all the neat tooling already there for Web development:
- Want to run Blazor as a `Progressive Web app `to get offline support, etc.?
- What about running it on desktop in `Electron`?
- Did I mention that running it on mobile in `Cordova` is too far either?

What's the best part of all of it? Will while you can already find some PoC on the internet to get your running, the aspnetcore team is also looking to enabling this as a standard in future versions of netcore framework!

Oh I forgot the most obvious part: since you are writing C#, you get accessing to code sharing between your client and your server, you get access to standard NuGet packages and so on! (Did I mention that I was rather enthusiast on the subject? Haha)

Well, even if I think the main usage of `Blazor` rely on `Blazor WebAssembly`, let's have a look to an unexpected yet interesting scenario enabled by `Blazor Server`

## Blazor Server

Do you want to keep the client side lightweight and and keep the load on the server, while still providing a dynamic UI without needing to reload your app when navigation?

Welcome `Blazor Server`, based on [SignalR](https://docs.microsoft.com/en-us/aspnet/core/signalr/introduction?view=aspnetcore-3.0), this `Blazor` flavour propose to just make the client download a small javascript to connect the `SignalR` system, and then send `JavaScript events` to the server, where a `Virtual DOM` is computed, and then send back to the client the `DOM modifications` that need to be performed on the client side.

There few advantages to this method:
- `.dll` files are not accessible from the Browser
- `Server side` execution of dotnetcore, thus getting access more easily to server capabilities (instead of browser capabilities)
- Support of [IE11](https://docs.microsoft.com/en-us/aspnet/core/blazor/supported-platforms?view=aspnetcore-3.0)...

Though you are not working as a SPA anymore, so you get obviously the following drawbacks:
- An aspnetcore server is required to make the connection (*Good bye static file deployment like*)
- You cannot work offline (*Good bye PWA*)
- Every JS event is processed by the server instead of the browser, thus generating some latency

## In conclusion

Well, I hope this article helped you to get an overview of the latest Blazor update and even made you want to try out this new cool technology!  
I plan to write more about other aspect of the `Blazor WebAssembly` (*You know me now, we can see Docker deployment, Azure, etc..*). Stay tuned! :)

Feel free to reach me out on Twitter [@vivienfabing](https://twitter.com/vivienfabing) or anywhere else, and may the code be with you!

> This article was heavily inspired by the great videos of [Daniel Roth](https://github.com/danroth27), published recently with the release of .NET Core 3.0 ([The Future of Blazor on the Client](https://youtu.be/qF6ixMjCzHA) and [Building Full-stack C# Web Apps with Blazor in .NET Core 3.0](https://youtu.be/MetcuX1OHD0))
