module Pages.Posts exposing (view)

import Components
import Ssr.Attributes exposing (class)
import Ssr.Document exposing (Document)
import Ssr.Html exposing (..)


view : Document msg
view =
    { meta =
        { title = "posts | rhg.dev"
        , description = "the latest and greatest."
        , image = "https://avatars2.githubusercontent.com/u/6187256"
        }
    , body =
        [ div [ class "column spacing-2" ]
            [ div []
                [ h1 [] [ text "posts" ]
                , h2 [] [ text "i can read ", em [] [ text "and" ], text " write!" ]
                ]
            , Components.posts Nothing
            ]
        ]
    }
