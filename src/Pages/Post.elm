module Pages.Post exposing (view)

import Components
import Ssr.Attributes exposing (class)
import Ssr.Document exposing (Document)
import Ssr.Html exposing (..)



-- import Ssr.Router exposing (Page)
-- type alias Model =
--     ()
-- type alias Msg =
--     Never
-- page : Page () Model Msg
-- page =
--     Ssr.Router.static
--         { view = view
--         }


view : String -> Document msg
view slug =
    { meta =
        { title = "rhg.dev"
        , description = "i have no idea what I'm doing."
        , image = "https://avatars2.githubusercontent.com/u/6187256"
        }
    , body =
        [ div [ class "container" ]
            [ Components.navbar
            , h1 [] [ text ("Post: " ++ slug) ]
            , Components.footer
            ]
        ]
    }
