module Posts exposing (main)

import Date
import Elmstatic exposing (..)
import Html exposing (..)
import Html.Attributes as Attr exposing (alt, attribute, class, href, src)
import Page
import Post
import Title


main : Elmstatic.Layout
main =
    let
        postItem post =
            div [ class "post" ]
                [ a
                    [ class "post__link"
                    , href ("/" ++ Elmstatic.postBlogLink post)
                    ]
                    [ h2 [] [ text post.title ] ]
                , Post.metadataHtml post
                ]

        postListContent posts =
            if List.isEmpty posts then
                [ text "No posts yet!" ]

            else
                List.map postItem posts

        sortPosts posts =
            sortByMap (.date >> Date.toRataDie) flippedCompare posts
    in
    Elmstatic.layout Elmstatic.decodePostList <|
        \content ->
            { headContent = [ Elmstatic.stylesheet "/posts.css" ]
            , content =
                Page.layout (Title.display content.title) <|
                    postListContent <|
                        sortPosts content.posts
            }


sortByMap : (a -> b) -> (b -> b -> Order) -> List a -> List a
sortByMap mapper comparer list =
    List.sortWith
        (\a b -> comparer (mapper a) (mapper b))
        list


flippedCompare : comparable -> comparable -> Order
flippedCompare a b =
    case compare a b of
        LT ->
            GT

        GT ->
            LT

        EQ ->
            EQ
