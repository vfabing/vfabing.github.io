---
layout: post
title:  "Azure Pipelines: How to add a build agent with Azure Container Instances"
date:   2019-05-14 13:37:00 +0200
categories: [azure-devops]
tags: [azure-pipelines, azure-container-instances, azure-log-analytics, azure-monitor, azure]
comments: true
---
## Context
Had enough waiting for a build agent to be available?  
Have some [Parallel jobs](https://docs.microsoft.com/en-us/azure/devops/pipelines/licensing/concurrent-jobs?view=azure-devops) available and looking for a way to exploit them ponctually?

Let's see how to run a container on `Azure Container Instances` to get a ponctual extra build agent available in few minutes for your Azure DevOps project.

## Reuse microsoft container images with tools already installed

The simplest way to get an Azure DevOps build agent running in 1 command line is to reuse one of Microsoft container image available.

The command line should look like the following:  
`az container create -g MY_RESOURCE_GROUP -n MY_CONTAINER_NAME --image mcr.microsoft.com/azure-pipelines/vsts-agent --cpu 1 --memory 7 --environment-variables VSTS_ACCOUNT=MY_ACCOUNT_NAME VSTS_TOKEN=MY_VSTS_TOKEN VSTS_AGENT=MY_AGENT_NAME VSTS_POOL=Default`

Where :
- `--image` corresponds to one of the image from the page [Azure Pipelines Agent](https://hub.docker.com/_/microsoft-azure-pipelines-vsts-agent)
- `VSTS_ACCOUNT` corresponds to your Azure DevOps account name
- `VSTS_TOKEN` corresponds to a PAT (Personal Access Token), used to access to your Azure DevOps account. To generate one follow [Create personal access tokens to authenticate access](https://docs.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/pats?view=azure-devops#create-personal-access-tokens-to-authenticate-access)
- `VSTS_AGENT` corresponds to your build agent name, displayed in Azure DevOps
- `VSTS_POOL` corresponds to the [agent pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues) where you want your build agent to belong to. Default to the `Default` agent pool.

You can find more information of other parameters used in `az container create` command line on [docs.microsoft.com](https://docs.microsoft.com/en-us/cli/azure/container?view=azure-cli-latest#az-container-create)

### Example
`az container create -g aci-vfa-rg -n my-aci-agent --image mcr.microsoft.com/azure-pipelines/vsts-agent --cpu 1 --memory 7 --environment-variables VSTS_ACCOUNT=vivien VSTS_TOKEN=5a7jwwhoj64nlcyxcxahnj2v74zifcijg6xzcpkun6kdutjlk2sq VSTS_AGENT=my-aci-agent VSTS_POOL=Default`

![01-azure-container-instances-running-azure-pipelines-build-agent](/assets/2019-05-14/01-azure-container-instances-running-azure-pipelines-build-agent.png)

Et voilà! Your new agent is ready to run your Azure Pipelines!

## To go further

When need, you just need to run the the `az container stop` to stop the container (*and stop paying for it*), as well as `az container start` to make it available again!

However the main drawback of the already existing Microsoft images is that they take around 10 minutes to be pulled off (and start) as the image size if more than 10GB. Depending on your context, this could be a real blocker, and one of the best way to answer to this problem is by creating your own "custom" image, which will bring only your needed dependencies (*and not the tooling for all languages available in the world *:)) and enable you to get your agent in seconds! 

But this will be the subject of an another blog post :)

May the code be with you!

## Bonus - Get Containers logs in Azure Log Analytics (Azure Monitor)

Your containers logs are directlly available from the Azure Portal:

![02-azure-container-instances-logs-from-azure-portal](/assets/2019-05-14/02-azure-container-instances-logs-from-azure-portal.png)

If you want to store your container logs, you can send them to an `Azure Log Analytics` workspace by specifying few more parameters to the `az container create` command line.

As a prerequisite, you need to have an Azure Log Analytics workspace available (*Check [this](https://www.vivienfabing.com/aspnetcore/2019/02/21/how-to-add-logging-on-azure-with-aspnetcore-and-serilog.html#creating-the-azure-log-analytics-service-from-azure-portal) section from my previous blog post to create one*), and retrieve your `WORKSPACE ID` and `PRIMARY KEY`.

Then add to your `az container create` command the parameters:
- `--log-analytics-workspace` corresponding to your `WORKSPACE ID`
- `--log-analytics-workspace-key` corresponding to your `PRIMARY KEY`

Enjoy browsing your logs through `Azure Log Analytics`! 

![03-azure-container-instances-logs-from-azure-log-analytics](/assets/2019-05-14/03-azure-container-instances-logs-from-azure-log-analytics.png)
