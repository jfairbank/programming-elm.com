module Icon exposing (brand, solid)

import Html exposing (Html, i)
import Html.Attributes exposing (class)


brand : String -> Html msg
brand name =
    i
        [ class "fab"
        , class ("fa-" ++ name)
        ]
        []


solid : String -> Html msg
solid name =
    i
        [ class "fas"
        , class ("fa-" ++ name)
        ]
        []
