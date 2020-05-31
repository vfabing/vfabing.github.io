---
layout: post
title:  "How to authenticate easily an SPA with Azure AD in an aspnetcore app"
date:   2020-03-06 13:37:00 +0200
categories: [aspnetcore]
tags: [aspnetcore, azure-ad, azure-active-directory, spa, react, cookie]
comments: true
---

Few months ago, my dear colleague [Jonathan](https://blogs.infinitesquare.com/users/jantoine) gave us a presentation to the various way of connecting an SPA to an aspnetcore API using [OpenId Connect](https://blogs.infinitesquare.com/posts/web/open-id-connect-et-oauth-les-differents-flow-de-connexion), and he said something which kept stuck in my mind : 
> At the end of the day, `Cookie authentication` is probably the most secure way of protecting your API.

Lately, I had to add some simple email checking to secure an `aspnetcore API` using `Azure AD` for a `React` SPA, and I tried to look for some examples on `Microsoft Docs` but could only find what I would qualify of "overkill" (*showing examples using [MSAL.js](https://docs.microsoft.com/en-us/azure/active-directory/develop/authentication-flows-app-scenarios#single-page-public-client-and-confidential-client-applications), etc.*)

## How we came up with this simple authentication workflow

So I called to the rescue my other good colleague [Thomas](https://blogs.infinitesquare.com/users/touvre) and he first guided me toward the default `Azure AD` integration in an ASP.NET Core web apps (*that you can obtain easily following the [official documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-v2-aspnet-core-webapp)*).
He told me to look especially at the [`Microsoft.AspNetCore.Authentication` middleware](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-v2-aspnet-core-webapp#startup-class) which by default was securing all `Controllers` endpoints, and was redirecting the users to the Azure AD authentication page if they were not already authenticated.

But there was few **problems** with this:
- When the `React` SPA was calling the API, they would get a redirection `302` instead of a `401` unauthorized HTTP status code.
- Authentication would only check that the user was successfully authenticated on the associated Azure AD tenant, but would not check if the user was authorized to access to the app (*i.e. his email was present in the database*)

So with the help of [Thomas](https://blogs.infinitesquare.com/users/touvre), we somehow managed to find a "simple" **workflow** authenticate our SPA users:
- When user try to access to an API without being authenticated, return a `401` error.
- When getting an `401` unauthorized, redirect the user to the `/api/auth` endpoint.
- The endpoint redirect the user to the `Azure AD` login page and call back the `/api/auth` endpoint after, with an `Authentication Cookie`.
- When successfully authenticated, the `/api/auth` redirect the user to the main page
- Additional API calls are made with the `Authentication Cookie` and are successful.

And to achieve this, we needed to add **some modifications** to the default Azure AD Authentication as following:
1. Instead of redirecting the users to the Azure AD Login page when calling an API without being authenticated, return them a `401` status code.
2. Configure the `Azure AD Authentication` to be made using `Cookies` (so that [Authorize] protected endpoints can check if the cookie is present or not).
3. In the SPA, call the `/api/auth` path to authenticate yourself on `Azure AD`
4. In the same API endpoint, check the user email, and show an error message if not authorized.

## Override default redirection to Azure AD to return a **401** Unauthorized Status Code

In order to do this, we need to define the `DefaultChallengeScheme` as our `CustomApiScheme`, as well as creating and registering our own `AuthenticationHandler` to return a `401` status code:

```csharp
private static readonly string CustomApiScheme = "CustomApiScheme";

private void ConfigureAuthentication(IServiceCollection services)
{
    services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = AzureADDefaults.CookieScheme;
        options.DefaultChallengeScheme = CustomApiScheme;
        options.DefaultSignInScheme = AzureADDefaults.CookieScheme;
    })
    .AddAzureAD(options =>
    {
        Configuration.Bind("AzureAd", options);
    })
    .AddScheme<AuthenticationSchemeOptions, CustomApiAuthenticationHandler>(CustomApiScheme, options => { });
    ...
}
```
```csharp
public class CustomApiAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    public CustomApiAuthenticationHandler(IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger, UrlEncoder encoder, ISystemClock clock) : base(options, logger, encoder, clock) { }

    protected override Task HandleChallengeAsync(AuthenticationProperties properties)
    {
        Response.StatusCode = 401;
        return Task.CompletedTask;
    }

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        return Task.FromResult(AuthenticateResult.NoResult());
    }
}
```

## Use `Cookies` for the Azure AD Authentication
Nothing fancy here, just configure the `CookieAuthenticationOptions` using the `AzureADDefaults.CookieScheme` and define the properties you want your cookie to have.
```csharp
private void ConfigureAuthentication(IServiceCollection services)
{
	...
	
    services.Configure<CookieAuthenticationOptions>(AzureADDefaults.CookieScheme, options =>
    {
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
        options.Cookie.SameSite = SameSiteMode.Lax;
    });
    
    ...
```
![01-aspnetcore-azuread-authentication-cookie.png](/assets/2020-03-06/01-aspnetcore-azuread-authentication-cookie.png)

## Redirect to the **/api/auth** authentication endpoint when receiving a **401** unauthorized
In our sample app, we only have one API call so I just made a small change in the `FetchData.js` file. In a more complex application, you probably would have to configure the behaviour you want in the `fetch`, `axios` or whatsoever way of getting data.

```js
async populateWeatherData() {
  ...
  if (response.status == 401) {
    // Redirect to authentication point if not authorized
    window.location.href = "/api/auth";
  }
  ...
}
```

## Trigger the Azure AD authentication in your authentication endpoint
For this last part, you will need to have an **anonymously** accessible endpoint and would need to trigger the `Challenge(AzureADDefaults.OpenIdScheme)` when the user is not authenticated.
This should redirect the user to the Azure AD Login page, and should call back this endpoint with an `Authentication Cookie` when successfully authenticated.
You could then redirect the user to your SPA.
```csharp
[Route("api/[controller]")]
[ApiController]
public class AuthController : ControllerBase
{
    [HttpGet]
    [AllowAnonymous]
    public IActionResult Login(CancellationToken cancellationToken = default)
    {
        if (User.Identity.IsAuthenticated) // = Is User authenticated by Azure AD
        {
            try
            {
                // Check if user access is legitimate on this website, and throw UnauthorizedAccessException if not
            }
            catch (UnauthorizedAccessException)
            {
                return Unauthorized(new { Message = "You are not authorized to access to this platform." });
            }
        }
        else
        {
            // Trigger Azure AD authentication (using redirection)
            return Challenge(AzureADDefaults.OpenIdScheme);
        }
        // Redirect to home page is successfully authenticated
        return Redirect("/");
    }
}
```

## Additional comments

I was quite surprised, and believe my surprise was shared with many of my colleagues, regarding the lack of easy access to some Official Documentation explaining this workflow, which seems to me as one of the simplest way to secure access between an SPA and its API.

One important thing to note though is that this workflow requires the SPA to be served on the same domain as the API (*Which is great as the `dotnet new react` or `dotnet new angular` templates are already following this kind of architecture*), as [Cookies are scoped by `Domain` and `Path`](https://en.wikipedia.org/wiki/HTTP_cookie#Domain_and_path).

Finally, I hope this article could help you or at least let you discover another option to secure your API with Azure AD.

Feel free to show your disagreements or any other opinion in the comments or in reply to my Twitter [@vivienfabing](https://twitter.com/vivienfabing).
May the code be with you!

You can find a working sample on my [GitHub](https://github.com/vfabing/simple-aspnetcore-azuread-react).
