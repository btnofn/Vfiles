using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

height_display := class(creative_device):

    @editable
    GroundLevelOffset: float = 0.0

    @editable
    Text:  string = "Height:  "

    @editable
    TextPosition: text_position = text_position.UpperCenter

    var DisplayMap: [player]?height_widget = map{}

    OnBegin<override>()<suspends>:void=
        
        Sleep(0.0)
        CheckForPlayers()

    CheckForPlayers()<suspends>: void =
        loop:
            Sleep(1.0)
            AllPlayers := GetPlayspace().GetPlayers()
            for (Player : AllPlayers):
                HeightWidgetInstance := height_widget{VerseDevice := Self, InstancePlayer := Player}
                PlayerHeight := GetHeight(Player)
                if (not DisplayMap[Player], set DisplayMap[Player] = option{HeightWidgetInstance}):
                    HeightWidgetInstance.CreateUIForPlayer(PlayerHeight)
                    if (Agent := agent[Player]):
                        HeightWidgetInstance.ShowUI(Agent)

    GetHeight(Player: player): int =
        if (FortCharacter := Player.GetFortCharacter[]):
            PlayerLocation := FortCharacter.GetTransform().Translation
            PlayerHeight := PlayerLocation.Z + GroundLevelOffset*100.0
            if (HeightInt := Floor[PlayerHeight/100.00]):
                return HeightInt

        return 0

height_widget := class():

    var VerseDevice : height_display = height_display{}
    InstancePlayer: player

    HeightText<localizes>(Text: string, Height: int) : message = "{Text} {Height}"
    HeightWidget : button_quiet = button_quiet{}

    var UIPerPlayer : [player]?canvas = map{}

    var XMinPos: float = 0.4
    var XMaxPos: float = 0.6
    var YMinPos: float = 0.0
    var YMaxPos: float = 0.0

    AdjustTextPos(): void =
        case (VerseDevice.TextPosition):

            text_position.LowerLeft =>
                set XMinPos = 0.0
                set XMaxPos = 0.2
                set YMinPos = 0.7
                set YMaxPos = 0.0

            text_position.LowerRight =>
                set XMinPos = 0.6
                set XMaxPos = 0.8
                set YMinPos = 0.7
                set YMaxPos = 0.0

            text_position.BottomCenter =>
                set XMinPos = 0.4
                set XMaxPos = 0.6
                set YMinPos = 0.7
                set YMaxPos = 0.0

            _ =>

    CreateUIForPlayer(Height: int):canvas=

        AdjustTextPos()
        
        HeightWidget.SetText(HeightText(VerseDevice.Text, Height))
        MyCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := XMinPos, Y := YMinPos}, Maximum := vector2{X := XMaxPos, Y := YMaxPos}}
                    Offsets := margin{Top := 100.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := HeightWidget

    ShowUI(Agent: agent): void =
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            if (MyUI := UIPerPlayer[Player]?):
                PlayerUI.RemoveWidget(MyUI)
                if {set UIPerPlayer[Player] = false}
            else:
                NewUI := CreateUIForPlayer(0)
                PlayerUI.AddWidget(NewUI, player_ui_slot{InputMode := ui_input_mode.None})
                if (set UIPerPlayer[Player] = option{NewUI}) {}
                spawn:
                    UpdateHeight()

    UpdateHeight()<suspends>: void =
        loop:
            Sleep(0.1)
            PlayerHeight := VerseDevice.GetHeight(InstancePlayer)
            HeightWidget.SetText(HeightText(VerseDevice.Text, PlayerHeight))

text_position := enum:

    UpperCenter
    BottomCenter
    LowerRight
    LowerLeft