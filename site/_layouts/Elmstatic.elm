module Elmstatic exposing
    ( Content
    , Layout
    , Page
    , Post
    , PostList
    , decodePage
    , decodePost
    , decodePostList
    , htmlTemplate
    , inlineScript
    , layout
    , script
    , stylesheet
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json


type alias Post =
    { date : String
    , link : String
    , markdown : String
    , section : String
    , siteTitle : String
    , tags : List String
    , title : String
    , stylesheet : Maybe String
    }


type alias Page =
    { markdown : String
    , siteTitle : String
    , title : String
    , stylesheet : Maybe String
    }


type alias PostList =
    { posts : List Post
    , section : String
    , siteTitle : String
    , title : String
    , stylesheet : Maybe String
    }


type alias Content a =
    { a | siteTitle : String, title : String, stylesheet : Maybe String }


type alias Layout =
    Program Json.Value Json.Value Never


decodePage : Json.Decoder Page
decodePage =
    Json.map4 Page
        (Json.field "markdown" Json.string)
        (Json.field "siteTitle" Json.string)
        (Json.field "title" Json.string)
        (Json.maybe <| Json.field "stylesheet" Json.string)


decodePost : Json.Decoder Post
decodePost =
    Json.map8 Post
        (Json.field "date" Json.string)
        (Json.field "link" Json.string)
        (Json.field "markdown" Json.string)
        (Json.field "section" Json.string)
        (Json.field "siteTitle" Json.string)
        (Json.field "tags" <| Json.list Json.string)
        (Json.field "title" Json.string)
        (Json.maybe <| Json.field "stylesheet" Json.string)


decodePostList : Json.Decoder PostList
decodePostList =
    Json.map5 PostList
        (Json.field "posts" <| Json.list decodePost)
        (Json.field "section" Json.string)
        (Json.field "siteTitle" Json.string)
        (Json.field "title" Json.string)
        (Json.maybe <| Json.field "stylesheet" Json.string)


script : String -> Html Never
script src =
    node "citatsmle-script" [ attribute "src" src ] []


inlineScript : String -> Html Never
inlineScript js =
    node "citatsmle-script" [] [ text js ]


stylesheet : String -> Html Never
stylesheet href =
    node "link" [ attribute "href" href, attribute "rel" "stylesheet", attribute "type" "text/css" ] []


maybeStylesheet : Maybe String -> Html Never
maybeStylesheet maybeHref =
    case maybeHref of
        Just href ->
            stylesheet href

        Nothing ->
            text ""


htmlTemplate : String -> List (Html Never) -> List (Html Never) -> Html Never
htmlTemplate title headContentNodes contentNodes =
    node "html"
        []
        [ node "head" [] <|
            [ node "title" [] [ text title ]
            , node "meta" [ attribute "charset" "utf-8" ] []
            , node "meta"
                [ attribute "http-equiv" "x-ua-compatible"
                , attribute "content" "ie=edge"
                ]
                []
            , node "meta"
                [ name "viewport"
                , attribute "content" "width=device-width, initial-scale=1.0"
                ]
                []
            , script "//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.1/highlight.min.js"
            , script "//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.1/languages/elm.min.js"
            , inlineScript "hljs.initHighlightingOnLoad();"
            , stylesheet "//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.1/styles/default.min.css"

            -- , stylesheet "//fonts.googleapis.com/css?family=Open+Sans|Proza+Libre|Inconsolata"
            -- CUSTOM STYLES
            , stylesheet "//fonts.googleapis.com/css?family=Amatic+SC|Open+Sans:400,600|Roboto+Slab:400,700"
            , stylesheet "/styles.css"
            ]
                ++ headContentNodes
        , node "body" [] contentNodes

        -- , node "body" [] <|
        --     contentNodes
        --         ++ [ script "http://programming-elm-livereload.ngrok.io/livereload.js?snipver=1" ]
        ]


layout : Json.Decoder (Content content) -> (Content content -> List (Html Never)) -> Layout
layout decoder view =
    Browser.document
        { init = \contentJson -> ( contentJson, Cmd.none )
        , view =
            \contentJson ->
                case Json.decodeValue decoder contentJson of
                    Err error ->
                        { title = ""
                        , body = [ htmlTemplate "Error" [] [ Html.text <| Json.errorToString error ] ]
                        }

                    Ok content ->
                        { title = ""
                        , body = [ htmlTemplate content.siteTitle [ maybeStylesheet content.stylesheet ] <| view content ]
                        }
        , update = \msg contentJson -> ( contentJson, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
