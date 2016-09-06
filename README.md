# elm-child-update

Delegates update messages to one or many children. Takes the grunt work out updating a collection of children. This small [Elm][] package exposes the `ChildUpdate` module with just two methods:

* `updateOne` for updating a child in a one-to-one parent to child relationship
* `updateMany` for updating a list of children in a one-to-many parent to child relationship

## updateOne example

Given a one-to-one parent to child relationship as follows:

```elm
type alias Model =
    { widget : Widget.Model
    }

setWidget : Model -> Widget.Model -> Model
setWidget model =
    \x -> { model | widget = x }

type Msg
    = WidgetMessage Widget.Msg
```

Use `updateOne` to delegate updates to the child `update` function:

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    WidgetMessage cMsg->
        updateOne Widget.update .widget setWidget WidgetMessage cMsg model
```

## updateMany example

Given a one-to-many parent to child relationship as follows:

```elm
type alias Model =
    { widgets : List Widget.Model
    }

setWidgets : Model -> List Widget.Model -> Model
setWidgets model =
    \x -> { model | widgets = x }

type Msg
    = WidgetMessage Widget.Id Widget.Msg
```

Use `updateMany` to delegate updates to the child `update` function:

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    WidgetMessage id cMsg->
        updateMany Widget.update .id .widgets setWidgets WidgetMessage id cMsg model
```

[Elm]: http://elm-lang.org/
