---
layout: post
title:  "How start or stop automatically an azure VM to optimize cost"
date:   2019-05-10 13:37:00 +0200
categories: [azure-devops]
tags: [azure, azure-pipelines, azure-devops-extension, virtual-machine]
comments: true
---
## Context
We use very often `Virtual Machines` on Azure, for development, testing, building, etc.  
Though these kind of VM might not be used all the time, especially very late in the night or during the weekend.
So one easy cost optimization could be to turn off these VM during those periods to save Azure Compute, and money :)

There are many ways to achieve that, but one of my favourite is to use `Azure DevOps`, and especially the `Azure Pipelines` part to do it, mainly because it gives me :
- A very easy and simple integration with Azure
- Traceability on the Start and Stop executions
- Fine tuned scheduling (which days, what time, many times per day, etc.)

If you are already familiar with `Azure CLI`, you could configure an auto Start/Stop workflow quite easily, but as I released a free extension for this purpose, let's see how to use it!

## Install **Azure Virtual Machine Manager Task** extension
You can go directly to the extension page [Azure Virtual Machine Manager Task](https://marketplace.visualstudio.com/items?itemName=vfabing.AzureVirtualMachineManagerTask) or look for it on the [Marketplace](https://marketplace.visualstudio.com/).

From the extension page, click on the `Get it free` button, and you should be redirected to your `Azure DevOps organization` selection page. 
From there, you have many options:
- If you have the [permissions](https://docs.microsoft.com/en-us/azure/devops/marketplace/how-to/grant-permissions?view=azure-devops) to manage extensions, you should be able to select your organization and start the installation immediatly.
- If you don't have the permissions, you can request the extension to be installed (Y*our organization administrators should then receive a notification email*)
- If you are `On-Premise` (*Azure DevOps Server 2019*), you have to [download and install it](https://docs.microsoft.com/en-us/azure/devops/marketplace/get-tfs-extensions?view=azure-devops-2019)

You can then create a new `Release definition` on the `Azure Pipelines` and start configuring it.

## Configure the Release scheduling
For this part, you can leverage the scheduling functionalities already existing in the Release triggers:

See [Scheduled release triggers](https://docs.microsoft.com/en-us/azure/devops/pipelines/release/triggers?view=azure-devops#scheduled-triggers)

## Use the **Azure Virtual Machine Manager** task in an Azure Pipeline Release
Iin your environment, you can add a new task and select the `Azure Virtual Machine Manager` task from the `Utility` tab:

![01-select-azure-virtual-machine-manager-task-in-azure-pipelines-release](/assets/2019-05-10/01-select-azure-virtual-machine-manager-task-in-azure-pipelines-release.png)

## Start or Stop Azure VM with **Azure Virtual Machine Manager** task
The configuration should be pretty straightforward:
- **Action**: Choose to `Start` or `Stop` the VM.
- **Azure subscription**: The azure subscription where the VM is located .
- **Resource group**: The resource group where the VM is located.
- **Virtual machine name**: The name of the virtual machine.

![02-start-or-stop-azure-virtual-machnie-with-azure-virtual-machine-manager](/assets/2019-05-10/02-start-or-stop-azure-virtual-machnie-with-azure-virtual-machine-manager.png)

Once everything is configured, you can start a Release manually to check that everything is working correctly! 

Congratulation :)

Feel free to give me any feedback (*problem you could encounter or feature suggestion*) in the comments or on Twitter!

May the code be with you!
