---
title: "shared state"
date: 1600791370619
description: "dealing with sharing data between pages"
image: "https://images.unsplash.com/photo-1523726491678-bf852e717f6a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=640&q=60"
tags: [ "elm", "architecture", "design" ]
---

### Background

A few months ago, I released [elm-spa](https://elm-spa.dev), a tool for building single page applications with Elm. There were several versions and iterations on this project before the release (version 5.x at the time of writing).

Of all the challenges in creating __elm-spa__, the biggest was coming up with a design for __sharing data between pages__.

This article hopes to give a quick overview of the different options I encountered, and talk through some of the assumptions and benefits of each approach:

Here are the three strategies covered in this post:

1. Returning More Data
2. Providing More Input
3. Adding New Functions

### Assumptions

Before we dive into the code, let's start with a basic overall structure:

```bash
- elm.json
- src/
   |- Main.elm
   |- Shared.elm
   |- Pages.elm
   |- Pages/
       |- Home.elm
       |- Blog.elm
       |- Settings.elm
       |- NotFound.elm
```

#### src/Main.elm

```elm
module Main exposing (..)

import Shared
import Pages

type alias Model = 
  { shared : Shared.Model
  , page : Pages.Model
  }
```

#### src/Shared.elm

```elm
module Shared exposing (Model)

type alias Model =
  { user : Maybe User
  }
```

#### src/Pages.elm

```elm
module Pages exposing (Model)

import Pages.Home
import Pages.Blog
import Pages.Settings
import Pages.NotFound

type Model
  = Home_Model Pages.Home.Model
  | Blog_Model Pages.Blog.Model
  | Settings_Model Pages.Settings.Model
  | NotFound_Model Pages.NotFound.Model
```

The applications we are building are going to store a data model that looks like this:

- `model.shared` is the state that persists between page navigation.
- `model.page` is the state of our current page. Because the internet, we should only have one page at a time.

There are three pages in this example, and the required "not found" page:

Module | File | URL
:-- | :-- | :--
Pages.Home | src/Pages/Home.elm | `/`
Pages.Blog | src/Pages/Blog.elm | `/blog`
Pages.Settings | src/Pages/Settings.elm | `/settings`
Pages.NotFound | src/Pages/NotFound.elm | (everything else)

### the challenge

We want each of these four pages to contain their own `Model`/`Msg`/`init`/`update`/`view`. This makes it easier to navigate around the project, but requires an API for working with the `model.shared` data mentioned above!

Let's dive into a few designs that address that problem, while maintaining the assumptions we made above.

### Strategy 1: Returning More Data

A common strategy for dealing with shared state is to mimic what [elm/browser](https://package.elm-lang.org/packages/elm/browser/latest/Browser) did when introducing side effects:

```elm
-- Browser.sandbox
update : Msg -> Model -> Model

-- Browser.element
update : Msg -> Model -> ( Model, Cmd Msg )
```

If we continue this pattern, we end up with one of these:

```elm
update : Msg -> Model -> ( Model, Cmd Msg, Cmd Shared.Msg )
-- or 
update : Msg -> Model -> ( Model, Cmd Msg, Shared.Msg )
-- or
update : Msg -> Model -> Shared.Update Model Msg
```

Each of these are slight modifications on one big idea: __return more data__ from our page's `init` and `update` functions.

If we had to pick from these three, which should we choose?

#### Returning ( Model, Cmd Msg, Cmd Shared.Msg )

In practice, sending `Cmd Shared.Msg` involves using `Task.perform` on `Shared.Msg` types, which is a bit overwhelming for beginners (and still confusing for everyone else).

This was the approach elm-spa v3 took, and while it solved the problem, I think it was a bit silly. I had to expose a `Shared.send : msg -> Cmd msg` helper function to do the weird `Task` calls under the hood.

However, it allowed users to provide `Cmd.none` when they didn't have shared updates to make:

```elm
module Pages.Home exposing (..)

import Shared

-- ...

update : Msg -> Model -> ( Model, Cmd Msg, Cmd Shared.Msg )
update msg model =
  case msg of
    Increment ->
      ( { model | counter = model.counter + 1 }
      , Cmd.none
      , Cmd.none
      )

    FetchPosts ->
      ( model
      , Http.get { ... }
      , Shared.send Shared.NoOp
      )

    SignInUser user ->
      ( model
      , Cmd.none
      , Shared.send (Shared.SignIn user)
      )
```

#### Returning ( Model, Cmd Msg, Shared.Msg )

This is a slight variation on the example above, but doesn't use `Cmd`, so it's easier to work with.

Likely, users would define a `Shared.NoOp` in place of the `Cmd.none` used earlier:


```elm
module Pages.Home exposing (..)

import Shared

-- ...

update : Msg -> Model -> ( Model, Cmd Msg, Shared.Msg )
update msg model =
  case msg of
    Increment ->
      ( { model | counter = model.counter + 1 }
      , Cmd.none
      , Shared.NoOp
      )

    FetchPosts ->
      ( model
      , Http.get { ... }
      , Shared.NoOp
      )

    SignInUser user ->
      ( model
      , Cmd.none
      , Shared.SignIn user
      )
```

There are a few variations on this approach:

Return Type | How to do nothing | Improvement on previous
:-- | :-- | :--
`Shared.Msg` | `Shared.NoOp` | ...
`Maybe Shared.Msg` | `Nothing` | No need to define a `NoOp`
`List Shared.Msg` | `[]` | Easy to send multiple messages

All of these have one thing in common: they encourage the user to __expose their Shared.Msg__ variants. This isn't a great idea, because now external code knows too much about the implementation of `Shared.Msg`.

Ideally, changing `Shared.Msg` variants down the road shouldn't break any other modules.

#### Returning Update Model Msg

Earlier, we were returning triplets, or tuples with 3 items. 

So what's `Update Model Msg`? It's a custom type we define below in `src/Shared/Update.elm` that provides a nicer API for dealing with optional `Cmd msg` and `Shared.Msg` values from our page's `update` function.

```elm
module Shared.Update exposing
  ( Update
  , new, withCmd, withSharedMsg
  , toTriplet
  )
  
import Shared
  
-- Under the hood
type Update model msg =
  Update model (List (Cmd msg)) (List Shared.Msg)
    
-- Creating updates
    
new : model -> Update model msg
new model =
  Update model [] []
  
withCmd : Cmd msg -> Update model msg -> Update model msg
withCmd cmd (Update model cmds msgs) =
  Update model (cmd :: cmds) msgs

withSharedMsg : Shared.Msg -> Update model msg -> Update model msg
withSharedMsg msg (Update model cmds msgs) =
  Update model cmds (msg :: msgs)

-- Getting values later

toTriplet : Update model msg -> ( model, Cmd msg, List Shared.Msg )
toTriplet (Update model cmds msgs) =
  ( model, Cmd.batch cmds, msgs )
```

That's it! A custom type designed to make working with triplets a lot nicer. Let's compare a usage example with what we saw before:


```elm
module Pages.Home exposing (..)

import Shared
import Shared.Update as Update exposing (Update)

-- ...

update : Msg -> Model -> Update Model Msg
update msg model =
  case msg of
    Increment ->
      Update.new { model | counter = model.counter + 1 }

    FetchPosts ->
      Update.new model
        |> Update.withCmd (Http.get { ... })

    SignInUser user ->
      Update.new model
        |> Update.withSharedMsg (Shared.SignIn user)
```

__Much nicer!__ It's common practice in Elm to define data structures in modules to make better APIs for ourselves!

This `with*` pattern is just like the one in Brian Hick's "[Robot Buttons from Mars](https://www.youtube.com/watch?v=PDyWP-0H4Zo)" talk!

If we had to choose this strategy, I would __strongly__ recommend creating the `Shared.Update` type to make returning more data much easier on each page.


### Strategy 2: Providing More Input

Is there a way to keep the `( Model, Cmd Msg )` return type in our `update` function?

That's the big idea behind this strategy, __providing more input__ to `init` and `update`!

```elm
module Pages.Home exposing (..)

-- ...

-- before
update : Msg -> Model -> ( Model, Cmd Msg )

-- after
update : Converter Msg msg -> Msg -> Model -> ( Model, Cmd msg )
```

Here we changed __two things__:

1. We passed something called `Converter msg` into our `update` function

2. We changed `Cmd Msg` to `Cmd msg` (made the `msg` generic!)

The important thing is now our `Pages.Home.update` function can return more than just `Cmd Pages.Home.Msg`, it can also return `Cmd Shared.Msg`.

It does that by receiving a `Converter` that knows how to convert `Shared.Msg` and `Msg` into the generic `msg` type:

```elm
module Shared.Converter exposing (..)

type alias Converter pageMsg msg =
  { fromCmd : Cmd pageMsg -> Cmd msg
  , fromSharedMsg : Shared.Msg -> Cmd msg
  }
```

When you think about it `Converter pageMsg msg`, is like the inverse of `Update model msg` from the last section.

Here's what it looks like in practice:

```elm
update : Converter Msg msg -> Msg -> Model -> ( Model, Cmd msg )
update converter msg model =
  case msg of
    Increment ->
      ( { model | counter = model.counter + 1 }
      , Cmd.none
      )

    FetchPosts ->
      ( model
      , converter.fromCmd (Http.get { ... })
      )

    SignInUser user ->
      ( model
      , converter.fromSharedMsg (Shared.SignIn user)
      )
```

We can call `converter.fromCmd` to send `Cmd Msg` values, and `converter.fromSharedMsg` to send `Shared.Msg` values from our pages.

What if we need to send both a `Cmd Msg` and a `Shared.Msg`? We can use `Cmd.batch`!

```elm
( model
, Cmd.batch
    [ converter.fromCmd (Http.get { ... })
    , converter.fromSharedMsg (Shared.SignIn user)
    ]
)
```

How do we get a `Converter msg`? It's up to the code in `src/Pages.elm` to provide the converters for each page type:

```
module Pages exposing (..)

import Shared.Converter as Converter exposing (Converter)

-- ...

type Msg
  = Home_Msg Pages.Home.Msg
  | Blog_Msg Pages.Blog.Msg
  | Settings_Msg Pages.Settings.Msg
  | NotFound_Msg Pages.NotFound.Msg

update : Converter Msg msg -> Msg -> Model -> ( Model, Cmd msg )
update converter msg_ model_ =
  case ( msg_, model_ ) of
    ( Home_Msg msg, Home_Model model ) ->
        Pages.Home.update (Converter.map Home_Msg converter) msg model

    ( Blog_Msg msg, Blog_Model model ) ->
        Pages.Blog.update (Converter.map Blog_Msg converter) msg model

    ( Settings_Msg msg, Settings_Model model ) ->
        Pages.Settings.update (Converter.map Settings_Msg converter) msg model

    ( NotFound_Msg msg, NotFound_Model model ) ->
        Pages.NotFound.update (Converter.map NotFound_Msg converter) msg model

    _ ->
        ( model_, Cmd.none )
```

`Converter.map` isnt that interesting, it just converts one converter into another:

```
module Shared.Converter exposing (Converter, map)

-- ...

map : (a -> b) -> Converter a msg -> Converter b msg
map fn converter =
  { fromShared = converter.fromShared
  , fromPage = \pageCmd -> pageCmd |> Cmd.map fromPageMsg |> converter.fromCmd
  }
```

### Strategy 3: Adding New Functions

### Summary
