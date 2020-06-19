---
layout: post
title:  "Docker : ASP.NET Core container and HTTPS"
date:   2019-10-03 13:37:00 +0200
categories: [docker]
tags: [docker, dotnetcore, https, certificate]
comments: true
---

## `ASP.NET` Core container and HTTPS

Nowadays, getting your web app running in HTTPS is almost a prerequisite, even if you "just" want to be able to develop it!   
That's why when working on a `non-docker ASP.NET` application, Visual Studio set up for you a developer certificate in order to access your web pages in `https`.  
However when running an `ASP.NET` Core app in Docker, your container is exposed through `http` by default, so you need to define how to expose it securely.

Let's see what are our possibilities and how to implement them:

## Easiest way: run your container in `http` behind a reverse proxy exposed in `https`?

One of the easiest way, and also the one supported by default on Azure: keep your container exposed in `http` behind a reverse proxy exposed in `https`.
You can achieve this using the `App Service` on Azure for instance, where you just need to specify where to pull your [Docker image](https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-custom-docker-image#configure-registry-credentials-in-web-app) and manage SSL termination through the Azure Portal.

Or you could use a Nginx as a reverse proxy. You can find various way to configure it on internet, and you can also have a look to what have written my colleagues [Thibaut](https://blog.runasync.net/2018/11/27/create-a-log-engine-using-docker-elastic-search-kibana-and-nginx-architecture-local-work/) and [Thomas](https://thomaslevesque.com/2018/04/17/hosting-an-asp-net-core-2-application-on-a-raspberry-pi/#exposing-the-app-on-the-network) on their blogs :).

Even though it is one of the easiest way to get a container exposed in `https` (after all, you just keep running it in `http` as you would do before), there are some times when you don't want or you can't have a reverse proxy and need to enable access to your container directly in `https` (When nobody around you has the knowledge of how to set up a Reverse Proxy, or for any other reason).  

Let's see how to expose our container directly in `https` then.

## Use SSL with Kestrel in Docker

When you run your `ASP.NET` Core app using `dotnet run`, your app is hosted on the Kestrel web server, of which you can set up `https` access.

If you have a look at the official documentation, you have two built-in ways of doing this: one for running a [development](https://github.com/dotnet/dotnet-docker/blob/master/samples/run-aspnetcore-https-development.md) container, and one for a [production](https://github.com/dotnet/dotnet-docker/blob/master/samples/host-aspnetcore-https.md) container.
Most of the steps are common for these two ways, and the main difference being to use the `user-secrets` in the `development` version against using environment variables in the `production` version.

Let's implement the `production` way on this article:

First of all, we need a certificate:
- For your `production` environment, you will probably need a certificate signed by a trusted authority, being [Let's Encrypt](https://letsencrypt.org/), [VeriSign](https://www.verisign.com/), [GoDaddy](https://www.godaddy.com/web-security/ssl-certificate), etc.
- For your other environment, a self signed certificate should do the job (though each computer accessing the website will either receive a horrible `Your connection is not private` page before accessing your website or you will have to trust your self signed certificate on every computer).

Fortunately, for the second option, you have some command in the dotnet cli which can help: `dotnet dev-certs`.

## Create a self signed certificate to use in your container

To create a self signed certificate, you can run the following command line:
```cmd
dotnet dev-certs https -ep %USERPROFILE%\.aspnet\https\mycertificatename.pfx -p mycertificatepassword
```
Where `mycertificatename.pfx` is the name of your certificate, and `mycertificatepassword` is its password.  
Note also that the certificate is stored in the folder `%USERPROFILE%\.aspnet\https` which is containing the `dotnet dev-certs` generated certificates.

Then you will need to trust your self-signed certificate (if you want to prevent the `Your connection is not private` message). For this 2 solutions: either you browse to your certificate and install it by double clicking it, or you can just execute the following command line:
```cmd
dotnet dev-certs https --trust
```
This command line look for certificates in your `%USERPROFILE%\.aspnet\https` folder and automatically trust them for your. Pretty simple isn't it ? :)

## Run your container using your certificate

Alright, let's see the main part of this article: How to run your container and tell it to secure it's access using the previously generated certificate!

For this, we just need this one line:

```cmd
docker run --rm -it -p 5000:80 -p 5001:443 -e ASPNETCORE_URLS="https://+;http://+" -e ASPNETCORE_HTTPS_PORT=5001 -e ASPNETCORE_Kestrel__Certificates__Default__Password="mycertificatepassword" -e ASPNETCORE_Kestrel__Certificates__Default__Path=/https/mycertificatename.pfx -v %USERPROFILE%\.aspnet\https:/https/ aspnetcore-react:latest
```
Where:
- `--rm` and `-it` are [standard docker](https://docs.docker.com/engine/reference/commandline/run/) command line telling the container to self remove when exited and to display the logs in the console output.
- `-p 5000:80` and `-p 5001:443` are the mapping for `http` and `https` access
- `ASPNETCORE_URLS="https://+;http://+"` is used to tell `Kestrel` to listen to `https` and `http` urls
- `ASPNETCORE_HTTPS_PORT=5001` is used to tell the port used in the url to access the app in `https`
- `-v %USERPROFILE%\.aspnet\https:/https/` is used to mount the local folder `%USERPROFILE%\.aspnet\https`, containing the certificate, into the folder `/https` inside of the container.
- `-e ASPNETCORE_Kestrel__Certificates__Default__Path=/https/mycertificatename.pfx` is used to specify where to find the certificate to be used for encrypting traffic.
- `ASPNETCORE_Kestrel__Certificates__Default__Password="mycertificatepassword"` is used to specify the certificate password. Obviously for production environments, the password should be specified secretly (*by using `Azure Pipelines` [Secrets](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/variables?view=azure-devops&tabs=yaml%2Cbatch#secret-variables) for instance ?*)

Access to your container using https://localhost:5001 and...

![01-https-enabled-on-aspnetcore-container](/assets/2019-10-03/01-https-enabled-on-aspnetcore-container.png)

That's all, hopefully this article helped you to start more easily with Docker and ASP.NET Core.

Feel free to reach me out on Twitter [@vivienfabing](https://twitter.com/vivienfabing) or anywhere else, and may the code be with you!
