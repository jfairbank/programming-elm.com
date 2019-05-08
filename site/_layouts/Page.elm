module Page exposing (layout, main, markdown)

import Elmstatic exposing (..)
import Html exposing (Html, a, div, h1, header, img, li, nav, span, text, ul)
import Html.Attributes as Attr exposing (alt, attribute, class, classList, href, src)
import Icon
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
        , headerNav [ class "social-media-nav" ]
            [ navLink "https://www.facebook.com/programmingelm"
                [ Icon.brand "facebook-f" ]
            , navLink "https://twitter.com/programming_elm"
                [ Icon.brand "twitter" ]
            ]
        , headerNav [ class "main-nav" ]
            -- [ navLink "/blog"
            --     [ text "Blog" ]
            [ navLinkWithAttributes
                "https://pragprog.com/book/jfelm/programming-elm"
                [ class "main-nav__buy-now-link" ]
                [ text "Buy Now" ]
            ]
        ]


viewBookCover : Html Never
viewBookCover =
    img
        [ src "/img/cover.jpg"
        , alt "Programming Elm Book Cover"
        ]
        []


navLink : String -> List (Html msg) -> Html msg
navLink url content =
    navLinkWithAttributes url [] content


navLinkWithAttributes : String -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
navLinkWithAttributes url attributes content =
    li []
        [ a (href url :: attributes) content ]


headerNav : List (Html.Attribute msg) -> List (Html msg) -> Html msg
headerNav attributes content =
    nav (class "header-nav" :: attributes)
        [ ul [] content ]


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
