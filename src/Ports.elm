port module Ports exposing (afterNavigate)

import Ssr.Document

port afterNavigate : Ssr.Document.Meta -> Cmd msg
