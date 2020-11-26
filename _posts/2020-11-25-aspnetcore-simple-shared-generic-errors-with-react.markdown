---
layout: post
title:  "ASP.NET Core: Simple shared generic errors with React"
date:   2020-11-25 13:37:00 +0200
categories: [react]
tags: [dotnet, aspnetcore, react, axios, middleware, swagger, openapi]
comments: true
---

Given an ASP.NET Core React app, sometimes you might want to throw some errors from any API endpoint, and be able to handle them gracefully in your Front end.
For generic well known errors (401, 403, 404, etc.), the API part is pretty simple and a generic Front end handler system such as [axios interceptors](https://github.com/axios/axios#interceptors) should do the job quite well.

But what if you wanted to provide some business details to enhance your generic `Bad Request` errors and be able to tell "What was bad" and how to correct it, while still keeping all this handling generic to any HTTP call in your application?

Well let me show you a simple version of the system implemented with the help of my great colleagues [Thomas](https://thomaslevesque.com/) and [Zack](https://blogs.infinitesquare.com/users/zkonate).

# Foreword: Standardizing errors output with `ProblemDetails`?

How are we going to handle the errors in our app? Classical question when you start a new project, isn't it?

Well since ASP.NET Core 2.2, the [Problem Details](https://docs.microsoft.com/en-us/aspnet/core/web-api/?WT.mc_id=DOP-MVP-5003680&view=aspnetcore-5.0#problem-details-for-error-status-codes) format (*based on the [RFC 7807](https://tools.ietf.org/html/rfc7807)*) became the standard response for errors (*for status code >= 400*), and this system could give us some answers our previous question.

Example of the JSON produced for a `404` error using a `ProblemDetails`:
```json
{
  type: "https://tools.ietf.org/html/rfc7231#section-6.5.4",
  title: "Not Found",
  status: 404,
  traceId: "0HLHLV31KRN83:00000001"
}
```

The main purpose of the `Problem Details` standard is to provide an `easy to understand`, `standard` way of defining our errors details.
Moreover, the implementation in .NET possesses a [ProblemDetails.Extensions](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.mvc.problemdetails.extensions?WT.mc_id=DOP-MVP-5003680&view=aspnetcore-5.0) Property which will allow us to provide our additional details.

But enough talk, let's see what the ASP.NET Core part looks like:

# ASP.NET Core generic error handling with `Mvc.Filters` and `ProblemDetails`

So what we want is a way to catch our exceptions and have the opportunity to customize/enhance our `Problem Details` exceptions before they are returned to the Front end.
For this, we could have implemented a custom `ProblemDetailsFactory` as suggested by the [documentation](https://docs.microsoft.com/en-us/aspnet/core/web-api/handle-errors?WT.mc_id=DOP-MVP-5003680&view=aspnetcore-5.0#implement-problemdetailsfactory).
But since we were more familiar with the `Mvc.Filters` and didn't encounter any problem so far (*and it stayed quite simple, as described in the blog title ;)*), I'll show you the steps which are need for this solution:

## Define our custom `Mvc.Filters`
So basically, we just need to implement the `IExceptionFilter` interface and define the `OnException` method to return our `ProblemDetails` according to the type of `Exception`  raised:
```csharp
public class MyAppErrorFilter : IExceptionFilter
{
    public void OnException(ExceptionContext context)
    {
        if (context.ExceptionHandled)
        {
            return;
        }

        var result = context.Exception switch
        {
            EntityNotFoundException _ => context.CreateErrorResult(ApiErrorCode.EntityNotFound),
            InvalidStatusChangeException ex => context.CreateErrorResult(ApiErrorCode.InvalidStatusChange, additionalDetails: new { ex.AllowedStatus }),
            _ => null
        };

        if (result != null)
        {
            result.DeclaredType = typeof(ProblemDetails);
            result.ContentTypes.Add("application/problem+json");
            context.Result = result;
            context.HttpContext.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            context.ExceptionHandled = true;
        }
    }
}
```

The `switch` is in charge of generating the `ProblemDetails` by calling a custom `CreateErrorResult` extension method which will be done by using the `ProblemDetailsFactory` and adding 2 custom properties: 
- `code`: An `ApiErrorCode` enum which will help us to get a simple way to define the type of error from the Front end, 
- `additionalDetails`: An `object` representing any additional information to get a better understanding of the error, such as a list of [`AllowedStatus` in our example](https://github.com/vfabing/simple-aspnetcore-react-shared-generic-errors/blob/066aec6f3ed0f8e8c1e98f15c43deaf54f8f53e7/ErrorHandling/MyAppErrorFilter.cs#L20)

Here is the `ApiErrorCode` enum as well as the `CreateErrorResult` extension method:
```csharp
public enum ApiErrorCode
{
    Unknown,
    EntityNotFound,
    InvalidStatusChange
}
```
```csharp
public static class ErrorHandlingExtensions
{
    public static ObjectResult CreateErrorResult(this ActionContext context, ApiErrorCode errorCode, object additionalDetails = null)
    {
        var problemDetailsFactory = context.HttpContext.RequestServices.GetRequiredService<ProblemDetailsFactory>();
        var problemDetails = problemDetailsFactory.CreateProblemDetails(context.HttpContext, statusCode: (int?)HttpStatusCode.BadRequest);

        problemDetails.Extensions["code"] = errorCode;

        if (additionalDetails != null)
        {
            problemDetails.Extensions["additionalDetails"] = additionalDetails;
        }

        return new ObjectResult(problemDetails);
    }
}
```
> *Disclaimer: In this example, the ASP.NET Core `ProblemDetails` is used but is not following all the best practices described in the [RFC](https://tools.ietf.org/html/rfc7807) for the sake of simplicity.*

## Registering our custom `Mvc.Filter`

For the final touch, we just need to register our filter in the `ConfigureServices` of our `Startup.cs` file:
```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddControllersWithViews().AddMvcOptions(options =>
    {
        options.Filters.Add<MyAppErrorFilter>();
    })
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter(options.JsonSerializerOptions.PropertyNamingPolicy, false));
    });
}
```
> *Note: For a better readability of our `ApiErrorCode` enum, we also added the `JsonStringEnumConverter` to use our enum through `string` values rather than `int`*


## API result
With all of this implemented, we should now get the following error result from our API:

![02a-generic-error-with-payload](/assets/2020-11-25/02a-generic-error-with-payload.png)

Alright with all of this setup, what we are left now is to see how we can handle these errors in our Front end.

# Interacting with APIs and intercepting errors using `axios`

`axios` library is pretty common when it comes to handle API calls, and one thing that I personnally like is it's [interceptors](https://github.com/axios/axios#interceptors) implementation.

This will allow us to handle the errors returned by the API, and more specifically our generic errors.

The code necessary for this should be quite straightforward:

```ts
let axiosInstance = axios.create();

axiosInstance.interceptors.response.use((response: AxiosResponse<any>) => {
    return response;
}, (error) => {

    const problemDetails: ProblemDetails = error.response.data;
    
    switch (problemDetails.code) {
        case ApiErrorCode.EntityNotFound:
            toast.error("EntityNotFound!");
            break;
        case ApiErrorCode.InvalidStatusChange:
            toast.error(`Invalid Status Change! Allowed status: ${(problemDetails.additionalDetails.allowedStatus as string[]).join(', ')}`);
            break;
        default:
            // Do nothing and let specific custom business exception handling.
    }
    
    return Promise.reject(error);
});
```

In this example, we add an `interceptor` to an `axios` instance, and provide the `error` handling part:
- We first retrieve our `ProblemDetails` from the error response
- Then we lookup for the `code` property which gives us the type of error raised, and we can treat our generic error as we want (we display a toast notification in this example)
- Notice on the `InvalidStatusChange` error that we can also customize our error handling by looking at our `additionalDetails` property which gives us more details and information to act properly
- Finally, if the error is not one of our "generic errors", we just do nothing and rethrow it to let our app handle it by itself (maybe for more custom non generic error, page specific, etc.)

Also to make it easier to use, we could also wrap all of this configuration into a custom React hook such as:

```tsx
type AxiosContext = { axiosInstance?: AxiosInstance };
const initialContext: AxiosContext = { axiosInstance: undefined };
const AxiosReactContext = createContext<AxiosContext>(initialContext);

// 1 component to define an Axios Instance in a Context
export const AxiosProvider: React.FunctionComponent<{ children: ReactNode }> = (props) => {

    const contextValue: AxiosContext = useMemo(() => {
        let axiosInstance = axios.create();

        axiosInstance.interceptors.response.use(
            ... // configure axios interceptor as above
        );

        return { axiosInstance };
    }, []);

    return (<AxiosReactContext.Provider value={contextValue}>
        {props.children}
    </AxiosReactContext.Provider>)
}

// 1 custom hook to access the Axios Instance from the Context

export const useAxios = () => useContext(AxiosReactContext).axiosInstance;
```

In this example, I define a custom React hook in which I configure the interceptor as described above and expose it through the React [Context API](https://reactjs.org/docs/context.html).

Then we only need to define it in our `App.tsx` file as below :
```diff
+import { AxiosProvider } from './custom-hooks/useAxios';

export default class App extends Component {
  static displayName = App.name;

  render() {
    return (
      <Layout>
+        <AxiosProvider>
          <Route exact path='/' component={Home} />
          <Route path='/counter' component={Counter} />
          <Route path='/status' component={Status} />
          <Route path='/fetch-data' component={FetchData} />
          <ToastContainer position="bottom-right" />
+        </AxiosProvider>
      </Layout>
    );
  }
}
```

And then use it anywhere in our app to call APIs like this:
```tsx
const axios = useAxios();

useEffect(() => {
  (async () => {
    if (axios) {
      try {
        let result = await axios.get("/weatherforecast/1");
        console.debug("result", result);
      } catch (error) {
        console.error("error", error);
      }
    }
  })()
}, [axios]);
```

![02b-generic-error-with-payload](/assets/2020-11-25/02b-generic-error-with-payload.PNG)

And Voilà! we can now call freely any API from our `React` app without worrying about handling any generic error which could occur :)

# In conclusion
That's all for this article, I hope it could provide you with some idea if you were looking for a similar solution. 
As it is a pretty common problem, I am expecting that you have encountered/implementer other systems. Feel free to share your solutions in the comments, and as usual you can reach me on Twitter [@vivienfabing](https://twitter.com/vivienfabing).

# Bonus: Add swagger to this solution

To get a nice description of our generic error handling (*and especially of our `ProblemDetails` custom extensions*) in swagger like this:

![03-generic-error-with-swagger-support](/assets/2020-11-25/03-generic-error-with-swagger-support.PNG)

We need to add a custom `ISchemaFilter` to our swagger configuration as described in the following `commit`:  
https://github.com/vfabing/simple-aspnetcore-react-shared-generic-errors/commit/c5ab26dc9f6f0ad8e71d19100f5c1f3c5ffc52f4

You may ask why focus so much on getting a nice description in our swagger system, well all of these efforts could help "generate" automatically some code and be able to share very easily our models and API clients... But this is a subject for another blog article :)

Till then, May the code be with you!
