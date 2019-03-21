---
layout: post
title:  "Should I abstract DateTime dependencies to produce testable code ?"
date:   2019-03-11 13:37:00 +0200
categories: [dotnetcore]
tags: [dotnetcore, automated-testing, aspnetcore, unit-testing, integration-testing]
comments: true
---
## DateTime.Now, one of the automated test killer
If you have read a little bit about unit testing and stuff, you probably have heard few golden rules: `new` keyworld is bad, `static` and `singleton` are dangerous, and so on.  
But there is another classical "test killer" in the nature: `DateTime.Now`!  

Let's take an example:  
You are running a physical store and a website, and you want your customers to be able to list your products only during your work hours (*which will give you time to update your list everyday, because your shop is not yet equiped with a system which synchronize your real stocks and your website* :))

You have then a method `GetProductsIfStoreIsOpen` which can list your products. You call `DateTime.Now` to know the current time and return your products only if the current hour is between 8:00AM and 19:00PM.  
So far so good, everything is working. Now let's see how to test that...
You call the `GetProductsIfStoreIsOpen` method in your test, and... Oh wait! How to tell the method that the store is opened or closed since your method is using `DateTime.Now` to know that ???  
Well, good job, what you have is called an "untestable code" (*or a least hard to test*) :)

Want so more official reading? Have a look at the offical Microsoft documentation [Unit testing best practices with .NET Core and .NET Standard](https://docs.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices#stub-static-references) which gives another example about this subject.

## Mock or Fake DateTime in .NET by using an interface abstraction
Who never wished to be able to control Time?  
Well fortunately in .NET, being able to control the implementation of something in an automated testing context is fairly simple. Basically the easiest way to achieve that is by using some abstraction: Let's use an interface which can return the current time!

## [Chronos.Net](https://www.nuget.org/packages/Chronos.Net/) nuget package to the rescue
As I find myself almost all the time recreating these time abstracting libraries, I decided to package them into some NuGet packages called `Chronos.Net`, `Chronos.Abstractions` and `Chronos.AspNetCore`.  

Basically, the first one `Chronos.Abstraction` contains a simple `IDateTimeProvider` interface which expose two properties: `Now` and `UtcNow`.  

```csharp
public interface IDateTimeProvider
{
    DateTime UtcNow { get; }
    DateTime Now { get; }
}
```

The second one `Chronos.Net` is the implementation of this interface, and obviously return either `DateTime.Now` or `DateTime.UtcNow`.  

```csharp
public class DateTimeProvider : IDateTimeProvider
{
    public DateTime UtcNow => DateTime.UtcNow;

    public DateTime Now => DateTime.Now;
}
```

The last one `Chronos.AspNetCore` is a little bonus to be help configuring the dependency injection of this system by simply calling `UseDateTimeProvider()` with your aspnetcore `IWebHostBuilder`.

```csharp
public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
    WebHost.CreateDefaultBuilder(args)
    .UseDateTimeProvider()
    .UseStartup<Startup>();
```

## Testing and choosing what time it is

Using `Chronos.Net`, you are now able to abstract time using your favorite mocking librarye (*[FakeItEasy](https://fakeiteasy.github.io/) in the following example*)

```csharp
[TestMethod]
public void GetProductsIfStoreIsOpen_ShouldReturnAnErrorMessage_WhenCurrentTimeIsOutsideStoreOpenedHours()
{
    // Arrange
    var dateTimeInStoreOpenedHours = new DateTime(2019, 3, 6, 23, 0, 0);
    var expected = new string[] { "store is not opened" };

    var dateTimeProvider = A.Fake<IDateTimeProvider>();
    A.CallTo(() => dateTimeProvider.Now).Returns(dateTimeInStoreOpenedHours);

    var controller = new DateTimeDependentController(dateTimeProvider);

    // Act
    var result = controller.GetProductsIfStoreIsOpen();

    // Assert
    CollectionAssert.AreEquivalent(expected, result.Value);
}
```

You can also see a [sample aspnetcore application](https://github.com/vfabing/Chronos.Net/tree/master/samples/SimpleWebSample) using `Chronos.Net` to abstract time in its tests

## Feedback
I will continue to improve these packages as I will use them in the future.  
If you want to give it a try, you can have a look to the NuGet packages as well as the source code on GitHub.  

[![NuGet Version](https://img.shields.io/nuget/v/Chronos.Net.svg)](https://www.nuget.org/packages/Chronos.Net/) 
[![github](https://img.shields.io/badge/github-1.0.16-green.svg?cacheSeconds=2592000)](https://github.com/vfabing/Chronos.Net)

Any feedback is of course warmly welcomed :)

May the code be with you!