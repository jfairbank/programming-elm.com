module Html.Extra exposing (meta)

import Html exposing (Html, node)


meta : List (Html.Attribute msg) -> Html msg
meta attributes =
    node "meta" attributes []
