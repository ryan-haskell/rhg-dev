module Pages.Homepage exposing (view)

import Ssr.Attributes exposing (class)
import Ssr.Document exposing (Document)
import Ssr.Html exposing (..)


view : Document msg
view =
    { meta =
        { title = "rhg.dev"
        , description = "i have no idea what I'm doing."
        , image = "https://avatars2.githubusercontent.com/u/6187256"
        }
    , body =
        [ h1 [] [ text "Homepage" ]
        ]
    }
