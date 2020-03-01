module Pages.NotFound exposing (view)

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


view : Document msg
view =
    { meta =
        { title = "404 | rhg.dev"
        , description = "that's not a page!"
        , image = "https://avatars2.githubusercontent.com/u/6187256"
        }
    , body =
        [ div [ class "container" ]
            [ Components.navbar
            , h1 [] [ text "Not found" ]
            , Components.footer
            ]
        ]
    }
