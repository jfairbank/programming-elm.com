module Page exposing (layout, main, markdown)

import Elmstatic exposing (..)
import Html exposing (Html, a, div, h1, header, img, li, nav, span, text, ul)
import Html.Attributes as Attr exposing (alt, attribute, class, href, src)
import List exposing (map)
import Markdown
import Styles as S


markdown : String -> Html Never
markdown s =
    let
        mdOptions : Markdown.Options
        mdOptions =
            { defaultHighlighting = Just "elm"
            , githubFlavored = Just { tables = False, breaks = False }
            , sanitize = False
            , smartypants = True
            }
    in
    Markdown.toHtmlWith mdOptions [ attribute "class" "markdown" ] s


viewHeader : Html Never
viewHeader =
    header [ class "main-header" ]
        [ a
            [ class "main-header__brand"
            , href "/"
            ]
            [ viewBookCover
            , span [] [ text "Programming Elm" ]
            ]
        , nav [ class "main-nav" ]
            [ ul []
                [ li []
                    [ a [ href "/blog" ]
                        [ text "Blog" ]
                    ]
                , li []
                    [ a [ href "https://pragprog.com/book/jfelm/programming-elm" ]
                        [ text "Buy Now" ]
                    ]
                ]
            ]
        ]


viewBookCover : Html Never
viewBookCover =
    img
        [ src "/img/jfelm.jpg"
        , alt "Programming Elm Book Cover"
        ]
        []


viewContent : String -> List (Html Never) -> Html Never
viewContent title contentItems =
    div [ class "content" ] <|
        [ h1 [] [ text title ] ]
            ++ contentItems


layout : String -> List (Html Never) -> List (Html Never)
layout title contentItems =
    [ viewHeader
    , viewContent title contentItems
    ]


main : Elmstatic.Layout
main =
    Elmstatic.layout Elmstatic.decodePage <|
        \content ->
            layout content.title [ markdown content.markdown ]
