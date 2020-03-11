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
                [ h1 [] [ text "hi, i'm ryan." ]
                , h2 [] [ text "and you're yourself, how nice!" ]
                ]
            , div [ class "column spacing-1" ]
                [ markdown """
### welcome to here

My name is Ryan Haskell-Glatz– and I'm a web developer near Chicago!
This site is where I share random things I've been working on.

I tried to make it with Comic Sans, but that fell apart very quickly.

I usually like to write about design, elm, and side projects I'm creating.
If you're interested in that kind of thing, you should check out
my blog posts!

### latest posts
"""
                , Components.posts (Just 3)
                , markdown """
### other places

I'm not much of a social media guy, but if you'd like you can follow me on [github](https://www.github.com/ryannhg) or [twitter](https://www.twitter.com/ryan_nhg).
I also have links for those like two inches below this paragraph (just in case)!
"""
                ]
            ]
        ]
    }
