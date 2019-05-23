module TwitterCard exposing
    ( TwitterCardType(..)
    , card
    , creator
    , description
    , image
    , site
    , title
    )

import Date exposing (Date)
import Html exposing (Html)
import Html.Attributes exposing (name)
import Html.Attributes.Extra exposing (content)
import Html.Extra exposing (meta)


type TwitterCardType
    = Summary


card : TwitterCardType -> Html msg
card cardType =
    twitter "card" <|
        case cardType of
            Summary ->
                "summary"


site : String -> Html msg
site =
    twitter "site_name"


title : String -> Html msg
title =
    twitter "title"


description : String -> Html msg
description =
    twitter "description"


creator : String -> Html msg
creator =
    twitter "creator"


image : String -> Html msg
image =
    twitter "image"


twitter : String -> String -> Html msg
twitter name_ content_ =
    meta [ name <| "twitter:" ++ name_, content content_ ]
