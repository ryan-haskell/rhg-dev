module Ssr.Html exposing
    ( Html, map
    , text, node, div
    , header, main_, aside, footer
    , a, span, strong, em
    , h1, h2, h3, h4, h5, h6
    , pre, blockquote, code
    , img, hr, br
    , p, ul, ol, li
    , toString, toHtml
    )

{-|

@docs Html, map

@docs text, node, div

@docs header, main_, aside, footer

@docs a, span, strong, em

@docs h1, h2, h3, h4, h5, h6

@docs pre, blockquote, code

@docs img, hr, br

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


aside : List (Attribute msg) -> List (Html msg) -> Html msg
aside =
    node "aside"


main_ : List (Attribute msg) -> List (Html msg) -> Html msg
main_ =
    node "main"


footer : List (Attribute msg) -> List (Html msg) -> Html msg
footer =
    node "footer"


a : List (Attribute msg) -> List (Html msg) -> Html msg
a =
    node "a"


span : List (Attribute msg) -> List (Html msg) -> Html msg
span =
    node "span"


strong : List (Attribute msg) -> List (Html msg) -> Html msg
strong =
    node "strong"


em : List (Attribute msg) -> List (Html msg) -> Html msg
em =
    node "em"


pre : List (Attribute msg) -> List (Html msg) -> Html msg
pre =
    node "pre"


code : List (Attribute msg) -> List (Html msg) -> Html msg
code =
    node "code"


img : List (Attribute msg) -> List (Html msg) -> Html msg
img =
    node "img"


blockquote : List (Attribute msg) -> List (Html msg) -> Html msg
blockquote =
    node "blockquote"


hr : List (Attribute msg) -> List (Html msg) -> Html msg
hr =
    node "hr"


br : List (Attribute msg) -> List (Html msg) -> Html msg
br =
    node "br"


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
            htmlEncode string


toHtml : Html msg -> Core.Html msg
toHtml html =
    case html of
        Node tag attrs children ->
            Core.node tag (List.map Attributes.toHtmlAttribute attrs) (List.map toHtml children)

        Text string ->
            Core.text string


htmlEncode : String -> String
htmlEncode str =
    List.foldl
        (\( unsafe, safe ) -> String.replace unsafe safe)
        str
        [ ( "<", "&lt;" )
        , ( ">", "&gt;" )
        ]



-- [ ( "\"", "&quot;" )
-- , ( "'", "&apos;" )
-- , ( "&", "&amp;" )
-- , ( "<", "&lt;" )
-- , ( ">", "&gt;" )
-- , ( "&", "&nbsp;" )
-- , ( "¡", "&iexcl;" )
-- , ( "¢", "&cent;" )
-- , ( "£", "&pound;" )
-- , ( "¤", "&curren;" )
-- , ( "¥", "&yen;" )
-- , ( "¦", "&brvbar;" )
-- , ( "§", "&sect;" )
-- , ( "¨", "&uml;" )
-- , ( "©", "&copy;" )
-- , ( "ª", "&ordf;" )
-- , ( "«", "&laquo;" )
-- , ( "¬", "&not;" )
-- , ( "\u{00AD}", "&shy;" )
-- , ( "®", "&reg;" )
-- , ( "¯", "&macr;" )
-- , ( "°", "&deg;" )
-- , ( "±", "&plusmn;" )
-- , ( "²", "&sup2;" )
-- , ( "³", "&sup3;" )
-- , ( "´", "&acute;" )
-- , ( "µ", "&micro;" )
-- , ( "¶", "&para;" )
-- , ( "·", "&middot;" )
-- , ( "¸", "&cedil;" )
-- , ( "¹", "&sup1;" )
-- , ( "º", "&ordm;" )
-- , ( "»", "&raquo;" )
-- , ( "¼", "&frac14;" )
-- , ( "½", "&frac12;" )
-- , ( "¾", "&frac34;" )
-- , ( "¿", "&iquest;" )
-- , ( "×", "&times;" )
-- , ( "÷", "&divide;" )
-- , ( "À", "&Agrave;" )
-- , ( "Á", "&Aacute;" )
-- , ( "Â", "&Acirc;" )
-- , ( "Ã", "&Atilde;" )
-- , ( "Ä", "&Auml;" )
-- , ( "Å", "&Aring;" )
-- , ( "Æ", "&AElig;" )
-- , ( "Ç", "&Ccedil;" )
-- , ( "È", "&Egrave;" )
-- , ( "É", "&Eacute;" )
-- , ( "Ê", "&Ecirc;" )
-- , ( "Ë", "&Euml;" )
-- , ( "Ì", "&Igrave;" )
-- , ( "Í", "&Iacute;" )
-- , ( "Î", "&Icirc;" )
-- , ( "Ï", "&Iuml;" )
-- , ( "Ð", "&ETH;" )
-- , ( "Ñ", "&Ntilde;" )
-- , ( "Ò", "&Ograve;" )
-- , ( "Ó", "&Oacute;" )
-- , ( "Ô", "&Ocirc;" )
-- , ( "Õ", "&Otilde;" )
-- , ( "Ö", "&Ouml;" )
-- , ( "Ø", "&Oslash;" )
-- , ( "Ù", "&Ugrave;" )
-- , ( "Ú", "&Uacute;" )
-- , ( "Û", "&Ucirc;" )
-- , ( "Ü", "&Uuml;" )
-- , ( "Ý", "&Yacute;" )
-- , ( "Þ", "&THORN;" )
-- , ( "ß", "&szlig;" )
-- , ( "à", "&agrave;" )
-- , ( "á", "&aacute;" )
-- , ( "â", "&acirc;" )
-- , ( "ã", "&atilde;" )
-- , ( "ä", "&auml;" )
-- , ( "å", "&aring;" )
-- , ( "æ", "&aelig;" )
-- , ( "ç", "&ccedil;" )
-- , ( "è", "&egrave;" )
-- , ( "é", "&eacute;" )
-- , ( "ê", "&ecirc;" )
-- , ( "ë", "&euml;" )
-- , ( "ì", "&igrave;" )
-- , ( "í", "&iacute;" )
-- , ( "î", "&icirc;" )
-- , ( "ï", "&iuml;" )
-- , ( "ð", "&eth;" )
-- , ( "ñ", "&ntilde;" )
-- , ( "ò", "&ograve;" )
-- , ( "ó", "&oacute;" )
-- , ( "ô", "&ocirc;" )
-- , ( "õ", "&otilde;" )
-- , ( "ö", "&ouml;" )
-- , ( "ø", "&oslash;" )
-- , ( "ù", "&ugrave;" )
-- , ( "ú", "&uacute;" )
-- , ( "û", "&ucirc;" )
-- , ( "ü", "&uuml;" )
-- , ( "ý", "&yacute;" )
-- , ( "þ", "&thorn;" )
-- , ( "ÿ", "&yuml;" )
-- ]
