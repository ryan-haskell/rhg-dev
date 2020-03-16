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
import Html exposing (div, h1, h2, text)
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

- Functions like `div`, `h1`, and `h2` take in a list of attributes followed by a list of
list of children.
- Functions like `text` just take a String and render it to the DOM.

If we wanted to write Elm code that rendered on the server, we'd need a way to render the
HTML data structure as a string on the backend. The `elm/html` package wasn't designed for
folks to do things like this, so we'll need to roll our own shady garbage.

For this experiment, we can create our own **custom type** to capture the types of HTML elements we want to render!

```elm
type Html msg
  = Node (List (Attribute msg)) (List (Node msg))
  | Text String
```

Here we say Html is one of two things:

1. A node with attributes and children
1. Some text we want to render
