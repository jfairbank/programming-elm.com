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
    , postBlogLink
    , script
    , stylesheet
    )

import Browser
import Config
import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json
import Json.Decode.Pipeline as Pipeline


type alias Post =
    { date : Date
    , link : String
    , markdown : String
    , description : String
    , section : String
    , siteTitle : String
    , tags : List String
    , title : String
    , stylesheet : Maybe String
    , authorName : String
    , authorUrl : String
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
    Json.succeed Post
        |> Pipeline.required "date"
            (Json.string
                |> Json.andThen (Date.fromIsoString >> resultToDecoder)
            )
        |> Pipeline.required "link" Json.string
        |> Pipeline.required "markdown" Json.string
        |> Pipeline.required "description" Json.string
        |> Pipeline.required "section" Json.string
        |> Pipeline.required "siteTitle" Json.string
        |> Pipeline.required "tags" (Json.list Json.string)
        |> Pipeline.required "title" Json.string
        |> Pipeline.custom (Json.maybe <| Json.field "stylesheet" Json.string)
        |> Pipeline.optional "authorName" Json.string Config.defaultPostConfig.authorName
        |> Pipeline.optional "authorUrl" Json.string Config.defaultPostConfig.authorUrl


decodePostList : Json.Decoder PostList
decodePostList =
    Json.map5 PostList
        (Json.field "posts" <| Json.list decodePost)
        (Json.field "section" Json.string)
        (Json.field "siteTitle" Json.string)
        (Json.field "title" Json.string)
        (Json.maybe <| Json.field "stylesheet" Json.string)


postBlogLink : Post -> String
postBlogLink { link } =
    String.replace "posts/" "blog/" link


resultToDecoder : Result String a -> Json.Decoder a
resultToDecoder result =
    case result of
        Ok value ->
            Json.succeed value

        Err error ->
            Json.fail error


script : List (Html.Attribute Never) -> Html Never
script attributes =
    node "citatsmle-script" attributes []


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
            , googleAnalytics
            , script [ attribute "src" "//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.1/highlight.min.js" ]
            , script [ attribute "src" "//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.1/languages/elm.min.js" ]
            , script [ attribute "src" "//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.1/languages/plaintext.min.js" ]
            , inlineScript "hljs.initHighlightingOnLoad();"
            , stylesheet "//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.1/styles/tomorrow-night-eighties.min.css"

            -- CUSTOM STYLES
            , stylesheet "//fonts.googleapis.com/css?family=Amatic+SC|Roboto+Slab:400,700"
            , stylesheet "//use.fontawesome.com/releases/v5.8.2/css/all.css"
            , stylesheet "/styles.css"
            , inlineScript """
                if ('serviceWorker' in navigator) {
                  navigator.serviceWorker.ready.then(function(registration) {
                    registration.unregister();
                  })
                }
              """
            ]
                ++ headContentNodes
        , node "body" [] contentNodes
        ]


googleAnalytics : Html Never
googleAnalytics =
    inlineScript """
      if (window.location.href.match(/programming-elm\\.com/)) {
        const meta = document.getElementsByTagName('meta')[0]
        const script = document.createElement('script')

        script.async = true
        script.src = 'https://www.googletagmanager.com/gtag/js?id=UA-52148605-7'

        meta.parentNode.insertBefore(script, meta)

        window.dataLayer = window.dataLayer || []
        function gtag() { dataLayer.push(arguments) }
        gtag('js', new Date())

        gtag('config', 'UA-52148605-7')
      }
    """


layout :
    Json.Decoder (Content content)
    -> (Content content -> { headContent : List (Html Never), content : List (Html Never) })
    -> Layout
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
                        , body =
                            [ let
                                output =
                                    view content
                              in
                              htmlTemplate
                                content.siteTitle
                                (output.headContent ++ [ maybeStylesheet content.stylesheet ])
                                output.content
                            ]
                        }
        , update = \msg contentJson -> ( contentJson, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
