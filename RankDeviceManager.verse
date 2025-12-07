using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level

spawner := class(tag){}

sentries := class(tag){}

TextForUI<localizes>(InText : string, Agent : agent) : message = "{InText}"

TextForUI2<localizes>(InText : string) : message = " | {InText}"


RankDeviceManager := class(creative_device):
    
    var PlayerMap : [player]RankDeviceManager = map{}

    @editable Tracker : tracker_device = tracker_device{}

    @editable Bronze : hud_message_device = hud_message_device{}

    @editable SilverR : hud_message_device = hud_message_device{}

    @editable GoldR : hud_message_device = hud_message_device{}

    @editable diamondR : hud_message_device = hud_message_device{}

    @editable platR : hud_message_device = hud_message_device{}

    @editable EliteR : hud_message_device = hud_message_device{}

    @editable ChampionR : hud_message_device = hud_message_device{}

    @editable UnrealR : hud_message_device = hud_message_device{}



    InitSpawners():void =
        Spawners := GetCreativeObjectsWithTag(spawner{})

        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerAdded)


    # Runs when the device is started in a running game
    OnBegin< override>()< suspends>:void=
        # TODO: Replace this with your code
        Print("Hello, world!")
        Print("2 + 2 = {2 + 2}")
        InitSpawners()
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)

    
    KillSpawnLoop(Player : player, TextBlock : text_block, Agent : agent)<suspends>:void =
        loop:
            Sleep(0.1)
            if (AgentStats := PlayerMap[Player]):
                TextBlock.SetText(TextForUI("{Tracker.GetValue(Player)}", Agent))

    RankSpawnLoop(Player : player, TextBlock : text_block, Agent : agent)<suspends>:void =
        loop:
            Sleep(0.1)
            if (Tracker.GetValue(Player) >= 1): 
                if (PlayerUi := GetPlayerUI[Player]):
                    Bronze.Show(Agent)
                    TextBlock.SetText(TextForUI2("50"))
                    break
        loop:
            Sleep(0.1)
            if (Tracker.GetValue(Player) >= 50):
                if (PlayerUi := GetPlayerUI[Player]):
                    SilverR.Show(Agent)
                    TextBlock.SetText(TextForUI2("150"))
                    break
        loop:
            Sleep(0.1)
            if (Tracker.GetValue(Player) >= 150):
                 if (PlayerUi := GetPlayerUI[Player]):
                    GoldR.Show(Agent)
                    TextBlock.SetText(TextForUI2("250"))
                    break            
        loop:
            Sleep(0.1)
            if (Tracker.GetValue(Player) >= 250):
                if (PlayerUi := GetPlayerUI[Player]):
                    diamondR.Show(Agent)
                    TextBlock.SetText(TextForUI2("350"))
                    break
        loop:
            Sleep(0.1)
            if (Tracker.GetValue(Player) >= 350):
                    if (PlayerUi := GetPlayerUI[Player]):
                    platR.Show(Agent)
                    TextBlock.SetText(TextForUI2("450"))
                    break       
        loop:
            Sleep(0.1)
            if (Tracker.GetValue(Player) >= 450):
                    if (PlayerUi := GetPlayerUI[Player]):
                    EliteR.Show(Agent)
                    TextBlock.SetText(TextForUI2("550"))
                    break
        loop:
            Sleep(0.1)
            if (Tracker.GetValue(Player) >= 550):
                    if (PlayerUi := GetPlayerUI[Player]):
                    ChampionR.Show(Agent)
                    TextBlock.SetText(TextForUI2("650"))
                    break
        loop:
            Sleep(0.1)
            if (Tracker.GetValue(Player) >= 650):
                    if (PlayerUi := GetPlayerUI[Player]):
                    UnrealR.Show(Agent)
                    TextBlock.SetText(TextForUI2("∞"))
                    break

    OnPlayerAdded(NewPlayer : agent):void =
        Print("Player Added")
        if (PlayerObj := player[NewPlayer]):
            if (PlayerExists := PlayerMap[NewPlayer]):

            else:
                if (set PlayerMap[PlayerObj] = RankDeviceManager{}):
                    if(PlayerUI := GetPlayerUI[PlayerObj]):
                        var TextBlock2 : text_block = text_block{DefaultTextColor := Beige}

                        if (Tracker.GetValue(PlayerObj) < 1):
                            MyCanvas2 := canvas:
                                Slots := array:
                                    canvas_slot:
                                        Anchors := anchors{Minimum := vector2{X := 0.11, Y := 0.650}, Maximum := vector2{X := 0.11, Y := 0.650}}
                                        Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                                        Alignment := vector2{X := 0.5, Y := 0.925}
                                        SizeToContent := true
                                        Widget := TextBlock2
                            Print("Ui should be added")
                            PlayerUI.AddWidget(MyCanvas2)
                            TextBlock2.SetText(TextForUI2("1"))

                        if (Tracker.GetValue(PlayerObj) >= 1):
                            Bronze.Show(NewPlayer)
                            MyCanvas2 := canvas:
                                Slots := array:
                                    canvas_slot:
                                        Anchors := anchors{Minimum := vector2{X := 0.11, Y := 0.650}, Maximum := vector2{X := 0.11, Y := 0.650}}
                                        Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                                        Alignment := vector2{X := 0.45, Y := 0.925}
                                        SizeToContent := true
                                        Widget := TextBlock2
                            Print("Ui should be added")
                            PlayerUI.AddWidget(MyCanvas2)
                            TextBlock2.SetText(TextForUI2("50"))
                            if (Tracker.GetValue(PlayerObj) >= 50):
                                SilverR.Show(NewPlayer)
                                TextBlock2.SetText(TextForUI2("150"))
                                if (Tracker.GetValue(PlayerObj) >= 150):
                                    GoldR.Show(NewPlayer)
                                    TextBlock2.SetText(TextForUI2("250"))
                                    if (Tracker.GetValue(PlayerObj) >= 250):
                                        diamondR.Show(NewPlayer)
                                        TextBlock2.SetText(TextForUI2("350"))
                                        if (Tracker.GetValue(PlayerObj) >= 350):
                                            platR.Show(NewPlayer)
                                            TextBlock2.SetText(TextForUI2("450"))
                                            if (Tracker.GetValue(PlayerObj) >= 450):
                                                EliteR.Show(NewPlayer)
                                                TextBlock2.SetText(TextForUI2("550"))
                                                if (Tracker.GetValue(PlayerObj) >= 550):
                                                    ChampionR.Show(NewPlayer)
                                                    TextBlock2.SetText(TextForUI2("650"))
                                                    if (Tracker.GetValue(PlayerObj) >= 650):
                                                        UnrealR.Show(NewPlayer)
                                                        TextBlock2.SetText(TextForUI2("∞"))
                        
                        
                        var TextBlock : text_block = text_block{DefaultTextColor := White}

                        MyCanvas := canvas:
                            Slots := array:
                                canvas_slot:
                                    Anchors := anchors{Minimum := vector2{X := 0.07, Y := 0.650}, Maximum := vector2{X := 0.07, Y := 0.650}}
                                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                                    Alignment := vector2{X := 0.45, Y := 0.925}
                                    SizeToContent := true
                                    Widget := TextBlock
                        Print("Ui should be added")
                        PlayerUI.AddWidget(MyCanvas)

                        spawn{KillSpawnLoop(PlayerObj, TextBlock, NewPlayer)}

                        spawn{RankSpawnLoop(PlayerObj, TextBlock2, NewPlayer)}


                        

    OnPlayerRemoved(PlayerLeaving : player):void =
        if (ActualPlayer := PlayerMap[PlayerLeaving]):
            var TempPlayerMap:[player]RankDeviceManager = map{}
            for (Key -> Value : PlayerMap, Key <> PlayerLeaving):
                set TempPlayerMap = ConcatenateMaps(TempPlayerMap, map{Key => Value})

            set PlayerMap = TempPlayerMap