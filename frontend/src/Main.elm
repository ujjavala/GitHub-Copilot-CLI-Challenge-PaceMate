module Main exposing (main)

import Browser
import Types exposing (Model, Msg(..))
import Update
import View
import Subscriptions


{-| Main application entry point
-}
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        }


{-| Initialize application with idle state
-}
init : () -> ( Model, Cmd Msg )
init () =
    ( { state = Types.Idle, feedback = Nothing }
    , Cmd.none
    )
