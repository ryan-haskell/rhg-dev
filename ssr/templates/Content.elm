module Content exposing
    ( Post
    , viewPost
    , posts
    )

{{imports}}
import Ssr.Document exposing (Document)


viewPost : String -> Maybe (Document msg)
viewPost slug =
    case slug of
{{conditions}}
        _ ->
            Nothing

type alias Post =
    { slug : String
    , title : String
    , date : Int
    }

posts : List Post
posts =
{{posts}}