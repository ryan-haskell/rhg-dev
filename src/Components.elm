module Components exposing (footer, navbar)

import Route
import Ssr.Attributes exposing (class, href)
import Ssr.Html as Html exposing (..)


navbar : Html msg
navbar =
    let
        link ( label, route ) =
            a [ class "link", href (Route.toPath route) ] [ text label ]
    in
    header [ class "row justify-between" ]
        [ a [ class "nav__brand link", href "/" ] [ text "rhg.dev" ]
        , div [ class "row spacing-1" ]
            (List.map link
                [ ( "posts", Route.Posts )
                ]
            )
        ]


footer : Html msg
footer =
    Html.footer []
        [ text "Built by Ryan Haskell-Glatz, 2020"
        ]
