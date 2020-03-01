module Pages.Post exposing (view)

import Ssr.Attributes exposing (class)
import Ssr.Document exposing (Document)
import Ssr.Html exposing (..)


view : String -> Document msg
view slug =
    { meta =
        { title = titleify slug ++ " | posts | rhg.dev"
        , description = "i have no idea what I'm doing."
        , image = "https://avatars2.githubusercontent.com/u/6187256"
        }
    , body =
        [ h1 [] [ text ("Post: " ++ slug) ]
        ]
    }


titleify : String -> String
titleify =
    String.replace "-" " "
