module OpenGraph exposing
    ( OpenGraphType(..)
    , articleAuthor
    , articlePublishedTime
    , articlePublisher
    , description
    , image
    , siteName
    , title
    , type_
    , url
    )

import Date exposing (Date)
import Html exposing (Html)
import Html.Attributes exposing (attribute)
import Html.Attributes.Extra exposing (content)
import Html.Extra exposing (meta)


type OpenGraphType
    = Article


type_ : OpenGraphType -> Html msg
type_ ogType =
    og "type" <|
        case ogType of
            Article ->
                "article"


siteName : String -> Html msg
siteName =
    og "site_name"


title : String -> Html msg
title =
    og "title"


description : String -> Html msg
description =
    og "description"


url : String -> Html msg
url =
    og "url"


image : String -> Html msg
image =
    og "image"


articleAuthor : String -> Html msg
articleAuthor =
    article "author"


articlePublisher : String -> Html msg
articlePublisher =
    article "publisher"


articlePublishedTime : Date -> Html msg
articlePublishedTime =
    article "published_time" << Date.toIsoString


article : String -> String -> Html msg
article =
    prefixed "article"


og : String -> String -> Html msg
og =
    prefixed "og"


prefixed : String -> String -> String -> Html msg
prefixed prefix property_ content_ =
    meta [ property <| prefix ++ ":" ++ property_, content content_ ]


property : String -> Html.Attribute msg
property =
    attribute "property"
