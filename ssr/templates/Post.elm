module Generated.{{moduleName}} exposing (view)

import Components
import Generated.Posts exposing (Post)
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
        [ div [ class "column spacing-2" ]
            [ div [ class "column" ]
                [ h1 [] [ text "{{meta.title}}" ]
                , h2 [] [ text "{{meta.description}}" ]
                ]
            , markdown {{content}}
            , Generated.Posts.nextUp "{{slug}}"
              |> Maybe.map Components.postListing
              |> Maybe.map (\post ->
                    div [ class "column spacing-1" ]
                        [ h3 [] [ text "next up:" ]
                        , post
                        ]
              )
              |> Maybe.withDefault (text "")
            ]
        ]
    }