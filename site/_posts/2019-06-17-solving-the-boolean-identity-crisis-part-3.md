---
title: "Solving the Boolean Identity Crisis: Part 3"
description: See how boolean properties cause bugs from invalid state configurations. Then, learn how to collapse boolean properties into a single property with a custom type.
tags: elm
---

![Dog holding a ball in its mouth](/img/dog-fetch.jpg)

In the [last post](/blog/2019-05-30-solving-the-boolean-identity-crisis-part-2),
you learned how boolean return values cause boolean blindness. Boolean blindness
can create bugs in conditional statements by letting code access data that
shouldn't be available. We swapped out boolean return values with `Maybe` and a
custom type to wrap the data in a particular type constructor and provide more
meaningful return values. This let the compiler ensure code only accessed data
when it was truly available.

In this post, you will see that boolean properties in Elm records open the door
to invalid state configurations. Boolean properties require more complex
conditional code and more tests to prevent bugs. You will learn that custom
types&mdash;seeing a pattern here&mdash;eliminate the need for complex code and tests
by harnessing the power of the compiler to prevent invalid state configurations.

## The Problem

I begin my talk
[Solving the Boolean Identity Crisis](https://www.youtube.com/watch?v=8Af1bh-BVY8)
with a problem I encountered while building applications with
[Redux](https://redux.js.org) and [React](https://reactjs.org).
When fetching data from a server, I would track the state of fetching that data
with multiple boolean properties. Unfortunately, I brought that pattern over to
the Elm applications I built.

For example, let's say we're building a application for tracking rescue dogs. We
need to fetch a dog from the server. Initially, we wouldn't have a dog, so we
would likely have a model like this.

```elm
type alias Model =
    { dog : Maybe Dog }
```

That seems reasonable so far. Next, we want to display a loading spinner while
we fetch the dog from a server. So, we could add a `fetching` property to the
model.

```elm
type alias Model =
    { dog : Maybe Dog
    , fetching : Bool
    }
```

When `fetching` is `True`, we will display the spinner. When `fetching` is `False`,
we will display nothing.

Once we have the dog, fetching should be `False`, but we want to display the
dog. We could add a `success` boolean property to indicate we have the dog.

```elm
type alias Model =
    { dog : Maybe Dog
    , fetching : Bool
    , success : Bool
    }
```

Now, if success is `True`, we display the dog. Otherwise, if it's `False` and
fetching is `False`, then we're back in a "ready to fetch" state and should
display nothing. (Alternatively, we could look at a combination of `fetching`
and if `dog` is `Just` or `Nothing` to decide what state we're in.)

All seems well, but the dog could not exist on the server or we could encounter
other server errors. We need to know if the request failed and handle any errors
appropriately. Well, we could add an `error` boolean property along with an
`errorMessage` property.

```elm
type alias Model =
    { dog : Maybe Dog
    , fetching : Bool
    , success : Bool
    , error : Bool
    , errorMessage : String
    }
```

If error is `True`, then we can display the `errorMessage`. Otherwise, we'll need to
examine the other boolean properties to determine what to do.

If we were to handle this in the `view` function, it might look like this.

```elm
view : Model -> Html Msg
view model =
    if model.error then
        viewError model.errorMessage

    else if model.fetching then
        viewSpinner

    else if model.success then
        viewDog model.dog

    else
        viewSearchForm
```

The `view` function has a couple of issues.

1. It suffers from
   [boolean blindness](/blog/2019-05-30-solving-the-boolean-identity-crisis-part-2).
   We depend on certain boolean properties to be true before attempting to
   access data. Nothing stops us from accessing data in other branches such as
   `model.dog` or `model.errorMessage`. (Granted, if we tried to access
   `model.dog`, we'd still have the safety of `Maybe`.)
2. It requires more thorough automated testing to ensure we handle all cases
   properly. We could leave out all the `else if` branches and the code would
   still compile even if it was incorrect.

Also, our model can arrive at incorrect configurations like this.

```elm
{ dog = Just { name = "Tucker" }
, fetching = True
, success = True
, error = True
, errorMessage = "Uh oh!"
}
```

All boolean properties are true, we have a dog, and we have an `errorMessage`.
We're hard-pressed to determine what state we're really in. We have no choice
but to depend on the arbitrary ordering of the if-else conditionals in `view` to
make that decision. Of course, we'll need a strong test suite to ensure we can't
configure the model like this.

## Prevent Invalid State

I finally realized the problem with how I represented my data. I thought the
states of fetching data (ready, fetching, success, and error) were separate from
one another. Really, they are different _state values_ of the same overall
state. That sounds like a
[state machine](https://en.wikipedia.org/wiki/Finite-state_machine).

A state machine can only be in one state value at a time. My record
representation forbid that by letting multiple state values be `True`. Elm
has an awesome type system and compiler. We should leverage them as much as
possible to prevent invalid state configurations by essentially creating a
state machine. 

We could introduce a new custom type.

```elm
type RemoteDoggo
    = Ready
    | Fetching
    | Success Dog
    | Error String
```

The `RemoteDoggo` type has four constructors that map to each possible state,
`Ready`, `Fetching`, `Success`, and `Error`. We wrap a `Dog` with the `Success`
constructor and wrap a `String` error message with the `Error` constructor.
Then, we can update the model to look like this.

```elm
type alias Model =
    { dog : RemoteDoggo }
```

We remove all but the `dog` property and change the `dog` property to the
`RemoteDoggo` type. We can now transform the `view` function into this.

```elm
view model =
    case model.dog of
        Ready ->
            viewSearchForm

        Fetching ->
            viewSpinner

        Success dog ->
            viewDog dog

        Error error ->
            viewError error
```

Instead of worrying about the order of boolean properties, we pattern match on
the `dog` property with a `case` expression. We map each constructor to the
appropriate view helper function.

Our code has gained a few benefits here by this change.

1. The code makes the states explicit with the `RemoteDoggo` type.
2. We eliminated boolean blindness. We can only access the dog in `Success` and 
   the error message in `Error`.
3. We have compiler enforced UI states. If we forget to handle one of the
   `RemoteDoggo` values, then our code won't compile.

   This code:

     ```elm
     view model =
         case model.dog of
             Ready ->
                 viewSearchForm

             Fetching ->
                 viewSpinner

             Success dog ->
                 viewDog dog

             -- forgetting to handle errors
     ```

   Will produce this compiler error:

     ```plaintext
     This `case` does not have branches for all possibilities:
     
     |>    case model.dog of
     |>        Ready ->
     |>            viewSearchForm
     |>
     |>        Fetching ->
     |>            viewSpinner
     |>
     |>        Success dog ->
     |>            viewDog dog
     
     Missing possibilities include:
     
         Error _
     ```

Now our code is clearer and safer thanks to custom types.

## What You Learned

In this post, you learned that boolean properties can cause invalid state
configurations, which create bugs that the compiler can't catch. Boolean
properties lead to complex if-else expressions with arbitrary ordering that are
hard to follow. You saw that by reducing the boolean properties down to one
property with a custom type you can write more explicit code with compiler
safety. If you have some code with multiple boolean properties like this, try
refactoring to a custom type to make your code clearer and safer.

## Further Resources

For more info on how to use Elm's type system to prevent invalid state
configurations, watch Richard Feldman's talk [Making Impossible States
Impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8).

For a more general type similar to `RemoteDoggo`, check out the
[krisajenkins/remotedata](https://package.elm-lang.org/packages/krisajenkins/remotedata/latest)
package.
