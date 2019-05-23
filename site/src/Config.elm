module Config exposing
    ( PostConfig
    , SiteConfig
    , defaultPostConfig
    , siteConfig
    , url
    )


type alias SiteConfig =
    { baseUrl : String }


type alias PostConfig =
    { authorName : String
    , authorUrl : String
    }


siteConfig : SiteConfig
siteConfig =
    { baseUrl = "https://programming-elm.com" }


defaultPostConfig : PostConfig
defaultPostConfig =
    { authorName = "Jeremy Fairbank"
    , authorUrl = "https://twitter.com/elpapapollo"
    }


url : String -> String
url path =
    siteConfig.baseUrl ++ "/" ++ path
