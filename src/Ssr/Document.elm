module Ssr.Document exposing (Document, Meta, toDocument)

{-|

@docs Document, Meta, toDocument

-}

import Browser
import Ssr.Html as Html exposing (Html)


type alias Document msg =
    { meta : Meta
    , body : List (Html msg)
    }


type alias Meta =
    { title : String
    , description : String
    , image : String
    }


toDocument : Document msg -> Browser.Document msg
toDocument { meta, body } =
    Browser.Document
        meta.title
        (List.map Html.toLazyHtml body)
