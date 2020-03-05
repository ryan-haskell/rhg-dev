module Components exposing
    ( footer
    , layout
    , navbar
    )

import Route
import Ssr.Attributes exposing (class, href, target)
import Ssr.Html as Html exposing (..)
import Transition exposing (Transition)


layout : { transition : Transition } -> List (Html msg) -> Html msg
layout options content =
    div [ class "layout pad-1 container" ]
        [ navbar
        , div
            [ case options.transition of
                Transition.Visible ->
                    class "page page--visible"

                Transition.Invisible ->
                    class "page"
            ]
            content
        , footer
        ]


navbar : Html msg
navbar =
    let
        links : List (Html msg)
        links =
            List.map link
                [ ( "posts", Route.Posts )
                ]
                ++ List.map externalLink
                    [ ( "github", "https://www.github.com/ryannhg" )
                    , ( "twitter", "https://www.twitter.com/ryan_nhg" )
                    ]

        link ( label, route ) =
            a [ class "link", href (Route.toPath route) ] [ text label ]
    in
    div [ class "navbar" ]
        [ header [ class "header row space-between center-x" ]
            [ a [ class "font--heading", href "/" ] [ text "rhg.dev" ]
            , div [ class "row font--small spacing-1" ] links
            ]
        , aside [ class "font--big aside column spacing-1 center-y" ]
            [ a [ class "font--heading", href "/" ] [ text "rhg.dev" ]
            , div [ class "column center-y font--small spacing-1" ] links
            ]
        ]


externalLink : ( String, String ) -> Html msg
externalLink ( label, url ) =
    a [ class "link link--external", target "_blank", href url ] [ text label ]


footer : Html msg
footer =
    Html.footer [ class "row center-x space-between pt-2 pb-1" ]
        [ span [ class "font--small" ] [ text "built by Ryan Haskell-Glatz in 2020" ]
        , div [ class "row spacing-1" ]
            (List.map externalLink
                [ ( "github", "https://www.github.com/ryannhg" )
                , ( "twitter", "https://www.github.com/ryan_nhg" )
                ]
            )
        ]
