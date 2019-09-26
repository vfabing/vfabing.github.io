---
layout: post
title:  "Docker : .NET Core container automated tests from Azure Pipelines"
date:   2019-09-26 13:37:00 +0200
categories: [docker]
tags: [docker, dotnetcore, azure-pipelines, tests]
comments: true
---

## Next step after building a container: running automated tests from it
After getting your Docker build automated in Azure Pipelines (by following the article [Optimize ASP.NET Core SPA container with Visual Studio]() for instance :), you are now wondering how could you automatize the execution of your tests in this Pipeline ?

Well let's see now 2 ways of achieving this:

## Easiest way to run tests from a container: Run them during the build!

First way is also the simplest: like you would do with a normal non-dockerized build, you could just run your tests in your container right after building your solution. You could then get the test results from your container using the `docker cp` command and upload them to your Azure Pipeline (and make it fail probably :))

Although this technique is pretty straightforward, 2 things are actually bothering me :
- Having tests results inside my production container (*because you need them to stay in your container in order to be to copy them outside and upload them on Azure DevOps*),
- And being unable to separate the Build execution from the Test execution (*Not that much of a problem, but there are times when you just want to build and run your container, without always having to execute the test necessarly*).

Well it bothered me until I was told about multistage docker builds and especially about targeting a particular stage! Let's see about this in details.

## Generating 2 images: One for test and one for production using multi stage docker builds

I was already using multi stage docker builds, in particular for getting a clean production image, not polluted by all the tools necessary for building my application.
However I didn't know that I could target a special stage and stop the build at the end of that same stage!

Great finding! With this in mind, we are now able to launch 2 Docker builds:
- One pretty short, with just enough to run the tests
- And another with all the packaging and cleaning, necessary to produce a nice production image.

Cherry on the cake: thanks to the system of Docker build layers cache, all of the steps performed during the first build will be almost instantaneous when performed again in the production build as the steps cache will be used!

So let's resume the global workflow of this approach:
- Build an image targeting the "Test" stage
- Run the container triggering the test executions
- Copy the tests results from the container to the build agent directory
- Publish the test results to the Azure Pipelines and make stop the build if any test fails
- If all tests are fine, build the production image and push it to your registry

![01-multi-stage-docker-build-with-azure-pipelines](/assets/2019-09-26/01-add-docker-support-to-aspnetcore-react-project.png)

## Add a Test stage in the Dockerfile to run the tests and get the tests results
Let's take our exiting `Dockerfile`, and just before the `dotnet publish` step, let's add a new stage:
```Dockerfile
FROM build AS test
WORKDIR /src
ENTRYPOINT ["dotnet", "test", "--logger:trx", "--results-directory", "/testsresults"]
```

This instruction will run the `dotnet test` command at the container execution, producing `.trx` tests results files inside of the `/testsresults` directory of the container.

Then you will need to run the following command lines to build your container targeting the `test` stage, launch the container thus starting the tests execution, and then copy the tests results from the container to the current directory:

```cmd
docker build -t myimage-test --target test .
docker run -i --name mycontainer-test myimage-test
docker cp mycontainer-test:/testsresults .
```

![02-run-tests-from-docker](/assets/2019-09-26/02-run-tests-from-docker.png)

You should then be able to upload all the `.trx` files to the Azure Pipelines, storing tests history, enabling to fail the build, etc.

![03-run-docker-tests-from-azure-pipelines](/assets/2019-09-26/03-run-docker-tests-from-azure-pipelines.png)

For building the production image, you just need to build your `Dockerfile` without targetting any stage (Visual Studio Dockerfile is already using multi-stage builds to get a "clean` production image :))

## Store your tests results outside of the build workspace to optimize Docker cache

As it is right now, the tests results are stored directly in the build workspace, which is an easy way to manipulate them, but prevent Docker for reusing some cache as during the `COPY . .` step, Docker will copy your tests results inside of your container, thus detect change and rebuild your project...

So in order to prevent this behaviour, one simple way is to store the tests results outside of the workspace, or more precisly one folder upper in the hierachy. 
To do that we just need to change the following line:

```diff
-docker cp mycontainer-test:/testsresults .
+docker cp mycontainer-test:/testsresults ../
```

And then modify the `Publish Tests Results` task `Search folder` to look for in `$(Agent.BuildDirectory)` which is the folder above where the source code is pulled.

![04-store-tests-results-outside-the-workspace-to-optimize-docker-cache](/assets/2019-09-26/04-store-tests-results-outside-the-workspace-to-optimize-docker-cache.png)

## To go further

To go further, we could also add the JavaScript tests results as well, which mainly consists in:
- Adding a test framework such as [jest](https://jestjs.io/)*, as well as a reporter to produce JUnit tests results such as [jest-junit](https://www.npmjs.com/package/jest-junit)
- Instead of just running the dotnet test using `ENTRYPOINT ["dotnet", "test", "--logger:trx", "--results-directory", "/testsresults"]`, you could now use a script file using `ENTRYPOINT ["sh", "./run-tests.sh"]` which would enable you to run dotnet and javascript tests
- Add another `Publish Tests Results`, this time configured with `JUnit` Test result format

I hope this short article gave you some ideas about how to deal with your tests in your Docker project.  

As usual, you can find a working example on [Github](https://github.com/vfabing/docker-aspnetcore-react/tree/d997da1db216841ad0817a9fce4350365771bd56)

Next time I would like to give a practical example of adding https to a aspnetcore docker container as it is not so trivial all the time.

Feel free to reach me out on twitter or anywhere else, and May the code be with you!
