module ChildUpdate exposing (updateOne, updateMany)

{-| Delegates update messages to one or many children. Takes the grunt work out
updating a collection of children. This module exposes

@docs updateOne, updateMany
-}


{-| Delegates update messages to a child. Given a one-to-one parent to child
relationship as follows:

    type alias Model =
        { widget : Widget.Model
        }

    setWidget : Model -> Widget.Model -> Model
    setWidget model =
        \x -> { model | widget = x }

    type Msg
        = WidgetMessage Widget.Msg

Use `updateOne` to delegate updates to the child `update` function:

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        WidgetMessage cMsg->
            updateOne Widget.update .widget setWidget WidgetMessage cMsg model
-}
updateOne :
    (childMsg -> childModel -> ( childModel, Cmd childMsg ))
    -> (model -> childModel)
    -> (model -> childModel -> model)
    -> (childMsg -> msg)
    -> childMsg
    -> model
    -> ( model, Cmd msg )
updateOne childUpdate getter setter msgMap childMsg model =
    let
        ( newChild, childCmd ) =
            childUpdate childMsg (getter model)
    in
        ( setter model newChild, Cmd.map msgMap childCmd )


{-| Delegates update messages to many children. Given a one-to-many parent to
child relationship as follows:

    type alias Model =
        { widgets : List Widget.Model
        }

    setWidgets : Model -> List Widget.Model -> Model
    setWidgets model =
        \x -> { model | widgets = x }

    type Msg
        = WidgetMessage Widget.Id Widget.Msg

Use `updateMany` to delegate updates to the child `update` function:

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        WidgetMessage id cMsg->
            updateMany Widget.update .id .widgets setWidgets WidgetMessage id cMsg model
-}
updateMany :
    (childMsg -> childModel -> ( childModel, Cmd childMsg ))
    -> (childModel -> childId)
    -> (model -> List childModel)
    -> (model -> List childModel -> model)
    -> (childId -> childMsg -> msg)
    -> childId
    -> childMsg
    -> model
    -> ( model, Cmd msg )
updateMany childUpdate getId getter setter msgMap childId childMsg model =
    let
        ( newChildren, childCmd ) =
            (getter model)
                |> updateManyChildren childUpdate getId childId childMsg
    in
        ( (setter model newChildren), Cmd.map (msgMap childId) childCmd )


updateManyChildren :
    (childMsg -> childModel -> ( childModel, Cmd childMsg ))
    -> (childModel -> childId)
    -> childId
    -> childMsg
    -> List childModel
    -> ( List childModel, Cmd childMsg )
updateManyChildren childUpdate getId id msg children =
    let
        ( newChildren, cmds ) =
            children
                |> List.map (updateOneChildOfMany childUpdate getId id msg)
                |> List.unzip
    in
        ( newChildren, Cmd.batch cmds )


updateOneChildOfMany :
    (childMsg -> childModel -> ( childModel, Cmd childMsg ))
    -> (childModel -> childId)
    -> childId
    -> childMsg
    -> childModel
    -> ( childModel, Cmd childMsg )
updateOneChildOfMany childUpdate getId id msg child =
    let
        ( newChild, cmd ) =
            if (getId child) == id then
                childUpdate msg child
            else
                ( child, Cmd.none )
    in
        ( newChild, cmd )
