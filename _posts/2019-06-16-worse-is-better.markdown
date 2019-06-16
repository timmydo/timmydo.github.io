---
layout: post
title: "Worse is better"
date: Sun, 16 Jun 2019 20:53:43 +0000
tags:
  - worse is better
  - KISS
  - DRY
  - SOLID
  - monolith
  - microservices
---

A couple of weeks ago when arguing the merits of microservices vs monoliths in the office, I decided to go back and read a couple of famous blog posts:

  - [Worse is Better](https://www.jwz.org/doc/worse-is-better.html)
  - [EINTR and PC loser-ing (The "Worse Is Better" case study)](http://blog.reverberate.org/2011/04/eintr-and-pc-loser-ing-is-better-case.html)


I think of Worse is Better as taking KISS (keep it simple, stupid) to concept the max, and only invest in something when it's broken. I think part of the reason this works well is because it aligns well with how many businesses invest in software development. If you were to wait until you had a perfect product to release, you'd either be too late or you'd run out of money getting there.

One comment I read on [Hacker News](https://news.ycombinator.com/news) recently that I liked was along the lines of: _"Good software is software that is easy to replace."_ I think this goes well with the KISS, single responsibility principle, and worse is better (there are simple interfaces if it's easy to replace).

It also reminds me of this thread: [How is GNU `yes` so fast?](https://www.reddit.com/r/unix/comments/6gxduc/how_is_gnu_yes_so_fast/?st=j3v3iw3c&sh=5651ea3c) Given that it's a one-page program that is easily replaceable, you can have two wildly different implementations:
  
  - Fast: [GNU Coreutils version](https://github.com/coreutils/coreutils/blob/master/src/yes.c)
  - Simple: [OpenBSD version](https://github.com/openbsd/src/blob/master/usr.bin/yes/yes.c)

