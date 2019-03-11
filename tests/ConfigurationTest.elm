module ConfigurationTest exposing (expectedCardsTest)

import Configuration exposing (Configuration, expectedCards)
import Expect
import Fuzz
import Test exposing (Test, fuzz2)


expectedCardsTest : Test
expectedCardsTest =
    fuzz2 Fuzz.int Fuzz.int "From configuration, returns the expected number of cards to get" <|
        \level cardsByLevel ->
            []
                |> Configuration level cardsByLevel
                |> expectedCards
                |> Expect.equal (level * cardsByLevel)
