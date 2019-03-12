# elm-memory-game
Basic Memory game built with Elm 0.19

[Play now](http://rdelgatte.github.io/elm-memory-game)

THE RULES FOR PLAYING "MEMORY"
- Mix up the cards.
- Lay them in rows, face down.
- Turn over any two cards.
- If the two cards match, keep them.
- If they don't match, turn them back over.
- Remember what was on each card and where it was.
- The game is over when all the cards have been matched.

## Step-by-step build

### Step-0: Start the application

Checkout branch `step-0` and run `elm-live src/Main.elm --port=1234 --open  -- --output=main.js --debug`

In this branch, you will find a single button and a value which is randomly generated (from 1 to 100).

![step-0](doc/step-0.png)

Once it is done, you can go to the next step: `git checkout -f step-1`

### Step-1: Render image

Instead of displaying the random value, we will now use [Picsum photo](https://picsum.photos/) to render a picture by its id.

For example: when 13 is rendered, we should render picture whose url is `https://picsum.photos/200/300?image=13`.

![step-1](doc/step-1.png)

Once it is done, you can go to the next step: `git checkout -f step-2`

### Step-2: Use `elm-ui`

- Install [elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/) so our layout and style are explicit and easy to modify.
You can see it as a layer over `elm/html`. 

- Transform your code to use only `elm-ui` elements

```elm
img => Element.image 
```
```elm
div => Element.row | Element.column | Element.el
```

```elm
button : Element Msg
button =
    { onPress = Just Generate
    , label = text "Generate"
    }
        |> Input.button []
```

- Use `Element.layout` to transform `Element` to `Html Msg`

You can now arrange your elements easily (without a single line of CSS).

- Bonus: Create a function which takes an Int (image id) and returns the image:

```elm
renderImage : Int -> Element Msg
renderImage imageId = ...
```

Once it is done, you can go to the next step: `git checkout -f step-3`

### Step-3: Generate multiple images 

In this step, we need to change the `Model` so we can have a list of multiple values and then render the images as expected

- Change `Model` to get `values: List Int`
- Check your compiler for the next steps :-) 

You can generate 5 random images for this example

![step-3](doc/step-3.png)

--- 
**Few tips** 
- We need to change the function to generate a `List` of `Int`. You can use: 
```elm
generate : Int -> Int -> Cmd Msg
generate min max =
    max
        |> Random.int min
        |> Random.list 5
        |> Random.generate Generated
```
- The result of `Generated` should change accordingly
- You can transform the list of generated image ids to images using:
```elm
images : List (Element Msg)
images =
    values
        |> List.map (\imageId -> imageId |> renderImage)
```

Once it is done, you can go to the next step: `git checkout -f step-4`

### Step-4: Image model

Images can have multiple states in a memory game: 
- *Hidden* = reverse side of the card (initial state) 
- *Visible* = when user click on it to discover the image
- *Found* = when user found associated images

We need to explicitly define a `Image` type to handle images in the application.

- Create a new Elm file `Image.elm` which defines a new `type alias` for `Image` with following attributes:
    - `id`: `Int`
    - `description`: `String`
    - `status`: `Status`

You also need to create a `Status` type to highlight the three status we highlighted before.

- Instead of generating an `Element.image` from the generated Id, we will now build an `Image` from a provided id using a build function like:
```elm
buildImage: Int -> Image
buildImage id = ...
```
You can set the default status of the Image to `Hidden` for now.

- Transform function `renderImage` to get an `Image` and return a `Element Msg` as before

Once it is done, you can go to the next step: `git checkout -f step-5`
