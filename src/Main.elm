import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Url.Builder as Url


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
  { topic : String
  , url : String
  , title : String
  , errorMessage : Maybe Http.Error
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( Model "cat" "waiting.gif" "Waiting Cat" Nothing
  , getRandomGif "cat"
  )


--UPDATE

type Msg
  = MorePlease
  | NewGif (Result Http.Error Gif)
  | ChangeTopic String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      ( model
      , getRandomGif model.topic
      )

    NewGif result ->
      case result of
        Ok newGif ->
          ( { model | url = newGif.url, title = newGif.title}
          , Cmd.none
          )

        Err error ->
          ( { model | errorMessage = Just error }
          , Cmd.none
          )

    ChangeTopic newTopic ->
      ( { model | topic = newTopic }
      , Cmd.none
      )

--SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

--VIEW

view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text model.topic ]
    , button [ onClick MorePlease ] [ text "More Please!" ]
    , br [] []
    , case model.errorMessage of
        Just error ->
          div [] [ text <| errorToString error ]
        Nothing ->
          h4 [] [text model.title]
          , img [ src model.url ] []
    , br [] []
    , label [ for "topic" ] [ text "change topic:" ]
    , input [ type_ "text", id "topic", placeholder "cat", value model.topic, onInput ChangeTopic] []
    ]

-- HTTP

type alias Gif =
  { url : String
  , title : String
  }

getRandomGif : String -> Cmd Msg
getRandomGif topic =
  Http.send NewGif (Http.get (toGiphyUrl topic) gifDecoder)

toGiphyUrl : String -> String
toGiphyUrl topic =
  Url.crossOrigin "https://api.giphy.com" ["v1","gifs","random"]
    [ Url.string "api_key" "dc6zaTOxFJmzC"
    , Url.string "tag" topic
    ]

gifDecoder : Decode.Decoder Gif
gifDecoder =
  Decode.map2 Gif
    (Decode.field "data" (Decode.field "image_url" Decode.string))
    (Decode.field "data" (Decode.field "title" Decode.string))

titleDecoder : Decode.Decoder String
titleDecoder =
  Decode.field "data" (Decode.field "title" Decode.string)

errorToString : Http.Error -> String
errorToString error =
  case error of
    Http.Timeout ->
      "Connection timed out"
    Http.NetworkError ->
      "A network error has occured"
    Http.BadPayload badpayload response ->
      badpayload
    Http.BadUrl url ->
      url
    Http.BadStatus response ->
      response.status.message
