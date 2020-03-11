module Content exposing (viewPost, posts)

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
    }

posts : List Post
posts =
{{posts}}