module Types exposing (State(..), Model, Msg(..), Feedback, Metrics, Theme(..))


{-| Session state machine states
-}
type State
    = Idle
    | Breathing
    | Prompt
    | Speaking
    | FeedbackState


{-| Detailed feedback from AI or backend
-}
type alias Feedback =
    { encouragement : String
    , pacing : String
    , tips : String
    , metrics : Maybe Metrics
    }


{-| Speech metrics from analysis
-}
type alias Metrics =
    { words : Int
    , sentences : Int
    , avgSentenceLength : Float
    , estimatedWpm : Float
    }


{-| Theme preference
-}
type Theme
    = Light
    | Dark


{-| Application model containing session state and feedback
-}
type alias Model =
    { state : State
    , feedback : Maybe Feedback
    , theme : Theme
    }


{-| User and system messages
-}
type Msg
    = ClickStart
    | ClickBreathing
    | ClickPrompt
    | ClickDone
    | ClickRestart
    | ToggleTheme
    | ReceiveFeedback (Result String Feedback)
