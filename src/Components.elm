module Components exposing
    ( footer
    , layout
    , navbar
    )

import Route
import Ssr.Attributes exposing (class, href, rel, target)
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
                ++ List.map viewExternalLink externalLinks

        link ( label, route ) =
            a [ class "link", href (Route.toPath route) ] [ text label ]
    in
    div [ class "navbar" ]
        [ header [ class "header row space-between center-x" ]
            [ a [ class "font--heading font--big", href "/" ] [ text "rhg.dev" ]
            , div [ class "row spacing-1 font--small" ] links
            ]
        , aside [ class "aside column spacing-1 center-y" ]
            [ a [ class "font--heading font--big", href "/" ] [ text "rhg.dev" ]
            , div [ class "column center-y spacing-half" ] links
            ]
        ]


viewExternalLink : ( String, String ) -> Html msg
viewExternalLink ( label, url ) =
    a
        [ class "link link--external"
        , target "_blank"
        , href url
        , rel "noopener"
        ]
        [ text label ]


footer : Html msg
footer =
    Html.footer [ class "row center-x space-between pt-2 pb-1 font--small" ]
        [ text "built by Ryan Haskell-Glatz in 2020"
        , div [ class "row spacing-1" ]
            (List.map viewExternalLink externalLinks)
        ]


externalLinks : List ( String, String )
externalLinks =
    [ ( "github", "https://www.github.com/ryannhg" )
    , ( "twitter", "https://www.twitter.com/ryan_nhg" )
    ]
