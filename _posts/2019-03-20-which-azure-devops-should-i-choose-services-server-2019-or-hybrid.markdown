---
layout: post
title:  "Which Azure DevOps should I choose ? Services, Server 2019 or Hybrid ?"
date:   2019-03-20 13:37:00 +0200
categories: [azure-devops]
tags: [azure-devops, azure-devops-services, azure-devops-server-2019, team-foundation-server]
comments: true
---
## Terminology clarification
We are now in March 2019, the new `Azure DevOps Server 2019` just got released. Now it is time to have a look to all the **hosting** possibilities we have regarding the `Azure DevOps` product.  
But before that, a little clarification on all the names associated to this product.

`Visual Studio Team System`, `Team Foundation Server`, `Team Foundation Services`, `Visual Studio Online`, `Visual Studio Team Services`, `Azure DevOps` and now `Azure DevOps Server` & `Azure DevOps Services`: Easy to be lost when you are not following with attention these evolutions :)

Good news! Now you can forget all of the previous names and keep only one: `Azure DevOps`. This is the name of the product, that you can have in 2 versions:
- `Azure DevOps Services` for the [SaaS](https://en.wikipedia.org/wiki/Software_as_a_service) version, hosted by Microsoft in Azure.
- `Azure DevOps Server` for the [On-premise](https://en.wikipedia.org/wiki/On-premises_software) version, that you can install on your own servers.

Now that the names are clarified, let's have a look at the advantages and drawbacks of each of the 2 solutions (SaaS or On-premise), and also have a look at a potential third solution (an hybrid solution ?).

## A brief parenthesis on access licences
As of March 2019, the pricing for the client access licences (CAL) are the same in both the SaaS and the on-premise version:
- You start with 5 free Basic access licences.
- You can go to the `Azure Marketplace` and buy some additional Basic access licences through the [Azure DevOps Services Users](https://marketplace.visualstudio.com/items?itemName=ms.vss-vstsuser).

The only real difference here, is that for the on-premise version (i.e. `Azure DevOps Server 2019`), you need to have purchased at least 1 Visual Studio subscription ([Professional](https://marketplace.visualstudio.com/items?itemName=ms.vs-professional-monthly) or [Enterprise](https://marketplace.visualstudio.com/items?itemName=ms.vs-enterprise-monthly)) to get the right to use `Azure DevOps Server 2019` in production. But I guess that if you are reading this post, that is already the case for you ;)
> official documentation on the subject [here](https://visualstudio.microsoft.com/team-services/tfs-pricing/) and [here](https://docs.microsoft.com/en-us/azure/devops/organizations/billing/buy-access-tfs-test-hub?view=azure-devops-2019)

## Azure DevOps Services: Recommended solution for starters in most cases
This one will be pretty straightforward: 
- **No installation or server to maintain** (Scaling, Failover, etc.), 
- **Automatic upgrade** with the latest functionality each sprint (*~15 new announces every 3 weeks*)
- **1800 minutes per month of Azure Pipelines** to Build or Deploy your project using Hosted pools (*Ubuntu, VS2017, MacOSX, etc.*) 
- **Free pricing for open sources projects**
-** Secure `https` exposition**, protected with [Azure AD](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/manage-conditional-access?view=azure-devops) (*Active Directory*)
- [**Azure Datacenters Security**](https://docs.microsoft.com/en-us/azure/security/azure-physical-security) (No you don't enter to change manually a hard drive in an Azure Datacenter that easily :)

> In short, if you want to use product and not worrying about anything, go for `Azure DevOps Services`!

Some drawbacks to keep in mind though:
- **English language only**
- The **location of the data**, which is defined at a [geographical level](https://azure.microsoft.com/en-us/global-infrastructure/geographies/) and not at a datacenter level (i.e. as of today, you cannot locate your data in France only). 
    > Official reference [here](https://github.com/MicrosoftDocs/vsts-docs/issues/2009#issuecomment-427906722)

## Azure DevOps Server 2019: Keep everything under control (but bear the maintainance associated with it)

Ok, so you are not so lucky as to be able to use `Azure DevOps Services`, but you might be interested by running your own version on your own servers on-premise! Main advantages are:
- **Multi-languages** (French, Japanese, etc.)
- Control over your **data location** (*within your own enterprise private network*)
- Control over the **`upgrade` timing** (*when you need to validate, plan and guide the users with the new features*)
- **No limit to [concurrency jobs](https://docs.microsoft.com/en-us/azure/devops/pipelines/licensing/concurrent-jobs?view=azure-devops)** in `Builds` or `Releases`
  > Reference [here](https://developercommunity.visualstudio.com/content/problem/442431/unable-to-use-or-set-parallel-jobs-in-azure-devops.html)
- Access to **`Artifacts` packages within the `Basic` access licence**
  > Reference [here](https://docs.microsoft.com/en-us/azure/devops/server/release-notes/azuredevops2019?view=azure-devops#changes-to-artifacts-and-release-management-deployment-pipeline-licensing)

> In summary, go for the `Azure DevOps Server 2019` on-premise version when you have strong requirements about `data location`, `upgrade timing` or `languages`, but be prepared for the heavy workload associated.

Main drawbacks are:
- **!!! INFRASTRUCTURE COST !!!**: You get the idea: not the easiest thing to match a 99,9% Uptime SLA and a security as high as the one in the Azure datacenters. 
- **Upgrade cost**: yes you have the control over the timing, but planning a migration is not without a cost, especially if you have heavily customized your own version.

## The Hybrid configuration with Azure DevOps Server 2019 in an Azure VM, relying on an Azure SQL Database: Intermediary step to move from on-premise to the Cloud?

With the latest `Azure DevOps Server 2019`, an interesting new feature make its appearance:   
The possibility to run `Azure DevOps Server 2019` on an `Azure VM` and rely on `Azure SQL Database` managed service for the data.
> Official announcement [here](https://docs.microsoft.com/en-us/azure/devops/server/release-notes/azuredevops2019?view=azure-devops#support-for-azure-sql-database)

All in all, you get :
- The **same benefits of the on-premise version** `Azure DevOps Server 2019` 
- **No need to maintain hardware and benefit from the elasticity of the Cloud** (You need more CPU? more memory? storage? No problem!)
- **No need to manage your SQL Database service **(failover, scaling, backups, etc.)
- My favourite advantage: You get also the benefit of being able to **locate your data in a chosen `Azure Region` (*France for instance*) and profit from the security and certifications** of the region (*Who wants an Azure DevOps product running in `sensitive health data certified` environment such as [French HDS](https://azure.microsoft.com/fr-fr/blog/microsoft-azure-is-now-certified-to-host-sensitive-health-data-in-france/) (`Hébergeurs de Données de Santé` or `Health Data Hosting`)?* :))

> If you need an Azure DevOps Server HDS certified, or if you want to get rid of those physical servers in your office, this Hybrid configuration might be the right choice for you!

## Conclusion
For small companies, as well as big companies who want to move onto the Cloud to externalize the infrastructure management, `Azure DevOps Services` is the version to go, and if you just want to go one step at a time, the `Hybrid configuration` might be a good compromise for a start.

And even if you are not ready to move onto the Cloud right now, `Azure DevOps Server 2019` get you covered and let you manage things the way you used to do.

Hopefully this small comparison have given you some insights. As usual, feel free to come back to me on twitter or anything if you have any question/remark.

May the code be with you!
