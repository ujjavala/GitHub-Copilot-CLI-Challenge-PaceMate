module Types exposing (State(..), Model, Msg(..), Feedback, Metrics, Theme(..), Page(..), AnalyticsData)


{-| Page navigation
-}
type Page
    = PracticePage
    | DashboardPage


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


{-| Analytics data from backend
-}
type alias AnalyticsData =
    { totalSessions : Int
    , totalWords : Int
    , averageWpm : Float
    , currentStreak : Int
    }


{-| Application model containing session state and feedback
-}
type alias Model =
    { state : State
    , feedback : Maybe Feedback
    , theme : Theme
    , currentPage : Page
    , analytics : Maybe AnalyticsData
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
    | NavigateTo Page
    | ReceiveFeedback (Result String Feedback)
    | ReceiveAnalytics (Result String AnalyticsData)
