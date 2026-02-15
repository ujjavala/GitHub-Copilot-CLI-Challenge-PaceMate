module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Svg exposing (svg, line, circle, text_, polyline, g, rect)
import Svg.Attributes as SvgAttr
import Types exposing (State(..), Model, Msg(..), Feedback, Metrics, Theme(..), Page(..), AnalyticsData, WidgetType(..), SessionHistory)
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
                    [ viewDashboard model
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


{-| Dashboard view showing analytics with optional chart
-}
viewDashboard : Model -> Html Msg
viewDashboard model =
    div [ class "dashboard-layout" ]
        [ div [ class "dashboard-left" ]
            [ div [ class "dashboard-container" ]
                [ h2 [ class "dashboard-title" ] [ text "Your Progress" ]
                , p [ class "dashboard-subtitle" ] [ text "Track your mindful speaking journey" ]
                , case model.analytics of
                    Just analytics ->
                        div []
                            [ viewEncouragement analytics
                            , viewAnalyticsGrid analytics model.selectedWidget
                            ]

                    Nothing ->
                        div [ class "loading-container" ]
                            [ p [] [ text "Loading your analytics..." ]
                            , div [ class "spinner" ] []
                            ]
                ]
            ]
        , div [ class "dashboard-right" ]
            [ case ( model.selectedWidget, model.analytics ) of
                ( Just widgetType, Just _ ) ->
                    viewChart widgetType model.sessionHistory

                ( Nothing, Just _ ) ->
                    div [ class "chart-placeholder" ]
                        [ i [ class "fas fa-chart-line chart-placeholder-icon" ] []
                        , p [ class "chart-placeholder-text" ] [ text "Click on a stat card to view detailed trends" ]
                        ]

                _ ->
                    text ""
            ]
        ]


{-| Analytics grid with stat cards
-}
viewAnalyticsGrid : AnalyticsData -> Maybe WidgetType -> Html Msg
viewAnalyticsGrid analytics selectedWidget =
    div [ class "analytics-grid" ]
        [ viewStatCard SessionsWidget "fa-calendar-check" "Total Sessions" (String.fromInt analytics.totalSessions) "session-card" selectedWidget
        , viewStatCard WordsWidget "fa-comment" "Words Spoken" (String.fromInt analytics.totalWords) "words-card" selectedWidget
        , viewStatCard WpmWidget "fa-gauge-high" "Average WPM" (String.fromFloat (roundTo 1 analytics.averageWpm)) "wpm-card" selectedWidget
        , viewStatCard StreakWidget "fa-fire" "Current Streak" (String.fromInt analytics.currentStreak ++ " days") "streak-card" selectedWidget
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


{-| Individual stat card with click handler
-}
viewStatCard : WidgetType -> String -> String -> String -> String -> Maybe WidgetType -> Html Msg
viewStatCard widgetType iconClass label value cardClass selectedWidget =
    let
        isSelected =
            selectedWidget == Just widgetType

        selectedClass =
            if isSelected then " selected" else ""
    in
    div
        [ class ("stat-card " ++ cardClass ++ selectedClass)
        , onClick (SelectWidget widgetType)
        ]
        [ div [ class "stat-icon" ]
            [ i [ class ("fas " ++ iconClass) ] [] ]
        , div [ class "stat-content" ]
            [ p [ class "stat-label" ] [ text label ]
            , p [ class "stat-value" ] [ text value ]
            ]
        ]


{-| Chart container with title and content
-}
viewChart : WidgetType -> List SessionHistory -> Html Msg
viewChart widgetType history =
    div [ class "chart-container" ]
        [ h3 [ class "chart-title" ]
            [ i [ class ("fas " ++ getWidgetIcon widgetType), style "margin-right" "0.5rem" ] []
            , text (getChartTitle widgetType)
            ]
        , if List.isEmpty history then
            div [ class "chart-empty" ]
                [ i [ class "fas fa-chart-line", style "font-size" "3rem", style "opacity" "0.3", style "margin-bottom" "1rem" ] []
                , p [] [ text "No data available yet." ]
                , p [ style "font-size" "0.9rem", style "opacity" "0.7" ] [ text "Start practicing to see your progress!" ]
                ]
          else
            viewTimelineChart widgetType history
        ]


{-| Get chart title based on widget type
-}
getChartTitle : WidgetType -> String
getChartTitle widgetType =
    case widgetType of
        SessionsWidget ->
            "Sessions Over Time"

        WordsWidget ->
            "Words Spoken Trend"

        WpmWidget ->
            "Speaking Speed (WPM)"

        StreakWidget ->
            "Practice Consistency"


{-| Get icon for widget type
-}
getWidgetIcon : WidgetType -> String
getWidgetIcon widgetType =
    case widgetType of
        SessionsWidget ->
            "fa-calendar-check"

        WordsWidget ->
            "fa-comment"

        WpmWidget ->
            "fa-gauge-high"

        StreakWidget ->
            "fa-fire"


{-| Timeline chart using SVG
-}
viewTimelineChart : WidgetType -> List SessionHistory -> Html Msg
viewTimelineChart widgetType history =
    let
        width = 700
        height = 400
        paddingValue = 60
        chartWidthValue = width - (2 * paddingValue)
        chartHeightValue = height - (2 * paddingValue)

        dataPoints = extractDataPoints widgetType history
        maxValue = List.maximum dataPoints |> Maybe.withDefault 1 |> Basics.max 1
        pointCount = List.length dataPoints

        xStep = if pointCount > 1 then toFloat chartWidthValue / toFloat (pointCount - 1) else 0
        yScale = toFloat chartHeightValue / maxValue

        points =
            List.indexedMap
                (\index value ->
                    let
                        x =
                            toFloat paddingValue + (toFloat index * xStep)

                        y =
                            toFloat paddingValue + (toFloat chartHeightValue - (value * yScale))
                    in
                    ( x, y )
                )
                dataPoints

        linePoints = points
            |> List.map (\(x, y) -> String.fromFloat x ++ "," ++ String.fromFloat y)
            |> String.join " "
    in
    svg
        [ SvgAttr.width (String.fromInt width)
        , SvgAttr.height (String.fromInt height)
        , SvgAttr.class "timeline-chart"
        , SvgAttr.viewBox ("0 0 " ++ String.fromInt width ++ " " ++ String.fromInt height)
        ]
        [ -- Background grid
          g [ SvgAttr.class "chart-grid" ]
            (List.range 0 4 |> List.map (\i ->
                let
                    y = toFloat paddingValue + (toFloat i * (toFloat chartHeightValue / 4))
                in
                line
                    [ SvgAttr.x1 (String.fromFloat (toFloat paddingValue))
                    , SvgAttr.y1 (String.fromFloat y)
                    , SvgAttr.x2 (String.fromFloat (toFloat (paddingValue + chartWidthValue)))
                    , SvgAttr.y2 (String.fromFloat y)
                    , SvgAttr.stroke "#e0e0e0"
                    , SvgAttr.strokeWidth "1"
                    ]
                    []
            ))
        , -- Y-axis labels
          g [ SvgAttr.class "chart-labels" ]
            (List.range 0 4 |> List.map (\i ->
                let
                    value = maxValue * (1 - (toFloat i / 4))
                    y = toFloat paddingValue + (toFloat i * (toFloat chartHeightValue / 4))
                in
                text_
                    [ SvgAttr.x (String.fromFloat (toFloat paddingValue - 10))
                    , SvgAttr.y (String.fromFloat (y + 4))
                    , SvgAttr.textAnchor "end"
                    , SvgAttr.fontSize "12"
                    , SvgAttr.fill "#666"
                    ]
                    [ Svg.text (formatValue widgetType value) ]
            ))
        , -- Data line
          polyline
            [ SvgAttr.points linePoints
            , SvgAttr.fill "none"
            , SvgAttr.stroke "#3b82f6"
            , SvgAttr.strokeWidth "3"
            , SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            ]
            []
        , -- Data points
          g [ SvgAttr.class "chart-points" ]
            (points |> List.map (\(x, y) ->
                circle
                    [ SvgAttr.cx (String.fromFloat x)
                    , SvgAttr.cy (String.fromFloat y)
                    , SvgAttr.r "6"
                    , SvgAttr.fill "#3b82f6"
                    , SvgAttr.class "chart-point"
                    ]
                    []
            ))
        , -- X-axis date labels (show first, middle, and last dates)
          g [ SvgAttr.class "chart-x-labels" ]
            (let
                labelIndices =
                    if pointCount <= 3 then
                        List.range 0 (pointCount - 1)
                    else
                        [ 0, pointCount // 2, pointCount - 1 ]
             in
             labelIndices
                |> List.filterMap (\index ->
                    case ( List.drop index history |> List.head, List.drop index points |> List.head ) of
                        ( Just historyItem, Just (x, _) ) ->
                            Just (
                                text_
                                    [ SvgAttr.x (String.fromFloat x)
                                    , SvgAttr.y (String.fromFloat (toFloat (paddingValue + chartHeightValue + 20)))
                                    , SvgAttr.textAnchor "middle"
                                    , SvgAttr.fontSize "11"
                                    , SvgAttr.fill "#666"
                                    ]
                                    [ Svg.text (formatDate historyItem.date) ]
                            )
                        _ ->
                            Nothing
                )
            )
        ]


{-| Extract data points for specific widget type
-}
extractDataPoints : WidgetType -> List SessionHistory -> List Float
extractDataPoints widgetType history =
    case widgetType of
        SessionsWidget ->
            List.map (\h -> toFloat h.sessions) history

        WordsWidget ->
            List.map (\h -> toFloat h.words) history

        WpmWidget ->
            List.map (\h -> h.avgWpm) history

        StreakWidget ->
            List.map (\h -> toFloat h.sessions) history


{-| Format value based on widget type
-}
formatValue : WidgetType -> Float -> String
formatValue widgetType value =
    case widgetType of
        WpmWidget ->
            String.fromInt (round value)

        _ ->
            String.fromInt (round value)


{-| Format date for X-axis labels (MM/DD format)
-}
formatDate : String -> String
formatDate dateString =
    case String.split "-" dateString of
        [ _, month, day ] ->
            month ++ "/" ++ day

        _ ->
            dateString
