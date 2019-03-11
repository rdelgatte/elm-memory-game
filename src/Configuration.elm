module Configuration exposing (Configuration, cardsWidth, expectedCards, levelOptions)

import Element
import Element.Input as Input


type alias Configuration =
    { level : Int
    , cardsByLevel : Int
    , codes : List Int
    }


expectedCards : Configuration -> Int
expectedCards { cardsByLevel, level } =
    cardsByLevel * level


levelOptions : List (Input.Option Int msg)
levelOptions =
    [ 1, 2, 3, 4, 5 ]
        |> List.map
            (\level ->
                level
                    |> String.fromInt
                    |> Element.text
                    |> Input.option level
            )


cardsWidth : Configuration -> Int
cardsWidth { cardsByLevel } =
    cardsByLevel * 205
