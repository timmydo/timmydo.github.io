---
layout: post
title:  "Unresponsive .NET Web Applications and the Mysterious ThreadPool"
date:  Sat, 28 Sep 2019 10:40:51 -0700
tags:
  - async
  - await
  - threadpool
  - .net
  - asp.net
---

I'm not going to claim to be an expert on the matter, but I'm hoping some of my recent experiences can help others. The premise is like this:

> My C# web application is becoming unresponsive. Kubernetes marks instances as non-ready and takes them out of rotation because they fail to respond the readiness probe in 10 seconds. Once that starts happening, it's a negative feedback look as more and more instances start failing. Then the application can't recover because the traffic is too high. **I use async/await everywhere I can, but it's possible that a synchronous network call to something happens during some requests--after all it's a large app.**

There are a couple of things you might initially do:

  - Add circuit breakers at the app level. That is, tell the web server to not handle more than X concurrent requests because you know it won't be able to handle that many. In ASP.NET Core land, this might be setting the Kestrel max connection count. If it gets to that point, you want this to be taken out of load-balancer rotation. `kubernetes describe` will now show that the non-ready pod rejected the request rather than a timeout. Hopefully you have upstream monitoring to count the rejected requests.
  - Add circuit breakers at a higher level. Don't let the individual instances get more than X concurrent requests so that you won't hit a point where you can't recover because there is too much traffic. If you are getting a thousand requests per second and you have 0 ready pods, the first pod that becomes ready will get nailed by a burst of traffic and become unresponsive again. This will allow the service to get back up if it goes down.


You do the above, but you are still getting timeouts here and there. _You don't always see the timeouts on the liveness ping, it may show up elsewhere._  What's next? Learning more about how the .NET ThreadPool creates new threads. In particular, read [about System.Threading.ThreadPool.SetMinThreads](https://docs.microsoft.com/en-us/dotnet/api/system.threading.threadpool.setminthreads?view=netcore-3.0)

Here is my understanding:

  - The default minimum worker thread count on .NET Core 3.0 is set to [Environment.ProcessorCount](https://docs.microsoft.com/en-us/dotnet/api/system.environment.processorcount?view=netcore-3.0). A value that maximizes your app's usage of the CPU if your code is perfectly asynchronous.
  - Until you hit the minimum worker thread count, new worker threads are created instantly.
  - After you hit the minimum worker thread count, new worker threads are created using an algorithm that **tries to protect you from creating too many threads by injecting a delay**
  
_For the purposes of this explanation_, suppose we have a web app that behaves like this:

  - Every request makes a network call to a backend that takes 2 seconds to complete.
  - We are running on a 4-core CPU machine and the ThreadPool minimum worker thread count is 4.
  - We get 10 requests per second, they all happen at the beginning of the second.
  - The .NET algorithm waits a second before creating a new thread if you are above the min thread count. (It might actually be half a second?)
  
  
  Here is how this might look if each 10 requests per second come in at the beginning of each the second:

  - Request 1: Starts at t=0. Returns at t=2 
  - Request 2: Starts at t=0. Returns at t=2 
  - Request 3: Starts at t=0. Returns at t=2 
  - Request 4: Starts at t=0. Returns at t=2 
  - Request 5: Starts at t=0. Returns at t=3 (waits 1 seconds for thread creation)
  - Request 6: Starts at t=0. Returns at t=4 (waits 2 seconds for thread creation)
  - Request 7: Starts at t=0. Returns at t=5 
  - Request 8: Starts at t=0. Returns at t=6 
  - Request 9: Starts at t=0. Returns at t=7 
  - Request 10: Starts at t=1. Returns at t=8 
  - Request 11: Starts at t=1. Returns at t=9 
  - Request 12: Starts at t=1. Returns at t=10 
  - Request 13: Starts at t=1. Returns at t=11 (10 second latency!)

In this fake example, you can see after one second how requests to our app start to take more than 10 seconds, even if our backend returns in 2 seconds, just because of synchronous calls and thread creation delay. On top of that, it won't recover because the concurrent number of request the app needs to handle grows over time. This mechanism that is supposed to protect us from creating too many threads actually hurts our app here!

If, instead, our minimum worker thread count was set to 25 (request latency × requests/second + buffer), all of the requests take 2 seconds and the first ones will finish before we hit the throttling algorithm. Moral of the story is that you might want to call `ThreadPool.SetMinThreads` at the beginning of your program to an appropriate value if synchronous code is executed on some of your requests. **It's not just failure to respond to incoming requests that expose this issue--that's when things have really gotten bad. You may start by seeing timeouts happening mid-request because a worker thread took too to get scheduled again.**

It's a good idea to have metrics covering these. You can use `ThreadPool.GetAvailableThreads`, `ThreadPool.GetMaxThreads`, `ThreadPool.GetMinThreads`, and calculate these:

```
workerThreadInUse =  workerThreadMax - workerThreadAvailable;
workerThreadFree = workerThreadMin - workerThreadInUse;
```

You might be running low on capacity when `workerThreadFree` is low or CPU is high.
