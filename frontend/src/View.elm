module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (State(..), Model, Msg(..), Feedback, Metrics)


{-| Main view rendering application state
-}
view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ viewHeader
        , main_ [] [ viewStateContent model ]
        , viewFooter
        ]


{-| Application header
-}
viewHeader : Html Msg
viewHeader =
    header []
        [ h1 [] [ text "Speaking Practice" ]
        , p [ class "subtitle" ] [ text "A calm, distraction-free experience" ]
        ]


{-| Application footer
-}
viewFooter : Html Msg
viewFooter =
    footer []
        [ p [] [ text "Take your time. You're doing great." ]
        ]


{-| Route to appropriate state view
-}
viewStateContent : Model -> Html Msg
viewStateContent model =
    case model.state of
        Idle ->
            viewIdleState

        Breathing ->
            viewBreathingState

        Prompt ->
            viewPromptState

        Speaking ->
            viewSpeakingState

        Feedback ->
            viewFeedbackState model.feedback


{-| Idle state: waiting for user to start
-}
viewIdleState : Html Msg
viewIdleState =
    div [ class "state idle" ]
        [ h2 [] [ text "Ready to practice?" ]
        , p [] [ text "Click below when you're ready to begin." ]
        , div [ class "button-group" ]
            [ button [ class "btn btn-primary", onClick ClickStart ]
                [ i [ class "fas fa-play" ] []
                , text "Start Session"
                ]
            ]
        ]


{-| Breathing state: calm breathing prompt with animation
-}
viewBreathingState : Html Msg
viewBreathingState =
    div [ class "state breathing" ]
        [ h2 [] [ text "Take a moment to breathe" ]
        , div [ class "icon-container breathing-animation" ]
            [ i [ class "fas fa-circle" ] [] ]
        , p [] [ text "Breathe gently. There's no rush." ]
        , div [ class "button-group" ]
            [ button [ class "btn btn-secondary", onClick ClickBreathing ]
                [ text "I'm ready"
                , i [ class "fas fa-arrow-right" ] []
                ]
            ]
        ]


{-| Prompt state: display speaking prompt
-}
viewPromptState : Html Msg
viewPromptState =
    div [ class "state prompt" ]
        [ h2 [] [ text "Here's your prompt" ]
        , div [ class "prompt-text" ]
            [ i [ class "fas fa-quote-left" ] []
            , text " Tell me about your favorite hobby. "
            , i [ class "fas fa-quote-right" ] []
            ]
        , p [] [ text "Speak at your own pace. Take pauses whenever you need." ]
        , div [ class "button-group" ]
            [ button [ class "btn btn-secondary", onClick ClickPrompt ]
                [ i [ class "fas fa-microphone" ] []
                , text "Start speaking"
                ]
            ]
        ]


{-| Speaking state: indicate user is speaking
-}
viewSpeakingState : Html Msg
viewSpeakingState =
    div [ class "state speaking" ]
        [ h2 [] [ text "You're speaking" ]
        , div [ class "icon-container speaking-indicator" ]
            [ i [ class "fas fa-microphone" ] [] ]
        , p [] [ text "Take your time. Pause whenever you need." ]
        , div [ class "button-group" ]
            [ button [ class "btn btn-primary", onClick ClickDone ]
                [ i [ class "fas fa-check" ] []
                , text "I'm done"
                ]
            ]
        ]


{-| Feedback state: display detailed AI feedback or loading state
-}
viewFeedbackState : Maybe Feedback -> Html Msg
viewFeedbackState maybeFeedback =
    div [ class "state feedback" ]
        [ h2 [] [ text "Great job! 🎉" ]
        , case maybeFeedback of
            Just feedback ->
                div [ class "feedback-container" ]
                    [ viewFeedbackCard feedback
                    , div [ class "button-group" ]
                        [ button [ class "btn btn-secondary", onClick ClickRestart ]
                            [ i [ class "fas fa-redo" ] []
                            , text "Practice again"
                            ]
                        ]
                    ]

            Nothing ->
                div [ class "loading-container" ]
                    [ p [] [ text "Analyzing your speech..." ]
                    , div [ class "spinner" ] []
                    , p [ class "loading-text" ] [ text "AI is generating personalized feedback" ]
                    ]
        ]


{-| Feedback card with multiple sections
-}
viewFeedbackCard : Feedback -> Html Msg
viewFeedbackCard feedback =
    div [ class "feedback-card" ]
        [ viewFeedbackSection "💬 Encouragement" feedback.encouragement "encouragement"
        , viewFeedbackSection "⏱️ Pacing Analysis" feedback.pacing "pacing"
        , viewFeedbackSection "💡 Tips for Improvement" feedback.tips "tips"
        , case feedback.metrics of
            Just metrics ->
                viewMetricsSection metrics

            Nothing ->
                text ""
        ]


{-| Individual feedback section
-}
viewFeedbackSection : String -> String -> String -> Html Msg
viewFeedbackSection title content sectionClass =
    div [ class ("feedback-section " ++ sectionClass) ]
        [ h3 [ class "feedback-section-title" ] [ text title ]
        , p [ class "feedback-section-content" ] [ text content ]
        ]


{-| Metrics display section
-}
viewMetricsSection : Metrics -> Html Msg
viewMetricsSection metrics =
    div [ class "feedback-section metrics" ]
        [ h3 [ class "feedback-section-title" ] [ text "📊 Speech Metrics" ]
        , div [ class "metrics-grid" ]
            [ viewMetricItem "Words" (String.fromInt metrics.words)
            , viewMetricItem "Sentences" (String.fromInt metrics.sentences)
            , viewMetricItem "Avg Length" (String.fromFloat (roundTo 2 metrics.avgSentenceLength) ++ " words/sentence")
            , viewMetricItem "Est. Speed" (String.fromFloat (roundTo 1 metrics.estimatedWpm) ++ " WPM")
            ]
        ]


{-| Individual metric item
-}
viewMetricItem : String -> String -> Html Msg
viewMetricItem label value =
    div [ class "metric-item" ]
        [ p [ class "metric-label" ] [ text label ]
        , p [ class "metric-value" ] [ text value ]
        ]


{-| Helper to round floats
-}
roundTo : Int -> Float -> Float
roundTo decimals value =
    let
        multiplier =
            toFloat (10 ^ decimals)
    in
    toFloat (round (value * multiplier)) / multiplier
