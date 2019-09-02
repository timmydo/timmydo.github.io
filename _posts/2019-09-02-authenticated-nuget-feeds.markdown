---
layout: post
title:  "Authenticated Nuget Feeds Inside Docker"
date:  Mon, 02 Sep 2019 23:02:10 +0000
tags:
  - nuget
  - docker
  - pipelines
  - devops
---

If you are working with .NET Core, containers, and Azure DevOps Pipelines (or whatever they are called now), you may come across a common scenario where you are using private Nuget packages and you need to restore them from inside a Docker container. There is a [related thread on GitHub here](https://github.com/microsoft/azure-pipelines-tasks/issues/6135). The devops pipeline yaml file uses `sed` to update a `nuget.config` on the fly with credentials from the build agent.



Here is a sample `nuget.config` that would be checked into the base of your repository. On your devbox, it could be used as-is without credentials in it.

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="myrepo" value="https://X.pkgs.visualstudio.com/_packaging/XYZ/nuget/v3/index.json" />
    <add key="NuGet" value="https://api.nuget.org/v3/index.json" />
  </packageSources>
</configuration>
```


Here is a sample `azure-pipeline.yaml`:

```yaml
name: "$(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)"

resources:
- repo: self

variables:
  fullImageName: 'X.azurecr.io/XYZ:$(Build.BuildId)'

stages:
  - stage: stage1
    displayName: "Build XYZ"
    jobs:
      - job: myjob
        displayName: "Docker images"
        pool:
          vmImage: 'Ubuntu-16.04'
        steps:
          - bash: |
              set -exo pipefail
              sed -i 's;</packageSources>;</packageSources><packageSourceCredentials><myrepo><add key="Username" value="any" /><add key="ClearTextPassword" value="$(System.AccessToken)" /></myrepo></packageSourceCredentials>;' nuget.config              
              docker build --file Dockerfile --tag $(fullImageName) .
            displayName: 'Build Docker images'

          - task: Docker@1
            displayName: push docker image with build tag
            inputs:
              command: push
              azureContainerRegistry: 'X.azurecr.io'
              azureSubscriptionEndpoint: 'X'
              imageName: $(fullImageName)
```

Here is a sample `Dockerfile` (There is nothing special here):

```
FROM mcr.microsoft.com/dotnet/core/sdk:3.0 as build
WORKDIR /app/myapp
COPY . .
RUN dotnet publish myapp/myapp.csproj -c release -r linux-x64 -o /out/build


FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.0 as runtime
WORKDIR /app/myapp
COPY --from=build /out/build/* ./
ENTRYPOINT [ "./myapp" ]
```