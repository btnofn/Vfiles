using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath}
using { /Verse.org/Colors }


Ranked := class(creative_device):
    @editable
    Scores: []score_manager_device = array{}
    @editable
    FivePoints : score_manager_device = score_manager_device{}
    @editable
    FourPoints : score_manager_device = score_manager_device{}
    @editable
    ThreePoints : score_manager_device = score_manager_device{}
    @editable
    TwoPoints : score_manager_device = score_manager_device{}
    @editable
    OnePoint : score_manager_device = score_manager_device{}

    @editable
    MinusOnePoint : score_manager_device = score_manager_device{}
    @editable
    MinusTwoPoints : score_manager_device = score_manager_device{}
    @editable
    MinusThreePoints : score_manager_device = score_manager_device{}

    @editable
    RankAdder : elimination_manager_device = elimination_manager_device{}
    @editable
    RankRemover :elimination_manager_device = elimination_manager_device{}

    @editable
    UnrankedUI : hud_message_device = hud_message_device{}
    @editable
    Bronze1UI : hud_message_device = hud_message_device{}
    @editable
    Bronze2UI : hud_message_device = hud_message_device{}
    @editable
    Bronze3UI : hud_message_device = hud_message_device{}
    @editable
    Silver1UI : hud_message_device = hud_message_device{}
    @editable
    Silver2UI : hud_message_device = hud_message_device{}
    @editable
    Silver3UI : hud_message_device = hud_message_device{}
    @editable
    Gold1UI : hud_message_device = hud_message_device{}
    @editable
    Gold2UI : hud_message_device = hud_message_device{}
    @editable
    Gold3UI : hud_message_device = hud_message_device{}
    @editable
    Platinum1UI : hud_message_device = hud_message_device{}
    @editable
    Platinum2UI : hud_message_device = hud_message_device{}
    @editable
    Platinum3UI : hud_message_device = hud_message_device{}
    @editable
    Diamond1UI : hud_message_device = hud_message_device{}
    @editable
    Diamond2UI : hud_message_device = hud_message_device{}
    @editable
    Diamond3UI : hud_message_device = hud_message_device{}
    @editable
    ChampionUI : hud_message_device = hud_message_device{}
    @editable
    EliteUI : hud_message_device = hud_message_device{}
    @editable
    UnrealUI : hud_message_device = hud_message_device{}
    
    @editable
    UnrankedKillUI : hud_message_device = hud_message_device{}
    @editable
    Bronze1KillUI : hud_message_device = hud_message_device{}
    @editable
    Bronze2KillUI : hud_message_device = hud_message_device{}
    @editable
    Bronze3KillUI : hud_message_device = hud_message_device{}
    @editable
    Silver1KillUI : hud_message_device = hud_message_device{}
    @editable
    Silver2KillUI : hud_message_device = hud_message_device{}
    @editable
    Silver3KillUI : hud_message_device = hud_message_device{}
    @editable
    Gold1KillUI : hud_message_device = hud_message_device{}
    @editable
    Gold2KillUI : hud_message_device = hud_message_device{}
    @editable
    Gold3KillUI : hud_message_device = hud_message_device{}
    @editable
    Platinum1KillUI : hud_message_device = hud_message_device{}
    @editable
    Platinum2KillUI : hud_message_device = hud_message_device{}
    @editable
    Platinum3KillUI : hud_message_device = hud_message_device{}
    @editable
    Diamond1KillUI : hud_message_device = hud_message_device{}
    @editable
    Diamond2KillUI : hud_message_device = hud_message_device{}
    @editable
    Diamond3KillUI : hud_message_device = hud_message_device{}
    @editable
    ChampionKillUI : hud_message_device = hud_message_device{}
    @editable
    EliteKillUI : hud_message_device = hud_message_device{}
    @editable
    UnrealKillUI : hud_message_device = hud_message_device{}
    @editable
    KilledName : hud_message_device = hud_message_device{}
    @editable
    EliminatedText : hud_message_device = hud_message_device{}

    @editable
    Trigger : trigger_device = trigger_device{}

    @editable
    Spawners : []player_spawner_device = array{}
    @editable
    ScoreTracker : tracker_device = tracker_device{}

    var UIText : text_block = text_block{}
    var PlayerData : [agent]CustomPlayerData = map{}
    var UI : [agent]?RankProgressBar =  map{}

    AgentToMessage<public><localizes>(Agent:agent)<transacts>:message = "{Agent}"
    TextForUI<localizes>(RankPoints : int) : message = "{RankPoints}"
    StringToMessage<public><localizes>(String:string)<transacts>:message = "{String}"

    OnBegin<override>()<suspends>:void=

        for(Score : Scores):
            Score.ScoreOutputEvent.Subscribe(AddRankPointsw)
        Trigger.TriggeredEvent.Subscribe(AddRankPoints)
        AllPlayers := GetPlayspace().GetPlayers()
        for(Player :  AllPlayers):
            if(set PlayerData[Player] = CustomPlayerData{}):
        for(Spawner  : Spawners):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
        AlllPlayers := GetPlayspace().GetPlayers()
        for(Player : AlllPlayers):
            OnPlayerSpawned(Player)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        
        RankAdder.EliminationEvent.Subscribe(AddRankPoints)
        RankRemover.EliminatedEvent.Subscribe(RemoveRankPoints)

    OnPlayerSpawned(Player : agent):void=
        if(set PlayerData[Player] = CustomPlayerData{}):
        if(RealPlayer := player[Player]):
            var X : float = 0.05
            var Y : float = 0.8
            if ( PlayerUI := GetPlayerUI[RealPlayer]):
                RankBar :RankProgressBar = RankProgressBar:
                    BackgroundColor := NamedColors.Black 
                    ForegroundColor := NamedColors.DarkCyan
                    BorderColor := NamedColors.White 
                    XSize := 300.0
                    YSize := 60.0
                    Device := Self
                    OurAgent := RealPlayer
                    OurPlayerUI := PlayerUI
                Canvas := canvas:
                    Slots := array:
                        canvas_slot:
                            Widget := RankBar.Init()
                            Anchors := anchors{Minimum := vector2{X := X, Y := Y}, Maximum := vector2{X := X, Y := Y}}
                            Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                            Alignment := vector2{X := X, Y := Y}
                PlayerUI.AddWidget(Canvas, player_ui_slot{ZOrder:=10,InputMode := ui_input_mode.None})

                if(set UI[Player] = option{RankBar}):
        Print("Player Spawned")
        ScoreTracker.Load(Player)
        Rank := ScoreTracker.GetValue(Player)
        Print(ToString(Rank))
        if(set PlayerData[Player].RankScore = Rank ):
        RankCheck(Player, Rank)
        if(FC: fort_character := Player.GetFortCharacter[]):
            FC.EliminatedEvent().Subscribe(EliminatedEvent)
        

    EliminatedEvent(Result : elimination_result):void=
        Print("Player Eliminated")
        Eliminator := Result.EliminatingCharacter
        Eliminated := Result.EliminatedCharacter
        if:
            EliminatorFC := Eliminator?
            EliminatedAgent:= agent[Eliminated]
            EliminatorAgent:= agent[EliminatorFC]
        then:
            # if(set PlayerData[EliminatedAgent].Eliminator = EliminatorAgent):
            Rank := ScoreTracker.GetValue(EliminatedAgent)
            # if(RankPoints := PlayerData[EliminatedAgent].DeathPoints):
                # RankPoints.Activate(EliminatedAgent)
                ScoreTracker.Save(EliminatedAgent)
                spawn:
                    RankUp(EliminatedAgent)
            # ShowRankOnKill(EliminatorAgent, EliminatedAgent)
                    

    OnPlayerRemoved (OutPlayer:player) :void=
        Print("Player Removed")
        if(ActualPlayer := PlayerData[OutPlayer]):
            var TempAllPlayersMap: [agent]CustomPlayerData = map{}
            for (Key -> Value : PlayerData, Key <> OutPlayer):
                set TempAllPlayersMap = ConcatenateMaps(TempAllPlayersMap, map{Key => Value})

            set PlayerData = TempAllPlayersMap

    AddRankPointsw(Player : agent):void=
        Print("Player Killed")
            # if(RankPoints := PlayerData[PlayerAgent].KillPoints):
        ScoreTracker.Save(Player)
        ScoreTracker.Save(Player)
        Rank := ScoreTracker.GetValue(Player)
        if(set PlayerData[Player].RankScore = Rank):
            spawn:
                RankUp(Player)
        # TestPointsShowRankOnKill(PlayerAgent)

    AddRankPoints(Player : ?agent):void=
        Print("Player Killed")
        if(PlayerAgent :agent = Player?):
            # if(RankPoints := PlayerData[PlayerAgent].KillPoints):
                ScoreTracker.Save(PlayerAgent)
                ScoreTracker.Save(PlayerAgent)
                Rank := ScoreTracker.GetValue(PlayerAgent)
                if(set PlayerData[PlayerAgent].RankScore = Rank):
                    spawn:
                        RankUp(PlayerAgent)
                # TestPointsShowRankOnKill(PlayerAgent)

    RemoveRankPoints(PlayerAgent : agent):void=
        Rank := ScoreTracker.GetValue(PlayerAgent)
        # if(RankPoints := PlayerData[PlayerAgent].DeathPoints): 
            spawn:
                RankUp(PlayerAgent) 

    # ShowRankOnKill(Killer : agent, Killed : agent):void=
        # Print("Show Rank On Kill")
        # KilledAgentName := AgentToMessage(Killed)
        # KilledName.SetText(KilledAgentName)
        # if(KillerUi := PlayerData[Killed].KillUI):
        #     KillerUi.Show(Killer)
        #     EliminatedText.Show(Killer)
        #     KilledName.Show(Killer)



    RankCheck(Player : agent, Rank : int):void=

        if(set PlayerData[Player].RankScore = Rank):
        Print("Rank Check")
        if(Rank = 0):
            UnrankedUI.Show(Player)
            if(set PlayerData[Player].KillUI = UnrankedKillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 0):
            if(set PlayerData[Player].RankRange = (0, 0)):
        if(Rank > 0 and Rank < 20):
            Bronze1UI.Show(Player)
            if(set PlayerData[Player].KillUI = Bronze1KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusOnePoint):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 1):
            if(set PlayerData[Player].RankRange = (0, 19)):
        if(Rank > 19 and Rank < 40):
            Bronze2UI.Show(Player)
            if(set PlayerData[Player].KillUI = Bronze2KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusOnePoint):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 2):
            if(set PlayerData[Player].RankRange = (20, 39)):
        if(Rank > 39 and Rank < 65):
            Bronze3UI.Show(Player)
            if(set PlayerData[Player].KillUI = Bronze3KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusOnePoint):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 3):
            if(set PlayerData[Player].RankRange = (40, 64)):
        if(Rank > 64 and Rank < 80):
            Silver1UI.Show(Player)
            if(set PlayerData[Player].KillUI = Silver1KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusTwoPoints):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 4):
            if(set PlayerData[Player].RankRange = (65, 79)):
        if(Rank > 79 and Rank < 100):
            Silver2UI.Show(Player)
            if(set PlayerData[Player].KillUI = Silver2KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusTwoPoints):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 5):
            if(set PlayerData[Player].RankRange = (80, 99)):
        if(Rank > 99 and Rank < 135):
            Silver3UI.Show(Player)
            if(set PlayerData[Player].KillUI = Silver3KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusTwoPoints):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 6):
            if(set PlayerData[Player].RankRange = (100, 134)):
        if(Rank > 134 and Rank < 160):
            Gold1UI.Show(Player)
            if(set PlayerData[Player].KillUI = Gold1KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 7):
            if(set PlayerData[Player].RankRange = (135, 159)):
        if(Rank > 159 and Rank < 180):    
            Gold2UI.Show(Player)
            if(set PlayerData[Player].KillUI = Gold2KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 8):
            if(set PlayerData[Player].RankRange = (160, 179)):
        if(Rank > 179 and Rank < 230):
            Gold3UI.Show(Player)
            if(set PlayerData[Player].KillUI = Gold3KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 9):
            if(set PlayerData[Player].RankRange = (180, 229)):
        if(Rank > 229 and Rank < 260):
            Platinum1UI.Show(Player)
            if(set PlayerData[Player].KillUI = Platinum1KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 10):
            if(set PlayerData[Player].RankRange = (230, 259)):
        if(Rank > 259 and Rank < 280):
            Platinum2UI.Show(Player)
            if(set PlayerData[Player].KillUI = Platinum2KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 11):
            if(set PlayerData[Player].RankRange = (260, 279)):
        if(Rank > 279 and Rank < 320):
            Platinum3UI.Show(Player)
            if(set PlayerData[Player].KillUI = Platinum3KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 12):
            if(set PlayerData[Player].RankRange = (280, 319)):
        if(Rank > 319 and Rank < 400):
            Diamond1UI.Show(Player)
            if(set PlayerData[Player].KillUI = Diamond1KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints):
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 13):
            if(set PlayerData[Player].RankRange = (320, 399)):
        if(Rank > 399 and Rank < 500):
            Diamond2UI.Show(Player)
            if(set PlayerData[Player].KillUI = Diamond2KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints): 
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 14):
            if(set PlayerData[Player].RankRange = (400, 499)):
        if(Rank > 499 and Rank < 600):
            Diamond3UI.Show(Player)
            if(set PlayerData[Player].KillUI = Diamond3KillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints): 
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 15):
            if(set PlayerData[Player].RankRange = (500, 599)):
        if(Rank > 599 and Rank < 1000):
            ChampionUI.Show(Player)
            if(set PlayerData[Player].KillUI = ChampionKillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints): 
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 16):
            if(set PlayerData[Player].RankRange = (600, 999)):
        if(Rank > 999 and Rank < 1700):
            EliteUI.Show(Player)
            if(set PlayerData[Player].KillUI = ChampionKillUI):
            # if(set PlayerData[Player].KillPoints = threePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints): 
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 17):
            if(set PlayerData[Player].RankRange = (1000, 1699)):
        if(Rank > 1699):
            UnrealUI.Show(Player)
            if(set PlayerData[Player].KillUI = UnrealKillUI):
            # if(set PlayerData[Player].KillPoints = FivePoints):
            # if(set PlayerData[Player].DeathPoints = MinusThreePoints): 
            if(set PlayerData[Player].RankScore = Rank):
            if(set PlayerData[Player].CurrentRank = 18):
            if(set PlayerData[Player].RankRange = (1700, 9999)):
        spawn:
            UpdateProggressBar(Player)




#rank ranges
# 0 - 0 Unranked
# 0 - 9 Bronze 1
# 10 - 19 Bronze 2
# 20 - 29 Bronze 3
# 30 - 39 Silver 1
# 40 - 49 Silver 2
# 50 - 64 Silver 3
# 65 - 79 Gold 1
# 80 - 99 Gold 2
# 100 - 119 Gold 3
# 120 - 139 Platinum 1
# 140 - 159 Platinum 2
# 160 - 199 Platinum 3
# 200 - 249 Diamond 1
# 250 - 299 Diamond 2
# 300 - 399 Diamond 3
# 400 - 599 Elite
# 600 - 999 Champion
# 1000+ Unreal

    UpdateProggressBar(Player : agent)<suspends>:void=
        Print("Update Proggress Bar")
        var Result: []tuple(int, int) = array{}
        if:
            var CurrentRank : int = PlayerData[Player].CurrentRank
            var RankScore : int = PlayerData[Player].RankScore
            var RankRange : []int = PlayerData[Player].RankRange
        then:
            if(LowerBound  := RankRange[0] , UpperBound := RankRange[1]):
                ProggressInRank := RankScore - LowerBound
                ProggressInRankFloat := ProggressInRank * 1.0
                Print("Proggress in rank is {ToString(ProggressInRank)}")
                Print("Proggress in rank float is {ToString(ProggressInRankFloat)}")
                TotalPointsInRank := UpperBound - LowerBound + 1
                TotalPointsInRankFloat := TotalPointsInRank * 1.0
                Print("Total points in rank is {ToString(TotalPointsInRank)}")
                Print("Total points in rank float is {ToString(TotalPointsInRankFloat)}")
                ProggressPecentage := ProggressInRankFloat / TotalPointsInRankFloat
                    Test := ProggressPecentage 
                    TestMultiplyed := Test * 100.0
                    Print("Proggress Test Pecentage is {ToString(Test)}")
                    Print("Proggress Test Multiplyed is {ToString(TestMultiplyed)}")
                    if(RB := UI[Player]):
                        if(RRB := RB?):
                            Task := RRB.SetProgress(TestMultiplyed)
                            Task.Await()
                            RRB.SetProgress(TestMultiplyed)

    RankUp(Player : agent)<suspends>:void=
        Print("Rank Up")
        if:
            var CurrentRank : int = PlayerData[Player].CurrentRank
            var RankScore : int = PlayerData[Player].RankScore
            var RankRange : []int = PlayerData[Player].RankRange
        then:
            Print("Rank Up then")
            Print("Current Rank is {ToString(CurrentRank)}")
            Print("Rank Score is {ToString(RankScore)}")
            if(LowerBound  := RankRange[0] , UpperBound := RankRange[1]):
                if:
                    RankScore > UpperBound
                then:
                    Print("Rank Up If")
                    if(RankBarForPlayer := UI[Player]):
                        if(RRB := RankBarForPlayer?):
                            Print("Rank Up For")
                            RRB.SetProgress(100.0).Await()
                            Sleep(0.5)
                            RankCheck(Player, RankScore)
                else:
                    Print("Rank Up Else")
                    RankCheck(Player, RankScore)
            else:
                Print("Rank Up Else")
                RankCheck(Player, RankScore)
