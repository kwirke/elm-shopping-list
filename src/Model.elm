module Model exposing (..)

import Json.Decode as D
import Json.Encode as E
import Note exposing (..)
import OpaqueDict exposing (OpaqueDict)
import Page exposing (Page(..))
import Ui.ListedNote exposing (NoteState(..))


type alias Model =
    { pending : PendingDict
    , done : DoneDict
    , currentPage : Page
    , backgroundTextureUrl : String
    }


type alias PendingDict =
    OpaqueDict NoteId Note


type alias DoneDict =
    OpaqueDict NoteId Note


initModel : String -> PendingDict -> DoneDict -> Model
initModel backgroundTextureUrl pending done =
    { pending = pending
    , done = done
    , currentPage = ListPage
    , backgroundTextureUrl = backgroundTextureUrl
    }


encodeModel : Model -> E.Value
encodeModel model =
    let
        encodeDict =
            OpaqueDict.encode noteIdToString encodeNote
    in
    E.object
        [ ( "pending", encodeDict model.pending )
        , ( "done", encodeDict model.done )
        ]


decodeModel : D.Decoder Model
decodeModel =
    let
        decodeDict =
            OpaqueDict.decode decodeNoteIdFromString noteIdToString decodeNote
    in
    D.map3 initModel
        (D.field "backgroundTextureUrl" D.string)
        (D.field "pending" decodeDict)
        (D.field "done" decodeDict)


type alias NotesInModel a =
    { a | pending : OpaqueDict NoteId Note, done : OpaqueDict NoteId Note }


allNotes : NotesInModel a -> List NoteIdPair
allNotes { pending, done } =
    List.concat
        [ OpaqueDict.toList pending
        , OpaqueDict.toList done
        ]


sortNotes : List NoteIdPair -> List NoteIdPair
sortNotes =
    List.sortBy (Tuple.second >> .title >> String.toLower)


move : k -> OpaqueDict k v -> OpaqueDict k v -> ( OpaqueDict k v, OpaqueDict k v )
move k dictFrom dictTo =
    let
        elem =
            OpaqueDict.get k dictFrom

        newFrom =
            OpaqueDict.remove k dictFrom

        newTo =
            elem
                |> Maybe.map (\e -> OpaqueDict.insert k e dictTo)
                |> Maybe.withDefault dictTo
    in
    ( newFrom, newTo )
