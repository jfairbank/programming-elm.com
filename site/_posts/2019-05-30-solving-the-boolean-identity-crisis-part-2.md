---
title: "Solving the Boolean Identity Crisis: Part 2"
description: Learn how boolean return values cause boolean blindness and create bugs. Then, discover how to replace boolean return values with Elm's custom types to have safer code.
tags: elm
---

![Man and dog walking down road through fog](/img/fog-boolean-blindness.jpg)

In the [previous post](/blog/2019-05-20-solving-the-boolean-identity-crisis-part-1),
we explored how boolean arguments obscure the intent of code. We replaced
boolean arguments with custom type values to make code more explicit and
maintainable.

In this post, you will discover that boolean return values cause a problem known
as _boolean blindness_. Boolean blindness can create accidental bugs in if-else
expressions that the compiler can't prevent. You will learn how to replace
boolean return values with custom types to eliminate boolean blindness and
leverage the compiler for safer code.

## The Problem

In my talk, [Solving the Boolean Identity Crisis](https://www.youtube.com/watch?v=8Af1bh-BVY8),
I share a tale from a
[lecture](https://www.cs.cmu.edu/~15150/previous-semesters/2012-spring/resources/lectures/09.pdf) by
[Dan Licata](http://dlicata.web.wesleyan.edu), a professor at Wesleyan University.

> Sometimes, when I'm walking down the street, someone will ask me "do you know what time it
is?" If I feel like being a literalist, I'll say "yes." Then they roll their eyes and say "okay, [tell]
me what time it is!" The downside of this is that they might get used to demanding the time, and
start demanding it of people who don't even know it.
It's better to ask "do you know what time is it, and if so, please tell me?". [T]hat's what "what
time is it?" usually means. This way, you get the information you were after, when it's available.

If we translate this into code, it might look like this.

```elm
type alias Person =
    { time : String }


doYouKnowTheTime : Person -> Boolean
doYouKnowTheTime person =
    person.time /= ""


tellMeTheTime : Person -> String
tellMeTheTime person =
    person.time


currentTime : Person -> String
currentTime person =
    if doYouKnowTheTime person then
        tellMeTheTime person

    else
        "Does anybody really know what time it is?"
```

The `doYouKnowTheTime` function accepts a `Person` type and checks if the `time`
field isn't the empty string. Then, we branch on a call to `doYouKnowTheTime` inside the
`currentTime` function. If it returns `True`, then we call `tellMeTheTime` to
return the value of `person.time`. Otherwise, we return a default time.

This code may look fine but it suffers from a couple of problems.

First, as Dan rightly points out, people could demand time of others that don't
have it. Nothing stops us from writing this code.

```elm
currentTime person =
    if doYouKnowTheTime person then
        tellMeTheTime person

    else
        tellMeTheTime person -- returns empty string
```

We can still call `tellMeTheTime` when `person.time` is the empty string. This
would likely cause a bug.

Second, the fact that we can cause the previous situation surfaces a
data-modeling code smell. Strings notoriously cause trouble because any string
is valid according to the type system. The compiler can't enforce that a given
string is not empty. This is a weak substitute for a more meaningful data type.

We want to give the compiler better type information so it can constrain this
code to only access the time when it's truly available. Let's explore how to
make this code clearer and safer.

## Fix the Boolean Blindness

The first problem stems from boolean blindness. When you reduce information to a
boolean, you lose that information easily. The information that boolean carries
is only known inside the `if` check. As soon as you branch into the body of the
if-else expression, you become _blind_ to the original information that got you
there. Because that boolean loses information, you must backtrack to recover it
when you need it again.

Dan offers this solution to boolean blindness, "boolean tests let you _look_,
options let you _see_."

Dan is referring to the `option` type in
[ML](https://en.wikipedia.org/wiki/ML_%28programming_language%29). In Elm, we call
it the `Maybe` type. What Dan means is that booleans only tell you if something is
present. The `Maybe` type tells you if it's present by giving it to you when
it's available. Let's rewrite our example with `Maybe String`.


```elm
type alias Person =
    { time : Maybe String }


whatTimeIsIt : Person -> Maybe String
whatTimeIsIt person =
    person.time


currentTime : Person -> String
currentTime person =
    case whatTimeIsIt person of
        Just time ->
            time

        Nothing ->
            "Does anybody really know what time it is?"
```

We update the `time` field to be `Maybe String`. Then, we add a `whatTimeIsIt`
function that returns `person.time`. Inside `currentTime` we now call
`whatTimeIsIt` and pattern match on the result. If the person has the time, then
we immediately have access to it inside `Just`. No need to first check with an
if-else expression. If the person doesn't have the time, i.e. `Nothing`, then we
return our default. 

We can't accidentally access the time if it's not present because the compiler
will enforce the `Maybe` type constraint.

We still have a problem, though. The time inside `Just` could be the empty
string, which is an invalid time. Let's fix that next.

## Use Time.Posix

We need a better type for encoding the time to avoid the empty string. Luckily,
Elm has a package for working with time called
[elm/time](https://package.elm-lang.org/packages/elm/time/latest/). It offers a
`Posix` type to represent Unix time, or the amount of time that has passed since
midnight UTC on January 1, 1970. We can use the `Posix` type and then convert it
to a formatted time when needed.


```elm
import Time exposing (Posix, toHour, toMinute, utc)


type alias Person =
    { time : Maybe Posix }


whatTimeIsIt : Person -> Maybe Posix
whatTimeIsIt person =
    person.time


currentTime : Person -> String
currentTime person =
    case whatTimeIsIt person of
        Just time ->
            String.fromInt (toHour utc time)
                ++ ":"
                ++ String.fromInt (toMinute utc time)

        Nothing ->
            "Does anybody really know what time it is?"
```

We import the `Time` module and expose `Posix`, `toHour`, `toMinute`, and `utc`.
We change the `time` field to `Maybe Posix` and update the type annotation for
`whatTimeIsIt`. Inside the `Just` branch of `currentTime`, we now know we have a
valid time thanks to the `Posix` type. We use the `toHour` and `toMinute`
functions along with `String.fromInt` and the `utc` time zone to build a
formatted string time.

This is great. Because of static types, the compiler will enforce our code to
only access a valid time when it exists.

We could go one step further to improve this code. If a person doesn't have the
time, then it's `Nothing`. But, that doesn't explain _why_ the person doesn't
have time. We can replace `Maybe` with our own custom type. 

```elm
type CurrentTime
    = CurrentTime Posix
    | NoWatch
    | InAHurry


type alias Person =
    { time : CurrentTime }


currentTime : Person -> String
currentTime person =
    case whatTimeIsIt person of
        CurrentTime time ->
            String.fromInt (toHour utc time)
                ++ ":"
                ++ String.fromInt (toMinute utc time)

        NoWatch ->
            "I don't have the time."

        InAHurry ->
            "Sorry, I'm in a hurry."
```

We introduce a `CurrentTime` custom type with three constructors, `CurrentTime`,
`NoWatch`, and `InAHurry`. The `CurrentTime` constructor wraps `Posix`. We then
change the `time` field to be `CurrentTime`. In the `currentTime` function, we
handle all three constructors. The `CurrentTime` branch stays the same as the
previous `Just` branch. The `NoWatch` and `InAHurry` branches each return a
string that describes why the person doesn't have the time.

Now, we have made the code more precise about why a person doesn't have the time
and have encoded better business domain rules into the code with custom types.
Plus, we still have the compiler to ensure we can only access a valid time in
the `CurrentTime` branch.

## What You Learned

In this post, you learned that boolean return values cause boolean blindness.
You saw that boolean blindness can lead to human error by letting code access
data in incorrect places. You discovered that built-in custom types such as
`Maybe` or your own custom type let you test and access the presence of data.
Additionally, the compiler ensures you access data only when it's truly
available. Try refactoring some of your own code to replace a boolean return
value with a more meaningful custom type to make your code more maintainable.
