module Pages exposing (view)

import Pages.Homepage
import Pages.NotFound
import Pages.Post
import Pages.Posts
import Route exposing (Route)
import Ssr.Document exposing (Document)
import Ssr.Html exposing (..)


view : Route -> Document msg
view route =
    case route of
        Route.Homepage ->
            Pages.Homepage.view

        Route.Posts ->
            Pages.Posts.view

        Route.Post slug ->
            Pages.Post.view slug

        _ ->
            Pages.NotFound.view
