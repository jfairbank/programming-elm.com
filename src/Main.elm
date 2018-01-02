module Main exposing (..)

import Color exposing (blue, rgb, white)
import Element
    exposing
        ( Device
        , Element
        , button
        , classifyDevice
        , column
        , el
        , h1
        , html
        , image
        , italic
        , link
        , newTab
        , paragraph
        , responsive
        , row
        , subheading
        , text
        , when
        )
import Element.Attributes
    exposing
        ( center
        , fill
        , maxWidth
        , padding
        , paddingBottom
        , paddingTop
        , paddingXY
        , percent
        , px
        , spacing
        , spread
        , verticalCenter
        , width
        )
import Html exposing (Html, i)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, field, int, map, map2, string)
import Style exposing (StyleSheet, style)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Shadow as Shadow
import Window


type alias Flags =
    { coverUrl : String
    , width : Int
    , height : Int
    }


type alias Model =
    { coverUrl : String
    , device : Device
    }


decodeDevice : Decoder Device
decodeDevice =
    map2 Window.Size
        (field "width" int)
        (field "height" int)
        |> map classifyDevice


decodeModel : Decoder Model
decodeModel =
    map2 Model
        (field "coverUrl" string)
        decodeDevice


initialModel : Flags -> Model
initialModel { coverUrl, width, height } =
    { coverUrl = coverUrl
    , device = classifyDevice (Window.Size width height)
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, Cmd.none )


type Style
    = None
    | Title
    | Author
    | AuthorName
    | Description
    | Beta
    | BuyButton
    | Cover


coverCutoffDeviceWidth : Int
coverCutoffDeviceWidth =
    1020


fontGeorgia : Style.Property class variation
fontGeorgia =
    Font.typeface
        [ Font.font "Georgia"
        , Font.serif
        ]


fontSourceSansPro : Style.Property class variation
fontSourceSansPro =
    Font.typeface
        [ Font.font "Source Sans Pro"
        , Font.sansSerif
        ]


stylesheet : Float -> StyleSheet Style variation
stylesheet deviceWidth =
    let
        widthRange =
            ( 600, 1400 )
    in
    Style.styleSheet
        [ style Title
            [ Font.size (responsive deviceWidth widthRange ( 40, 60 ))
            , fontGeorgia
            ]
        , style Author
            [ Font.size (responsive deviceWidth widthRange ( 26, 40 ))
            , fontGeorgia
            ]
        , style AuthorName
            [ Color.text blue ]
        , style Description
            [ Font.size 18
            , fontSourceSansPro
            ]
        , style Beta
            [ Font.bold
            , Font.size 30
            , fontSourceSansPro
            ]
        , style BuyButton
            [ Border.rounded 4
            , Color.background (rgb 58 60 160)
            , Color.text white
            , Font.bold
            , Font.italic
            , Font.size 40
            , fontSourceSansPro
            ]
        , style Cover
            [ Shadow.simple ]
        ]


viewIcon : String -> Element Style variation msg
viewIcon name =
    html <|
        i [ class ("fa fa-4x fa-" ++ name) ] []


viewIconLink : String -> String -> Element Style variation msg
viewIconLink name url =
    name
        |> viewIcon
        |> newTab url


bookUrl : String
bookUrl =
    "https://pragprog.com/book/jfelm/programming-elm"


viewCover : String -> Int -> Element Style variation msg
viewCover coverUrl deviceWidth =
    let
        coverWidth =
            if deviceWidth >= 1230 then
                600
            else if deviceWidth >= coverCutoffDeviceWidth then
                400
            else
                200
    in
    newTab bookUrl <|
        image Cover
            [ width (px coverWidth) ]
            { src = coverUrl
            , caption = "Programming Elm Cover"
            }


viewBuyButton : Element Style variation msg
viewBuyButton =
    row None
        [ center ]
        [ link bookUrl <|
            el BuyButton [ paddingXY 20 12 ] (text "Buy Now")
        ]


viewActionLinks : Int -> Element Style variation msg
viewActionLinks deviceWidth =
    let
        linksLayout =
            if deviceWidth >= 500 then
                row None [ spacing 40, verticalCenter ]
            else
                column None [ spacing 40, paddingTop 20 ]
    in
    linksLayout
        [ viewBuyButton
        , row None
            [ center, spacing 40 ]
            [ viewIconLink "twitter" "https://twitter.com/programming_elm"
            , viewIconLink "facebook" "https://www.facebook.com/programmingelm"
            , viewIconLink "book" bookUrl
            ]
        ]


viewAuthor : Element Style variation msg
viewAuthor =
    paragraph Author
        []
        [ text "by "
        , newTab "https://twitter.com/elpapapollo" <|
            el AuthorName [] (text "Jeremy Fairbank")
        ]


viewContent : String -> Int -> Element Style variation msg
viewContent coverUrl deviceWidth =
    let
        descriptionWidth =
            if deviceWidth >= 600 then
                percent 75
            else
                fill
    in
    column None
        [ spacing 10 ]
        [ h1 Title [] (text "Programming Elm")
        , viewAuthor
        , paragraph Description
            [ paddingBottom 20, width descriptionWidth ]
            [ text description ]
        , when (deviceWidth < coverCutoffDeviceWidth)
            (viewCover coverUrl deviceWidth)
        , el Beta [ paddingTop 20 ] (italic "NOW IN BETA!")
        , viewActionLinks deviceWidth
        ]


view : Model -> Html msg
view { coverUrl, device } =
    Element.layout (stylesheet (toFloat device.width)) <|
        el None [ center ] <|
            row None
                [ padding 40, spread, maxWidth (px 1400) ]
                [ viewContent coverUrl device.width
                , when (device.width >= coverCutoffDeviceWidth)
                    (viewCover coverUrl device.width)
                ]


type Msg
    = UpdateSize Window.Size


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        UpdateSize size ->
            ( { model | device = classifyDevice size }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Window.resizes UpdateSize


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


description : String
description =
    "Elm brings the safety and stability of functional programing to front-end development, making it one of the most popular new languages. Elm’s functional nature and static typing means that run-time errors are nearly impossible, and it compiles to JavaScript for easy web deployment. This book helps you take advantage of this new language in your web site development. Learn how the Elm Architecture will help you create fast applications. Discover how to integrate Elm with JavaScript so you can update legacy applications. See how Elm tooling makes deployment quicker and easier."
