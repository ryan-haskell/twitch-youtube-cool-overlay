module YouTubeMessage exposing (YouTubeMessage, fromJson)

import Json.Decode
import Json.Encode


type alias YouTubeMessage =
    { id : String
    , author : String
    , text : String
    }


fromJson : Json.Decode.Value -> Result Json.Decode.Error YouTubeMessage
fromJson json =
    Json.Decode.decodeValue decoder json


decoder : Json.Decode.Decoder YouTubeMessage
decoder =
    Json.Decode.map3 YouTubeMessage
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.at [ "author", "name" ] Json.Decode.string)
        (Json.Decode.field "message" messageItemListDecoder
            |> Json.Decode.map (String.join "")
        )



-- MESSAGE ITEM


type alias MessageItem =
    String


messageItemListDecoder : Json.Decode.Decoder (List MessageItem)
messageItemListDecoder =
    Json.Decode.list messageItemDecoder


messageItemDecoder : Json.Decode.Decoder MessageItem
messageItemDecoder =
    Json.Decode.oneOf
        [ Json.Decode.field "text" Json.Decode.string
        , Json.Decode.field "isCustom" Json.Decode.bool
            |> Json.Decode.andThen
                (\isCustom ->
                    if isCustom then
                        Json.Decode.succeed ""

                    else
                        Json.Decode.field "emojiText" Json.Decode.string
                )
        ]
