import Browser
import Html exposing (..)



--MAIN

main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  {
  }

init :
init _ =


--UPDATE

type Msg
  =

update :
update msg model =
  case msg of

--SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =


--VIEW

view : Model -> Html Msg
view model =
