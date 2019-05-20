module Config exposing (Config, defaultPostConfig)


type alias Config =
    { authorName : String
    , authorUrl : String
    }


defaultPostConfig : Config
defaultPostConfig =
    { authorName = "Jeremy Fairbank"
    , authorUrl = "https://twitter.com/elpapapollo"
    }
