module Ssr.Router exposing
    ( Page
    , static
    , sandbox
    , element
    , upgrade
    , layout
    , Bundle
    )

{-|


# Page

A `Page` is similar to the [Browser.document](https://package.elm-lang.org/packages/elm/browser/latest/Browser#document) program.
Unlike a `Program` however, an application can have **multiple pages**, which can be composed together in a layout.

For pages, our `view` function always returns `Document msg` instead of `Html msg`,
because that's how Elm determines what title to render in the browser tab.

@docs Page


## Static pages

Just like [Elm's intro "Hello!" example](https://elm-lang.org/examples/hello), sometimes you just want a page
that renders some HTML, without having any state.

@docs static


## Sandbox pages

When you're ready to keep track of state, like
[Elm's "Counter" example](https://elm-lang.org/examples/buttons), you can use a
sandbox page.

Similar to [Browser.sandbox](https://package.elm-lang.org/packages/elm/browser/latest/Browser#sandbox),
this allows you to `init` your model, and `update` it with messages!

@docs sandbox


## Element pages

If you're ready to [send HTTP requests](https://elm-lang.org/examples/cat-gifs) or
[listen to events for updates](https://elm-lang.org/examples/time), it's time to
upgrade to an element page!

Additionally, an element will give you access to `Flags`, so you can access URL
parameters or other data.

@docs element


# Layouts

Creating pages is great, but we'll need to connect them together to view them in
our application! A [recommended way to build web applications](https://guide.elm-lang.org/webapps/structure.html) is to:

  - Organize your pages as modules
  - Model our pages with custom types

```
import Pages.Author as Author
import Pages.Home as Home
import Pages.Search as Search

type Model
    = Home_Model Home.Model
    | Search_Model Search.Model
    | Author_Model Author.Model

type Msg
    = Home_Msg Home.Msg
    | Search_Msg Search.Msg
    | Author_Msg Author.Msg
```

This is the way [the elm-spa-example app](https://github.com/rtfeldman/elm-spa-example/blob/30d19ec220634abd3f7a567bdf921df7192f4013/src/Main.elm#L40-L46) organizes things.
With `elm-router`, the idea is to use this technique and "upgrade" your pages like this:


## Upgrading pages

@docs upgrade

Starting with the `page` we export from our `Pages.*` modules, we provide the `upgrade`
function with a way to turn our:

  - `Home.Model` into a `Model`
  - `Home.Msg` into a `Msg`

This makes the final step much easier: **putting our pages together!**


## Using a layout

@docs layout

A layout uses the `init`, `update` and `bundle` functions to determine
which page should be visible at a given time.

When you use the `pages` we upgraded before, the code is a really easy pattern to follow:

    -- INIT
    init : Route -> ( Model, Cmd Msg )
    init route =
        case route of
            Route.Home ->
                pages.home.init ()

            Route.Search query ->
                pages.search.init query

            Route.Author id ->
                pages.author.init id

    -- UPDATE
    update : Msg -> Model -> ( Model, Cmd Msg )
    update appMsg appModel =
        case ( appMsg, appModel ) of
            ( Home_Msg msg, Home_Model model ) ->
                pages.home.update msg model

            ( Search_Msg msg, Search_Model model ) ->
                pages.search.update msg model

            ( Author_Msg msg, Author_Model model ) ->
                pages.author.update msg model

            _ ->
                ( appModel, Cmd.none )

    -- VIEW + SUBSCRIPTIONS
    bundle : Model -> Bundle Msg
    bundle appModel =
        case appModel of
            Home_Model model ->
                pages.home.bundle model

            Search_Model model ->
                pages.search.bundle model

            Author_Model model ->
                pages.author.bundle model


## What's a "bundle"?

@docs Bundle

Instead of writing out **two case expressions** for each layout:

    view : Model -> Document Msg
    view appModel =
        case appModel of
            Home_Model model ->
                pages.home.view model

            Search_Model model ->
                pages.search.view model

            Author_Model model ->
                pages.author.view model

    subscriptions : Model -> Sub Msg
    subscriptions appModel =
        case appModel of
            Home_Model model ->
                pages.home.subscriptions model

            Search_Model model ->
                pages.search.subscriptions model

            Author_Model model ->
                pages.author.subscriptions model

It would make a lot more sense to just ask for one that combined
`view` and `subscriptions` together.

    bundle : Model -> Bundle Msg
    bundle appModel =
        case appModel of
            Home_Model model ->
                pages.home.bundle model

            Search_Model model ->
                pages.search.bundle model

            Author_Model model ->
                pages.author.bundle model

This combination of `view` and `subscriptions` is called a `Bundle`, and its type
annotation is available above.

-}

import Ssr.Document exposing (Document)
import Ssr.Html as Html exposing (Html)



-- PAGE


{-| There are 4 ways to create a `Page`:

  - [static](#static) – for pages without state.
  - [sandbox](#sandbox) – for pages without side-effects.
  - [element](#element) – for advanced pages.
  - [layout](#layout) – for putting pages together.

-}
type alias Page flags model msg =
    { init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    }


{-|

    page : Page Flags Model Msg
    page =
        Page.static
            { view = view
            }

    -- VIEW
    view : Document Never
    view =
        { title = "Homepage"
        , body =
            [ h1 [] [ text "Home" ]
            ]
        }

**Note:** Because these pages never send messages or store a model, all
static pages must use `type alias Model = ()` and `type alias Msg = Never`.

You can still pass in any `Flags` you like, but only an [element](#element) page has access to them via the `init` function (just like
[Browser.element](https://package.elm-lang.org/packages/elm/browser/latest/Browser#element))

-}
static :
    { view : Document Never
    }
    -> Page flags () Never
static options =
    { init = \_ -> ( (), Cmd.none )
    , update = \_ model -> ( model, Cmd.none )
    , view = \_ -> options.view
    , subscriptions = \_ -> Sub.none
    }


{-|

    page : Page () Model Msg
    page =
        Page.sandbox
            { init = init
            , update = update
            , view = view
            }

    init : Model

    update : Msg -> Model -> Model

    view : Model -> Document Msg

-}
sandbox :
    { init : model
    , update : msg -> model -> model
    , view : model -> Document msg
    }
    -> Page flags model msg
sandbox options =
    { init = \_ -> ( options.init, Cmd.none )
    , update = \msg model -> ( options.update msg model, Cmd.none )
    , view = options.view
    , subscriptions = \_ -> Sub.none
    }


{-|

    page : Page Flags Model Msg
    page =
        Page.element
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }

    init : Flags -> ( Model, Cmd Msg )

    update : Msg -> Model -> ( Model, Cmd Msg )

    view : Model -> Document Msg

    subscriptions : Model -> Sub Msg

**New to Cmd or Sub?** Well so was I! I recommend [Elm's official guide](https://guide.elm-lang.org/effects/)
, it's how I wrapped my head around those two new concepts.

-}
element :
    { init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    }
    -> Page flags model msg
element =
    identity


{-|

    layout : Page Route Model Msg
    layout =
        { view = Layout.view
        , page =
            { init = init
            , update = update
            , bundle = bundle
            }
        }

    Layout.view : List (Html msg) -> Html msg

    init : Route -> ( Model, Cmd Msg )
    update : Msg -> Model -> ( Model, Cmd Msg )
    bundle : Model -> Bundle Msg

-}
layout :
    { view : List (Html msg) -> Html msg
    , page :
        { init : flags -> ( model, Cmd msg )
        , update : msg -> model -> ( model, Cmd msg )
        , bundle : model -> Bundle msg
        }
    }
    -> Page flags model msg
layout options =
    { init = options.page.init
    , update = options.page.update
    , subscriptions = options.page.bundle >> .subscriptions
    , view =
        \model ->
            let
                { title, meta, body } =
                    options.page.bundle model |> .view
            in
            { title = title
            , meta = meta
            , body = [ options.view body ]
            }
    }


{-|

    import Pages.Author as Author
    import Pages.Home as Home
    import Pages.Search as Search
    import Router

    type alias Page flags model msg =
        { init : flags -> ( Model, Cmd Msg )
        , update : msg -> model -> ( Model, Cmd Msg )
        , bundle : model -> Router.Bundle Msg
        }

    pages :
        { home : Page Home.Flags Home.Model Home.Msg
        , search : Page Search.Flags Search.Model Search.Msg
        , author : Page Author.Flags Author.Model Author.Msg
        }
    pages =
        { home =
            Home.page
                |> Router.upgrade Home_Model Home_Msg
        , search =
            Search.page
                |> Router.upgrade Search_Model Search_Msg
        , author =
            Author.page
                |> Router.upgrade Author_Model Author_Msg
        }

-}
upgrade :
    (model -> appModel)
    -> (msg -> appMsg)
    -> Page flags model msg
    ->
        { init : flags -> ( appModel, Cmd appMsg )
        , update : msg -> model -> ( appModel, Cmd appMsg )
        , bundle : model -> Bundle appMsg
        }
upgrade toModel toMsg page =
    { init =
        \flags ->
            page.init flags |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , update =
        \msg model ->
            page.update msg model |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , bundle =
        \model ->
            { view =
                page.view model
                    |> (\doc ->
                            { title = doc.title
                            , meta = doc.meta
                            , body = List.map (Html.map toMsg) doc.body
                            }
                       )
            , subscriptions = page.subscriptions model |> Sub.map toMsg
            }
    }


{-|

    import Router

    type alias Page flags model msg =
        { init : flags -> ( Model, Cmd Msg )
        , update : msg -> model -> ( Model, Cmd Msg )
        , bundle : model -> Router.Bundle Msg
        }

-}
type alias Bundle msg =
    { view : Document msg
    , subscriptions : Sub msg
    }
