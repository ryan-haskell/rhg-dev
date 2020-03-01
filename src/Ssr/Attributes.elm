module Ssr.Attributes exposing
    ( Attribute, map
    , attribute, class, style, href
    , on, onClick, onInput
    , toString, toHtmlAttribute
    )

{-|

@docs Attribute, map

@docs attribute, class, style, href

@docs on, onClick, onInput

@docs toString, toHtmlAttribute

-}

import Html as Core
import Html.Attributes as Attrs
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder)


type Attribute msg
    = Attribute String String
    | Event String (Decoder msg)


map : (a -> b) -> Attribute a -> Attribute b
map fn attr =
    case attr of
        Attribute key value ->
            Attribute key value

        Event name decoder ->
            Event name (Decode.map fn decoder)



-- ATTRIBUTES


attribute : String -> String -> Attribute msg
attribute =
    Attribute


class : String -> Attribute msg
class =
    attribute "class"


style : String -> String -> Attribute msg
style prop value =
    attribute "style" (prop ++ ": " ++ value ++ ";")


href : String -> Attribute msg
href =
    attribute "href"



-- EVENTS


on : String -> Decoder msg -> Attribute msg
on =
    Event


onClick : msg -> Attribute msg
onClick =
    on "click"
        << Decode.succeed


onInput : (String -> msg) -> Attribute msg
onInput toMsg =
    on "keyup"
        (Decode.at [ "target", "value" ] Decode.string |> Decode.map toMsg)



-- RENDERING


toString : List (Attribute msg) -> String
toString =
    let
        asString : Attribute msg -> Maybe String
        asString attr =
            case attr of
                Attribute key value ->
                    Just (key ++ "=\"" ++ value ++ "\"")

                Event _ _ ->
                    Nothing
    in
    combineStyles >> List.filterMap asString >> String.join " "


combineStyles : List (Attribute msg) -> List (Attribute msg)
combineStyles attrs =
    let
        nonStyleAttributes : List (Attribute msg)
        nonStyleAttributes =
            List.filter
                (\attr ->
                    case attr of
                        Attribute "style" _ ->
                            False

                        _ ->
                            True
                )
                attrs
    in
    List.foldl
        (\attr styles ->
            case attr of
                Attribute "style" value ->
                    styles ++ [ value ]

                _ ->
                    styles
        )
        []
        attrs
        |> (\styles ->
                if List.isEmpty styles then
                    nonStyleAttributes

                else
                    nonStyleAttributes ++ [ Attribute "style" (String.join " " styles) ]
           )


toHtmlAttribute : Attribute msg -> Core.Attribute msg
toHtmlAttribute attr =
    case attr of
        Attribute key value ->
            Attrs.attribute key value

        Event event decoder ->
            Events.on event decoder
