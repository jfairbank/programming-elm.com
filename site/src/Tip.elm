port module Tip exposing (main)

import Array exposing (Array)
import Browser
import Browser.Events exposing (onKeyUp)
import Html exposing (Html, a, div, img, text)
import Html.Attributes exposing (class, id, src, style)
import Html.Attributes.Extra exposing (role)
import Html.Events exposing (onClick)
import Icon
import Json.Decode as Json


port showModal : () -> Cmd msg


port hideModal : () -> Cmd msg


type Modal
    = Show Int
    | Hide


modalToMaybe : Modal -> Maybe Int
modalToMaybe modal =
    case modal of
        Show i ->
            Just i

        Hide ->
            Nothing


type alias Flags =
    { images : Array String }


type alias Model =
    { images : Array String
    , modal : Modal
    }


init : Flags -> ( Model, Cmd msg )
init flags =
    ( { images = flags.images
      , modal = Hide
      }
    , Cmd.none
    )


viewImage : Int -> String -> Html Msg
viewImage i imageUrl =
    a [ onClick <| Start i ]
        [ img
            [ src imageUrl
            , role "presentation"
            ]
            []
        ]


viewImages : Array String -> Html Msg
viewImages images =
    div [ id "post-tip-images", class "post__tip-images" ]
        (images
            |> Array.indexedMap viewImage
            |> Array.toList
        )


viewModal : Model -> Html Msg
viewModal model =
    let
        modal =
            model.modal
                |> modalToMaybe
                |> Maybe.andThen (\i -> Array.get i model.images)
    in
    case modal of
        Just imageUrl ->
            div [ class "post__tip-modal" ]
                [ div
                    [ class "post__tip-modal-backdrop"
                    , onClick Stop
                    ]
                    []
                , div [ class "post__tip-modal-content" ]
                    [ a
                        [ class "post__tip-modal-close"
                        , onClick Stop
                        ]
                        [ Icon.solid "times-circle" ]
                    , img [ src imageUrl ] []
                    ]
                ]

        Nothing ->
            text ""


view : Model -> Html Msg
view model =
    div []
        [ viewImages model.images
        , viewModal model
        ]


type Msg
    = Start Int
    | Stop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Start i ->
            ( { model | modal = Show i }
            , showModal ()
            )

        Stop ->
            ( { model | modal = Hide }
            , hideModal ()
            )


nextImage : Int -> Array String -> Int
nextImage i images =
    remainderBy (Array.length images) (i + 1)


previousImage : Int -> Array String -> Int
previousImage i images =
    remainderBy (Array.length images) (i - 1)


decodeKeyMsg : Int -> Array String -> Json.Decoder Msg
decodeKeyMsg index images =
    Json.field "key" Json.string
        |> Json.andThen
            (\key ->
                case key of
                    "ArrowRight" ->
                        Json.succeed <| Start <| nextImage index images

                    "ArrowLeft" ->
                        Json.succeed <| Start <| nextImage index images

                    "Escape" ->
                        Json.succeed Stop

                    _ ->
                        Json.fail ""
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.modal of
        Show i ->
            model.images
                |> decodeKeyMsg i
                |> onKeyUp

        Hide ->
            Sub.none


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
