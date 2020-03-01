module Pages.NotFound exposing (view)

import Ssr.Attributes exposing (class)
import Ssr.Document exposing (Document)
import Ssr.Html exposing (..)


view : Document msg
view =
    { meta =
        { title = "404 | rhg.dev"
        , description = "that's not a page!"
        , image = "https://avatars2.githubusercontent.com/u/6187256"
        }
    , body =
        [ h1 [] [ text "Not found" ]
        ]
    }
