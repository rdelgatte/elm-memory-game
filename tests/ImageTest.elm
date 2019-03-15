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
                    |> refreshImagesStatus 1
                    |> Expect.equal Nothing
        , test "Given empty images, returns empty images" <|
            \_ ->
                Just []
                    |> refreshImagesStatus 1
                    |> Expect.equal (Just [])
        , fuzz (Fuzz.list hiddenImageFuzzer) "Given all hidden images, returns images as they are" <|
            \hiddenImages ->
                Just hiddenImages
                    |> refreshImagesStatus 1
                    |> Expect.equal (Just hiddenImages)
        , fuzz (Fuzz.list foundImageFuzzer) "Given all found images, returns images as they are" <|
            \foundImages ->
                Just foundImages
                    |> refreshImagesStatus 1
                    |> Expect.equal (Just foundImages)
        , fuzz (Fuzz.list (mixedStatusImageFuzzer [ Found, Hidden ])) "Given mix of found and hidden images, returns images as they are" <|
            \images ->
                Just images
                    |> refreshImagesStatus 1
                    |> Expect.equal (Just images)
        , test "Given images with three different visible images, returns visible images to Hidden" <|
            \_ ->
                let
                    images : List Image
                    images =
                        [ Image 1 "1" Visible
                        , Image 3 "3" Visible
                        , Image 2 "2" Visible
                        , Image 2 "2" Hidden
                        , Image 1 "1" Hidden
                        , Image 3 "3" Hidden
                        ]

                    expectedImages : List Image
                    expectedImages =
                        [ Image 1 "1" Hidden
                        , Image 3 "3" Visible
                        , Image 2 "2" Hidden
                        , Image 2 "2" Hidden
                        , Image 1 "1" Hidden
                        , Image 3 "3" Hidden
                        ]
                in
                Just images
                    |> refreshImagesStatus 1
                    |> Expect.equal (Just expectedImages)
        , fuzz Fuzz.int "Given images with both visible images with identical id, returns visible images to Found whatever the index" <|
            \index ->
                let
                    images : List Image
                    images =
                        [ Image 1 "1" Visible
                        , Image 3 "3" Hidden
                        , Image 2 "2" Hidden
                        , Image 2 "2" Hidden
                        , Image 1 "1" Visible
                        , Image 3 "3" Hidden
                        ]

                    expectedImages : List Image
                    expectedImages =
                        [ Image 1 "1" Found
                        , Image 3 "3" Hidden
                        , Image 2 "2" Hidden
                        , Image 2 "2" Hidden
                        , Image 1 "1" Found
                        , Image 3 "3" Hidden
                        ]
                in
                Just images
                    |> refreshImagesStatus index
                    |> Expect.equal (Just expectedImages)
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
                        images
                            |> List.append [ { image | id = 1 }, { image | id = 1 } ]

                    expected : List Image
                    expected =
                        images
                            |> List.append [ { image | id = 1, status = Found }, { image | id = 1, status = Found } ]
                in
                Just originalImages
                    |> refreshImagesStatus 1
                    |> Expect.equal (Just expected)
        ]
