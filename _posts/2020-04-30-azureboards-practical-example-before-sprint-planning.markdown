---
layout: post
title:  "Azure Boards practical example - Before the Sprint Planning"
date:   2020-04-30 13:37:00 +0200
categories: [azure-devops]
tags: [azure-devops, azure-boards, scrum, agile]
comments: true
---

> We want to do this **project** given this **budget**, and we want to do it in **Scrum/Agile**!

If you are familiar with this sentence, you are in the right place and are welcome on the following series of blog articles trying to explain how the `Azure Boards` module from `Azure DevOps` can help us achieve this.

> *Disclaimer: These articles are very personal so feel free to disagree. I am hoping to provide a interesting feedback to help you make your own decisions.*

## Quick reminder: Why do I want a Sprint Planning

I consider the `Sprint Planning` definitely as one of the most important ceremonial of the `Scrum`, and among all the benefits it can provide, my favourites are:
- `As a developer, I can concentrate on being productive`. We are supposed to have made sure that the US (User Stories) are crystal clear, and listed all the necessary tasks to complete the US.
- `As a product owner, I have more time to focus` on preparing future US rather making sure than everything is well understood by the team everyday.
- The initial scope + the task estimates enable us to get a daily vision of our performance, as well as being able to give `more transparency to other people`.

That's being said, if everybody is convinced of its necessity, it does imply that it can be executed randomly. 
There are many pitfall, and duration is a very dangerous one.

## Keeping the Sprint planning short and efficient requires preparation

> - Let's go for another full day of Sprint Planning! Cheers everyone!
> - ...

Alright, meetings are time consuming.  
And **\*spoiler alert\*** the `Sprint Planning` is like any other meeting:  
If you don't prepare for it, it will be long and unefficient (*and will probably kill any good will coming from your teammates*).

I prefer having the team spending 4 days preparing for the next Sprint and be able to do a full Sprint Planning in half a day, rather than spending a whole day with the whole team, wasting (teammates number * 1 day) days + not getting a clear vision of the Sprint backlog.

I am also annoyed when a new User Story is explained and we either loose (*who said waste?*) a lot of time debating how to implement it, or either create a `Spike` or `PoC` and move the completion of the US for the next Sprint.  
To be more precise, if I was working on a project where `Time` (*often tightly coupled with `Cost`*) was not a problem, I would prefer these 2 solutions, but unfortunately I didn't encouter too much of these kind of projects :)

And I could continue longer (*[tweet me](https://twitter.com/vivienfabing) if you want to continue*), but let's move on to the `How` we can try to improve the duration and efficiency of the Sprint Planning.

## My ideal User Stories

Yes I personally think that even in Agile, we need more than just a `sentence on a post it` to be able to estimates correctly a functionality. (*more details about this in a previous blog post: [Do I still need traditional specifications when using User Stories?](https://www.vivienfabing.com/azure-devops/2019/02/06/do-i-still-need-traditional-specifications-when-using-user-stories-practical-usage-in-azure-boards.html)*)

But a Sprint backlog is not a random list of business rules either, so let me share how I like them to be written:

![02-my-ideal-user-story.png](/assets/2020-04-30/02-my-ideal-user-story.png)

1. I prefer a concise `Title`, with keywords easy to remember that the team will be able to reuse to communicate. I also like to add some [Tags] to see easily to which part this US is from.
2. `Acceptance Criteria` is where I am the strictest. I use the classical `As a`, `I want` `In order to` to understand who, what and why. (*And I do insist on the `why ?` to enable to think about the big picture and not just do because we were asked to...*). If needed, we can also add some small impact business rules precisions in this field also.
3. In the `Description` I usually want the links to the design as well as any other technical precision / direction.
4. Very important, if I consider that the User Story is not ready, I add a `Comment` mentionning the proper teammate as well as putting him in the `Assigned to` field.
5. It might be very specific to our organization, but we like to know to which skills the US is related to (*Front-End Development, Back-End, Design, Project Management, etc.*) in order to be able to do some optimization (e.g.: *next sprint is heavily related to the `Back-End` so we need to think about what `Front-End` dev can do!*)
6. As an IT consulting company, we need to provide workload estimations using days (*I could not find so far any project where we could sell Story Points workload :D*), so I usually put it in the `Story Point` or `Effort` field in order to keep track easily of the initial estimation and see how good or bad it was :)

## How do we organize to write them?

Getting a finalized backlog, ready for the Sprint Planning is a Team effort. Here is my favourite process in order to get it ready using the minimum time possible:

1. The PO (Product owner) write them, especially the `Title`, the `Acceptance Criteria` with Business rules, the `Description` with the Design (*if applicable*). If the project we are working on was estimated ahead, we also set the `Story Point` or `Effort` with the estimated workload in days.
   - This is clearly time consuming. Main problem being that ideally up to 2 Sprints of User Stories should be ready in order to keep the Team active. Taking 1 or 2 days per Sprint to write them properly does not surprise me that much.
2. Then some technical fellow (*ideally experienced ones*) read them, and check if everything is clear and ready for splitting and estimating. 
   - If not, he had some questions + mentions in the `Comments`, and `Assigned to` the mentioned teammate (*PO or designer for instance*).
   - He also add some `Tags` to know which skill will be needed.
   - If everything is ok, he also create the technical `Tasks` needed to complete the User Story and add an `Original Estimate`
   - Reviewing everything is also time consuming, especially if many comments exchanges are needed. 1~1.5 day per Sprint dedicated to this task looks pretty fine to me.

> *Note: Creating the `Tasks` and estimating them in advance is highly debatable. However by experience, I observed that very often if we don't do this, this is usually the experienced developer who ends up doing it during the Sprint Planning, making the whole team "waste" some precious time I would prefer them spending explaining what they conceived and how to implement it.*

This **second part** is where this whole process shine according to me: 
- It makes sure that the User Story is ready to be developped (as at least one developer could conceive how to do it)
- It gives time to perform quick background tasks:
  - Get an answer from the customer
  - Get additional designs
  - Look for the best way to resolve the problems required by the User Story by asking feedback from other colleagues internally, etc.

## Wrap up

That's all for this first part about `Sprint Planning` preparation with Azure DevOps.

I hope it could give you some new ways of conceiving how your team can work in Agile (or reassure the way you are doing it)

Next time, I will discuss about how to obtain a realistic capacity with Azure DevOps.

Feel free to show your disagreements or any other opinion in the comments or in reply to my Twitter [@vivienfabing](https://twitter.com/vivienfabing).
May the code be with you!