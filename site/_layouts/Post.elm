module Post exposing (main, metadataHtml)

import Date
import Elmstatic exposing (..)
import Html exposing (..)
import Html.Attributes as Attr exposing (alt, attribute, class, href, src)
import Page
import Title


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
    Elmstatic.layout Elmstatic.decodePost <|
        \content ->
            { headContent = [ Elmstatic.stylesheet "/post.css" ]
            , content =
                Page.layout
                    (Title.display content.title)
                    [ metadataHtml content, Page.markdown content.markdown ]
            }
