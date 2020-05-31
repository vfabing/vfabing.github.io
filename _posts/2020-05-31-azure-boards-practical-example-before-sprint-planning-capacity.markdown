---
layout: post
title:  "Azure Boards practical example - Sprint Capacity"
date:   2020-05-31 13:37:00 +0200
categories: [azure-devops]
tags: [azure-devops, azure-boards, scrum, agile]
comments: true
---

After [preparing as best as we could our Sprint Planning to keep it short and efficient](https://www.vivienfabing.com/azure-devops/2020/04/30/azureboards-practical-example-before-sprint-planning.html), let's see now how we can get a realistic Team `capacity` for the Sprint.

> *Disclaimer: These articles are very personal so feel free to disagree. I am hoping to provide a interesting feedback to help you make your own decisions.*

## **Sprint Capacity** preparation

To calculate the `Sprint capacity`, `Azure Boards` will mainly try to count the number of `Working days` in a Sprint, and will multiply it by the `daily capacity` in `Hours` of the `Team members`.

So let's first see how to configure the `Working days` of a Sprint.

## Configure the Sprint **Working days**

First of all, you have to set the [Team Working Days](https://docs.microsoft.com/en-us/azure/devops/organizations/settings/set-working-days?view=azure-devops&tabs=preview-page#configure-working-days) if not already done. (*Note that by default only `Saturday` and `Sunday` are not considered as working days*).

![01a-azure-boards-sprint-working-days-setup.png](/assets/2020-05-31/01a-azure-boards-sprint-working-days-setup.png)

Then obviously, we need to [set the Sprint Dates](https://docs.microsoft.com/en-us/azure/devops/organizations/settings/set-iteration-paths-sprints?view=azure-devops&tabs=preview-page#add-iterations-and-set-iteration-dates)

![01b-azure-boards-sprint-dates.png](/assets/2020-05-31/01b-azure-boards-sprint-dates.png)

Finally, we need to make sure that all Team members are defined in the [Sprint capacity](https://docs.microsoft.com/en-us/azure/devops/boards/sprints/set-capacity?view=azure-devops#set-capacity-for-the-team-and-team-members), and then define the `Team days off` (if any).

![01c-azure-boards-sprint-days-off.png](/assets/2020-05-31/01c-azure-boards-sprint-days-off.png)

From there you can already check the calculated Sprint working days  
![01-azure-boards-sprint-working-days.png](/assets/2020-05-31/01-azure-boards-sprint-working-days.png)

If possible, don't forget also to specify individual team members days off (also if any of course).

Alright, so far we manipulated `days`, but most of `Azure Boards` features are expressed in `hours`, so let's see how to convert these `days` into `hours`.

## Personal feedback: Use **1 day = 6 hours** to convert your estimates

As `Azure DevOps` only use hours for estimates, we use `6 hours` when we want to describe an estimate of a `full day task` and `3 hours` for a `half a day task`.  

`1 day` corresponding to `6 hours` is a completely arbitrary value and was chosen as the most fitting value for us, because it enables us to still get meaningful estimates while not `micro tracking` every unplanned events (*pair programming, review, questions, discussions etc. etc.*)

## Define **Sprint global capacity** and capacity by **activity** and **member**

Given the estimates scale described before, let's first configure the [Team members capacity](https://docs.microsoft.com/en-us/azure/devops/boards/sprints/set-capacity?view=azure-devops#set-capacity-for-the-team-and-team-members), specifying a capacity of `6` hours (for a full day of work) per team member.

![02b-azure-boards-sprint-members-capacity.png](/assets/2020-05-31/02b-azure-boards-sprint-members-capacity.png)  

With this, you should be able to see the `Sprint global capacity` as well as the individual `member capacity` from selecting `Work details` in the `View options`:

![02-azure-boards-sprint-global-and-members-work-capacity.png](/assets/2020-05-31/02-azure-boards-sprint-global-and-members-work-capacity.png)  
*In the picture above, the `Team overall capacity` is `600 hours` (meaning 10 people in the team for a 10 days Sprint), and `12 hours` of `Remaining Work` are already defined in the Sprint.  
For the Team member `Vivien`, he has a capacity of `60 hours`, and is already assigned to some `Tasks`, for a overall of `12 hours` of `Remaining Work` to do during the Sprint.*
> *You can typically see this kind of view before or at the beginning of the `Sprint Planning`*

That's a good start and could already be sufficiant for your context, but I found myself using very often another feature: The Task `Activity` field.

This field enables us to categorize `tasks` by affinity:  
For instance, I often see teams composed of `JavaScript/TypeScript` developers and `C#` developers. So instead of just seeing `600 hours of team capacity`, would not it be better to get a little bit more detailed view and be able to see `180 hours of JavaScript/TypeScript capacity`, `300 hours of C# capacity` and `120 hours of organization`?

![03-azure-boards-sprint-activity-capacity.png](/assets/2020-05-31/03-azure-boards-sprint-activity-capacity.png)  

> *Note that by default, Activity field contains only `Deployment`, `Design`, `Development`, `Documentation`, `Requirements` and `Testing` values. If you want to use custom values as shown above, you need to [customize the `Activity` field](https://stackoverflow.com/a/48659130).  
> If you don't have access to the work item customization, you can still agree on a defined mapping inside the team such as `Design` for `JavaScript` developers, `Development` for `C#` developers, `Requirement` for the team members related to organization, etc.*

For this, you will need to come back once again to the [Sprint Capacity](https://docs.microsoft.com/en-us/azure/devops/boards/sprints/set-capacity?view=azure-devops#set-capacity-for-the-team-and-team-members) tab and configure this time the `Activity` of the Team member (*and add multiple activities if the Team members needs to perform different type of tasks*)

![03b-azure-boards-sprint-member-activity.png](/assets/2020-05-31/03b-azure-boards-sprint-member-activity.png)  

## Wrap up

That's all for this second part about `Sprint capacity` preparation with Azure DevOps.

I hope this article could give you an overview of `capacity management` with Azure DevOps. Of course, this article is heavily related to the next article which will talk about `getting a realistic scope of work` for a Sprint. (*I will try to write it as soon as possible not to let the suspens fade away haha*)

Feel free to show your disagreements or any other opinion in the comments or in reply to my Twitter [@vivienfabing](https://twitter.com/vivienfabing).
May the code be with you!