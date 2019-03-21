---
layout: post
title:  "How to keep your UI tests maintainable over time? Welcome to Page Object Pattern"
date:   2019-02-14 13:37:00 +0200
categories: [automated-testing]
tags: [automated-testing, selenium-net]
comments: true
---
## Context
Creating an automated UI test for a web application using Selenium is really super simple. You can leverage `Katalon Recorder` extension if you are new to coding, or start directly coding by using the `Selenium.Webdriver` package. However at the end of the day, tests are described in lines of code, and like any code base which is growing, the problem of maintainability of the code base arise.

Like always, adding new layers when necessary is generally a good practice, and in UI testing, there is a widely used pattern named `Page Object` or sometimes `Page Object Model (POM)` which describe how to put it in practice with UI testing.
The use of this pattern enable to correct hundreds of failing tests at once by changing only a few lines of code, and also enable to reuse UI accessibility improvments accross all tests.

Conceptually, in your test scenarii, instead of manipulating the web browser by using Selenium API directly in your test code, you would use a layer called a `Page`, which would be responsible to call the right Selenium instructions in order to do something (*click a button, input text, etc.*). Then in your test code, you use your page (`HomePage` for instance), to do some action (`Authenticate()`, `DisplayTheBurgerMenu()`, etc.). Then if by any bad luck one action, let's say the "authentication" part, require you to do something additional such as filling a captcha, you would only have to modify the content of the method `Authenticate()` method with this new step to automatically fix all the test using authentication!

> **tl;dr** *Sample project source code is available on my github repo [`sample-selenium-dotnet`](https://github.com/vfabing/sample-selenium-dotnet){:target="_blank"}*

## Page Object Pattern in practice
> **Disclaimer** Some helpers were existing in Selenium.Support library, regrouped under the namespace Selenium.Support.PageObjects (but were removed as a separate project since v3.11). The following example will not be using it, as I consider the pattern pretty simple and worth implementing it yourself for comprehension, maintainability and debugging matters.

### Page creation
So the first thing to do is to create a `~Page` class (`BingHomePage` for instance), which will take an `IWebDriver` in its constructor
```csharp
public class BingHomePage
{
    private IWebDriver _driver;

    public BingHomePage(IWebDriver driver)
    {
        _driver = driver;
    }
}
```
Then, as we don't want tests to access directly to the `IWebElement`, we declare them `private`. And we also expose one or more `public` methods acting on these `private` fields.
> Note: In the following example, I also use an intermediary `private` property in order to load the `IWebElement` only once

```csharp
private IWebElement _searchTextBox;
private IWebElement SearchTextBox => _searchTextBox ?? _driver.FindElement(By.Id("sb_form_q"));

private IWebElement _searchButton;
private IWebElement SearchButton => _searchButton ?? _driver.FindElement(By.Id("sb_form_go"));

public void SearchFor(string text)
{
    SearchTextBox.SendKeys(text);
    SearchButton.Click();
}
```
All put together, this gives you:

```csharp
public class BingHomePage
{
    private IWebDriver _driver;

    public BingHomePage(IWebDriver driver)
    {
        _driver = driver;
    }

    private IWebElement _searchTextBox;
    private IWebElement SearchTextBox => _searchTextBox ?? _driver.FindElement(By.Id("sb_form_q"));

    private IWebElement _searchButton;
    private IWebElement SearchButton => _searchButton ?? _driver.FindElement(By.Id("sb_form_go"));

    public void SearchFor(string text)
    {
        SearchTextBox.SendKeys(text);
        SearchButton.Click();
    }
}
```
Pretty concise I think, and you would find easily where to look for if you have any problem regarding the Bing Home page.

### Using Pages in tests scenarii
Then if we come back to the test code of our scenario, we now need to instanciate the pages, and give them the `IWebDriver` as a parameter.

```csharp
[TestMethod]
public void BingSearch_ShouldReturnResults()
{
    var driver = new ChromeDriver();
    driver.Navigate().GoToUrl("https://bing.com");

    var bingHomePage = new BingHomePage(driver);
    bingHomePage.SearchFor("Hello World");

    var bingSearchResultsPage = new BingSearchResultsPage(driver);
    var numberOfResults = bingSearchResultsPage.GetNumberOfResults();

    Assert.IsTrue(numberOfResults > 0);
}
```

No notion of Web Element is visible anymore, which means that you can fix the way of performing the `SearchFor()` or `GetNumberOfResults()` actions in all your tests, just by fixing the `SearchFor()` or `GetNumberOfResults()` method in the `BingHomePage` or `BingSearchResultsPage` class.

## To go further
As we have seen, implementing the `Page Object Pattern` with Selenium .NET is pretty simple, and this simple pattern should save you a lot of unpleasant labour of fixing many tests, failing for the same reason :)

Of course that is not all, one could argue that we could add another layer, more focused on `Business` side, and which would be responsible to perform business scenarios by using one or more pages and transitionning information between them. But that is totally up to you.

Another very good improvment would be to get rid of the `new` keywords used and use either `dependency injection` or a `factory pattern` in order to easily manage the creation of these pages.

May the code be with you.