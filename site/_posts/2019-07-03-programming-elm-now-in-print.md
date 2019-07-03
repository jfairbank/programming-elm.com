---
title: "Programming Elm Now in Print"
description: Programming Elm is now available in print. Learn how to build your own safe and maintainable applications with Elm.
tags: elm
---

![Person using typewriter with a cup of coffee to the side](/img/typewriter.jpg)

After 2 years, 2 months, and 29 days of waking early, sacrificing weekends, and rewriting for Elm 0.19, I can proudly say that _Programming Elm_ is now available in print! Writing this book presented a challenging, but rewarding journey that taught me a ton about writing and teaching.

If you're a front-end developer tired of the JavaScript framework churn or want to build more resilient and maintainable applications, then you need to learn Elm. I have tailored _Programming Elm_ for front-end developers new to Elm who want to quickly learn how to build maintainable applications with it. You'll start with basics such as Elm's syntax and creating functions and advance all the way to building a single-page application.

## Why Elm?

More and more front-end developers are choosing Elm to build applications for benefits such as:

* _No runtime exceptions in practice:_ Elm's compiler catches problems early to prevent exceptions at runtime for your users.
* _No `null` or `undefined` errors:_ Elm offers more versatile types for representing `null`. The compiler also ensures you handle all possible nulls in your application.
* _No JavaScript fatigue:_ You don't have to choose and wire up different frameworks and libraries to build an application. Elm has a built-in framework for creating applications, the Elm Architecture.
* _Predictable code:_ All Elm code is free from side effects, so you can trust your functions to always produce the same result based on their arguments.
* _Immutable data types:_ You don't have to worry about your code or third-party code changing data unexpectedly and causing bugs. Your data will be consistent and safe.
* _Strong static types:_ Elm's compiler uses static types to ensure you call functions with the right types of arguments. You won't run into subtle type-coercion bugs.
* _Custom types:_ Elm's custom types let you create entirely new types for clearly modeling your business domain. Powerful pattern matching prevents undefined situations by ensuring you handle your custom types consistently.
* _Advanced tools:_ Elm's `Debug` module makes it easy to inspect data to catch bugs, and add placeholders to your code until you're ready to implement it. Third-party tools such as create-elm-app let you quickly bootstrap Elm applications and offer powerful development servers for immediate development feedback.

## What's in the Book?

The first five chapters of this book focus on how to build applications. You will create a photo sharing application called Picshare and add new functionality in each chapter.

Chapter 1 introduces you to Elm, explains some of the basics of functional programming, and lets you create a basic Picshare application.

Chapter 2 explains Elm's framework for building applications, the Elm Architecture. You'll use the Elm Architecture to manage state and events in the Picshare application.

Chapter 3 expands on the Picshare application.  You'll learn patterns for refactoring code and how to add new features to the Picshare application.

Chapter 4 lets you create a more realistic Picshare application. Front-end applications typically need to communicate with servers to be useful. You'll learn how to call APIs and safely decode JSON into static types.

Chapter 5 takes Picshare's interactivity further. You'll use Elm subscriptions with WebSockets to receive updates in real time.

The next six chapters focus on advanced patterns for scaling, debugging,
integrating, and maintaining Elm applications.

Chapter 6 addresses the problem of scaling complex applications containing lots of code. You'll use patterns such as reusable helper functions, extensible records, and message wrappers to refactor an application into a more maintainable state.

Chapter 7 introduces Elm's tooling. Although Elm's compiler prevents tons of bugs through static types, bugs can still occur from logic errors. You'll use Elm's `Debug` module to debug values at runtime. You'll also bundle and deploy an application with powerful third-party tools.

Chapter 8 covers interacting with JavaScript code, which is important for accessing impure APIs or migrating existing JavaScript applications to Elm. You'll learn how to add a new feature with Elm to an existing JavaScript application.

Chapter 9 introduces testing to ensure your code is correct. You'll use elm-test to create a module with test-driven development, test properties of your code with fuzz testing, and test an Elm application with elm-html-test.

Chapter 10 teaches you how to build modern single-page applications with Elm. You'll learn how to handle routes and coordinate different page components.

Chapter 11 concludes with speeding up your code. You'll learn about common performance issues, how to measure performance, and how to optimize applications with efficient algorithms, lazy design patterns, and the `Html.Lazy` module.

## Get Your Copy

So, what are you waiting for? Say goodbye to runtime exceptions and unmaintainable code. Learn how to build safe and maintainable front-end applications. Grab a copy of _Programming Elm_ from [The Pragmatic Programmers](https://pragprog.com/) today.

<a class="post__buy-book" href="https://pragprog.com/book/jfelm/programming-elm">Buy now</a>
