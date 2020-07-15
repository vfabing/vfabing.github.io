---
layout: post
title:  "Azure Boards practical example - Getting a realistic Sprint scope of work"
date:   2020-06-29 13:37:00 +0200
categories: [azure-devops]
tags: [azure-devops, azure-boards, scrum, agile]
comments: true
---

After [preparing the Sprint Backlog](https://www.vivienfabing.com/azure-devops/2020/04/30/azureboards-practical-example-before-sprint-planning.html), as well as preparing the [Sprint Capacity](https://www.vivienfabing.com/azure-devops/2020/05/31/azure-boards-practical-example-before-sprint-planning-capacity.html), let's now see how we can define a realistic scope of work, according to our Team capacity (that is to say, let's see now how we can get an initial `Remaining Work` coherent with the Team `capacity` for the Sprint)

This objective should usually be the main focus during the second half of the Sprint Planning, when there is enough `Remaining Work` defined to identify potential bottlenecks (*Too much work for Front developers, Too much work for a particular member, etc.*)

> *Disclaimer: These articles are very personal so feel free to disagree. I am hoping to provide a interesting feedback to help you make your own decisions.*

## Personal feedback: How do I do estimates with Azure Boards `Tasks`

First of all, I would like to share a personal feedback about `how I scale my estimates`.

The first question I ask is not so much "How much time should it take to do this" but rather "How much time would you need to be comfortable realizing this properly".
I realized that for the first wording, I received very often **very tight estimates**, sometimes conceiving a **quick and dirty** solution as the developers feel they should give the **smallest estimate possible to please the product owner** (*again this is not always true, but I did see this very often*).
For that reason, I prefer to use the second wording, challenging the developer if needed to fit these estimates with a tight schedule, but by default, I would keep the estimate of a realistic and clean implementation.
This approach is also aligned with my vision of planification with estimates: **It is usually easier to deal with initial estimates too big than too small :)**

For the scale used, originally I liked to use the [Fibonacci sequence](https://en.wikipedia.org/wiki/Fibonacci_number) **to represent how innacurrate estimates become when the scope is getting bigger**. However as I discovered this was not so mainstream as I thought and now use simpler estimates as following:
- 1 hour*
- 2 hours
- half a day (3 hours)
- one day (6 hours)

*By default, I don't have any task which would take less than 1 hour (because it implies understanding, developing, testing, deploying and communicating). If really too easy, It could be either be regrouped with other tasks, or counted as a **0 hour task** (explanation following below)*

I find that 90% of our estimates fit into these values (*using task splitting or regrouping when it makes sense*). For the 10% left, we sometimes use the **0 hour task** (or "free" task) when the task is really something really trivial, as well as the `in between half a day and one day` or even `one day and half` and `2 days` for really complex tasks such as architecturing the solution or `PoC` / `Spikes` tasks. But again, this is **not** most of our estimates (*and very important that they stay like this*)

This kind of discussion could continue very long, but let's go back to `Azure Boards` configuration.

## Choose your tracking strategy for your non-development work, planned or unplanned

For every Sprint, you will have few recurring workload, for which you have to decide how do you want to take them into account, while not impacting the way you follow your Sprint advancement. Namely:
1. Sprint Planning
2. Sprint Demo + its preparation
3. Sprint Retrospective
4. `User Stories technical review` before Sprint planning (*As described in the [first article](https://www.vivienfabing.com/azure-devops/2020/04/30/azureboards-practical-example-before-sprint-planning.html) of this serie*). 
5. Bug fixing (aouch. This one could take its own blog post haha)
6. etc.

For point 1 to 4, we chose to fix some values (*~half a day for Sprint Planning, 2 hours for the Sprint Demo, 1 hour for the Retrospective, between half a day and an entire day for the technical review*), so for each member participating to these, I usually create a corresponding task per member in the Sprint Planning.

![01-azure-boards-sprint-planning-recurring-tasks.png](/assets/2020-06-29/01-azure-boards-sprint-planning-recurring-tasks.png)

Thanks to these little recurring tasks, team members will be able to spend some time freely on these important tasks, without worrying of putting the Sprint Burndown in danger or not!

> *You can import all of these recurring task at once using [Excel](https://docs.microsoft.com/en-us/azure/devops/boards/backlogs/office/bulk-add-modify-work-items-excel)*

Regarding the `bug fixing`, this is a widely and heavily debated subject (*as you can see if you try to look for `estimating bugs` in your favourite search engine*).

I liked some answers provided by Dan Makarov in its blog post [How Should You Estimate Bugs?](https://hackernoon.com/should-you-estimate-bugs-4ocf37t2), and I invite to try these during few Sprints to see if it could fit into the way your team is working.
All in all, this is mainly a cursor to adjust between `being totally blind` about bug fixing estimation, and `spending too much time/effort` trying to estimate them :)

Personally I am quite fan of the "time booking" (*around half a day up to 1 day*) per member for each Sprint, allowing to absorb most of the bug fixing.
In the end, I still think it is a matter of your team preferences and depends heavily on how you are organizing yourselves (*Feel free to reach me for an opened discussion on the subject on [Twitter](https://twitter.com/vivienfabing) or in the comments haha*)

## Azure Boards - get a realistic scope for your Sprint

This is the last part! If you've made it so far, congratulations! Just a little bit more efforts, and you should get a nice start for your Sprint!

What's left is very simple:
- Have a look to the current sprint `Work details`, and make sure there are no "red bars", and you are good to go!

![02-azure-boards-sprint-planning-work-details.png](/assets/2020-06-29/02-azure-boards-sprint-planning-work-details.png)

And for this, Azure Boards provide you with 3 different way to make sure that the scope your team will commit to deliver is reachable:
- First you get the overall `Work`: overall `capacity` of your team vs. overall `Remaining Work` in the Sprint.
- Second, if you made the effort to set the `Activity` field of work items and Team members, you get the `Work By: Activity` metrics: With this you get a more detailed vision regarding fields (*`C#` and `JS` in the screenshot for instance*) and can detect earlier than certain fields have already too much work planned, even if the overall scope seemed fine. 
  > *In the example screenshot, some of your full stack developer will have to handle a little bit more of `JS` tasks, and not ony `C#` ones. If you don't have full stack developers, you might want to reduce the scope involving `JS` workload*
- Lastly, you get the `Work By: Assigned To` metric: Usually, I don't really want to use this one, because in my ideal organization, there is not such a thing as `only him/her can do this` kind of task, and team members adapt and choose the task they want to implement on a day to day basis.  
  However in reality, it happens... And we already know from the beginning who is going to implement the tasks... So in that case, we assign the tasks to the team member so that at least, if too much work is assigned to him, well you get the "red bar" and know that either he/she will need to stop sleeping, or you will need to reduce workload involving him/her :)

This work details part is really useful. You can also know when you could stop your sprint planning when you see that the overall `Work` bar is full!

And when it is, it is probably time to wish everyone good luck, and start focusing for your new Sprint!

## Wrap up

Alright, that's all for this `Sprint Planning` part. I hope that you could discover something new of confirm practices you were already using (or feel strongly in a disagreement with me, and you might want to reach me on my Twitter [@vivienfabing](https://twitter.com/vivienfabing)?)

All in all, I wish you the best, and May the code be with you!