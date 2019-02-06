---
layout: post
title:  "Do I still need traditional specifications when using User Stories? Practical usage in Azure Boards"
date:   2019-02-06 13:37:00 +0200
categories: [azure-devops]
tags: [azure-devops]
---
# Do I still need traditional specifications when using User Stories? Practical usage in Azure Boards  
## The need of User Stories  
When starting a new development project, expressing your needs, constraints and requirements are generally the first step. Moreover, this is probably one of the most important part of the project, as it will have huge impact of how you will organize not only your team but also your code.  

However, it has been largely proven and accepted that writing a huge file of a few hundred page, with detailed technical specifications, become easily outdated and unusable. Like technology nowadays, development projects often change and evolve, at a very high pace.  

That is why in Agile methods, people don’t want to spend time on conceiving and writing specification which might be used in 6 months (and which of course will be outdated by that time), but prefer to describe at a high level their needs, often as a form of User Stories.  

![01-create-user-stories-with-azure-boards](https://raw.githubusercontent.com/vfabing/vfabing.github.io/master/_posts/01-create-user-stories-with-azure-boards.png)

You can add a new User Story from many places in Azure Boards. One of the fastest is directly from the Backlogs pages which enable to create a User Story just by its name.  

You can then organize your project by prioritizing your User Stories, and by drawing high level roadmaps of your sprints, in which you will hopefully implement your User Stories.  

## Specification in Agile methods?  
As a developer, you understand that nobody want to lose time writing a book of specification, which was going to be outdated as soon as it would have started to be implemented (and which anyway, you weren’t going to read carefully :p). Still, when working on a development task, having the liberty on technical subjects is important to enable you to use your technical creativity at best, but having too much liberty on functional subjects can lead you to make assumptions, which are most of the time wrong or at least different than what your users wanted.  

I let you guess it: Yes, there is probably something in between a book of specification, and two lines on a post-it expressing a need.  

So you know that at what point, you will want detailed specifications before being able to start your development tasks, with a clear vision of what has to be done, aligned to what your client has in mind. Question is “who must do this and when?” using Agile methods.  

## The product owner, master of knowledge  
The title spoiled the fun: Yes, there is a role in Agile method for the person who will be responsible for producing detailed specifications in form of detailed User Stories, namely the Product Owner.  

However, as this is heavily time consuming, the difficulty on the subject is to produce them well enough in advance to make sure the team has time to review it and organize itself according to it, but not too much in advance, in order to not waste time on specification which will be deprioritized, changed or worst, abandoned.  

As a rule of thumb, it is widely accepted that around one to two sprints of User Stories in advance (i.e. except the current one) should be sufficiently detailed in order to optimize the team organization at best : It will allow to swap User stories during the Sprint Planning in case of business or technical urgency matter.  

![02-detail-your-specifications-in-description-acceptance-criteria-links-or-attachments-of-user-stories](https://raw.githubusercontent.com/vfabing/vfabing.github.io/master/_posts/02-detail-your-specifications-in-description-acceptance-criteria-links-or-attachments-of-user-stories.png)

To detail the specifications of your user story, you can fill the description, acceptance criteria, add a link to a file, or add it as an attachment of your User Story   

However, regarding the technical understanding of the product owner, having a “technical review” on each User Stories is usually a best practice.  

## Technical review and estimation  
Having the User Stories reviewed by developers is important, as it is crucial that they perfectly understand the need behind them, to produce the best technical solution. This is usually the moment where a lot of questions, not foreseen by the product owner, arise. And this might also be a good time to provide a Story Point or Effort metrics, which can help in return the Product Owner to prioritize the backlog.  

![03-drag-and-drop-your-user-stories-on-the-backlog-to-prioritize-them-according-to-story-points-and-effort.png](https://raw.githubusercontent.com/vfabing/vfabing.github.io/master/_posts/03-drag-and-drop-your-user-stories-on-the-backlog-to-prioritize-them-according-to-story-points-and-effort.png)

Drag and drop the User Stories on the Backlog page to prioritize them according to the Story Points and Efforts  

According to your team maturity and habits on the subject, this kind of review can be done during a preceding Sprint, or during the Sprint Planning. The advantages of the first one being that it let more time to focus on technical details during the Sprint Planning, and the advantage of the second being that it try to optimize the time spending on specifications.  

## Conclusion  
In the end, traditional specification as in “super fat book of specifications” might not be the best in a fast pace changing world like nowadays, but on the other hand, the lack of functional details available a few weeks before starting a Sprint might also have a negative impact on your organization.   

In summary, too much anticipation is not good, but no anticipation at all is also out of questions 😊  

May the force be with you.  
