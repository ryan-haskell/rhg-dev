---
title: ssr for hackers
description: if it don't be, i can make it do.
image: https://images.unsplash.com/photo-1583919540895-56040d9e6a60?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60
---

### what's ssr?

So back in the day, javascript didn't have a bunch of cool frameworks. most people used [jquery](https://jquery.com/),
and avoided JS as much as humanly possible.

when someone made a request to a website:

1. The server saw a path like `/posts/hello`
1. It fetched all the content from a database or something
1. It rendered the HTML
1. It sent it back to the user

So before *any* javascript even ran, you'd get something like this back:

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
1. It fetched all the content from a database or something
1. It sent that raw data to the user
1. JavaScript rendered the HTML

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
