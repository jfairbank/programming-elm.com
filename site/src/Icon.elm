module Icon exposing (brand)

import Html exposing (Html, i)
import Html.Attributes exposing (class)


brand : String -> Html msg
brand name =
    i
        [ class "fab"
        , class ("fa-" ++ name)
        ]
        []
