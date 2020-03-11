module Pages.Post exposing (view)

import Content
import Ssr.Attributes exposing (class)
import Ssr.Document exposing (Document)
import Ssr.Html exposing (..)
import Ssr.Markdown exposing (markdown)


view : String -> Document msg
view slug =
    Content.viewPost slug
        |> Maybe.withDefault
            { meta =
                { title = "404 | posts | rhg.dev"
                , description = "that post wasn't found..."
                , image = "https://avatars2.githubusercontent.com/u/6187256"
                }
            , body =
                [ div [ class "column spacing-2" ]
                    [ div [ class "column" ]
                        [ h1 [] [ text "hi, i'm ryan." ]
                        , h2 [] [ text "and i build things." ]
                        ]
                    , markdown ""
                    ]
                ]
            }
