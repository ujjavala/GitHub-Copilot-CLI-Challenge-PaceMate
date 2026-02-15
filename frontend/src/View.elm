module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (State(..), Model, Msg(..), Feedback, Metrics, Theme(..), Page(..), AnalyticsData)
import Constants


{-| Main view rendering application state
-}
view : Model -> Html Msg
view model =
    let
        themeClass =
            case model.theme of
                Light ->
                    Constants.themeClassLight

                Dark ->
                    Constants.themeClassDark
    in
    div [ class ("app " ++ themeClass) ]
        [ viewHeader model.theme model.currentPage
        , case model.currentPage of
            PracticePage ->
                div [ class "main-container" ]
                    [ viewHeroSection
                    , main_ [] [ viewStateContent model ]
                    ]

            DashboardPage ->
                div [ class "main-container" ]
                    [ main_ [] [ viewDashboard model.analytics ]
                    ]
        , viewFooter
        ]


{-| Application header with navigation
-}
viewHeader : Theme -> Page -> Html Msg
viewHeader theme currentPage =
    header []
        [ div [ class "header-content" ]
            [ div [ class "header-text" ]
                [ div [ class "header-title-with-logo" ]
                    [ img [ src "pacemate-icon.png", class "app-logo", alt "PaceMate Logo" ] []
                    , h1 [] [ text Constants.headerTitle ]
                    ]
                , p [ class "subtitle" ] [ text Constants.headerSubtitle ]
                ]
            , div [ class "header-actions" ]
                [ viewNavigation currentPage
                , button [ class "theme-toggle", onClick ToggleTheme, title Constants.themeToggleTooltip ]
                    [ i
                        [ class
                            (case theme of
                                Light ->
                                    Constants.iconMoon

                                Dark ->
                                    Constants.iconSun
                            )
                        ]
                        []
                    ]
                ]
            ]
        ]


{-| Navigation tabs
-}
viewNavigation : Page -> Html Msg
viewNavigation currentPage =
    nav [ class "nav-tabs" ]
        [ button
            [ class
                (if currentPage == PracticePage then
                    "nav-tab active"

                 else
                    "nav-tab"
                )
            , onClick (NavigateTo PracticePage)
            ]
            [ i [ class "fas fa-microphone" ] []
            , text " Practice"
            ]
        , button
            [ class
                (if currentPage == DashboardPage then
                    "nav-tab active"

                 else
                    "nav-tab"
                )
            , onClick (NavigateTo DashboardPage)
            ]
            [ i [ class "fas fa-chart-line" ] []
            , text " Dashboard"
            ]
        ]


{-| Hero section with features and benefits
-}
viewHeroSection : Html Msg
viewHeroSection =
    div [ class "hero-section" ]
        [ div [ class "hero-content" ]
            [ h2 [ class "hero-title" ] [ text Constants.heroTitle ]
            , p [ class "hero-description" ]
                [ text Constants.heroDescription ]
            , div [ class "hero-features" ]
                [ viewFeature Constants.iconMicrophone Constants.featureRealTimeTitle Constants.featureRealTimeDescription
                , viewFeature Constants.iconBrain Constants.featureAiCoachTitle Constants.featureAiCoachDescription
                , viewFeature Constants.iconChartLine Constants.featureTrackProgressTitle Constants.featureTrackProgressDescription
                ]
            ]
        ]


{-| Individual feature item
-}
viewFeature : String -> String -> String -> Html Msg
viewFeature iconClass title description =
    div [ class "feature-item" ]
        [ div [ class "feature-icon" ]
            [ i [ class ("fas " ++ iconClass) ] [] ]
        , h3 [ class "feature-title" ] [ text title ]
        , p [ class "feature-description" ] [ text description ]
        ]


{-| Application footer
-}
viewFooter : Html Msg
viewFooter =
    footer []
        [ p [] [ text "Mindful communication practice" ]
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

        FeedbackState ->
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
                , text Constants.startSessionButton
                ]
            ]
        ]


{-| Breathing state: calm breathing prompt with pulsing heart animation
-}
viewBreathingState : Html Msg
viewBreathingState =
    div [ class "state breathing" ]
        [ h2 [] [ text "Take a moment to breathe" ]
        , div [ class "icon-container breathing-animation" ]
            [ i [ class "fas fa-heart" ] [] ]
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
        [ h2 [] [ text Constants.promptTitle ]
        , div [ class "prompt-text" ]
            [ i [ class "fas fa-quote-left" ] []
            , text (" " ++ Constants.promptDefaultText ++ " ")
            , i [ class "fas fa-quote-right" ] []
            ]
        , p [] [ text "Speak at your own pace. Take pauses whenever you need." ]
        , div [ class "button-group" ]
            [ button [ class "btn btn-secondary", onClick ClickPrompt ]
                [ i [ class "fas fa-microphone" ] []
                , text Constants.startSpeakingButton
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
        [ h2 [ class "feedback-title" ]
            [ i [ class "fas fa-star feedback-star-icon" ] []
            , text "Great job!"
            ]
        , case maybeFeedback of
            Just feedback ->
                div [ class "feedback-container" ]
                    [ viewFeedbackCard feedback
                    , div [ class "button-group" ]
                        [ button [ class "btn btn-secondary", onClick ClickRestart ]
                            [ i [ class "fas fa-redo" ] []
                            , text Constants.practiceAgainButton
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
        [ viewFeedbackSection Constants.feedbackEncouragementLabel "fa-heart" feedback.encouragement "encouragement"
        , viewFeedbackSection Constants.feedbackPacingLabel "fa-gauge" feedback.pacing "pacing"
        , viewFeedbackSection Constants.feedbackTipsLabel "fa-lightbulb" feedback.tips "tips"
        , case feedback.metrics of
            Just metrics ->
                viewMetricsSection metrics

            Nothing ->
                text ""
        ]


{-| Individual feedback section
-}
viewFeedbackSection : String -> String -> String -> String -> Html Msg
viewFeedbackSection title iconClass content sectionClass =
    div [ class ("feedback-section " ++ sectionClass) ]
        [ h3 [ class "feedback-section-title" ]
            [ i [ class ("fas " ++ iconClass) ] []
            , text title
            ]
        , p [ class "feedback-section-content" ] [ text content ]
        ]


{-| Metrics display section
-}
viewMetricsSection : Metrics -> Html Msg
viewMetricsSection metrics =
    div [ class "feedback-section metrics" ]
        [ h3 [ class "feedback-section-title" ]
            [ i [ class "fas fa-chart-bar" ] []
            , text Constants.feedbackMetricsTitle
            ]
        , div [ class "metrics-grid" ]
            [ viewMetricItem Constants.feedbackMetricWords (String.fromInt metrics.words)
            , viewMetricItem Constants.feedbackMetricSentences (String.fromInt metrics.sentences)
            , viewMetricItem Constants.feedbackMetricAvgLength (String.fromFloat (roundTo 2 metrics.avgSentenceLength) ++ " words/sentence")
            , viewMetricItem Constants.feedbackMetricWpm (String.fromFloat (roundTo 1 metrics.estimatedWpm) ++ " WPM")
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


{-| Dashboard view showing analytics
-}
viewDashboard : Maybe AnalyticsData -> Html Msg
viewDashboard maybeAnalytics =
    div [ class "dashboard-container" ]
        [ h2 [ class "dashboard-title" ] [ text "Your Progress" ]
        , p [ class "dashboard-subtitle" ] [ text "Track your mindful speaking journey" ]
        , case maybeAnalytics of
            Just analytics ->
                viewAnalyticsGrid analytics

            Nothing ->
                div [ class "loading-container" ]
                    [ p [] [ text "Loading your analytics..." ]
                    , div [ class "spinner" ] []
                    ]
        ]


{-| Analytics grid with stat cards and encouragement
-}
viewAnalyticsGrid : AnalyticsData -> Html Msg
viewAnalyticsGrid analytics =
    div [ class "dashboard-content" ]
        [ viewEncouragement analytics
        , div [ class "analytics-grid" ]
            [ viewStatCard "fa-calendar-check" "Total Sessions" (String.fromInt analytics.totalSessions) "session-card"
            , viewStatCard "fa-comment" "Words Spoken" (String.fromInt analytics.totalWords) "words-card"
            , viewStatCard "fa-gauge-high" "Average WPM" (String.fromFloat (roundTo 1 analytics.averageWpm)) "wpm-card"
            , viewStatCard "fa-fire" "Current Streak" (String.fromInt analytics.currentStreak ++ " days") "streak-card"
            ]
        ]


{-| Encouragement message based on progress
-}
viewEncouragement : AnalyticsData -> Html Msg
viewEncouragement analytics =
    let
        message =
            if analytics.totalSessions == 0 then
                "Ready to start your journey? Every step counts!"

            else if analytics.totalSessions < 5 then
                "You're off to a great start! Keep practicing!"

            else if analytics.currentStreak > 0 then
                "You're rocking it! " ++ String.fromInt analytics.currentStreak ++ " day streak!"

            else
                "Keep up the excellent work! You're making real progress!"
    in
    div [ class "encouragement-banner" ]
        [ i [ class "fas fa-star encouragement-icon" ] []
        , p [ class "encouragement-text" ] [ text message ]
        ]


{-| Individual stat card
-}
viewStatCard : String -> String -> String -> String -> Html Msg
viewStatCard iconClass label value cardClass =
    div [ class ("stat-card " ++ cardClass) ]
        [ div [ class "stat-icon" ]
            [ i [ class ("fas " ++ iconClass) ] [] ]
        , div [ class "stat-content" ]
            [ p [ class "stat-label" ] [ text label ]
            , p [ class "stat-value" ] [ text value ]
            ]
        ]
