port module Subscriptions exposing (subscriptions, recv, recvAnalytics, recvSessionHistory)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Types exposing (Model, Msg(..), Feedback, Metrics, AnalyticsData, SessionHistory)


{-| Subscribe to incoming WebSocket messages and analytics data
-}
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ recv decodeFeedbackMessage
        , recvAnalytics decodeAnalyticsMessage
        , recvSessionHistory decodeSessionHistoryMessage
        ]


{-| Decode detailed feedback message from server
-}
decodeFeedbackMessage : Encode.Value -> Msg
decodeFeedbackMessage value =
    case Decode.decodeValue feedbackDecoder value of
        Ok feedback ->
            ReceiveFeedback (Ok feedback)

        Err error ->
            ReceiveFeedback (Err (Decode.errorToString error))


{-| Decoder for Feedback record
-}
feedbackDecoder : Decoder Feedback
feedbackDecoder =
    Decode.map4 Feedback
        (Decode.field "encouragement" Decode.string)
        (Decode.field "pacing" Decode.string)
        (Decode.field "tips" Decode.string)
        (Decode.field "metrics" (Decode.maybe metricsDecoder))


{-| Decoder for Metrics record
-}
metricsDecoder : Decoder Metrics
metricsDecoder =
    Decode.map4 Metrics
        (Decode.field "words" Decode.int)
        (Decode.field "sentences" Decode.int)
        (Decode.field "avg_sentence_length" Decode.float)
        (Decode.field "estimated_wpm" Decode.float)


{-| Decode analytics data from server
-}
decodeAnalyticsMessage : Encode.Value -> Msg
decodeAnalyticsMessage value =
    case Decode.decodeValue analyticsDecoder value of
        Ok analyticsData ->
            ReceiveAnalytics (Ok analyticsData)

        Err error ->
            ReceiveAnalytics (Err (Decode.errorToString error))


{-| Decoder for AnalyticsData record
-}
analyticsDecoder : Decoder AnalyticsData
analyticsDecoder =
    Decode.map4 AnalyticsData
        (Decode.field "totalSessions" Decode.int)
        (Decode.field "totalWords" Decode.int)
        (Decode.field "averageWpm" Decode.float)
        (Decode.field "currentStreak" Decode.int)


{-| External port for receiving WebSocket messages
-}
port recv : (Encode.Value -> msg) -> Sub msg


{-| External port for receiving analytics data
-}
port recvAnalytics : (Encode.Value -> msg) -> Sub msg


{-| Decode session history from server
-}
decodeSessionHistoryMessage : Encode.Value -> Msg
decodeSessionHistoryMessage value =
    case Decode.decodeValue (Decode.list sessionHistoryDecoder) value of
        Ok history ->
            ReceiveSessionHistory (Ok history)

        Err error ->
            ReceiveSessionHistory (Err (Decode.errorToString error))


{-| Decoder for SessionHistory record
-}
sessionHistoryDecoder : Decoder SessionHistory
sessionHistoryDecoder =
    Decode.map4 SessionHistory
        (Decode.field "date" Decode.string)
        (Decode.field "sessions" Decode.int)
        (Decode.field "words" Decode.int)
        (Decode.field "avgWpm" Decode.float)


{-| External port for receiving session history
-}
port recvSessionHistory : (Encode.Value -> msg) -> Sub msg
