module {{moduleName}} exposing (view)

import Ssr.Attributes exposing (class)
import Ssr.Document exposing (Document)
import Ssr.Html exposing (..)
import Ssr.Markdown exposing (markdown)


view : Document msg
view =
    { meta =
        { title = "{{meta.title}} | posts | rhg.dev"
        , description = "{{meta.description}}"
        , image = "{{meta.image}}"
        }
    , body =
        [ div [ class "column" ]
            [ h1 [] [ text "{{meta.title}}" ]
            , h2 [] [ text "{{meta.description}}" ]
            ]
        , markdown {{content}}
        ]
    }