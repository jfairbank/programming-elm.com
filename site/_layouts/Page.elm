module Page exposing (layout, main, markdown)

import Elmstatic exposing (..)
import Html exposing (Html, a, div, h1, header, img, li, nav, span, text, ul)
import Html.Attributes as Attr exposing (alt, attribute, class, classList, href, src)
import List exposing (map)
import Markdown
import String.Extra
import Styles as S
import Title exposing (Title)


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
                -- [ li []
                --     [ a [ href "/blog" ]
                --         [ text "Blog" ]
                --     ]
                [ li []
                    [ a [ href "https://pragprog.com/book/jfelm/programming-elm" ]
                        [ text "Buy Now" ]
                    ]
                ]
            ]
        ]


viewBookCover : Html Never
viewBookCover =
    img
        [ src "/img/cover.jpg"
        , alt "Programming Elm Book Cover"
        ]
        []


viewContent : Title -> List (Html Never) -> Html Never
viewContent title contentItems =
    div [ class "content", pageClass title ]
        (viewTitle title :: contentItems)


pageClass : Title -> Html.Attribute msg
pageClass =
    Title.class <|
        \title ->
            String.append "page-" <| String.Extra.dasherize <| String.toLower title


viewTitle : Title -> Html msg
viewTitle =
    Title.view <|
        \title ->
            h1 [] [ text title ]


layout : Title -> List (Html Never) -> List (Html Never)
layout title contentItems =
    [ viewHeader
    , viewContent title contentItems
    ]


main : Elmstatic.Layout
main =
    Elmstatic.layout Elmstatic.decodePage <|
        \content ->
            layout (Title.hide content.title) [ markdown content.markdown ]
