module Html.Attributes.Extra exposing (role)

import Html exposing (Html)
import Html.Attributes exposing (attribute)


role : String -> Html.Attribute msg
role =
    attribute "role"
