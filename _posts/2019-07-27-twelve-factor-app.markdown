---
layout: post
title:  "The Twelve-Factor App"
date:   Sat, 27 Jul 2019 13:46:14 -0700
tags:
  - twelve factor app
  - software development
  - design patterns
---

### Overview

There is a great website that tries to outline good practices you should use when creating software services. It's called [The Twelve-Factor App](https://12factor.net/). It's written with a Ruby/Python/Heroku point of view, but the concepts are still relevant to those using other technologies. I thought I'd read through the twelve factors again and leave my own impressions. For a while now I've wanted to add my own ideas to this list, so I'll take the opportunity below.

#### Codebase

Summary: Use a version control system such as git with one app per git repository. Put shared code into libraries and use a dependency/package manager.


This is fairly straightforward. As a counter argument to one-to-one source code repository to app, there are some companies who have had success with [monorepos](https://gomonorepo.org/). If you aren't a very large software company that can invest in the right tooling, it's probably better to stick with the one-to-one approach. It's probably harder to adopt open-source and train people if you have a lot of custom tooling around managing a monorepo.


#### Dependencies

Summary: Explicitly declare dependencies in a manifest file. Minimize build dependencies and have a build command that can build your app. 

Having a dependency manifest is pretty common now in 2019. Apps with a build command that works on a minimal setup--maybe not as common. [See number 2](https://www.joelonsoftware.com/2000/08/09/the-joel-test-12-steps-to-better-code/)

There should be a corollary here: _you should also be able to run the app with a single command or button press_.

#### Config

Summary: Don't store config in code, use environment variables for config, don't use config groups such as 'dev', 'staging', 'prod'.


I'm not sure I fully agree with this. Here is how I have done it:
  - Use _layered_ grouped configuration in files along with the app source code for most app config (e.g. config.ini, config.dev.ini)
  - Allow environment variables to override file-based configuration (allows for live changes without going through the build/test pipelines)
  - Storing config templates in a source code repository that produces deployment config as a part of a separate deployment build step. For example, this might produce `config.prod.eastus1.ini` which takes precedence over `config.prod.ini` and `config.ini`.

#### Backing services

Summary: You should be able to change config to connect to a different database. You shouldn't need a code change to do that.

I agree here. I'm a believer that most teams shouldn't be doing their own database work in 2019--just use a cloud provider and keep your platform stateless.

#### Build, release, run

Summary: Separate build and release pipeline.

You should have a build pipeline that produces build artifacts. Then have a release pipeline that takes those artifacts and the release config and tells your infrastructure to run it. Example: a build pipeline that builds docker images and pushes them to a container repository, and a release pipeline that runs `kubectl apply` on your yaml config files.

#### Processes

Summary: Applications are stateless and share nothing between each other.

I agree, managing a stateful service is more more involved and for most teams it makes sense to outsource the database to a cloud provider as I mentioned above.

#### Port binding

Summary: Use port binding to expose services. Basically, if you app is a web service, you should provide the web server part rather than relying on another interface or SDK (such as an apache module).

I agree--this makes your app more orchestrator agnostic. Containers talk over networking protocols, so I think this is a good abstraction layer.

#### Concurrency

Summary: You app should follow a process model where running your app is like running a single process. This makes it easier to scale out.

I agree your app should ideally be made up of single processes that can scale independently.

#### Disposability

Summary: Your app should start fast and stop fast (when asked--through a signal). In the face of sudden termination, batch processors should use a robust queuing backend that lets them restart where they left off if they didn't finish processing items.


This probably doesn't get enough testing from most people. Does your web server/orchestrator/load balancer work together to drain connections properly during rollouts or failures in specific replicas?

#### Dev/prod parity

Summary: Keep environments as similar as possible. Sounds like common sense.

#### Logs

Summary: Write events one per line to stdout. The app shouldn't concern itself with how it's logs are stored.


Agreed. The orchestrator infrastructure or service mesh should take care of it.

#### Admin processes

Summary: Ad-hoc admin processes that are run in prod should be run from the same build/release bits as the rest of the app.


Agreed. Ideally you are able to set up functionality in your app to do these so an admin doesn't need to log into a prod machine and manually run scripts.


### Add-ons

This post has already gotten longer than I hoped. But I want to add some more 'factors' of my own below.


#### Style requirements

Enforce code-style requirements through build and fail builds if the style or coding guidelines aren't met. Don't rely on pull request comments to enforce.

#### Pull requests

When using a source control system like git, you'll have 'pull requests' so developers can merge their changes with the master branch. They shouldn't be able to push their changes directly to master. You should have prerequisites such as: at least one other approver, build and tests pass, linked work items, etc. Squashing and merging by default is a good way to keep the history clean.

#### Watchdogs

You'll have an endpoint on your service which tells the load balancer whether it should serve traffic to a particular instance of your service, and maybe another to determine if your service is alive. You should do more than just always return `200 OK` for these--think about what your app needs to work properly. If you've received a signal to shut down, you'd probably want to return `503`.

#### Secret storage

If your app orchestrator can store a bootstrap secret for decrypting other secrets, you should probably use that, otherwise you could use an environment variable. When your app runs it would use the bootstrap secret to decrypt connection strings, etc.

You should have auto-rotation configured on keys/secrets/certificates that expire. If for some reason that can't work, there should be phone alerts starting months out with instructions on how to renew them. If it's done every two years, you might be lucky to have someone on the team that has done it before.

#### Monitoring

Your service should have an endpoint which _internally_ exposes metrics in a [human readable format](https://prometheus.io/docs/instrumenting/exposition_formats/). These are in-memory, point-in-time metrics. Another service (e.g. Prometheus) will periodically scrape this metrics endpoint into a time series database. Another service (e.g. Grafana) will provide a UI to query this database and display charts. Alerts will be set up to call someone if something is wrong.

When someone investigates an issue with the service, they will look at the logs written by your service during that time period.

You will also want availability monitoring in addition to normal reliability/latency metrics. Availability should be measured by an external service calling your app. Data absence alerts for reliability numbers are still necessary, but aren't sufficient.

Having a tracking/correlation ID that you can use to trace throughout multiple services is nice to have.

#### Tests

If you write your software using dependency injection, it should be pretty easy for you to create unit tests by mocking other parts of your application. Your build pipeline should measure test coverage.

You should have a pre-production and a canary environment. Pre-production tests your config in something that resembles prod and lets you run end-to-end tests on it before exposing changes to real traffic. It might be a good place to first test a certificate or infrastructure-related change. The canary environment handles a small portion of real-traffic to help find issues and experiment with new features that are difficult to flight behind code (see next section).


#### Flighting

You should have a way to enable or disable sections of code at runtime through a flighting service. Basically the code might be surrounded by `if featureIsEnabled("featureA", runtimeContext)`. Runtime context might provide some contextual information and you might have a simple rule engine to determine when to enable a feature. For example, you might want to enable a block of code for 1% of users in North America. Then the next stage of the flight might be 5% of NA users, and so on. Enabling, disabling, or advancing the stage should be immediate and the feature check itself shouldn't require a network request (a background thread could refresh the flight data every minute).

In general, you'd want to flight every new feature where it makes sense.

#### Infrastructure as Code

You should have your infrastructure written in code (and versioned in a source code repository) so that recreating infrastructure is as simple as running a command. You might not be in this situation if you are wondering what commands you would need to run to set up a new data center somewhere else in the world to run your app.

#### Business Continuity Plan

If your backend database suddenly disappeared, could you re-create it from backups? You don't have a BCP plan unless you've tested it.


#### Not Invented Here

Your app probably has an important business problem to solve. It doesn't need to also create its own metrics library, its own secret storage implementation, its own flighting system, its own map-reduce implementation, its own service orchestrator, etc. You might think you have special scale requirements or that you could write it better than the people who contribute to an open-source project on github. I can't hold you back if that's what you like to do.

But what you should do is have your own abstraction layer between each of these libraries you end up using, with the smallest interface possible. Then, if you need to change libraries, it should be relatively easy.