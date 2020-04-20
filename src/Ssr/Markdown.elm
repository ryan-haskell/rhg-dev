module Ssr.Markdown exposing (markdown)

import Markdown.Html
import Markdown.Parser
import Ssr.Attributes as Attr
import Ssr.Html as Html exposing (Html)


markdown : String -> Html msg
markdown content =
    Markdown.Parser.parse content
        |> Result.mapError (\_ -> "Couldn't parse.")
        |> Result.andThen (Markdown.Parser.render renderer)
        |> Result.withDefault []
        |> Html.div [ Attr.class "markdown column spacing-1" ]


renderer : Markdown.Parser.Renderer (Html msg)
renderer =
    { heading =
        \{ level, children } ->
            case level of
                1 ->
                    Html.h1 [] children

                2 ->
                    Html.h2 [] children

                3 ->
                    Html.h3 [] children

                4 ->
                    Html.h4 [] children

                5 ->
                    Html.h5 [] children

                6 ->
                    Html.h6 [] children

                _ ->
                    Html.text ""
    , raw = Html.p []
    , blockQuote = Html.blockquote []
    , html = Markdown.Html.oneOf []
    , plain = Html.text
    , code = Html.text >> List.singleton >> Html.code []
    , bold = Html.text >> List.singleton >> Html.strong []
    , italic = Html.text >> List.singleton >> Html.em []
    , link =
        \{ destination } ->
            (if String.startsWith "http" destination then
                Html.a [ Attr.class "link link--external", Attr.href destination, Attr.target "_blank", Attr.rel "noopener" ]

             else
                Html.a [ Attr.class "link", Attr.href destination ]
            )
                >> Ok
    , image = \{ src } alt -> Html.img [ Attr.src src, Attr.alt alt ] [] |> Ok
    , unorderedList = \items -> Html.ul [] (List.map (\(Markdown.Parser.ListItem _ views) -> Html.li [] views) items)
    , orderedList = \_ items -> Html.ol [] (List.map (Html.li []) items)
    , codeBlock =
        \{ body, language } ->
            case language of
                Just lang ->
                    Html.node "hljs-pre"
                        [ Attr.class ("lang-" ++ lang)
                        , Attr.attribute "value" (htmlEncode body)
                        ]
                        []

                Nothing ->
                    Html.pre []
                        [ Html.code
                            (language |> Maybe.map (\lang -> [ Attr.class ("lang-" ++ lang) ]) |> Maybe.withDefault [])
                            [ Html.text body ]
                        ]
    , thematicBreak = Html.hr [] []
    }


htmlEncode : String -> String
htmlEncode str =
    List.foldl
        (\( unsafe, safe ) -> String.replace unsafe safe)
        str
        [ ( "&", "&amp;" )
        , ( "<", "&lt;" )
        , ( ">", "&gt;" )
        , ( "'", "&apos;" )
        , ( "\"", "&quot;" )
        ]
