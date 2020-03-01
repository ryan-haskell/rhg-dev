port module Main.Ssr exposing (main)

import Pages
import Route
import Ssr.Html as Ssr
import Transition


port render : Page -> Cmd msg


type alias Page =
    { meta :
        { title : String
        , description : String
        , image : String
        }
    , path : String
    , content : String
    }


type alias Flags =
    { config : { baseUrl : String }
    , path : String
    }


main : Program Flags () msg
main =
    Platform.worker
        { init = \flags -> ( (), render (viewPage flags) )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


viewPage : Flags -> Page
viewPage { config, path } =
    let
        view =
            Pages.view
                { transition = Transition.Visible }
                (Route.fromPath config path)
    in
    { meta = view.meta
    , path = path
    , content = String.concat (List.map Ssr.toString view.body)
    }
