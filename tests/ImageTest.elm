module ImageTest exposing (refreshImagesTestSuite)

import Expect
import Fuzz exposing (Fuzzer)
import Image exposing (Image, Status(..), refreshImagesStatus)
import Test exposing (Test, describe, fuzz, fuzz2, fuzz3, test)


visibleImageFuzzer : Fuzzer Image
visibleImageFuzzer =
    Visible
        |> Fuzz.constant
        |> imageFuzzer


mixedStatusImageFuzzer : List Status -> Fuzzer Image
mixedStatusImageFuzzer status =
    status
        |> List.map (\s -> s |> Fuzz.constant)
        |> Fuzz.oneOf
        |> imageFuzzer


foundImageFuzzer : Fuzzer Image
foundImageFuzzer =
    Found |> Fuzz.constant |> imageFuzzer


hiddenImageFuzzer : Fuzzer Image
hiddenImageFuzzer =
    Hidden |> Fuzz.constant |> imageFuzzer


imageFuzzer : Fuzzer Status -> Fuzzer Image
imageFuzzer statusFuzzer =
    Fuzz.map Image Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap statusFuzzer


refreshImagesTestSuite : Test
refreshImagesTestSuite =
    describe "refreshImages test suite" <|
        [ test "Given Nothing as images, returns Nothing" <|
            \_ ->
                Nothing
                    |> refreshImagesStatus
                    |> Expect.equal Nothing
        , test "Given empty images, returns empty images" <|
            \_ ->
                Just []
                    |> refreshImagesStatus
                    |> Expect.equal (Just [])
        , fuzz (Fuzz.list hiddenImageFuzzer) "Given all hidden images, returns images as they are" <|
            \hiddenImages ->
                Just hiddenImages
                    |> refreshImagesStatus
                    |> Expect.equal (Just hiddenImages)
        , fuzz (Fuzz.list foundImageFuzzer) "Given all found images, returns images as they are" <|
            \foundImages ->
                Just foundImages
                    |> refreshImagesStatus
                    |> Expect.equal (Just foundImages)
        , fuzz (Fuzz.list (mixedStatusImageFuzzer [ Found, Hidden ])) "Given mix of found and hidden images, returns images as they are" <|
            \images ->
                Just images
                    |> refreshImagesStatus
                    |> Expect.equal (Just images)
        , fuzz visibleImageFuzzer "Given mix of found and hidden images and two images with the same id as Visible, returns both images as found inside the list" <|
            \image ->
                let
                    images : List Image
                    images =
                        [ Image 2 "2" Hidden
                        , Image 3 "3" Hidden
                        , Image 4 "4" Hidden
                        ]

                    originalImages : List Image
                    originalImages =
                        images |> List.append [ { image | id = 1 }, { image | id = 1 } ]

                    expected : List Image
                    expected =
                        images
                            |> List.append [ { image | id = 1, status = Found }, { image | id = 1, status = Found } ]
                in
                Just originalImages
                    |> refreshImagesStatus
                    |> Expect.equal (Just expected)
        ]
