---
layout: post
title:  "Docker: Optimize ASP.NET Core SPA container with Visual Studio"
date:   2019-09-16 13:37:00 +0200
categories: [docker]
tags: [docker, aspnetcore, dotnetcore, nodejs, visual-studio]
comments: true
---

## Visual doesn't yet support out of the box Docker for react SPA applications

With the recent versions of Visual Studio (and especially the latest 2019 version), it has been easier and easier to dockerize a aspnetcore application. It can now create for you automatically the Dockerfile, helping you to get your application running in a container in minutes without any Docker knowledge!

However, the default Dockerfile only contains what is necessary for building dotnet app, but nothing yet for the react SPA app (or any other javascript SPA framework) as we can see on opened Github issues [#5417](https://github.com/aspnet/AspNetCore/issues/5417) and [#5450](https://github.com/aspnet/AspNetCore.Docs/issues/5450).

While waiting for a more generic solution, we can still appropriate ourself of what is done in the Dockerfile, add the necessary tools for building the react SPA app and optimize its content.

Let's start with a simple practical example!

## Create a React aspnetcore app

This part is super simple, start by getting the [dotnet sdk](https://dotnet.microsoft.com/download) (using `choco install dotnetcore-sdk` for instance? :)

> The latest sdk is not working with Visual Studio 2017. You might want to install the 2.2.107 version

Then run the command line `dotnet new react` (and try your new React aspnetcore app by running `dotnet run`)

## Dockerize React aspnetcore app with Visual Studio 2019

Open now your project from Visual Studio 2019, and right click the `.csproj` and select `Add` > `Docker Support`.

![01-add-docker-support-to-aspnetcore-react-project](/assets/2019-09-16/01-add-docker-support-to-aspnetcore-react-project.png)

Select then the `Linux` option to create a Linux container. (Windows container could be the subject of other blog articles)

![01b-linux-container](/assets/2019-09-16/01b-linux-container.PNG)

Visual Studio should add to your project some [MSBuild properties](https://github.com/vfabing/docker-aspnetcore-react/commit/37f78d741745a2ec59eedab8c02838185ab0c40e#diff-32645297d48259ddcd780ddced263cd8L8), some [launch-settings](https://github.com/vfabing/docker-aspnetcore-react/commit/37f78d741745a2ec59eedab8c02838185ab0c40e#diff-25dda021b726757f13ff1c4fc2d8a248L1) as well as a [.dockerignore](https://github.com/vfabing/docker-aspnetcore-react/commit/37f78d741745a2ec59eedab8c02838185ab0c40e#diff-f7c5b4068637e2def526f9bbc7200c4eR1) file and a [Dockerfile](https://github.com/vfabing/docker-aspnetcore-react/commit/37f78d741745a2ec59eedab8c02838185ab0c40e#diff-3254677a7917c6c01f55212f86c57fbfR1).

Wonderful! Let's try now to generate an image from our Dockerfile by running `docker build -t docker-aspnetcore-react .`

![02-docker-react-aspnetcore-npm-not-found](/assets/2019-09-16/02-docker-react-aspnetcore-npm-not-found.PNG)

Oh no! `npm` command line was not found...

Let's see how to fix this!

## Add NodeJS to Dockerfile to generate react SPA project

The problem is just that Node.JS is not installed in our build container, so `npm install` and `npm build` cannot be executed to generate our react SPA files.

For that, we need first to add the command lines to install Node.JS in the Dockerfile of our Ubuntu build container :
```Dockerfile
RUN apt-get install --yes curl
RUN curl --silent --location https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install --yes nodejs
```
These 3 lines are the minimum required to installed nodejs on our Ubuntu container. This should enable us to run `npm command lines`.

But since we are at it, let's do some optimization on our Dockerfile in order to make it build as fast as possible!

## Docker optimization for react SPA application

The first one is pretty obvious: instead of copying all of `node_modules` files into the container, let's ignore their copy and let them be restored from the container, from the cache!
So to ignore the `node_modules` files, you can just add to your `.dockerignore` file this line :
```.dockerignore
**/node_modules
```

This should do the job, and skip copying megabytes of data and thousands of files! That's a good first step :)

For the second optimization, you need to understand a important particularity of building docker images: The docker images are built step by step (i.e. line by line) reading the Dockerfile, and more important, if no changes have been detected for this particular step since the last time the image was built, the build step will be skipped, and retrieven from the cache (in just single digit milliseconds).
So rule is to put steps which are not changing very often first, and put varying steps at the end of the Dockerfile.

For instance, you can find such optimization in the Dockerfile for the aspnetcore app: The `.csproj` files are first copied, then a `dotnet restore` command is executed restoring all dependencies (which should not necessary change very very often). Few steps later the whole source code is copied (which is supposed to change for each commit), and then the build happens.

Let's to the same for our nodejs project: Let's first copy the `package.json` and `package-lock.json` files, run `npm install`, and then let the build happens! For this we need to add to our `Dockerfile`:

```Dockerfile
COPY ["ClientApp/package.json", "ClientApp/"]
COPY ["ClientApp/package-lock.json", "ClientApp/"]
WORKDIR /src/ClientApp
RUN npm install

# Do not forget to change the current working directory to /src before copying all source code
WORKDIR /src
```

Alright! Let's try again to generate our image with `docker build -t docker-aspnetcore-react .`

![03-docker-react-aspnetcore-successfully-built](/assets/2019-09-16/03-docker-react-aspnetcore-successfully-built.PNG)

And yeah! It is now working!

To go further, we could see how to run our dotnet or javascript tests from docker, and how to get the results for publishing them (on Azure DevOps for instance ? :), or how to add some https support from our aspnetcore app in Docker, but these are subjects for futures articles!

May the code be with you!