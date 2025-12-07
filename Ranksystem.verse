using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using {/Verse.org/Simulation/Tags}
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Fortnite.com/UI }
 
 
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.
 
RankProgressBar := class():
    ProgressBarColorBase< private> : color_block = color_block{
        DefaultColor := MakeColorFromHex("000000")
        DefaultDesiredSize := vector2{X:= 250.0, Y := 40.0}} 
 
    var ProgressBarColorTop< private> : color_block = color_block{}  
    var Overlay : overlay = overlay{}
 
    PBarTitleTextBlock< private> : text_block = text_block{DefaultTextColor := MakeColorFromHex("FFFFFF")}
 
    HPTitleText< private>< localizes>(HPText : string) : message = "{HPText}"
 
    Init(Current : int, Goal : int):void=
        PBarTitleTextBlock.SetText(HPTitleText("{Current}/{Goal}"))
 
    #############################
 
    UpdateWidthAndText(iCurrent : int, Goal : int):void=
        var NewCurrent : float = iCurrent * 1.0
        var NewGoal : float = Goal * 1.0
 
        RankPercentage := NewCurrent / NewGoal
        BarSize := ProgressBarColorBase.GetDesiredSize()
        NewHealthBarWidth := BarSize.X * RankPercentage
        if (Current := float[NewGoal], Total := float[NewGoal]):
            PBarTitleTextBlock.SetText(HPTitleText("{iCurrent}/{Goal}"))
 
        UpdateHealthBar(NewHealthBarWidth)
 
    ShowUIForPlayer(Player : player):void=
        if (PlayerUI := GetPlayerUI[Player]):
            if (Fortchar := Player.GetFortCharacter[]):
                if (Instigator : agent = Fortchar.GetAgent[]):
                    PlayerUI.AddWidget(CreateUI(Instigator))
 
    UpdateHealthBar(NewWidth : float):void=
        Overlay.RemoveWidget(PBarTitleTextBlock)
        Overlay.RemoveWidget(ProgressBarColorTop)
        set ProgressBarColorTop = CreateTopHealthBar(NewWidth)
 
        Overlay.AddWidget(CreateOverlaySlot(ProgressBarColorTop, horizontal_alignment.Left))
        Overlay.AddWidget(CreateOverlaySlot(PBarTitleTextBlock,horizontal_alignment.Center))
 
    CreateOverlaySlot(TheWidget : widget, HAlignment : horizontal_alignment):overlay_slot=  
        overlay_slot:
            Widget := TheWidget 
            HorizontalAlignment := HAlignment
 
    CreateTopHealthBar< private>(Width: float):color_block=
        ColorBlock := color_block{
            DefaultColor := MakeColorFromHex("f5c800")
            DefaultDesiredSize := vector2{X:= Width, Y := 40.0}} 
 
        set ProgressBarColorTop = ColorBlock
 
 
    CreateOverlay< private>(Agent : agent) : overlay=
        TheOverlay := overlay:
            Slots := array:
                overlay_slot:
                    Widget := ProgressBarColorBase
                overlay_slot:
                    Widget := CreateTopHealthBar(1200.0)
                overlay_slot:
                    Widget := PBarTitleTextBlock
        set Overlay = TheOverlay
 
 
    CreateUI< private>(Agent : agent) : canvas=
        TheCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.975, Y := 0.47}, Maximum := vector2{X := 0.975, Y := 0.47}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.975, Y := 0.47}
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot:
                                Widget := CreateOverlay(Agent)
 
 
        return TheCanvas
 
 
# A Verse-authored creative device that can be placed in a level
 
AllSpawners := class(tag){}
 
RankSystem := class(creative_device):
 
    var PlayerMap : [agent]PlayerVariable = map{}
 
    @editable EliminationTracker : tracker_device = tracker_device{}
 
    Bronze1 : texture = Ranks.Bronze_1
 
    Bronze2 : texture = Ranks.Bronze_2
 
    Bronze3 : texture = Ranks.Bronze_3
 
    Gold1 : texture = Ranks.Gold_1
 
    Gold2 : texture = Ranks.Gold_2
 
    Gold3 : texture = Ranks.Gold_3 
 
    Silver1 : texture = Ranks.Silver_1
 
    Silver2 : texture = Ranks.Silver_2
 
    Silver3 : texture = Ranks.Silver_3 
 
    Platin1 : texture = Ranks.Platin_1
 
    Platin2 : texture = Ranks.Platin_2
 
    Platin3 : texture = Ranks.Platin_3
 
    Diamond1 : texture = Ranks.Diamond_1
 
    Diamond2 : texture = Ranks.Diamond_2
 
    Diamond3 : texture = Ranks.Diamond_3
 
    Elite_1 : texture = Ranks.Elite_1
 
    Champion_1 : texture = Ranks.Champion_1
 
    Unreal_1 : texture = Ranks.Unreal_1
 
    InitSpawners():void =
        Spawners := GetCreativeObjectsWithTag(AllSpawners{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
 
    # Runs when the device is started in a running game
    OnBegin< override>()< suspends>:void=
        # TODO: Replace this with your code
        Print("RankSystem Started")
        InitSpawners()
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        Sleep(0.3)
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers):
            Print("Player granted rank")
            OnPlayerSpawned(Player)
 
    OnPlayerSpawned(Agent : agent):void =
        if (PlayerObj := player[Agent]):
            if (PlayerExists := PlayerMap[Agent]):
 
            else:
                PV : PlayerVariable = PlayerVariable{AgentOB := Agent}
 
                PV.RankBar.Init(PV.GetCurrentValue(), PV.GetCurrentGoal())
 
                PV.RankBar.ShowUIForPlayer(PlayerObj)
 
                spawn{SetCurrentKills(Agent)}
 
                spawn{RankUpdateLoop(Agent, PlayerObj)}
 
                option:
                    set PlayerMap[Agent] = PV
 
 
    SetCurrentKills(Agent : agent)< suspends>:void =
        loop:
            Sleep(0.01)
            if (PV : PlayerVariable = PlayerMap[Agent]):
                PV.SetCurrentValue(EliminationTracker.GetValue(Agent))
                PV.RankBar.UpdateWidthAndText(PV.GetCurrentValue(), PV.GetCurrentGoal())
 
    RankUpdateLoop(Agent : agent, Player : player)< suspends>:void =
 
        RankTextureBlock : texture_block = texture_block{DefaultImage := Bronze1, DefaultDesiredSize := vector2{X := 210.0, Y := 75.0}}
 
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 0):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(25)
                    RankTextureBlock.SetImage(Bronze1)
                    NewCanvas : canvas = canvas:
                        Slots := array:
                            canvas_slot:
                                Widget := RankTextureBlock
                                Anchors := anchors{Minimum := vector2{X := 0.97, Y := 0.4}, Maximum := vector2{X := 0.97, Y := 0.4}}
                                Alignment := vector2{X := 0.97, Y := 0.4}
 
                    if (PlayerUI := GetPlayerUI[Player]):
                        PlayerUI.AddWidget(NewCanvas)
                        Print("Added Rank Widget")
                    break
 
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 25):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(50)
                    RankTextureBlock.SetImage(Bronze2)
 
                    break
 
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 50):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(75)
                    RankTextureBlock.SetImage(Bronze3)
 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 75):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(100)
                    RankTextureBlock.SetImage(Silver1)
 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 100):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(150)
                    RankTextureBlock.SetImage(Silver2)
 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 150):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(200)
                    RankTextureBlock.SetImage(Silver3)
 
                    break 
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 200):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(250)
                    RankTextureBlock.SetImage(Gold1)
 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 250):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(300)
                    RankTextureBlock.SetImage(Gold2)
 
                    break 
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 300):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(350)
                    RankTextureBlock.SetImage(Gold3)
 
                    break 
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 350):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(400)
                    RankTextureBlock.SetImage(Platin1)
 
                    break 
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 400):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(450)
                    RankTextureBlock.SetImage(Platin2)
 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 450):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(500)
                    RankTextureBlock.SetImage(Platin3)
 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 500):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(600)
                    RankTextureBlock.SetImage(Diamond1)
 
                    break 
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 600):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(700)
                    RankTextureBlock.SetImage(Diamond2)
 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 700):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(1000)
                    RankTextureBlock.SetImage(Diamond3)
 
                    break  
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 1000):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(1500)
                    RankTextureBlock.SetImage(Elite_1)
 
                    break
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 1500):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(3000)
                    RankTextureBlock.SetImage(Champion_1)
 
                    break 
        loop:
            Sleep(0.01)
            if (EliminationTracker.GetValue(Agent) >= 3000):
                if (PV : PlayerVariable = PlayerMap[Agent]):
                    PV.SetCurrentGoal(5000)
                    RankTextureBlock.SetImage(Unreal_1)
 
                    break 
 
 
 
    OnPlayerRemoved(PlayerLeft : agent):void =
        if (Agent := agent[PlayerLeft]):
            if (ActualPlayer := PlayerMap[Agent]):
                var TempAllPlayerMap : [agent]PlayerVariable = map{}
                for (Key -> Value : PlayerMap, Key <> Agent):
                    set TempAllPlayerMap = ConcatenateMaps(TempAllPlayerMap, map{Key => Value})
 
                set PlayerMap = TempAllPlayerMap