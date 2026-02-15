module Main exposing (main)

import Browser
import Types exposing (Model, Msg(..))
import Update
import View
import Subscriptions
import Prompts
import Random


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


{-| Initialize application with idle state and light theme
-}
init : () -> ( Model, Cmd Msg )
init () =
    ( { state = Types.Idle
      , feedback = Nothing
      , theme = Types.Light
      , currentPage = Types.PracticePage
      , analytics = Nothing
      , selectedWidget = Nothing
      , sessionHistory = []
      , currentPrompt = "Tell me about your day and what you're looking forward to."
      }
    , Random.generate Types.GenerateRandomPrompt Prompts.getRandomPrompt
    )
