---
layout: post
title:  "AutoCrane: Shipping containers safely on Kubernetes"
date:  Wed, 14 Oct 2020 14:14:38 -0700
tags:
  - autopilot
  - kubernetes
---

Kubernetes is the winning open source, cloud native orchestrator for
running containers. It's supported by anyone that's anybody selling
cloud compute. Unfortunately, the default primitives it gives you are
very low level for running complicated services. Fortunately, it's
very extensible, which I believe is one of the keys to its success.

Microsoft has an internal technology called
[Autopilot](https://www.microsoft.com/en-us/research/publication/autopilot-automatic-data-center-management/)
that runs in their data centers. They are both orchestrators. With
Autopilot you explicitly group a set of services to run on a number of
machines, but with Kubernetes you generally don't tell it which nodes to
schedule your pods on.

When rolling out your application, Kubernetes uses deployment objects
to scale up and down replica sets to roll out new versions of your
application. Out of the box, there aren't many options for failing a
deployment other than your service crashing so hard that the rollout
times out. And then there is no rollback function, so you need to take
manual action. This seems like a pretty big gap for someone that wants
to run a highly reliable service, so they might turn to a third-party
solution like [Flagger](https://flagger.app/) (I haven't used it) to
provide safer canary releases with rollbacks and feedback.

But that's not the only feature gap you might notice running on
out-of-the-box Kubernetes. What if your service encounters some sort
of error state after the rollout is finished--suppose it's not able to
refresh some external data or an availability monitor on another
machine is not getting the expected response?
The readiness and liveness pings don't have a concept of failing
limits. If all of the containers go into an error state at once,
either your load balancer will stop routing to them all or Kubernetes
will restart them all. Both of those would be undesirable. Maybe you
need to find some plugins that let you post status and then evict pods
up to a PodDisruptionBudget. I'd be curious if there are popular tools
doing this.

What if you want to sync data into a bunch of your containers? Do you
run a daemonset to copy them to local storage? A sidecar with
[git-sync](https://github.com/kubernetes/git-sync)? How do you do
safe, automatic, staged rollouts using watchdog feedback to decide
whether to progress or not? Do you update deployment specs, config
maps, or volume claims? What if you don't want your service to restart
because you have 20 data sources and you'd probably have the same
number of data deployments an hour?

The previous paragraphs pointed out deficiencies in Kubernetes but
made no mention of Autopilot. That's because Autopilot provides a
holistic solution to all of these issues.

I'd like to propose a solution where we borrow some of the best
practices of Autopilot when it comes to shipping containers on
Kubernetes. I'm proposing we call it AutoCrane. (Auto from Autopilot,
Crane because it would move shipping containers...) The goal would be
to implement solutions for:

  - Automatic, staged application rollouts/rollbacks using
    watchdog feedback.
  - Storing and viewing watchdog status on a per-pod basis.
  - Restarting pods with an error-level watchdog up to a configured
    failing limit (PodDisruptionBudget).
  - Implement safe and automatic data delivery/deployments (using the
    same watchdog feedback as in app deployments).
  - Monitoring and alerting on the above.

There are probably some questions I need to research first: would
AutoCraneDeployments use replicasets under the hood? Should I store
watchdog status in a pod's `status.conditions`? How I should manage
state, etc. But I think one thing is clear: Data deployments,
application watchdogs, and a safer canary rollout/rollback strategy
aren't just needs of Windows Live Search or Hotmail, they're good
practices that anyone running on Kubernetes could benefit from.
