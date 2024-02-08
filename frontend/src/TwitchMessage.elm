module TwitchMessage exposing (Message, fromJson)

import Json.Decode
import Json.Encode


type alias Message =
    { id : String
    , author : String
    , text : String
    }


fromJson : Json.Decode.Value -> Result Json.Decode.Error Message
fromJson json =
    Json.Decode.decodeValue decoder json


decoder : Json.Decode.Decoder Message
decoder =
    Json.Decode.map3 Message
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "author" Json.Decode.string)
        (Json.Decode.field "message" Json.Decode.string)
