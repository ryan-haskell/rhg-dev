module Ssr.Markdown exposing (markdown)

import Markdown.Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Ssr.Attributes as Attr
import Ssr.Html as Html exposing (Html)


markdown : String -> Html msg
markdown content =
    Markdown.Parser.parse content
        |> Result.mapError (\_ -> "Couldn't parse.")
        |> Result.andThen (Markdown.Renderer.render renderer)
        |> Result.withDefault []
        |> Html.div [ Attr.class "markdown column spacing-1" ]


renderer : Markdown.Renderer.Renderer (Html msg)
renderer =
    { heading =
        \{ level, children } ->
            case level of
                Markdown.Block.H1 ->
                    Html.h1 [] children

                Markdown.Block.H2 ->
                    Html.h2 [] children

                Markdown.Block.H3 ->
                    Html.h3 [] children

                Markdown.Block.H4 ->
                    Html.h4 [] children

                Markdown.Block.H5 ->
                    Html.h5 [] children

                Markdown.Block.H6 ->
                    Html.h6 [] children
    , blockQuote = Html.blockquote []
    , html = Markdown.Html.oneOf []
    , codeSpan = Html.text >> List.singleton >> Html.code []
    , strong = Html.strong []
    , emphasis = Html.em []
    , link =
        \{ destination } ->
            if String.startsWith "http" destination then
                Html.a [ Attr.class "link link--external", Attr.href destination, Attr.target "_blank", Attr.rel "noopener" ]

            else
                Html.a [ Attr.class "link", Attr.href destination ]
    , image = \{ src, alt } -> Html.img [ Attr.src src, Attr.alt alt ] []
    , unorderedList = \items -> Html.ul [] (List.map (\(Markdown.Block.ListItem _ views) -> Html.li [] views) items)
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
    , thematicBreak = Html.br [] []
    , hardLineBreak = Html.hr [] []
    , paragraph = Html.p []
    , table = Html.node "table" []
    , tableBody = Html.node "tbody" []
    , tableCell = Html.node "td" []
    , tableRow = Html.node "tr" []
    , tableHeader = Html.node "thead" []
    , tableHeaderCell = \_ -> Html.node "th" []
    , text = Html.text
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
