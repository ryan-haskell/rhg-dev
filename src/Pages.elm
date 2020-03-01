module Pages exposing (view)

import Components
import Pages.Homepage
import Pages.NotFound
import Pages.Post
import Pages.Posts
import Route exposing (Route)
import Ssr.Document exposing (Document)
import Ssr.Html exposing (..)
import Transition exposing (Transition)


view : { transition : Transition } -> Route -> Document msg
view options route =
    let
        page =
            case route of
                Route.Homepage ->
                    Pages.Homepage.view

                Route.Posts ->
                    Pages.Posts.view

                Route.Post slug ->
                    Pages.Post.view slug

                Route.NotFound ->
                    Pages.NotFound.view
    in
    { meta = page.meta
    , body =
        [ Components.layout options page.body
        ]
    }
