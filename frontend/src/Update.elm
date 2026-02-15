port module Update exposing (update, send, themeChanged, fetchAnalytics)

import Json.Encode as Encode
import Types exposing (State(..), Model, Msg(..), Feedback, Theme(..), Page(..))


{-| Pure update function implementing state machine logic
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickStart ->
            ( { model | state = Breathing }
            , Cmd.none
            )

        ClickBreathing ->
            ( { model | state = Prompt }
            , Cmd.none
            )

        ClickPrompt ->
            ( { model | state = Speaking }
            , sendStartSpeaking ()
            )

        ClickDone ->
            ( { model | state = FeedbackState, feedback = Nothing }
            , sendFinishedSpeaking ()
            )

        ReceiveFeedback result ->
            case result of
                Ok feedback ->
                    ( { model | feedback = Just feedback }
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

        ClickRestart ->
            ( { model | state = Idle, feedback = Nothing }
            , sendRestartSession ()
            )

        ToggleTheme ->
            let
                newTheme =
                    case model.theme of
                        Light ->
                            Dark

                        Dark ->
                            Light

                themeString =
                    case newTheme of
                        Light ->
                            "Light"

                        Dark ->
                            "Dark"
            in
            ( { model | theme = newTheme }
            , themeChanged themeString
            )

        NavigateTo page ->
            let
                cmd =
                    case page of
                        DashboardPage ->
                            fetchAnalytics ()

                        PracticePage ->
                            Cmd.none
            in
            ( { model | currentPage = page }
            , cmd
            )

        ReceiveAnalytics result ->
            case result of
                Ok analyticsData ->
                    ( { model | analytics = Just analyticsData }
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )


{-| Send "start_speaking" message to JavaScript to start microphone
-}
sendStartSpeaking : () -> Cmd Msg
sendStartSpeaking () =
    let
        message =
            Encode.object
                [ ( "topic", Encode.string "session:user_session" )
                , ( "event", Encode.string "start_speaking" )
                , ( "payload", Encode.object [] )
                ]
    in
    send message


{-| Send "finished_speaking" message to backend
-}
sendFinishedSpeaking : () -> Cmd Msg
sendFinishedSpeaking () =
    let
        message =
            Encode.object
                [ ( "topic", Encode.string "session:user_session" )
                , ( "event", Encode.string "finished_speaking" )
                , ( "payload", Encode.object [] )
                ]
    in
    send message


{-| Send "restart_session" message to backend
-}
sendRestartSession : () -> Cmd Msg
sendRestartSession () =
    let
        message =
            Encode.object
                [ ( "topic", Encode.string "session:user_session" )
                , ( "event", Encode.string "restart_session" )
                , ( "payload", Encode.object [] )
                ]
    in
    send message


{-| External port for sending WebSocket messages
-}
port send : Encode.Value -> Cmd msg


{-| Port for notifying JavaScript about theme changes
-}
port themeChanged : String -> Cmd msg


{-| Port for fetching analytics data from backend
-}
port fetchAnalytics : () -> Cmd msg
