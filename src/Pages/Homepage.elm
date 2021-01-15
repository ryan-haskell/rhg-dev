module Pages.Homepage exposing (view)

import Components
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
            [ div [ class "column" ]
                [ h1 [] [ text "hey, i'm ryan." ]
                , h2 [] [ text "welcome to here!" ]
                ]
            , div [ class "column spacing-1" ]
                [ markdown """
My name is Ryan Haskell-Glatz, and I'm a web developer from Chicago.
This site is where I share random projects I've been working on.

I tried to make it with Comic Sans, but that fell apart very quickly.

I usually write about design, elm, and side projects.
If you're interested in that sort of thing, you should check out
my blog posts!

### latest posts
"""
                , Components.posts (Just 3)
                , markdown """
### other places

I'm not much of a social media guy, but if you'd like you can follow me on [github](https://www.github.com/ryannhg) or [twitter](https://www.twitter.com/rhg_dev).
But I also have links for those like two inches below this paragraph (just in case)!
"""
                ]
            ]
        ]
    }
