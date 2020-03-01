module Ssr.Document exposing (Document, toDocument)

{-|

@docs Document, toDocument

-}

import Browser
import Ssr.Html as Html exposing (Html)


type alias Document msg =
    { meta :
        { title : String
        , description : String
        , image : String
        }
    , body : List (Html msg)
    }


toDocument : Document msg -> Browser.Document msg
toDocument { meta, body } =
    Browser.Document
        meta.title
        (List.map Html.toHtml body)
