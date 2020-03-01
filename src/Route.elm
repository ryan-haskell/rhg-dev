module Route exposing
    ( Route(..)
    , fromPath
    , fromUrl
    , toPath
    )

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Homepage
    | Posts
    | Post String
    | NotFound


routes : Parser (Route -> a) a
routes =
    Parser.oneOf
        [ Parser.map Homepage Parser.top
        , Parser.map Posts (Parser.s "posts")
        , Parser.map Post (Parser.s "posts" </> Parser.string)
        ]


fromUrl : Url -> Route
fromUrl =
    Parser.parse routes
        >> Maybe.withDefault NotFound


fromPath : { config | baseUrl : String } -> String -> Route
fromPath config =
    (++) config.baseUrl
        >> Url.fromString
        >> Maybe.map fromUrl
        >> Maybe.withDefault NotFound


toPath : Route -> String
toPath route =
    case route of
        Homepage ->
            "/"

        Posts ->
            "/posts"

        Post slug ->
            "/posts/" ++ slug

        NotFound ->
            "/not-found"
