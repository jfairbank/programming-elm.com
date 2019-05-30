module Post exposing (main, metadataHtml)

import Config
import Date
import Elmstatic exposing (..)
import Html exposing (..)
import Html.Attributes as Attr exposing (alt, attribute, class, href, rel, src, tabindex)
import Icon
import OpenGraph
import Page
import Title
import TwitterCard


tagsToHtml : List String -> List (Html Never)
tagsToHtml tags =
    let
        tagLink tag =
            "/tags/" ++ String.toLower tag

        linkify tag =
            a [ href <| tagLink tag ] [ text tag ]
    in
    List.map linkify tags


metadataHtml : Elmstatic.Post -> Html Never
metadataHtml post =
    div [ class "post-metadata" ]
        ([ span [ class "post-metadata__date" ]
            [ text <| String.append "Posted " <| Date.format "MMMM d, y," post.date ]
         , text " by "
         , a [ class "post-metadata__author", href post.authorUrl ]
            [ text post.authorName ]

         -- , span [] [ text "•" ]
         ]
         -- ++ tagsToHtml post.tags
        )


main : Elmstatic.Layout
main =
    let
        imageUrl =
            Config.url "img/cover-on-book.png"
    in
    Elmstatic.layout Elmstatic.decodePost <|
        \content ->
            { headContent =
                [ node "link"
                    [ rel "canonical"
                    , href <| Config.url <| Elmstatic.postBlogLink content
                    ]
                    []
                , OpenGraph.siteName "Programming Elm"
                , OpenGraph.title content.title
                , OpenGraph.description content.description
                , OpenGraph.url <| Config.url <| Elmstatic.postBlogLink content
                , OpenGraph.image imageUrl
                , OpenGraph.type_ OpenGraph.Article
                , OpenGraph.articlePublishedTime content.date
                , OpenGraph.articleAuthor "https://www.facebook.com/jfairbank"
                , OpenGraph.articlePublisher "https://www.facebook.com/programmingelm"
                , TwitterCard.card TwitterCard.Summary
                , TwitterCard.site "@programming_elm"
                , TwitterCard.creator "@elpapapollo"
                , TwitterCard.title content.title
                , TwitterCard.description content.description
                , TwitterCard.image imageUrl
                , Elmstatic.stylesheet "/post.css"
                , Elmstatic.script
                    [ attribute "src" "/share.js"
                    , attribute "async" "async"
                    , attribute "defer" "defer"
                    ]
                ]
            , content =
                Page.layout
                    (Title.display content.title)
                    [ metadataHtml content
                    , socialShare
                    , Page.markdown content.markdown
                    , socialShare
                    , buyBook
                    ]
            }


buyBook : Html Never
buyBook =
    div [ class "buy-book" ]
        [ div [ class "buy-book__action" ]
            [ img
                [ src "/img/cover-on-book.png"
                , alt "Programming Elm Book Cover"
                ]
                []
            , a [ href "https://pragprog.com/book/jfelm/programming-elm" ]
                [ text "Buy Now" ]
            ]
        , div [ class "buy-book__description" ]
            [ h4
                []
                [ text """
                    Ready to become an Elm developer or go beyond "hello world"
                    in Elm?
                  """
                ]
            , p
                []
                [ cite [] [ text "Programming Elm" ]
                , text """
                    guides you from knowing nothing about Elm to learning its
                    syntax, building maintainable applications with the Elm
                    Architecture, interacting with servers, debugging code,
                    testing, scaling applications, creating single-page
                    applications, and benchmarking performance.
                  """
                ]
            ]
        ]


socialShare : Html Never
socialShare =
    ul [ class "share" ]
        [ li [ class "share__prompt" ]
            [ text "share" ]
        , socialShareItem
            { name = "facebook"
            , icon = "facebook-f"
            , text = "Facebook"
            }
        , socialShareItem
            { name = "twitter"
            , icon = "twitter"
            , text = "Twitter"
            }
        ]


socialShareItem : { name : String, icon : String, text : String } -> Html Never
socialShareItem options =
    li [ class "share__item" ]
        [ a
            [ class "share__link"
            , class <| "share__link--" ++ options.name
            , class <| "share-" ++ options.name ++ "-js"
            , tabindex 0
            ]
            [ Icon.brand options.icon
            , span [] [ text options.text ]
            ]
        ]
