module Html.Attributes.Extra exposing (content, role)

import Html exposing (Html)
import Html.Attributes exposing (attribute)


role : String -> Html.Attribute msg
role =
    attribute "role"


content : String -> Html.Attribute msg
content =
    attribute "content"
