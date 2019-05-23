---
title: "Solving the Boolean Identity Crisis: Part 1"
description: See how boolean function arguments obscure the intent of code. Then, learn how to replace boolean arguments with Elm's custom types to write more understandable code.
tags: elm
---

Back in September 2017, I presented the talk "Solving the Boolean Identity
Crisis" at ElmConf. The talk highlights the downsides of using booleans in Elm
code and offers ways to write clearer, more maintainable code. This post and the
next couple of posts will share what I explored in that presentation. You can
preview what's to come by watching my talk on [YouTube](https://www.youtube.com/watch?v=8Af1bh-BVY8).

In this post, you will see how boolean function arguments obscure the intent of
code. Then, you will learn how to replace boolean arguments with Elm's custom
types to write more understandable code.

## The Problem

Look at this function call to understand the problem with boolean arguments.

```elm
bookFlight "OGG" True
```

We pass in a string argument `"OGG"` and a boolean argument `True` to a
`bookFlight` function. If you encountered this in an Elm codebase, you
might wonder what the boolean argument does.

Boolean arguments hide the intent of code. We don't know the significance of the
`True` value here without looking up the definition of `bookFlight`. The boolean
argument makes this code harder to understand, especially as a newcomer
learning the codebase.

Looking up the definition, we find this. (I use `...` to signify irrelevant
code.)

```elm
bookFlight : String -> Bool -> Cmd Msg
bookFlight airport isPremium =
    if isPremium then
        ...

    else
        ...
```

The boolean argument is called `isPremium`, so it means the booking customer has
a premium status. We use an if-else expression to branch on `isPremium`. If
`isPremium` is `False`, we're not certain what status this customer has. We have
to assume that the customer has a "regular" status because the code makes that
implicit. We've lost the explicit <emph>intent</emph> of this code by using a
boolean argument.

This code will present future problems if we need more than one customer status.
For example, let's say we need to introduce a new economy status. We could
introduce another boolean argument called `isRegular`.

```elm
bookFlight : String -> Bool -> Bool -> Cmd Msg
bookFlight airport isPremium isRegular =
    if isPremium then
        ...

    else if isRegular then
        ...

    else
        ...
```

After checking if `isPremium` is `True`, we check if `isRegular` `True`.
Otherwise, the implicit customer status is economy.

Now, function calls will look like this.

```elm
bookFlight "OGG" True False
```

That's even more confusing. We could easily mix up the order of the boolean
arguments too and accidentally book a customer with the wrong status. Also, we
could easily pass in two `True` arguments. A customer can't have both premium
and regular status. We have to let the first boolean argument `isPremium` take
precedence in the if-else expression to deal with this invalid argument
permutation.

## Show Intent

We can clean up the `bookFlight` function by replacing the boolean arguments
with an Elm custom type. Instead of hiding statuses behind boolean values, let's
make them explicit. We can easily encode each type of status like so.

```elm
type CustomerStatus
    = Premium
    | Regular
    | Economy
```

We add a `CustomerStatus` custom type with three values, or constructors. Each
value perfectly encodes each status, `Premium`, `Regular`, and `Economy`.

We can update the `bookFlight` function like so.

```elm
bookFlight : String -> CustomerStatus -> Cmd Msg
bookFlight airport customerStatus =
    case customerStatus of
        Premium ->
            ...

        Regular ->
            ...

        Economy ->
            ...
```

The `bookFlight` function makes it clear how to handle each customer status
without implicit if-else branching. Additionally, the compiler ensures we handle
each status. In the previous version of `bookFlight` with two boolean arguments,
nothing would prevent us from accidentally forgetting to handle the `else if
isRegular` branch. The compiler would accept this code.

```elm
bookFlight airport isPremium isRegular =
    if isPremium then
        ...

    else
        ...
```

If we forgot the `Regular` branch in the version with the `CustomerStatus` type,
the code would not compile.

This code:

```elm
bookFlight airport customerStatus =
    case customerStatus of
        Premium ->
            ...

        Economy ->
            ...
```

Would result in this compiler error:

```plaintext
This `case` does not have branches for all possibilities:

|>    case customerStatus of
|>        Premium ->
|>            ...
|>
|>        Economy ->
|>            ...

Missing possibilities include:

    Regular
```

Custom types provide compiler safety along with explicit code. Now calls to
`bookFlight` declare the intent of code because we pass in the `CustomerStatus`
directly.

```elm
bookFlight "OGG" Premium
```

If we ran into the above function, we would more easily understand what's
happening. We're booking a flight for a premium customer. We've made the code
clearer and more maintainable.

## What You Learned

In this post, you learned how boolean arguments can make code confusing and
unmaintainable by hiding the intent of code. You saw how replacing boolean
arguments with custom type values created better, safer code. Try this technique
out on your own Elm project. Find a function that accepts a boolean argument and
see if you can make a custom type that more explicitly encodes the meaning of
that boolean argument when it's `True` and `False`.
