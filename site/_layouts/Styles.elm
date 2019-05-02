module Styles exposing (Styles(..), toAttribute)

import Html
import Html.Attributes


type Styles
    = HomeBookCover


toAttribute : Styles -> Html.Attribute msg
toAttribute styles =
    Html.Attributes.class (toClass styles)


toClass : Styles -> String
toClass styles =
    case styles of
        HomeBookCover ->
            "home-book-cover"
