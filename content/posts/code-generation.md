---
title: "Code Generation with Elm"
date: 1581351300142
description: "Generating Elm code with Elm code (and some JS)"
image: "https://github.com/ryannhg/rhg-dev/blob/master/images/elm-code-generation.png?raw=true"
tags: [ "elm", "generation", "elm-spa" ]
---

### overview

someone reached out to me recently about how i generated Elm code with Elm for [elm-spa](https://elm-spa.dev). At a high-level, this post is about the things you'll need to do to create your own library.


#### designing for the elm community?

__Code generation is neat, but having a well-designed package is a better outcome!__ Elm folks can easily understand functions and data types over your custom library.


### creating the elm project

Let's create a new elm project from the command line:

```sh
mkdir codegen
cd codegen
elm init
```

Those commands will create a new project in the `codegen` folder. 

From there, we'll use [Platform.worker](https://package.elm-lang.org/packages/elm/core/latest/Platform#worker) to create a "headless" elm app that doesn't render to the DOM with a `view` function.

We can do this by creating `src/Main.elm`:

```elm
module Main exposing (main)

-- PROGRAM


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = always Sub.none
        }



-- INIT


type alias Model =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )



-- UPDATE


type alias Msg =
    Never


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )

```

The way our `Platform.worker` will communicate with the outside world is with [ports](https://guide.elm-lang.org/interop/ports.html). These will allow us to send messages back and forth to NodeJS!

Let's create a `src/Ports.elm` file for that code

```elm
port module Ports exposing (send)

port send : String -> Cmd msg
```

For now we'll only expose `Ports.send`, which when given a `String`, will send a message to NodeJS!

Let's update our `src/Main.elm` to send that message on `init` (when the app starts up):


```elm
module Main exposing (main)

import Ports

-- ...

type alias Model =
    ()

init : Flags -> ( Model, Cmd Msg )
init _ =
    ( ()
    , Ports.send "Hello from Elm!"
    )

-- ...
```

That's enough Elm for now, let's make sure your app compiles:

```bash
elm make src/Main.elm --output=dist/elm.js --optimize
```

Hopefully, you'll see `Success!` and you'll have a new file at `dist/elm.js`.

### the nodejs part

Alright, let's use the Elm program we just compiled in a new NodeJS program at `index.js`:

```js
const { Elm } = require('./dist/elm.js')

const app = Elm.Main.init()

app.ports.send.subscribe(console.log)
```

This is a simple program that does three things:

1. imports the elm app we compiled earlier
1. starts the app
1. listens on the `send` port for messages.

Run the app like this:

```bash
node index.js
```

You should see this in the output:

```sh
Hello from Elm!
```

### code generation!

Alright, if all the steps above are working, we're ready to generate some Elm code!

Let's imagine this is the app we want to make:

1. We receive a list of pages (`[ "Dashboard", "AboutUs", "NotFound" ]`)
1. We need to generate a `dist/Route.elm` file like this:

```elm
module Route exposing (routes)

import Url.Parser as Parser exposing (Parser)


type Route
  = Dashboard
  | AboutUs
  | NotFound


routes : Parser (Route -> a) a
routes =
  Parser.oneOf
    [ Parser.map Dashboard (Parser.s "dashboard")
    , Parser.map AboutUs (Parser.s "about-us")
    , Parser.map NotFound (Parser.s "not-found")
    ]
```

Let's upgrade our existing app piece by piece to support this.

#### but first!

Something I did __not__ do when writing the elm-spa code generator was use `elm-test`. That was stupid, I feel stupid. Now I come back to my code and am very spooked.

I'm not much of a unit testing kinda guy, but holy boy I should have written tests for these things because i forgot how they worked like a week later.

### setting up elm-test

```sh
npm i -g elm-test
elm-test init
```

That's it– great job, we'll add some in soon!

### taking input from nodejs

Let's add in some flags, so we can take in JSON input from NodeJS

Here's `src/Main.elm`

```elm
module Main exposing (main)

-- ...

type alias Flags =
    List String

init : Flags -> 

-- ...
```

And here's the new `index.js`

```js
const { Elm } = require('./dist/elm.js')

const app = Elm.Main.init({
  flags: [ "Dashboard", "AboutUs", "NotFound" ]
})

app.ports.send.subscribe(console.log)
```

Let's see if our Elm app received them, by printing them back out with our `Ports.send` from earlier:

```elm
init : Flags -> ( Model, Cmd Msg )
init flags =
    ( ()
    , Ports.send (String.join ", " flags)
    )
```

Let's rebuild the app, and run it again!

```sh
elm make src/Main.elm --output=dist/elm.js --optimize
node index.js
```

You should see this output:

```sh
Dashboard, AboutUs, NotFound
```

Sick, bro!

### rendering an elm file

The next step is to use a different function than `String.join ", "` to convert the input into a `dist/Routes.elm` file.

Let's create a module called `src/Route.elm` to contain our functions:

```elm
module Route exposing (render)

render : List String -> String
render names =
  String.trim """
module Route exposing (routes)

import Url.Parser as Parser exposing (Parser)


type Route
  = Dashboard
  | AboutUs
  | NotFound


routes : Parser (Route -> a) a
routes =
  Parser.oneOf
    [ Parser.map Dashboard (Parser.s "dashboard")
    , Parser.map AboutUs (Parser.s "about-us")
    , Parser.map NotFound (Parser.s "not-found")
    ]
  """
```

And we'll use `Routes.render` in the `init` function in `src/Main.elm`:

```elm
import Route

init : Flags -> ( Model, Cmd Msg )
init flags =
    ( ()
    , Ports.send (Route.render flags)
    )
```

Now when we recompile and run the app:

```sh
elm make src/Main.elm --output=dist/elm.js --optimize
node index.js
```

We should see this printed out in the console:

```sh
module Route exposing (routes)

import Url.Parser as Parser exposing (Parser)


type Route
    = Dashboard
    | AboutUs
    | NotFound


routes : Parser (Route -> a) a
routes =
    Parser.oneOf
        [ Parser.map Dashboard (Parser.s "dashboard")
        , Parser.map AboutUs (Parser.s "about-us")
        , Parser.map NotFound (Parser.s "not-found")
        ]
```

### "string interpolation" in Elm

To make the code printed out dynamic, we'll need to replace the hard-coded custom type and parsers with ones generated from the data.

To do that, we'll need to replace the content in the template with a string that reflects the code we want.

This is the technique I used for elm-spa

```elm
import Utils.Template as Utils

render : List String -> String
render names =
  let
    routeCustomType =
      names
        |> Utils.customType
        |> Utils.indent 1

    routeParsers =
      names
        |> List.map toParser
        |> Utils.list
        |> Utils.indent 2
  in
  """
module Route exposing (routes)

import Url.Parser as Parser exposing (Parser)


type Route
{{routeCustomType}}


routes : Parser (Route -> a) a
routes =
    Parser.oneOf
{{routeParsers}}
  """
    |> String.replace "{{routeCustomType}}" routeCustomType
    |> String.replace "{{routeParsers}}" routeParsers
    |> String.trim
```

By using the `{{variableName}}` syntax, I can use `String.replace` to insert the dynamic value into the string where I want it.

As a convention, I made the variable name match the name inside `{{}}`, so it would be easier to find.

I also found it helpful to create an `indent` function to take care of the proper tab formatting for me.

### unit tests!

Something I failed to do with elm-spa was to write unit tests for the `Utils.Templates` functions, and especially for the `Route.render` function.

This time around, I used `elm-test` to write tests like these:

```elm
module Tests.Utils.Template exposing (suite)

import Expect
import Test exposing (Test, describe, test)
import Utils.Template


suite : Test
suite =
  describe "Utils.Template"
    [ describe "sluggify"
      [ test "works with CamelCase things" <|
        \_ ->
          [ "HelloThere"
          , "What"
          , "IsUpDood?"
          ]
            |> List.map Utils.Template.sluggify
            |> Expect.equalLists
                [ "hello-there"
                , "what"
                , "is-up-dood?"
                ]
      -- (more sluggify tests)
      ]
    -- (tests for the other functions)
    ]
```

Having simple examples of what I expect is _super_ useful when referencing things again later. I really wish I had done this work up front when working on elm-spa...

It was even more useful for `Route.render`, where I could see the full result of a template.

As the template code got more complex, I found myself wishing for a simple example of input/output I could glance at to understand what I was looking at!

```elm
module Tests.Route exposing (suite)

import Expect
import Route
import Test exposing (Test, describe, test)


suite : Test
suite =
  describe "Route"
    [ describe "render"
      [ test "works with one item" <|
        \_ ->
          [ "Dashboard" ]
            |> Route.render
            |> Expect.equal (String.trim """
module Route exposing (routes)

import Url.Parser as Parser exposing (Parser)


type Route
    = Dashboard


routes : Parser (Route -> a) a
routes =
    Parser.oneOf
        [ Parser.map Dashboard (Parser.s "dashboard")
        ]
          """)
      ]
    -- (example with multiple items)
    ]
```

If you'd like to see the actual implementation for [`Utils.Template` functions](https://github.com/ryannhg/elm-codegen/blob/master/src/Utils/Template.elm) or things like [the `Route.toParser` function](https://github.com/ryannhg/elm-codegen/blob/f047407cc7c37d0eb1e55c6b79fd838e8e731c56/src/Route.elm#L40-L42), you can click those links.

They're just functions that return `String` values, so I didn't want to get into them too much here!

### actually creating code

Alright, so if we update our `index.js` to send in different input data:

```js
const app = Elm.Main.init({
  flags: [
    "Dashboard",
    "AboutUs",
    "Careers",
    "NotFound"
  ]
})
```

And run the latest code, we should see the console print out this:

```sh
module Route exposing (routes)

import Url.Parser as Parser exposing (Parser)


type Route
    = Dashboard
    | AboutUs
    | Careers
    | NotFound


routes : Parser (Route -> a) a
routes =
    Parser.oneOf
        [ Parser.map Dashboard (Parser.s "dashboard")
        , Parser.map AboutUs (Parser.s "about-us")
        , Parser.map Careers (Parser.s "careers")
        , Parser.map NotFound (Parser.s "not-found")
        ]
```

Awesome, our new `Careers` item is inserted where we'd expect!

Let's actually use NodeJS to write out that string as a file: `dist/Route.elm`, and we're done!

```js
const fs = require('fs')
const path = require('path')
const { Elm } = require('./dist/elm.js')

const app = Elm.Main.init({
  flags: [
    "Dashboard",
    "AboutUs",
    "Careers",
    "NotFound"
  ]
})

app.ports.log.subscribe(routeFileContents =>
  fs.writeFileSync(
    path.join(__dirname, 'dist', 'Route.elm'),
    routeFileContents
  )
)
```

After importing `fs` and `path` at the top, and replace the `console.log` with something like `fs.writeFileSync`, we can actually write a file out to the file system.

If we build and run our app one last time:

```sh
elm make src/Main.elm --output=dist/elm.js --optimize
node index.js
```

This time, a new file is ready at `dist/Route.elm`, and it looks like this:

```elm
module Route exposing (routes)

import Url.Parser as Parser exposing (Parser)


type Route
    = Dashboard
    | AboutUs
    | Careers
    | NotFound


routes : Parser (Route -> a) a
routes =
    Parser.oneOf
        [ Parser.map Dashboard (Parser.s "dashboard")
        , Parser.map AboutUs (Parser.s "about-us")
        , Parser.map Careers (Parser.s "careers")
        , Parser.map NotFound (Parser.s "not-found")
        ]
```

### hooray!

That's it– We made Elm code with Elm code (and like 20 lines of JS)! For your project, you might get your input list from another source.

For example, elm-spa uses the names of items in the `src/Pages` folder to determine what code to generate.

Thanks for reading, hope this post was useful!

Feel free to check out [the project on Github](https://github.com/ryannhg/elm-codegen)!