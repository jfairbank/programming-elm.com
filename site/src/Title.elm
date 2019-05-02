module Title exposing
    ( Title
    , class
    , display
    , hide
    , view
    )

import Html exposing (Html)
import Html.Attributes


type Title
    = Display String
    | Hide String


display : String -> Title
display =
    Display


hide : String -> Title
hide =
    Hide


class : (String -> String) -> Title -> Html.Attribute msg
class handle title =
    Html.Attributes.class <| handle <| unwrap title


view : (String -> Html msg) -> Title -> Html msg
view handle title =
    case title of
        Display content ->
            handle content

        Hide _ ->
            Html.text ""


unwrap : Title -> String
unwrap title =
    case title of
        Display content ->
            content

        Hide content ->
            content
