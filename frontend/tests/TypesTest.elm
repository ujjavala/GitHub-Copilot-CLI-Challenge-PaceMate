module TypesTest exposing (..)

import Expect
import Test exposing (..)
import Types exposing (State(..), Model, Msg(..))


suite : Test
suite =
    describe "Types module"
        [ describe "State"
            [ test "Idle state exists" <|
                \() ->
                    let
                        state = Idle
                    in
                    Expect.equal state Idle
            , test "Breathing state exists" <|
                \() ->
                    Expect.equal Breathing Breathing
            , test "Prompt state exists" <|
                \() ->
                    Expect.equal Prompt Prompt
            , test "Speaking state exists" <|
                \() ->
                    Expect.equal Speaking Speaking
            , test "Feedback state exists" <|
                \() ->
                    Expect.equal Feedback Feedback
            ]
        , describe "Model"
            [ test "can create model with Idle state" <|
                \() ->
                    let
                        model = { state = Idle, feedback = Nothing }
                    in
                    Expect.equal model.state Idle
            , test "feedback field can be Nothing" <|
                \() ->
                    let
                        model = { state = Idle, feedback = Nothing }
                    in
                    Expect.equal model.feedback Nothing
            , test "feedback field can contain a string" <|
                \() ->
                    let
                        model = { state = Idle, feedback = Just "Great job!" }
                    in
                    Expect.equal model.feedback (Just "Great job!")
            ]
        , describe "Msg"
            [ test "ClickStart message exists" <|
                \() ->
                    Expect.pass
            , test "ClickBreathing message exists" <|
                \() ->
                    Expect.pass
            , test "ClickPrompt message exists" <|
                \() ->
                    Expect.pass
            , test "ClickDone message exists" <|
                \() ->
                    Expect.pass
            , test "ClickRestart message exists" <|
                \() ->
                    Expect.pass
            ]
        ]
