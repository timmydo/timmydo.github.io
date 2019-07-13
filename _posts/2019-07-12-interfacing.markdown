---
layout: post
title:  "Interfacing"
date:   Sat, 13 Jul 2019 04:38:13 +0000
tags:
  - dependencies
  - software development
  - interfaces
---

[In Soviet Russia](https://knowyourmeme.com/memes/in-soviet-russia), you don't take dependencies on a software library, software libraries take a dependency on you.

Every time I start using a new library (whether it's third-party or something I write myself) in a project I'm working on, I like to define a minimal set of functionality I need in an interface, then implement that interface using the library I selected.

Occasionally there comes a time when a library needs to be replaced, and the person doing it will be thankful that they only have to implement a handful of methods using a new library. They would be less amused if your interface had gratuitous functionality or was too closely aligned with the software library you chose at the beginning. Be careful that your interface doesn't expose the types from the library you're using.

The primary reason for this abstraction isn't so that your successor can replace the library later with less effort, it's so that you can test your code easier. It's common to use a dependency injection/inversion of control design pattern here. Then you can mock the library or implement the interface in another manner and do unit tests easily on your business logic.