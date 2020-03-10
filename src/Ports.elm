port module Ports exposing (sendAfterNavigate)


port afterNavigate : () -> Cmd msg


sendAfterNavigate : Cmd msg
sendAfterNavigate =
    afterNavigate ()
