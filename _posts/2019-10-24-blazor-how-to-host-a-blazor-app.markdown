---
layout: post
title:  "Blazor - Part 3: Hosting of a Blazor webapp"
date:   2019-10-24 13:37:00 +0200
categories: [blazor]
tags: [blazor, webassembly, spa, docker, nginx, azure-storage, github-pages]
comments: true
---

> *This article is part of a serie. You can jump to other articles here:*
> - [*Part 1: What is Blazor*](https://www.vivienfabing.com/blazor/2019/10/10/blazor-what-is-blazor.html)
> - [*Part 2: How to create a simple static Blazor SPA*](https://www.vivienfabing.com/blazor/2019/10/17/blazor-how-to-create-a-simple-static-blazor-website.html)
> - [*Part 3: Hosting of a Blazor webapp*](https://www.vivienfabing.com/blazor/2019/10/24/blazor-how-to-host-a-blazor-app.html)
> - [*Part 4: How to get a Blazor PWA using Workbox*](https://www.vivienfabing.com/blazor/2019/10/31/blazor-how-to-get-a-blazor-pwa-using-workbox.html)
> - [*Part 5: Show our Blazor webassembly app faster by using server prerendering*](https://www.vivienfabing.com/blazor/2019/11/14/blazor-how-to-show-faster-a-blazor-webassembly-app-with-server-prerendering.html)

Here he we go, now is the time for our 3rd part of our Blazor series.

After a short introduction and small stop to start with the [simplest static Blazor webassembly running app](https://www.vivienfabing.com/blazor/2019/10/17/blazor-how-to-create-a-simple-static-blazor-website.html), let's see how to host our app.

In fact the official documentation already describe very well all the different options existing about this subject. Let me just provide a grain of salt and some examples :)

## Stay simple: hosting a Blazor webassembly app on a static file web server

If you are already familiar with the classical IIS web server, Blazor offers an almost out of the box support as you can find a web.config in the output folder of your publishable project.
As it is a an SPA, you will just need to install the [URL Rewrite module](https://www.iis.net/downloads/microsoft/url-rewrite) in order to forward all requests to your SPA (*e.g.: forward the `/about` request to your SPA rather than trying to find a real `about` folder in the IIS website*)

And if you are more used to Nginx web server, you can also host it on it! You even have a simple `nginx.conf` configuration file as an example on the [official documentation](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/blazor/webassembly?view=aspnetcore-3.0#nginx).

You also have an example to host it on an `Apache` server: [example config file](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/blazor/webassembly?view=aspnetcore-3.0#apache)

But let's pursue on this Nginx hosting and go a little bit further by seeing how to host it in Docker.

## Hosting your SPA in a simple Nginx docker container

You also have a sample for hosting a Blazor app in a Nginx container in the [official documentation](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/blazor/webassembly?view=aspnetcore-3.0#nginx-in-docker) (*great work really* :), but in order to keep things simple, this Dockerfile is assuming that you have already built and published your Blazor app, and that you just need to copy the output files in the container.

This is a simple solution, but I like the idea of having a Dockerfile alongside my solution, able to host my app obviously, but also build the source code in order obtain the outputs necessaries to run the app.

For this, if you are already familiar with the writing of a aspnetcore app Dockerfile, the idea is the same: use the official dotnetcore-sdk image to build our source code, and copy the output files in our Nginx container during a multi-stage docker build.
> Note : since Blazor is only available starting from the version 3 of the dotnetcore-sdk, we need to get the container with at least the version 3 of the dotnetcore-sdk

Here is what it looks like:
```Dockerfile
FROM nginx:alpine AS base

FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS publish
WORKDIR /src

COPY ["SimpleStaticBlazor.csproj", ""]
RUN dotnet restore

COPY . .
RUN dotnet publish -c release -o /app

FROM base AS final
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=publish /app/SimpleStaticBlazor/dist /usr/share/nginx/html/
```

Pretty simple isn't it?
You will then need to run the command `docker build -t simplestaticblazor .` to build your container image, and then run the command `docker run -it --rm -p 5000:80 simplestaticblazor` to start it.

## Serve your static SPA from Azure Blob Storage

If you are already used to work with Azure, this one is pretty straightforward: on Azure Blob storage, you can leverage the `Static website` functionality to serve your static application using http protocol directly from the storage.

![01-blazor-webassembly-on-azure-storage.png](/assets/2019-10-24/01-blazor-webassembly-on-azure-storage.png)

Once the feature activated, you only need to copy your static files app to your Blob storage using your favourite tool such as `Azure Storage Explorer`, `Azure File Copy` task from `Azure DevOps, etc.

And voilà, you get a pretty scalable app without the need to manage a `web app service` just to serve a bunch of static files.

And to get a more complete picture, you will usually need an [Azure CDN]((https://docs.microsoft.com/en-us/azure/storage/blobs/storage-https-custom-domain-cdn)) to expose your Azure storage through your own custom domain name and also over HTTPS.

## Hosting your SPA on GitHub pages

Hosting your Blazor SPA on GitHub pages requires a small trick that I found so funny that I couldn't not mention it :)

Our problem on this context is that GitHub pages can't redirect all of our requests on our `index.html` file as GitHub pages requires 2 different files: 
- One used as a default page (*i.e.: index.html*)
- And one used as a 404 not found error page (*i.e.: 404.html*)

Fortunately, this limitation is well known by the community and with two small [JavaScript hack](https://github.com/rafrex/spa-github-pages#single-page-apps-for-github-pages) (*which are redirecting from the 404 page to the index.html page*), we get a functional Blazor app on GitHub pages! Great finding :)

## `ASP.NET` Core loves Blazor

Still our first citizen option is to run our Blazor Web assembly app directly served by an aspnetcore app on top of a kestrel server.

On fact aspnetcore already has some built-in extensions to host our Blazor SPA, be able to debug it, redirect requests to it, etc.

```diff
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    app.UseResponseCompression();

    if (env.IsDevelopment())
    {
        app.UseDeveloperExceptionPage();
+       app.UseBlazorDebugging();
    }

    app.UseStaticFiles();
+   app.UseClientSideBlazorFiles<Client.Startup>();

    app.UseRouting();

    app.UseEndpoints(endpoints =>
    {
        endpoints.MapDefaultControllerRoute();
+       endpoints.MapFallbackToClientSideBlazor<Client.Startup>("index.html");
    });
}
```

This kind of hosting is also a great way of enabling `Server Prerendering` scenarios. In short, it will enable to compute and prerender our Blazor page on the server. This will enable to first return a simple static HTML Page to our visitor accompanied with a small JavaScript, which will rehydrate our application in the background until the visitor get a fully functional Blazor SPA!

The great Daniel Roth has already a working demo on his [GitHub](https://github.com/danroth27/BlazorWebAssemblyWithPrerendering) :)

## In conclusion

Hopefully this article gave you some overview of the different possibilities to host your Blazor webassembly app.

You can have a look at a simple hosting in a nginx container on my [GitHub](https://github.com/vfabing/SimpleStaticBlazor)

Feel free to reach me out on Twitter [@vivienfabing](https://twitter.com/vivienfabing) or anywhere else, and may the code be with you!
