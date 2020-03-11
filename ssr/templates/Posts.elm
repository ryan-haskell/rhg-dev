module Generated.Posts exposing
    ( Post
    , nextUp
    , posts
    )


type alias Post =
    { slug : String
    , title : String
    , date : Int
    }


posts : List Post
posts =
{{posts}}
        |> List.sortBy .date
        |> List.reverse


nextUp : String -> Maybe Post
nextUp slug =
    posts
        |> List.indexedMap Tuple.pair
        |> List.filterMap (\(i, post) -> if post.slug == slug then Just i else Nothing)
        |> List.head
        |> Maybe.andThen (\i -> List.drop (i + 1) posts |> List.head)
