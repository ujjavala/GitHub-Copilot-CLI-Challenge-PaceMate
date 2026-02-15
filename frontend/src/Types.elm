module Types exposing (State(..), Model, Msg(..), Feedback, Metrics, Theme(..), Page(..), AnalyticsData, WidgetType(..), SessionHistory)


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


{-| Widget types for dashboard
-}
type WidgetType
    = SessionsWidget
    | WordsWidget
    | WpmWidget
    | StreakWidget


{-| Session history data point
-}
type alias SessionHistory =
    { date : String
    , sessions : Int
    , words : Int
    , avgWpm : Float
    }


{-| Application model containing session state and feedback
-}
type alias Model =
    { state : State
    , feedback : Maybe Feedback
    , theme : Theme
    , currentPage : Page
    , analytics : Maybe AnalyticsData
    , selectedWidget : Maybe WidgetType
    , sessionHistory : List SessionHistory
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
    | SelectWidget WidgetType
    | ReceiveSessionHistory (Result String (List SessionHistory))
