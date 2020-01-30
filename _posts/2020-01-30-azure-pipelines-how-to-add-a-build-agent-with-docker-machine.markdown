---
layout: post
title:  "Azure Pipelines: How to add a build agent with docker-machine"
date:   2020-01-30 13:37:00 +0200
categories: [azure-devops]
tags: [azure-pipelines, docker, docker-machine, azure]
comments: true
---

Last year, I wrote a small series of blog post about getting an azure pipelines agent in minutes using `Azure Container Instances` ([here](https://www.vivienfabing.com/azure-devops/2019/05/14/azure-pipelines-how-to-add-a-build-agent-with-azure-container-instances.html), [here](https://www.vivienfabing.com/azure-devops/2019/06/20/azure-pipelines-how-to-add-a-build-agent-with-azure-container-instances-part-2-custom-agent.html) and [here](https://www.vivienfabing.com/azure-devops/2019/08/22/azure-pipelines-how-to-add-a-build-agent-with-azure-container-instances-part-3-build-agent-on-demand.html)), and I got a great question from Thierry which made me admit that my favorite build environment is still having a self-hosted agent on an `Azure Virtual Machine`.

In this blog post, I would like to explain what are the advantages I find in this solution, and how to set it up in a matter of minutes.

## Why I find self-hosted agent on an Azure VM often better than Microsoft-hosted agent

> tl;dr: You get a faster and easier to debug build system.

1. When my colleagues tell me "My build takes too much time, how can I make it faster?", very often my first answer is "What about using a self-hosted build machine?".  
The reason for this is very simple: `Microsoft-hosted agents` are created and destroyed for each build, which means you can hardly reuse any out-of-the-box cache system (*Even though using the latest [Pipelines caching](https://docs.microsoft.com/en-us/azure/devops/pipelines/caching/?view=azure-devops) system could help, even with [Docker](https://github.com/fadnavistanmay/azure-pipelines-caching-yaml)*).  
With your own build machine, you can easily make faster:
   - Your `source code retrieval`: instead of doing a full `git clone`, you just do a light `git pull` like any developer would do.
   - Your `build time`: instead of doing a `Rebuild` of every project, you just do a `Build` on the project modified and the project dependents on them.
   - Your `package restoration time`: instead of downloading all of them everytime, you can first rely on your build machine `global package cache` (*and just copy the packages instead of downloading them*), but also just reuse the package from the previous build, and just add/update the new packages modified.
   - Your `docker build time`: You can benefit from the `images cache`, as well as the `docker build step cache` (*explained briefly on my article about [optimizing an SPA docker build](https://www.vivienfabing.com/docker/2019/09/16/docker-optimize-aspnetcore-spa-container-with-visual-studio.html#docker-optimization-for-react-spa-application)*)

2. "The build crashed! Call a ALM/DevOps expert to fix it!". I heard this sentence quite a lot in the past. To me, the build machine is here to **automatize** tasks which are usually done **manually** by developers. And in this regard, I expect the build machine to be like a developer machine as in `with the same tools, IDE, dependencies, etc.` installed, to make sure that if the build crashes, fixing it could be as simple as connecting to the build machine, launching Visual Studio or running the command line executed during the build, and debugging it. At the end of the day, having access to a `developer like build environment` makes fixing a self-hosted build is sometime easier imho.
3. Last point less important, and very dependent to your organization, but as `Microsoft-hosted` agents are usually used by default for every new pipelines, I often find their queues too busy and need to wait a few builds/releases to complete every time I need a build/release...  
So if you are lucky enough to have a few self-hosted pipelines at your disposal *(such as having many `Visual Studio Enterprise` users in your organization, giving you a free self-hosted pipeline per VS Enterprise user, or by buying them for 15$ each*), setting up your own self-hosted agent allows you to get your own `agent pool`, thus your independent `agent queue`, and stop waiting for Microsoft-hosted pipelines to finish.

> Note: Don't get me wrong, I still find `Microsoft-hosted agents` better for starters, and for rarely executed builds, or for which build time is not a problem. I even consider building your own build machine as an `advanced` scenario, so if you are not familiar with all of this, please stick with the `Microsoft-hosted agents` which are still very practical.

> *Disclaimer: Most of the ideas discussed above are interesting conceptually, but could be a little bit different from the reality as the Azure DevOps Teams does a great work to optimize all of these pain points. I have no doubt there are few hidden systems which make the experience I described not as bad as it is in real.*

Alright, convinced now? Let's see how to setup your docker build in minutes then!

## How to setup up a docker build machine in minutes

2 years ago, I wrote [this blog post](https://blogs.infinitesquare.com/posts/alm/docker-sur-azure-setup-une-plateforme-de-dev-entiere-pour-pas-cher) (*in French*) about creating your own docker build machine in Azure. Happens that I now use a even easier/faster way of doing it using the `docker-machine` command line.

> Warning: `Easier and faster` is not equal to `perfect` from the start (in a matter of maintainability, security, etc.). You will still need to grab some understanding on the underlying concepts (ssh, docker, Azure, etc.), just you will get a working environment faster that you can improve gradually :)

But without further wait, here is the script I use to setup my azure docker build machine:

```cmd
@ECHO OFF

SET PREFIX=myapp
SET ENV=build
SET LOC=WestEurope
SET AZURE_SUBSCRIPTION=7c6bed95-1337-1664-abcd-aa4691816e72
SET RG=%PREFIX%-rg-%ENV%
SET VM_NAME=%PREFIX%-dockermachine-%ENV%
SET AZUREVM_SIZE=Standard_D4s_v3
SET ADMIN_USER=myadmin

REM Create docker build machine with docker-machine command line (Installed with Docker Desktop)
CALL docker-machine create --driver azure --azure-subscription-id %AZURE_SUBSCRIPTION% --azure-resource-group %RG% --azure-location %LOC% --azure-ssh-user %ADMIN_USER% --azure-size "%AZUREVM_SIZE%" %VM_NAME%

REM Show environment variables to set to connect to the Docker service installed in the docker-machine
CALL docker-machine env %VM_NAME%
```

Hopefully the comments are self explanatory.
The last command [docker-machine env](https://docs.docker.com/v17.09/machine/reference/env/) should show the environment variables to set to connect directly from your local computer to the docker service available on your docker build machine.

So after getting your machine running, you now need to run an `azure pipeline agent` on your VM.  
Of course you could install it directly in your VM by following the standard procedure [Self-hosted Linux agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops), but you would then need to "pollute" your VM with dev dependencies, handling tools version conflict, etc.

As we are using `Docker`, a far better way (*to my opinion*) would be to run our build agent itself inside of a container!

We could achieve that by connecting to the docker service of our build machine, and then run the following script:

```cmd
@ECHO OFF

SET PREFIX=myapp
SET ENV=build
SET VM_NAME=%PREFIX%-dockermachine-%ENV%

SET AZP_URL=https://dev.azure.com/vfabing/
SET AZP_TOKEN=7wzr66gqzjq42kjsjvdpyhl3zhello7dh3fhbopimdpxkkmyaigq
SET AZP_POOL=%PREFIX%-pool
SET AZP_AGENT_NAME=%VM_NAME%-01
SET AZP_AGENT_DOCKER_IMAGE=vfabing/azure-pipelines-agent-dotnet-core-sdk

REM Start an Azure Pipelines agent in a docker container
docker run -d --restart=always -e AZP_URL=%AZP_URL% -e AZP_TOKEN=%AZP_TOKEN% -e AZP_POOL=%AZP_POOL% -e AZP_AGENT_NAME=%AZP_AGENT_NAME% %AZP_AGENT_DOCKER_IMAGE%
```

> *Note: If you want more information about creating your own azure pipelines docker agent image, or what are the parameters used, you can have a look to my previous blog article [Azure Pipelines: How to add a build agent with Azure Container Instances - part 2 : Custom Agent](https://www.vivienfabing.com/azure-devops/2019/06/20/azure-pipelines-how-to-add-a-build-agent-with-azure-container-instances-part-2-custom-agent.html)*

Et voilà! :)

> Note 2: If you want your build agent to be able to build docker images from Azure Pipelines, you will need to add 2 parameters to your `docker run` command line which are `-v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker`.
> However this has serious security implications as mentionned by [Microsoft Docs](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops#using-docker-within-a-docker-container) so be aware of that.

## Conclusion

I hope this article gave you more insight about azure devops docker build machines. 
Feel free to react in the comments or on Twitter [@vivienfabing](https://twitter.com/vivienfabing), and may the code be with you!
