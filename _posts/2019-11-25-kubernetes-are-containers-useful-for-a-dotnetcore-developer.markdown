---
layout: post
title:  "Kubernetes: Are containers useful for a (dotnetcore) developer?"
date:   2019-11-25 13:37:00 +0200
categories: [kubernetes]
tags: [kubernetes, dotnet, docker, devops]
comments: true
---

> **tl;dr:** Useful? Yes. Absolutely necessary? No. Used for a single application? Nothing extraordinary... Used by the company with operations in mind? Now we are talking :)

At the era of the almighty DevOps, it is now almost impossible not to have heard about `Kubernetes` and `Docker`, whatever language you are using as a developer.

Even as a dotnet developer mainly working in Windows environments, it is hard to ignore these 2 technologies, although coming originally from the "Linux" world, as we are reminded of their existences at each Microsoft conferences (*the latest Microsoft Ignite 2019 was no exception* :)).

In this article, I would like to share my opinion about the actual benefits and drawbacks of using Docker + Kubernetes for dotnet applications.

## DevOps and  containers: story of a natural partnership

> **tl;dr:** If you think as a "pure" developer point of view, `Containers` don't have much appealing. But if you think as a `DevOps developer`, containers are just naturally fitted.

To my mind, one of the biggest problem with `Docker`/`Kubernetes` is that it has to be implemented by **developers**, to get **benefits mainly outside of the development** phase.

However I think that with the right awareness, this problem might go away:
In fact, I find it similar in many way as the problem we had for convincing everyone to spend time writing automated tests: Once again this topic could be considered as a burden for developers, providing benefits mainly outside of the development phase! However nowadays, thanks to the popularization of Agile methods, we (hopefully) don't need anymore to convince anybody of the usefulness of writing automated tests.

Now with the DevOps wave, we want to give the developers the responsibility of a new concept (for them): running applications in production!
Well this is almost the same formula as with `developers` and `testers` paradigm: Split the responsibilities between two teams of `developers` and `operators`, and you can count on the development team to relay operations concerns at a low priority a.k.a. "When we have time", like the previous automated testing problem :)
However if you give the responsibility of running your application in production to the development team, much more attention will be given to thinking ahead and preventing risky operations tasks.

As such, more automation is wanted, comes `Infrastructure as Code`, `Pipeline as Code` and whatever `as Code` to try to simplify at maximum putting this little piece of code into production! 
And in this quest of automation and reliability of the services deployed, 2 technologies came to be really well suited for this: **Containers** (`Docker` being the most famous type of containers) and **Containers Orchestrators** (`Kubernetes` seeming to have won the recent orchestrator war).

## Development phase: Nothing mind blowing?

Let's do a simple listing of all advantages and drawbacks of containers during the development phase:

**Drawbacks:**
- Need to rely on additional tools (*Docker Desktop* and/or *minikube*), a little bit heavy and sometimes unstable (*especially on Windows...*)
- Need to maintain additional files (`Dockerfile`, `Helm charts`) for building, testing, deploying
- Need to learn new usage, tools and methods (though this overhead disappears after few days)

**Advantages:**
- Rely on existing containers in seconds (*Run your SQL Server in a container without needing to install it!*)
- Having access to your build process / automated test process described in your `Dockerfile` (*easier to debug the CI!*)
- Running multiple entire environments with different configurations simultaneously on your own computer (*Great for checking quickly multiple environments!*)
- [Azure Dev Spaces](https://docs.microsoft.com/en-us/azure/dev-spaces/about) for testing and debugging quickly some containers inside a entire micro-service system

Well that's mainly everything what I could think of so far... (*If you find anything else, feel free to mention it in the comments!*)

As you can see the overhead is not that much in the long term (*and is still far less time than the 50% time of a developer required for unit testing announced by Microsoft in its [Pattern and practice](https://docs.microsoft.com/en-us/previous-versions/msp-n-p/jj159336(v=pandp.10)#chapter-2-unit-testing-testing-the-inside)*), but the gain in the development phase are not that much either.

Let's see however what benefits can we gain from this little effort as we advanced into the production phase.

## Outside the development phase: Where the greatness starts...

Even if using containers doesn't have a direct effect on the development teams, it has many indirect effects which, in the long term, might help to have plenty more time to focus on development.

Of course, the most famous benefit of using containers is the weakening of the `it works on my machine` syndrome, as containers offer **isolation** and bring everything necessary to be runable (necessary dependencies, services, etc.). `What a peace of mind not having to worry about the versions of dotnet frameworks available on the environment where we want to deploy :)`

[![before devops / after devops geek comic](http://turnoff.us/image/en/before-devops-after-devops.png)
](http://turnoff.us/geek/before-devops-after-devops/)

If the build of the source code is done in your `Dockerfile` (which is obviously strongly advised), setting up a **continuous integration pipeline** seems like a breeze. `Again, no need to worry about which version of each tool is installed on the build machine as we can describe freely in our Dockerfile which version of which tool we really want :)`
Cherry on the cake: relying on the `Docker` build steps cache helps to get an even faster build, relying on dependency installation and restoration cache, and keeping the build time to the compilation and unit test execution only.

Thanks to the isolation of the containers, the small memory footprint of each, and the deployment described in the helm charts, we can set up **new environments in seconds**. `What if you could get a new environment for every new Pull Request to be able to try out the new feature or check this new design modification?` Well you should try out the new [Review Apps](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments-kubernetes?view=azure-devops#setup-review-app) now in public preview in Azure DevOps and available for `Kubernetes` environments :)

## Letting developers deploy into production: pure madness?

No magic here, production related concepts still need to be grasped correctly. Just that using `Kubernetes`, you get a common standard way of doing things, and also some nice behaviors and tooling to make these tasks a little bit easier. 

Given that we already have some `Kubernetes` cluster already set up for us (*`Azure Kubernetes Service` for instance*?), many scenarios are already handled for us:
- What if your container has crashed ? Just let the [Self-healing](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/#why-you-need-kubernetes-and-what-can-it-do) functionalities of Kubernetes restart your container for you!
- Want to add some `Load Balancing` to your application between many nodes? Just set up the `replicas` count of your deployment higher than 1!
- Want to be able to deploy without downtime or rollback easily? Just make sure to have more than 1 replica and use [Helm](https://docs.bitnami.com/kubernetes/how-to/deploy-application-kubernetes-helm/#perform-rolling-updates-and-rollbacks) to deploy using `Rolling upgrades`!
- How about handling some heavy traffic punctually? 2 notions are available for you: 
  - [Horizontal pod autoscale](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) which will add more replicas of your pods to handle requests.
  - and [Cluster autoscale](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler) which will add more nodes (so more VM) to your cluster and is obviously specific to your Kubernetes provider.
- etc,..

This is just some of the few scenarios which are facilitated by using `Kubernetes` and `Helm`.

Again no magic here, running applications in productions still require to understand few concepts. But now with containers, you have many tools to help you handle these subjects like a pro :)

## Conclusion time, but wait, what did it have to do with Microsoft tech?

In the end, most of this article could be applied to any language and any development technology you use (*that's why the `dotnetcore` word in the title was in parenthesis haha*). So in the end why as a Microsoft technology user I should know about all of this stuff?

Well, this has everything to do with the Microsoft of nowadays. The time when Microsoft was developing its own technologies and forcing you to use their own tools only is far away, and now they try to provide tools well integrated in standard tools so that Microsoft tech user can also leverage new open source advancements.

What does it means for us, dotnet developers?

Well it means that our development environment will be a combination of open source tools/tech and specific Microsoft tech, giving us the freedom to reuse and explore by ourselves popular open sources tools, while having Microsoft at our back providing nice integrations and guidances.

However this also gives us more responsibility when we are sometimes trying new usages ahead of time, but I am afraid that this is actually the best suited way of doing things in our so fast evolving tech world.

Wow, that's all for this article. I did my best to summarize of all I could think about why you would want to adopt containers while using Microsoft tech, but that was not an easy task :)
To reassure developers who don't want to hear about `Linux` and `Open source` stuff, and keep everything running with Microsoft tech only, I would like to say that most of the features mentioned in this article are already available using `Azure` services, or will likely be available in the future if you don't mind waiting for few months/years for new cool tech that `open source` folks are already using :)

Feel free to show your disagreement, additional point of view or anything in the comments, or in reply to my Twitter [@vivienfabing](https://twitter.com/vivienfabing) account, and may the code be with you!