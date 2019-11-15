---
layout: post
title:  "Blazor - Part 5: Show our Blazor webassembly app faster by using server prerendering"
date:   2019-11-14 13:37:00 +0200
categories: [blazor]
tags: [blazor, webassembly, spa, pwa, prerendering]
comments: true
---

Hi everyone,

After managing to make our app [work offline](https://www.vivienfabing.com/blazor/2019/10/31/blazor-how-to-get-a-blazor-pwa-using-workbox.html), let's see how to add to our Blazor PWA app a way to render the UI faster at the beginning.

When made only of static files, before being able to render any UI, our app need to wait that all files are loaded, which gives us a not so cool "loading..." message for few seconds at the start.

Once everything is loaded, our app is super fast since it doesn't need to reload whole pages from the server and render everything from the browser.

However if you remember of the "good old time" of aspnet MVC, reloading every time you do an action was surely an overhead we probably didn't want, but at least the first page rendering was faster and didn't require any "loading" time.

If only we could get something smart, with the first rendering done on the server, but then would get all the necessary files to run as an SPA in the background... Well the time has come, let's rejoice of a super basic yet complex functionality: `Server Prerendering`!

In fact, the `server side Blazor` (the only official way of using `Blazor` in production at the moment by the way) is already leveraging this feature by rendering `Blazor` components on the server and use signal R to send the DOM modifications to the browser.

Let's now see how to implement that in our Blazor PWA.

## Is server prerendering only about greatness ?

Well, hum hum, not really. 
Even without talking about technical complexities (such as `OnInitialized` event triggered twice, etc. More info explained in the `Blazor Server` part of the [official documentation](https://docs.microsoft.com/en-us/aspnet/core/blazor/hosting-models?view=aspnetcore-3.0#blazor-server)), the main structuring point in my opinion is having to host our Blazor app in an aspnetcore app.

Even if as a .Net developer this might not be such a problem (and could rather be an advantage) it does reduce your possibilities for hosting your app (simple static file hosting is no more an option), and needs you to bring the aspnetcore runtime with your app to be able to run (fortunately quite facilitated with containers technologies such as docker).

## Server prerendering a Blazor webassembly app with aspnetcore

Alright, it is time to talk about real stuff!
First of all we will need obviously an aspnetcore 3 app, using your favourite editor to create it or the command line `dotnet new mvc`.

We will need mainly 2 things :
- Add a reference to `Microsoft.AspNetCore.Blazor.Server`
- and a reference to our Blazor project

After that, we will need to add a `_Host.cshtml` file in a `Pages` folder in order to render our Blazor `App` root component directly on the server, a little bit "à la" `Razor` way of rendering pages.
The content of this file should be the same as our Blazor project `index.html` file, except that instead of displaying a "Loading..." message, we are going to render our Blazor component using the following syntax:
```html
@using blazor_workbox_pwa
...
<app>@(await Html.RenderComponentAsync<App>(RenderMode.ServerPrerendered))</app>
```

> You can find the whole content of this file on [GitHub](https://github.com/vfabing/blazor-workbox-pwa/blob/master/aspnetcore-prerendering/Pages/_Host.cshtml)

Then in the `Startup.cs` file of our aspnetcore all, we need to add the necessary services in `ConfigureServices` for rendering our "Mvc" page as well as the `HttpClient` used by our Blazor app
:
```csharp
services.AddMvc();         
services.AddScoped<HttpClient>(s => 
{
  var navigationManager = s.GetRequiredService<NavigationManager>();
  return new HttpClient
  {
    BaseAddress = new Uri(navigationManager.BaseUri)
  };
});
```

Then in the `Configure` section, we need to add:
```csharp
if (env.IsDevelopment())
{
  ...
  app.UseBlazorDebugging();
}
else
{
  app.UseHsts();
}
app.UseHttpsRedirection();
app.UseClientSideBlazorFiles<blazor_workbox_pwa.Startup>();
app.UseStaticFiles();
app.UseRouting();
app.UseEndpoints(endpoints =>
{
  endpoints.MapDefaultControllerRoute();
  endpoints.MapFallbackToPage("/_Host");
});
```

For testing the prerendering, this is pretty all we needed. You can now launch your aspnetcore app and observe that the first rendering of the page doesn't need loading:

![01-blazor-server-prerendering-no-loading](/assets/2019-11-14/01-blazor-server-prerendering-no-loading.gif)

Alright, maybe not as "mind blowing" as expected? Let's remember how it was without server prerendering:

![02-blazor-no-server-prerendering-with-loading](/assets/2019-11-14/02-blazor-no-server-prerendering-with-loading.gif)

## Road to the "perfect" Blazor PWA

Finally, after some tuning (some html tags to add, etc. details available on [Github](https://github.com/vfabing/blazor-workbox-pwa/tree/9d237c936d0af3ee9a0a0a17d78547eeb96791d1)) let's see the score we can get through Chrome DevTools :

![03-final-chrome-audit-lighthouse-score-blazor-pwa-with-server-prerendering](/assets/2019-11-14/03-final-chrome-audit-lighthouse-score-blazor-pwa-with-server-prerendering.png)

Well, we get the maximum score possible on the PWA side of our app, we still have some improvements to do on the performance side (the first `85` score), mainly because of the total size of our `dll` files necessary to start interacting with our app.

For this particular subject, the future implementation of an `AoT (Ahead of Time) compilation` mode, tracked in the ticket [#5466](https://github.com/aspnet/AspNetCore/issues/5466) on Github could improve overall performance and package size.

## In conclusion

Well, as usual, I hope this article gave you an overview of how simple it is to get a faster display of your Blazor PWA at the start.

Many thanks to [Chris Sainty](https://chrissainty.com/) who does a lot for the Blazor community, and in particular for his [Prerendering a Client-side Blazor Application](https://chrissainty.com/prerendering-a-client-side-blazor-application/) article!
Many thanks also to our Blazor guru [Daniel Roth](https://github.com/danroth27/BlazorWebAssemblyWithPrerendering) who initially shared on Github an server prerendering example!

Feel free to reach me out on Twitter [@vivienfabing](https://twitter.com/vivienfabing) or anywhere else, and may the code be with you!
