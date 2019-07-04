---
layout: post
title:  "Docker for the build agent"
date:   Thu, 04 Jul 2019 18:32:43 +0000
tags:
  - docker
  - containers
  - devops
---

Here's a conversation I made up:

> Hey Chris, could you create me a devops pipeline so I can build my .NET Core 2.2 app? I'll need the SDK installed so I can run `dotnet build`.

_Chris: Sure, I'll get right on that._

> Hey Chris, uh, I need to build my app with .NET Core 3.0-preview1234, could you also make sure that's on the build agent?

_Chris: 2.2 won't work for you anymore? Ok..._

> Hey Chris, so they recently made this awesome addition and I want the latest SDK, could you just make it so I can install whatever SDK I want?

_Chris: Of course, I'll create a 'install SDK' build task! Then you won't need to keep asking me!_

> So, Chris... I need you to create a build agent with WSL installed, so that I can install cmake, clang-3.9, libicu-dev, uuid-dev, libcurl4-openssl-dev, zlib1g-dev, libkrb5-dev, and wget. I want to use [CoreRT](https://github.com/dotnet/corert) to build binaries for running on Linux.

_Chris: You know that the Windows Server 2016 build agents don't support WSL, so I'll need to create a new Windows Server 2019 build agent pool and setup the WSL installation with all those tools by running some apt-get commands. If they aren't in the default WSL distro, I'll just add a custom apt source and pull them from there. But what if someone else wants on a different version of /usr/bin/clang or some other tool on the install? Would you like me to create multiple instances of WSL with different packages installed?_


Ok, so I made all that up, but it might be based on real life events. What if we could change Chris's response to each of those questions with, __"Why don't you use docker? It's already installed on all the build agents."__

_Wouldn't that be nice?_

What are [Docker containers](https://www.docker.com/resources/what-container) you ask? Let me tell you since you won't click the previous link. Just imagine that it's a zip file with an app inside that is stored in a container registry, which is just a fancy word for a URL with the name and version. You can use [Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) and `docker build` to create new containers (_read: packaged applications_) with your favorite apps or tools, or you can use containers that other people made to run their software (`docker run`). It's convenient for a build pipeline that wants to have all the tools available and easily accessible, but not interfering with one another.

Here is an example:

```sh
λ docker run -it --workdir=/app mcr.microsoft.com/dotnet/core/sdk:2.2-alpine /bin/sh -c "dotnet new console && dotnet run"
Getting ready...
The template "Console Application" was created successfully.

Processing post-creation actions...
Running 'dotnet restore' on /app/app.csproj...
  Restore completed in 140.23 ms for /app/app.csproj.

Restore succeeded.

Hello World!
```

In practice, you might want to run docker with the `-v` flag to mount volumes. For example, your devops pipeline downloads the latest source code or build artifacts, then you `docker run -v $(pwd):/blah some-container command-to-run /blah`. This way, you run the application with the files from the host system rather than just what's in the container. Docker is also a handy way to [set up a dev environment](/2019/06/11/blogging-github-pages-jekyll.html).