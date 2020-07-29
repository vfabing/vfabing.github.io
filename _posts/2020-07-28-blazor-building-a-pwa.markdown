---
layout: post
title:  "Building a PWA with Blazor WebAssembly"
date:   2020-07-28 13:37:00 +0200
categories: [blazor]
tags: [blazor, webassembly, spa, pwa, manifest, service-worker]
comments: true
---

Last month I had the wonderful opportunity to speak at the [BlazorDay online conference](https://www.blazorday.net/) about `Building a PWA with Blazor WebAssembly` (*Replay is available on [Youtube](https://youtu.be/XoizucRjxgU?t=18130)*)

If you are more cumfortable with reading a small blog article in few minutes instead of watching a 30m video, stay with me and let's me explain the content of the talk.

## Workbox or not Workbox

> ***tl;dr:** you can say goodbye to Workbox :)*

You might have noticed (or not), but this article could be considered partly as an update of my previous blog article [Blazor - Part 4: How to get a Blazor PWA using Workbox](https://www.vivienfabing.com/blazor/2019/10/31/blazor-how-to-get-a-blazor-pwa-using-workbox.html).

At that time, there were no PWA support out-of-the box with Blazor, and manually setting up everything was not especially the easiest thing to do. So using an already battle-tested tool to simplify the transformation into a PWA seemed to me like the right thing to do.

But we are talking of something dated from a long time ago! (*Well around 8 months to be more precise haha*) and to date, `Blazor WebAssembly` is now officially released in the .NET Core SDK 3.1.300+.

At first, I really thought that the PWA support of Blazor would be something very simple, but would rapidly need to be replaced by a more robust toolchain such as `Workbox`... 
But I chased this idea from my mind very quickly I discovered the great work done by the `Blazor` team on this subject! 

But still, as I think this subject is not always the simplest (*especially the `service-worker` lifecycle part*), let's see the magic under `dotnet new blazorwasm -o MyNewProject --pwa` (*or behind the `Progressive Web Application` checkbox in Visual Studio*)

## Make your app installable

To make your app installable, nothing extraordinary on this side.
You can have a look on what is added to your Blazor app to make it installable in this [Github commit](https://github.com/vfabing/presentation-2020-06-BlazorDay/commit/2055af5c708f9d980678fd9d5a994cd32c8cb4ba)

Don't forget also to register a service worker, even if empty, to be able to be considered as a PWA in [lighthouse](https://developers.google.com/web/tools/lighthouse).

> *For more information about all available configuration possible, have a look to the official documention on https://developer.mozilla.org/en-US/docs/Web/Manifest.*

## Add offline support using the service-worker.js

Ok things are getting interesting starting from this one.
For offline support, you need basically 2 things:
1) A list of all the statics assets to be cached in the browser.
2) A description of how you want to handle your cache usage and update.

For the first one, `Blazor` provides us with an MSBuild property named `<ServiceWorkerAssetsManifest>` which will take care of listing all the files in the published output, produce a `hash` to know if the file has changed, and resume all of this information in a `service-worker-assets.js` file. (*More info in this [Github commit](https://github.com/vfabing/presentation-2020-06-BlazorDay/commit/17bb7a1aa0d4a59e2acb90d6281ef6751fa93b77)*)

For the second one, `Blazor` provides us with an additional `service-worker.published.js` file containing implementing a `Cache, falling back to network` strategy.

[![https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook#cache-falling-back-to-network](https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/images/ss-falling-back-to-network.png)](https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook#cache-falling-back-to-network)
**Cache, falling back to network schema from developers.google.com/web/fundamentals*

Though, as described in the [official documentation](https://docs.microsoft.com/en-us/aspnet/core/blazor/progressive-web-app?view=aspnetcore-3.1&tabs=visual-studio#offline-support), the offline support is only enabled for *published* apps, which means that the original `service-worker.js` file is replaced by the `service-worker.published.js` only when using the `dotnet publish` command (*or when publishing through Visual Studio*)

Alright, if you've come that far, congratulation, your application is offline enabled.
But as usual, as I don't like black box, let's see a little bit more what is done inside.

## Service worker lifecycle events

If you have a look inside of `service-worker.published.js` file, you will see a simple workflow made of 4 parts:
- A `self.assetsManifest` reference to your assets manifest, containing the list of the file needed to be cached, as well as a version computed from the hashes
- an action when `installing` your service workeer
- an action when `activating` it
- and lastly an action when `fetching` resources.

To start with, the `installing` event will be triggered when a new version of your PWA assets is published, and will cache all of your assets in a cache named from your assets manifest version.
When the installation process is completed, your service worker new version will be in the `waiting` state, waiting for the user to close all instances of your PWA to `activate` your new version.

During the `activation` process, the *new* service worker version becomes the *current* version, and all other version are deleted as they are not used anymore.

Finally, everytime the user request a resource (image, icons, html file, js files, etc.), the `fetch` event is triggered and will look into the cache if the resource is available, and if yes, will return it, without even triggering any network request.

Well, the best might still be to debug the service worker by yourself and see step by step how this each events are triggered.

## To go further

The service worker `update` workflow is sometime quite surprising, and you might wonder how could we `notify` the user that a new version is available, and give him an `update now` button. Well you can find an [example on my Github](https://github.com/vfabing/presentation-2020-06-BlazorDay/commit/ed874f4ea688913faa0e29f1a8523f0e6818a392) of how to do that by using the `self.skipWaiting()` instruction, as well the `BroadcastChannel` API to communicate between your service worker and your web app.

![01-blazor-progressive-web-app-update-now-button.png](/assets/2020-07-28/01-blazor-progressive-web-app-update-now-button.png)

That being said, I hope this article could be a good refresh if you didn't remember clearly my public speaking, or helped you understand this subject better if you prefer reading than watching!

As usual, feel free to reach me out on Twitter [@vivienfabing](https://twitter.com/vivienfabing) or anywhere else, and may the code be with you!
