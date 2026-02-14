module Subscriptions exposing (subscriptions)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Types exposing (Model, Msg(..), Feedback, Metrics)


{-| Subscribe to incoming WebSocket messages
-}
subscriptions : Model -> Sub Msg
subscriptions _ =
    recv decodeFeedbackMessage


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


{-| External port for receiving WebSocket messages
-}
port recv : (Encode.Value -> msg) -> Sub msg
