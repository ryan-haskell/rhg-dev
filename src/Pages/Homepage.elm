module Pages.Homepage exposing (view)

import Ssr.Attributes exposing (class)
import Ssr.Document exposing (Document)
import Ssr.Html exposing (..)
import Ssr.Markdown exposing (markdown)


view : Document msg
view =
    { meta =
        { title = "rhg.dev"
        , description = "i have no idea what I'm doing."
        , image = "https://avatars2.githubusercontent.com/u/6187256"
        }
    , body =
        [ div [ class "column spacing-2" ]
            [ h1 [] [ text "hi, i'm ryan." ]
            , markdown """
### welcome to my site.

I'm a web developer working in Chicago! This site is a place for me to keep
track of projects and blog posts.

"""
            ]
        ]
    }
