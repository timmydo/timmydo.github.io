---
layout: post
title:  "Ideas for Programming Languages"
date:  Sat, 12 Sep 2020 13:32:24 -0700
tags:
  - programming
  - golang
---

I don't have enough time to follow the latest and cutting-edge of
programming languages, but I was thinking about creating a new
programming language recently as another hobby project. I didn't have
any other ideas on what I could post, so I thought I'd take some time
to write down some thoughts...

First impressions are important, and syntax is where the first
impression is usually made. When I originally tried
[Go](https://golang.org/), I was put off by the syntax, but eventually
it grew on me. A lot of people are put off by Lisp's s-expression
syntax, but I believe that one can be overcome as well when you
realize the power of macros. I think a powerful macro system should be
a top priority for a programming language. Lisp-syntax makes it easier
to write macros that manipulate syntax trees. I'm wondering how much
of the language could actually be written as macros (`if`, `and`,
`or`, `while`, etc.)...

When you look at software, a large part of the direction it moves in
is influenced by the culture or values of the people working on
it. There are essays like [Worse is
better](https://en.wikipedia.org/wiki/Worse_is_better) that describe
cultures where simplicity is valued over correctness and
completeness. Personally, I think my design values for a programming
language would be closer to "Worse is better" than "The Right Thing."
I think the most noticeable example of such a thing wouldn't be
necessarily how you design signal handling, but rather things like
having the string type be a byte array rather than a character
array. I think I would value performance-by-default rather than
correctness-by-default.

While we are on the performance tangent, maybe I should say that I
wouldn't want to have a garbage collector. There are so many languages
that are VMs or have GCs now, and I think it's time the pendulum has
gone in the other direction. I think Rust has gained a lot of
popularity due to its ability to be safe *and* fast. I would need to
take some time to understand how the borrow checker works at a lower
level. I haven't had the chance to do any serious programming in Rust
yet.

Not having a GC might make you less likely to do needless dynamic
memory allocations. If you're not doing as many memory allocations,
the standard deviation on your performance numbers should be a lot
less. First class support for slices (like Go uses) in the language
and throughout all the standard libraries helps a lot with this. In
some programming languages, string methods like `substring` will cause
an allocation. I would like to play with those methods returning value
objects that point to the underlying array. Maybe methods like `split`
could return multiple value results instead of an array. Speaking of
which, I think multiple return values would need first-class support.

While RAII is the bread-and-butter of languages like C++ (and it makes
it livable without a GC), the possibility for control flow to not be
explicitly declared in the code (through
destructors/casting/exceptions) is a non-starter for me. While Go's
`if err != nil` everywhere is sort of annoying, I applaud it's effort
to keep code verbose and readable. I think it would be important to
have a `defer` feature like Go does. Otherwise, you'd probably need to
use a lot of `goto`, which doesn't look great in lisp syntax.


One new feature I like in C# is the ability for you to enable nullable
reference types. It reminds me of the Kotlin launch where they
introduced null safety. (They probably weren't the first but the first
that I remember specifically). Basically, the compiler can tell you if a
value you may dereference could be null, and when you can specify
whether a function can return null or not. I think that's a pretty
important feature for a language to have now.


I like Go's implicit interface support and I do not think I would want
to support inheritance. I'd probably adopt some of the Go-isms
for capital names being public, lowercase being internal, and not dive
too far into OOP. One of the danger's of OOP is that it seems to make
it harder to get zero-cost abstractions (another part of Rust's fame?).

Around my time in college, I was immensely interested in dynamic
languages and things like multiple dispatch (I worked on the Slate
programming language for a bit). After spending more time in industry,
I began to develop more of an appreciation for statically compiled
languages. I think a lot of people notice it when moving from
Javascript to Typescript, because refactoring code becomes a lot
easier. Unit tests are also really important.


In summary:

  - Lisp syntax and first-class macro support
  - No GC
  - Worse is better approach/Strings as byte arrays
  - Zero cost abstractions/Idiomatic code should not be slower
  - No runtime exceptions/No panics
  - Safety/Don't crash unless using unsafe code
  - Multiple return values
  - Nullable reference types with compiler checking
  - Slices instead of arrays
  - Compile-time generic methods/First-class code-generation (maybe
    using macros?)
  - No reflection (use code generation instead)
  - First class functions (investigate closure support)
  - No binary modules, must compile everything from code to a single static
    executable
  - Static type system
