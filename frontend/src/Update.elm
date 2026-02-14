module Update exposing (update)

import Json.Encode as Encode
import Types exposing (State(..), Model, Msg(..), Feedback)


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
            , Cmd.none
            )

        ClickDone ->
            ( { model | state = Feedback, feedback = Nothing }
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
