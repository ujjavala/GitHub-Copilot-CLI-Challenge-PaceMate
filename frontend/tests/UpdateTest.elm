module UpdateTest exposing (..)

import Expect
import Test exposing (..)
import Types exposing (State(..), Model, Msg(..))
import Update


suite : Test
suite =
    describe "Update module"
        [ describe "ClickStart"
            [ test "transitions from Idle to Breathing" <|
                \() ->
                    let
                        model = { state = Idle, feedback = Nothing }
                        ( newModel, _ ) = Update.update ClickStart model
                    in
                    Expect.equal newModel.state Breathing
            ]
        , describe "ClickBreathing"
            [ test "transitions from Breathing to Prompt" <|
                \() ->
                    let
                        model = { state = Breathing, feedback = Nothing }
                        ( newModel, _ ) = Update.update ClickBreathing model
                    in
                    Expect.equal newModel.state Prompt
            ]
        , describe "ClickPrompt"
            [ test "transitions from Prompt to Speaking" <|
                \() ->
                    let
                        model = { state = Prompt, feedback = Nothing }
                        ( newModel, _ ) = Update.update ClickPrompt model
                    in
                    Expect.equal newModel.state Speaking
            ]
        , describe "ClickDone"
            [ test "transitions from Speaking to Feedback" <|
                \() ->
                    let
                        model = { state = Speaking, feedback = Nothing }
                        ( newModel, _ ) = Update.update ClickDone model
                    in
                    Expect.equal newModel.state Feedback
            , test "clears feedback when transitioning to Feedback" <|
                \() ->
                    let
                        model = { state = Speaking, feedback = Just "Old feedback" }
                        ( newModel, _ ) = Update.update ClickDone model
                    in
                    Expect.equal newModel.feedback Nothing
            ]
        , describe "ClickRestart"
            [ test "transitions from Feedback to Idle" <|
                \() ->
                    let
                        model = { state = Feedback, feedback = Just "Great job!" }
                        ( newModel, _ ) = Update.update ClickRestart model
                    in
                    Expect.equal newModel.state Idle
            , test "clears feedback when restarting" <|
                \() ->
                    let
                        model = { state = Feedback, feedback = Just "Great job!" }
                        ( newModel, _ ) = Update.update ClickRestart model
                    in
                    Expect.equal newModel.feedback Nothing
            ]
        , describe "ReceiveFeedback"
            [ test "sets feedback when receiving success" <|
                \() ->
                    let
                        model = { state = Feedback, feedback = Nothing }
                        ( newModel, _ ) = Update.update (ReceiveFeedback (Ok "Nice pacing!")) model
                    in
                    Expect.equal newModel.feedback (Just "Nice pacing!")
            , test "keeps model unchanged on error" <|
                \() ->
                    let
                        model = { state = Feedback, feedback = Nothing }
                        ( newModel, _ ) = Update.update (ReceiveFeedback (Err "Error")) model
                    in
                    Expect.equal newModel model
            ]
        ]
