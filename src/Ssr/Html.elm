module Ssr.Html exposing
    ( Html, map
    , text, node, div
    , header, footer
    , a, span
    , h1, h2, h3, h4, h5, h6
    , p, ul, ol, li
    , toString, toHtml
    )

{-|

@docs Html, map

@docs text, node, div

@docs header, footer

@docs a, span

@docs h1, h2, h3, h4, h5, h6

@docs p, ul, ol, li

@docs toString, toHtml

-}

import Html as Core
import Ssr.Attributes as Attributes exposing (Attribute)


type Html msg
    = Node String (List (Attribute msg)) (List (Html msg))
    | Text String


map : (a -> b) -> Html a -> Html b
map fn html =
    case html of
        Node tag attrs children ->
            Node tag
                (List.map (Attributes.map fn) attrs)
                (List.map (map fn) children)

        Text string ->
            Text string



-- TEXT


text : String -> Html msg
text =
    Text



-- NODES


node : String -> List (Attribute msg) -> List (Html msg) -> Html msg
node =
    Node


div : List (Attribute msg) -> List (Html msg) -> Html msg
div =
    node "div"


header : List (Attribute msg) -> List (Html msg) -> Html msg
header =
    node "header"


footer : List (Attribute msg) -> List (Html msg) -> Html msg
footer =
    node "footer"


a : List (Attribute msg) -> List (Html msg) -> Html msg
a =
    node "a"


span : List (Attribute msg) -> List (Html msg) -> Html msg
span =
    node "span"


p : List (Attribute msg) -> List (Html msg) -> Html msg
p =
    node "p"


ul : List (Attribute msg) -> List (Html msg) -> Html msg
ul =
    node "ul"


ol : List (Attribute msg) -> List (Html msg) -> Html msg
ol =
    node "ol"


li : List (Attribute msg) -> List (Html msg) -> Html msg
li =
    node "li"


h1 : List (Attribute msg) -> List (Html msg) -> Html msg
h1 =
    node "h1"


h2 : List (Attribute msg) -> List (Html msg) -> Html msg
h2 =
    node "h2"


h3 : List (Attribute msg) -> List (Html msg) -> Html msg
h3 =
    node "h3"


h4 : List (Attribute msg) -> List (Html msg) -> Html msg
h4 =
    node "h4"


h5 : List (Attribute msg) -> List (Html msg) -> Html msg
h5 =
    node "h5"


h6 : List (Attribute msg) -> List (Html msg) -> Html msg
h6 =
    node "h6"



-- rendering


toString : Html msg -> String
toString html =
    case html of
        Node tag attrs children ->
            String.concat
                [ "<"
                , tag
                , if List.isEmpty attrs then
                    ""

                  else
                    " " ++ Attributes.toString attrs
                , ">"
                , children |> List.map toString |> String.concat
                , "</"
                , tag
                , ">"
                ]

        Text string ->
            string


toHtml : Html msg -> Core.Html msg
toHtml html =
    case html of
        Node tag attrs children ->
            Core.node tag (List.map Attributes.toHtmlAttribute attrs) (List.map toHtml children)

        Text string ->
            Core.text string
