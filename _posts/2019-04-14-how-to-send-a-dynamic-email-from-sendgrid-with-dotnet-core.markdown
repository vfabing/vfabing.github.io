---
layout: post
title:  "How to send a dynamic email from Sendgrid with dotnetcore"
date:   2019-04-14 13:37:00 +0200
categories: [dotnetcore]
tags: [dotnetcore, sendgrid, azure, dynamic-transactional-templates]
comments: true
---
## Context
Sending email for notifications or confirmations is pretty common in applications, and Sendgrid email service is definitely a leader on this domain. 

As an Azure user, creating a (*free*) Sendgrid account is pretty straightforward from the Azure Portal.

But the common problem is **"how to offer a nice user interface for business user to provide their email templates while keeping it simple for a developer to enrich this template with user data ?"**

Here comes **Sendgrid Dynamic Transctional Templates**, and the **Sendgrid NuGet package** in **dotnetcore**.

## Sendgrid Dynamic Transactional Templates creation
As a prerequisites, you need a Sendgrid account, which can be easily created from the Azure Portal following the [Create a SendGrid Account](https://docs.microsoft.com/en-us/azure/sendgrid-dotnet-how-to-send-email#create-a-sendgrid-account) documentation.

Then you can access on your Sendgrid management dashboard by clicking on the `Manage` button.

From there you can access to the `Templates` > `Transactional` and create your first template

![01-create-sendgrid-transactional-template](/assets/2019-04-14/01-create-sendgrid-transactional-template.png)

When adding a `Version` to your template, you will be asked which kind of edtitor you want to use. Let's select the `Design Editor` to do some wysiwyg editing :)

![02-use-sendgrid-design-editor](/assets/2019-04-14/02-use-sendgrid-design-editor.png)

On this interface, you can configure your template settings: Configure the default sender email, the Subject, etc. but moreover, you can drag and drop many modules such as `Button`, `Text` and `Image` to build your email super easily.

![03-sendgrid-drag-and-drop-button-text-and-image](/assets/2019-04-14/03-sendgrid-drag-and-drop-button-text-and-image.png)

The important part here is to define your template variables by surrounding them by double brackets.
On the example, I defined a `name` variable and an `url` variable (to which the user will be redirected when clicking the button).

## Prepare for sending emails
First you will need [To find your SendGrid API Key](https://docs.microsoft.com/en-us/azure/sendgrid-dotnet-how-to-send-email#to-find-your-sendgrid-api-key).

Then you will need to get your Template `ID`

![04-get-sendgrid-email-template-id](/assets/2019-04-14/04-get-sendgrid-email-template-id.png)

## Use Sendgrid in dotnetcore console application
Start by adding the [Sendgrid](https://www.nuget.org/packages/Sendgrid/) NuGet package to your project.

You will then need to create a new `SendGridClient` which take your API Key in parameter, as well as a `SendGridMessage`, from which you will be able to configure many settings such as :
- The sender using `SendGridMessage.SetFrom(string email, string name)`
- The receiver using `SendGridMessage.AddTo(string email, string name)`
- Set the email Template ID to use using `SendGridMessage.SetTemplateId(string templateId)`
- And finally set the variables using `SendGridMessage.SetTemplateData(object dynamicTemplateData)`.
  - For this purpose, you can create a `class` and decorate your properties with the `JsonProperty` values corresponding to your template variables (the ones you surrounded with double brackets in the wysiwyg editor)

The only thing left to do is to call the `SendGridClient.SendEmailAsync(SendGridMessage msg)` et voilà!

![05-sendgrid-end-user-received-email](/assets/2019-04-14/05-sendgrid-end-user-received-email.png)

May the code be with you!

## Bonus - gist

{% gist 3f547635d6b4ac2d138f67f92b7f59c7 %}
