---
title: "Demystifying Functional Programming: Understand Point Free"
description: TODO
tags: elm
---

<!-- ![Hand using a marker to check off items on a checklist](/img/checklist.jpg) -->
## TODO placeholder image

Elm harnesses many functional programming concepts to provide a delightful, safe
language. As you dive deeper into Elm, you will likely encounter confusing
functional programming jargon, though. In this post and future posts, we will
explore and clarify those confusing concepts.

This post will introduce <em>point-free style</em>. You will learn what it looks
like in Elm and how it relates to currying and partial application. Then, you
will discover how to practically apply it in your code. Finally, you will learn
when not to use it by examining its downsides.

<!-- Downsides: -->
<!-- * Perf? Double check this. Basically the idea of creating unnecessary closures if you apply point free to function that takes multiple arguments. -->
<!-- * Cognitive overload for you and teammates. -->

## Learn Point-free Style

```elm
doubleNumbers : List number -> List number
doubleNumbers =
    List.map (\n -> n * 2)

doubleNumbers [ 1, 2, 3 ]
-- [ 2, 4, 6 ]
```

If you've ever experienced code like above, you've run into point-free style.
The `doubleNumbers` function's type alias says it takes a `List number` argument
and returns `List number`, but the function body accepts no arguments. Yet, you
can call `doubleNumbers` with `[1, 2, 3]` and receive `[2, 4, 6]` back.

Point-free style, also known as [tacit
programming](https://en.wikipedia.org/wiki/Tacit_programming), lets you define
functions without explicitly identifying their arguments. In this case,
`doubleNumbers` still accepts a list argument without identifying it. This works
thanks to partially applying arguments to Elm's curried functions.

If you're unfamiliar with currying and partial application, grab a copy of
[_Programming Elm_](https://pragprog.com/book/jfelm/programming-elm) for a great
explanation. In short, curried functions accept one argument at a time. Partial
application means passing only some of the arguments to a function. The function
doesn't execute until it receives all arguments.

In our example, `List.map` expects two arguments, a mapping function and a list.
We only provide the first mapping function argument. That means we get back a
function expecting the second list argument. We assign the partially applied
function to the `doubleNumbers` identifier. So, `doubleNumbers` is a function
waiting on the list of numbers argument.

Point-free style gets its name by referring to arguments as points. We make
the function "free" of identifying points. TODO: how to finish this paragraph
up?

TODO: continue
