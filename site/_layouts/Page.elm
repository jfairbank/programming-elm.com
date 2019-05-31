module Page exposing (layout, main, markdown)

import Elmstatic exposing (..)
import Html exposing (Html, a, div, footer, h1, header, img, li, main_, nav, span, text, ul)
import Html.Attributes exposing (alt, attribute, class, classList, href, src)
import Html.Attributes.Extra exposing (role)
import Icon
import List exposing (map)
import Markdown
import String.Extra
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
        , socialMediaNav
        , navigation [ class "main-header__nav" ]
            [ navLinkWithAttributes "/blog"
                [ class "main-header__nav__link" ]
                [ text "Blog" ]
            , li [] [ buyNowLink ]
            ]
        ]


buyNowLink : Html Never
buyNowLink =
    a
        [ class "buy-now-link"
        , href "https://pragprog.com/book/jfelm/programming-elm"
        ]
        [ text "Buy Now" ]


viewFooter : Html Never
viewFooter =
    footer [ class "main-footer" ]
        [ socialMediaNav
        , buyNowLink
        ]


socialMediaNav : Html Never
socialMediaNav =
    nav [ class "social-media-nav" ]
        [ ul []
            [ navLink "https://www.facebook.com/programmingelm"
                [ Icon.brand "facebook-f" ]
            , navLink "https://twitter.com/programming_elm"
                [ Icon.brand "twitter" ]
            , navLink "https://www.instagram.com/programmingelm"
                [ Icon.brand "instagram" ]
            , navLink "https://www.linkedin.com/company/programming-elm"
                [ Icon.brand "linkedin-in" ]
            , navLink "https://www.goodreads.com/book/show/37824829-programming-elm"
                [ Icon.brand "goodreads-g" ]
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


navigation : List (Html.Attribute msg) -> List (Html msg) -> Html msg
navigation attributes content =
    nav attributes
        [ ul [] content ]


viewContent : Title -> List (Html Never) -> Html Never
viewContent title contentItems =
    main_
        [ class "main-content"
        , pageClass title
        , role "main"
        ]
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
            h1 [ class "main-title" ]
                [ text title ]


layout : Title -> List (Html Never) -> List (Html Never)
layout title contentItems =
    [ viewHeader
    , viewContent title contentItems
    , viewFooter
    ]


main : Elmstatic.Layout
main =
    Elmstatic.layout Elmstatic.decodePage <|
        \content ->
            { headContent = []
            , content =
                layout
                    (Title.hide content.title)
                    [ markdown content.markdown ]
            }
