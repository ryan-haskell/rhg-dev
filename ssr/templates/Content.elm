module Generated.Content exposing
    ( viewPost
    )

{{imports}}
import Ssr.Document exposing (Document)


viewPost : String -> Maybe (Document msg)
viewPost slug =
    case slug of
{{conditions}}
        _ ->
            Nothing
