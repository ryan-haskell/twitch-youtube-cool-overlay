port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes
import Html.Keyed
import Json.Decode
import TwitchMessage exposing (Message)


maxMessageCount : Int
maxMessageCount =
    50



-- PORTS


port onWebSocketMessage : (Json.Decode.Value -> msg) -> Sub msg



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { messages : List Message
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { messages = [] }
    , Cmd.none
    )



-- UPDATE


type Msg
    = ApiSentChatMessage Json.Decode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ApiSentChatMessage rawJson ->
            case TwitchMessage.fromJson rawJson of
                Ok message ->
                    ( { model
                        | messages =
                            message
                                :: model.messages
                                |> List.take maxMessageCount
                      }
                    , Cmd.none
                    )

                Err reason ->
                    ( model
                    , Cmd.none
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    onWebSocketMessage ApiSentChatMessage



-- VIEW


view : Model -> Html Msg
view model =
    model.messages
        |> List.map viewItem
        |> Html.Keyed.ul []


viewItem : Message -> ( String, Html Msg )
viewItem message =
    let
        colors : List String
        colors =
            [ "red", "yellow", "green", "blue", "purple" ]

        id : Int
        id =
            message.author
                |> String.toList
                |> List.map Char.toCode
                |> List.sum

        color : String
        color =
            colors
                |> List.drop (Basics.modBy (List.length colors) id)
                |> List.head
                |> Maybe.withDefault "red"
    in
    ( message.id
    , li []
        [ div
            [ Html.Attributes.class "message"
            , Html.Attributes.attribute "data-color" color
            ]
            [ span [] [ text message.text ] ]
        ]
    )
