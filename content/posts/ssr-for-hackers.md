---
title: ssr for hackers
description: if it don't be, i can make it do.
date: "1583961793589"
image: https://images.unsplash.com/photo-1583919540895-56040d9e6a60?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60

---
### what's ssr?

So back in the day, javascript didn't have a bunch of cool frameworks. most people used [jquery](https://jquery.com/), and avoided JS as much as humanly possible.

when someone made a request to a website:

1. The server saw a path like `/posts/hello`
2. It fetched all the content from a database or something
3. It rendered the HTML
4. It sent it back to the user

So before any javascript even ran, you'd get something like this back:

```html
<html>
  <head>...</head>
  <body>
    <h1>Hey there!</h1>
    <p>Welcome to my website</p>
  </body>
</html>
```

and that was it! Rendering the content on the server is called "server side rendering".
But holy boy times have changed and things got a whole lot more bizarre.

### client-side rendering?

Most javascript frameworks and modern technologies do "client side rendering", meaning they
do the following sequence of steps:

1. The server saw a path like `/posts/hello`
2. It fetched all the content from a database or something
3. It sent that raw data to the user
4. JavaScript rendered the HTML

And now, before any scripts ran on the page, your browser gets something like this:

```html
<html>
  <head>...</head>
  <body>
    <div id="app"></app>
    <script>
      let node = document.getElementById('app')
      FancyBoi.renderApp(node)
    </script>
  </body>
</html>
```

Here, `FancyBoi` could be React, Vue, or Elm. They all wait until the javascript has loaded to render the view the user sees!

### how do we get ssr?

So rendering Elm in HTML looks something like this:

```elm
import Html exposing (Html, div, h1, h2, text)
import Html.Attributes exposing (class)

view : Html msg
view =
  div [ class "hero" ]
      [ h1 [ class "hero__title" ] [ text "Hello!" ]
      , h2 [ class "hero__subtitle" ] [ text "Sup?" ]
      ]
```

When the JavaScript on the page loads, Elm renders this under the hood:

```html
<div class="hero">
  <h1 class="hero__title">Hello!</h1>
  <h2 class="hero__subtitle">Sup?</h2>
</div>
```

- Functions like `div`, `h1`, and `h2` take in a list of attributes followed by a list of children.
- Functions like `text` just take a String and render it to the DOM.

If we wanted to write Elm code that rendered on the server, we'd need a way to render the
HTML data structure as a string on the backend. The `elm/html` package wasn't designed for
folks to do things like this, so we'll need to roll our own shady garbage.

For this experiment, we can create our own **custom type** to capture the types of HTML elements we want to render!

```elm
type Html msg
  = Node String (List (Attribute msg)) (List (Html msg))
  | Text String
```

Here we say Html is one of two things:

1. A node with attributes and children
1. Some text we want to render

### making Ssr.Html

In a file at `src/Ssr/Html.elm` let's build an API on top of that data structure:

```elm
module Ssr.Html exposing
  ( Html
  , node, div, h1, h2
  , text
  )

import Ssr.Attributes exposing (Attribute)


type Html msg
  = Node String (List (Attribute msg)) (List (Html msg))
  | Text String


-- NODES

node : String -> List (Attribute msg) -> List (Html msg) -> Html msg
node =
  Node
  
div : List (Attribute msg) -> List (Html msg) -> Html msg
div =
  node "div"

h1 : List (Attribute msg) -> List (Html msg) -> Html msg
h1 =
  node "h1"

h2 : List (Attribute msg) -> List (Html msg) -> Html msg
h2 =
  node "h2"

-- TEXT

text : String -> Html msg
text =
  Text
```

We'll also need to define `src/Ssr/Attributes.elm` to support adding attributes and events:

```elm
module Ssr.Attributes exposing
  ( Attribute
  , attribute, id, class
  , event, onClick
  )
  
import Json.Decode as Json exposing (Decoder)
  
type Attribute msg
  = Attribute String String
  | Event String (Decoder msg)
  
-- ATTRIBUTES

attribute : String -> String -> Attribute msg
attribute =
  Attribute
  
class : String -> Attribute msg
class =
  attribute "class"
  
-- EVENTS

event : String -> Decoder msg -> Attribute msg
event =
  Event
  
onClick : msg -> Attribute msg
onClick msg =
  event "click" (Json.succeed msg)
```

### aaaand... it's useless.

With this API, we're able to write HTML that looks just like `elm/html`, the only difference
is we need to update our import statement to use the new module:


```elm
import Ssr.Html exposing (Html, div, h1, h2, text)
import Ssr.Attributes exposing (class)

view : Html msg
view =
  div [ class "hero" ]
      [ h1 [ class "hero__title" ] [ text "Hello!" ]
      , h2 [ class "hero__subtitle" ] [ text "Sup?" ]
      ]
```

The new `Ssr.Html` and `Ssr.Attributes` are working great for building up data structures, but we can't do anything with them! We need to actually render Html:

1. The static server-side markup like `<h1>Hello</h1>`
1. The living, breathing HTML that Elm uses so we can click buttons and do actual stuff!

For that reason, `Ssr.Html` and `Ssr.Attributes` need to expose two new functions:

```elm
module Ssr.Html exposing
  ( ...
  , toString, toHtml
  )

import Ssr.Attributes as Attr exposing (Attribute)
import Html as Core


type Html msg
  = Node String (List (Attribute msg)) (List (Html msg))
  | Text String
  
toString : Html msg -> String
toString html =
  case html of
    Node tag attrs children ->
      String.concat
        [ "<", tag, Attr.toString attrs, ">"
        , String.concat (List.map toString children)
        , "</", tag, ">"
        ]
    
    Text string ->
       -- ensure HTML safe characters
      htmlEncode string

toHtml : Html msg -> Core.Html msg
toHtml html =
  case html of
    Node tag attributes children ->
      Core.node tag (List.map Attr.toAttribute attributes) (List.map toHtml children)

    Text string ->
      Core.text string
```

Now we can have two entrpoints to our app, `src/Main/Ssr.elm` and `src/Main/Client.elm` that reuse that same
`Ssr.Html` markup for different outputs:

```elm
module Main.Ssr exposing (main)

main : Program Flags Model Msg
main =
  Platform.worker
    { -- uses Ssr.Html.toString
    }
```

```elm
module Main.Client exposing (main)

main : Program Flags Model Msg
main =
  Browser.application
    { -- uses Ssr.Html.toHtml
    }
```

When it comes time to call `elm make`, `src/Main/Ssr.elm` is used by NodeJS to generate static HTML files, while `src/Main/Client.elm` is used to rehydrate the app when the JavaScript loads.

That results in something like this:

![A slick 98/100/100/100 google lighthouse raiting, because this page is blazing fast and accessible bro](/rhg-dev-lighthouse-audit.png)

### want more detail?

You can check out the source code on github: [https://github.com/ryannhg/rhg-dev](https://github.com/ryannhg/rhg-dev)

Thanks for reading!
