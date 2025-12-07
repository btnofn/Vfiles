using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Verse.org/Colors }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.
perplayerdisplay:=class(){
    Device : team_score_display_device
    OurPlayerUI : player_ui
    var Canvas : ?canvas

    TextShadowOffset:?vector2=option{vector2{X:=2.0,Y:=2.0}}

    StringToMessage<localizes>(value:string) : message = "{value}"

    var TeamOneScore:text_block = text_block {DefaultTextColor := NamedColors.White} #Blue
    var TeamTwoScore:text_block = text_block {DefaultTextColor := NamedColors.White} #Red
    BlueTeamText:text_block = text_block {DefaultTextColor := NamedColors.Blue} #Team One
    VsText:text_block = text_block {DefaultTextColor := NamedColors.White} #Team One
    RedTeamText:text_block = text_block {DefaultTextColor := NamedColors.Red} #Team Two

    InitWidget():void=
        InitDefaultUIValues()
        NewUI := CreateMyUI()
        OurPlayerUI.AddWidget(NewUI, player_ui_slot{ZOrder:=10,InputMode := ui_input_mode.None})
        set Canvas = option{NewUI}

    InitDefaultUIValues():void=
        BlueTeamText.SetText(StringToMessage("Blue"))
        RedTeamText.SetText(StringToMessage("Red"))
        VsText.SetText(StringToMessage("VS"))
        TeamOneScore.SetText(StringToMessage(ToString("0")))
        TeamTwoScore.SetText(StringToMessage(ToString("0")))

    UpdateUI(InTeamOneScore:int,InTeamTwoScore:int):void=
        TeamOneScore.SetText(StringToMessage(ToString(InTeamOneScore)))
        TeamTwoScore.SetText(StringToMessage(ToString(InTeamTwoScore)))

    CreateMyUI():canvas=
        TeamOneScore.SetShadowOffset(TextShadowOffset)
        TeamOneScore.SetShadowOpacity(1.0)
        TeamOneScore.SetShadowColor(NamedColors.Blue)
        TeamTwoScore.SetShadowOffset(TextShadowOffset)
        TeamTwoScore.SetShadowOpacity(1.0)
        TeamTwoScore.SetShadowColor(NamedColors.Red)
        BlueTeamText.SetShadowOffset(TextShadowOffset)
        BlueTeamText.SetShadowOpacity(1.0)
        RedTeamText.SetShadowOffset(TextShadowOffset)
        RedTeamText.SetShadowOpacity(1.0)
        VsText.SetShadowOffset(TextShadowOffset)
        VsText.SetShadowOpacity(1.0)

        NewCanvas := canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{ Minimum:= vector2{X:=0.5, Y:=0.0}, Maximum:= vector2{X:=0.5, Y:=0.0} }
                    Alignment := vector2{X:=0.5, Y:=0.0}
                    SizeToContent:=true
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := array:
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Left # Alignment of widget within slot.
                                Widget := stack_box:
                                    Orientation := orientation.Vertical
                                    Slots := array:
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center # Alignment of widget within slot.
                                            Padding := margin{Top:=6.0, Bottom:= 2.0} # Empty space between Title and Lines, in pixels.
                                            Widget := RedTeamText
                                        stack_box_slot:
                                            Padding := margin{Top:=2.0, Left:= 12.0, Right:= 12.0, Bottom:= 2.0}
                                            Widget := TeamTwoScore
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center # Alignment of widget within slot.
                                Padding := margin{Top:=2.0, Left:= 24.0, Right:= 24.0, Bottom:= 2.0}
                                Widget := VsText
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Right # Alignment of widget within slot.
                                Widget := stack_box:
                                    Orientation := orientation.Vertical
                                    Slots := array:
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center # Alignment of widget within slot.
                                            Padding := margin{Top:=6.0, Bottom:= 2.0} # Empty space between Title and Lines, in pixels.
                                            Widget := BlueTeamText
                                        stack_box_slot:
                                            Padding := margin{Top:=2.0, Left:= 12.0, Right:= 12.0, Bottom:= 2.0}
                                            Widget := TeamOneScore                                             
        return NewCanvas
}
# A Verse-authored creative device that can be placed in a level
team_score_display_device := class(creative_device):
    var MaybeMyUIPerPlayer:[player]perplayerdisplay = map{}
    var TeamOneKills:int=0
    var TeamTwoKills:int=0

    @editable 
    TeamOneBlue : team_settings_and_inventory_device = team_settings_and_inventory_device{}
    @editable 
    TeamTwoRed : team_settings_and_inventory_device = team_settings_and_inventory_device{}


    OnBegin<override>()<suspends>:void=
        TeamOneBlue.EnemyEliminatedEvent.Subscribe(OnTeamOneScore)
        TeamTwoRed.EnemyEliminatedEvent.Subscribe(OnTeamTwoScore)
        AllPlayers := GetPlayspace().GetPlayers()
        for (L_Agent : AllPlayers):
            HandleJoiningPlayer(L_Agent)
        GetPlayspace().PlayerAddedEvent().Subscribe(HandleJoiningPlayer)

    HandleJoiningPlayer(InAgent:agent):void=
        AddCanvas(InAgent)

    AddCanvas(InAgent:agent):void=
        if (InPlayer := player[InAgent], PlayerUI := GetPlayerUI[InPlayer]):
            if (not MaybeMyUIPerPlayer[InPlayer]):
                PerPlayerDisplay:perplayerdisplay=perplayerdisplay{Device:=Self,OurPlayerUI:=PlayerUI,Canvas:=false}
                PerPlayerDisplay.InitWidget()
                if (set MaybeMyUIPerPlayer[InPlayer] = PerPlayerDisplay) {}

    UpdateUI(InTeamOneScore:int,InTeamTwoScore:int):void=
        for (Key->Value : MaybeMyUIPerPlayer):
            Value.UpdateUI(InTeamOneScore, InTeamTwoScore)

    OnTeamOneScore(InAgent:agent):void=
        IncTeamOneKills()
        UpdateUI(TeamOneKills,TeamTwoKills)

    OnTeamTwoScore(InAgent:agent):void=
        IncTeamTwoKills()
        UpdateUI(TeamOneKills,TeamTwoKills)

    IncTeamOneKills()<transacts>:void=
        set TeamOneKills += 1

    IncTeamTwoKills()<transacts>:void=
        set TeamTwoKills += 1