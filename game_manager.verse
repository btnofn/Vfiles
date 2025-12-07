using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation/Tags }

GameManagerTag := class(tag){}

game_manager := class(creative_device):

    @editable var IsTesting:logic = false
    @editable var TestingNumber:int = 0

    @editable Barrier:barrier_device = barrier_device{}
    @editable WallProp:prop_manipulator_device = prop_manipulator_device{}
    @editable PlayerCount:player_counter_device = player_counter_device{}
    @editable DBNO:down_but_not_out_device = down_but_not_out_device{}
    @editable RemoveItems:item_remover_device = item_remover_device{}
    @editable ResetBombs:[]explosive_device = array{}
    @editable NoClass:class_and_team_selector_device = class_and_team_selector_device{}
    @editable ToggleSystem:toggle_system = toggle_system{}
    @editable RemoteGranter:item_granter_device = item_granter_device{}
    @editable RemoteRemover:item_remover_device = item_remover_device{}
    @editable MutatorZone:mutator_zone_device = mutator_zone_device{}
    @editable Volume:volume_device = volume_device{}
    @editable ScoreManager:score_manager_device = score_manager_device{}
    @editable RoundXP:accolades_device = accolades_device{}
    @editable PlayerCounter:player_counter_device = player_counter_device{}

    @editable RoundWonHUD:hud_message_device = hud_message_device{}
    @editable RoundLostHUD:hud_message_device = hud_message_device{}
    @editable RoundDrawHUD:hud_message_device = hud_message_device{}

    @editable LavaMinigame:lava_minigame = lava_minigame{}
    @editable SlomoMinigame:slomo_minigame = slomo_minigame{}
    @editable SpeedMinigame:speed_minigame = speed_minigame{}
    @editable ItemMinigames:item_minigames = item_minigames{}
    @editable FirstPersonMinigame:firstperson_minigame = firstperson_minigame{}
    @editable InstantReloadMinigame:instantreload_minigame = instantreload_minigame{}
    @editable BalloonMinigame:balloon_minigame = balloon_minigame{}
    @editable PlaneMinigame:plane_minigame = plane_minigame{}
    @editable MysteryMinigame:mystery_minigame = mystery_minigame{}
    @editable DoublePumpMinigame:doublepump_minigame = doublepump_minigame{}
    @editable OneShotMinigame:oneshot_minigame = oneshot_minigame{}
    @editable ObbyMinigame:obby_minigame = obby_minigame{}
    @editable TimewarpMinigame:timewarp_minigame = timewarp_minigame{}
    @editable TopdownMinigame:topdown_minigame = topdown_minigame{}
    @editable InvisibleMinigame:invisible_minigame = invisible_minigame{}
    @editable BouncehouseMinigame:bouncehouse_minigame = bouncehouse_minigame{}
    @editable Sniperduel:sniperduel_minigame = sniperduel_minigame{}
    @editable ImpulseMinigame:impulse_minigame = impulse_minigame{}
    @editable HideNSeekMinigame:hidenseek_minigame = hidenseek_minigame{}
    @editable MazeMinigame:maze_minigame = maze_minigame{}
    @editable BoxfightMinigame:boxfight_minigame = boxfight_minigame{}
    @editable JunkMinigame:junk_minigame = junk_minigame{}
    @editable BoogieMinigame:boggiedown_minigame = boggiedown_minigame{}
    @editable PickaxeMinigame:pickaxe_minigame = pickaxe_minigame{}
    @editable ThrowablesMinigame:throwables_minigame = throwables_minigame{}

    @editable HeightMinigame:height_minigame = height_minigame{}
    @editable TrapTowerMinigame:traptower_minigame = traptower_minigame{}
    @editable ZoneWarsMinigame:zonewars_minigame = zonewars_minigame{}
    @editable BoatMinigame:boat_minigame = boat_minigame{}

    @editable SpinnigWheelHUD:hud_message_device = hud_message_device{}

    @editable LavaChoosingHUD:hud_message_device = hud_message_device{}
    @editable SlomoChoosingHUD:hud_message_device = hud_message_device{}
    @editable SpeedChoosingHUD:hud_message_device = hud_message_device{}
    @editable BladeChoosingHUD:hud_message_device = hud_message_device{}
    @editable FirstPersonChoosingHUD:hud_message_device = hud_message_device{}
    @editable MythicChoosingHUD:hud_message_device = hud_message_device{}
    @editable ExplosiveChoosingHUD:hud_message_device = hud_message_device{}
    @editable ExoticChoosingHUD:hud_message_device = hud_message_device{}
    @editable FishFightChoosingHUD:hud_message_device = hud_message_device{}
    @editable InstantReloadChoosingHUD:hud_message_device = hud_message_device{}
    @editable BalloonChoosingHUD:hud_message_device = hud_message_device{}
    @editable PlaneChoosingHUD:hud_message_device = hud_message_device{}
    @editable MysteryChoosingHUD:hud_message_device = hud_message_device{}
    @editable DoublePumpChoosingHUD:hud_message_device = hud_message_device{}
    @editable OneShotChoosingHUD:hud_message_device = hud_message_device{}
    @editable ObbyChoosingHUD:hud_message_device = hud_message_device{}
    @editable TimewarpChoosingHUD:hud_message_device = hud_message_device{}
    @editable OGChoosingHUD:hud_message_device = hud_message_device{}
    @editable TopdownChoosingHUD:hud_message_device = hud_message_device{}
    @editable InvisibleChoosingHUD:hud_message_device = hud_message_device{}
    @editable BouncehouseChoosingHUD:hud_message_device = hud_message_device{}
    @editable SniperduelChoosingHUD:hud_message_device = hud_message_device{}
    @editable ImpulseChoosingHUD:hud_message_device = hud_message_device{}
    @editable HideNSeekChoosingHUD:hud_message_device = hud_message_device{}
    @editable MazeChoosingHUD:hud_message_device = hud_message_device{}
    @editable BoxfightChoosingHUD:hud_message_device = hud_message_device{}
    @editable JunkChoosingHUD:hud_message_device = hud_message_device{}
    @editable BoogieChoosingHUD:hud_message_device = hud_message_device{}
    @editable PickaxeChoosingHUD:hud_message_device = hud_message_device{}
    @editable ThrowablesChoosingHUD:hud_message_device = hud_message_device{}
    @editable HeightChoosingHUD:hud_message_device = hud_message_device{}
    @editable TrapTowerChoosingHUD:hud_message_device = hud_message_device{}
    @editable ZoneWarsChoosingHUD:hud_message_device = hud_message_device{}
    @editable BoatChoosingHUD:hud_message_device = hud_message_device{}
    @editable PrimalChoosingHUD:hud_message_device = hud_message_device{}
    @editable CubedChoosingHUD:hud_message_device = hud_message_device{}

    @editable LavaHUD:hud_message_device = hud_message_device{}
    @editable SlomoHUD:hud_message_device = hud_message_device{}
    @editable SpeedHUD:hud_message_device = hud_message_device{}
    @editable BladeHUD:hud_message_device = hud_message_device{}
    @editable FirstPersonHUD:hud_message_device = hud_message_device{}
    @editable MythicHUD:hud_message_device = hud_message_device{}
    @editable ExplosiveHUD:hud_message_device = hud_message_device{}
    @editable ExoticHUD:hud_message_device = hud_message_device{}
    @editable FishFightHUD:hud_message_device = hud_message_device{}
    @editable InstantReloadHUD:hud_message_device = hud_message_device{}
    @editable BalloonHUD:hud_message_device = hud_message_device{}
    @editable PlaneHUD:hud_message_device = hud_message_device{}
    @editable MysteryHUD:hud_message_device = hud_message_device{}
    @editable DoublePumpHUD:hud_message_device = hud_message_device{}
    @editable OneShotHUD:hud_message_device = hud_message_device{}
    @editable ObbyHUD:hud_message_device = hud_message_device{}
    @editable TimewarpHUD:hud_message_device = hud_message_device{}
    @editable OGHUD:hud_message_device = hud_message_device{}
    @editable TopdownHUD:hud_message_device = hud_message_device{}
    @editable InvisibleHUD:hud_message_device = hud_message_device{}
    @editable BouncehouseHUD:hud_message_device = hud_message_device{}
    @editable SniperduelHUD:hud_message_device = hud_message_device{}
    @editable ImpulseHUD:hud_message_device = hud_message_device{}
    @editable HideNSeekHUD:hud_message_device = hud_message_device{}
    @editable MazeHUD:hud_message_device = hud_message_device{}
    @editable BoxfightHUD:hud_message_device = hud_message_device{}
    @editable JunkHUD:hud_message_device = hud_message_device{}
    @editable BoogieHUD:hud_message_device = hud_message_device{}
    @editable PickaxeHUD:hud_message_device = hud_message_device{}
    @editable ThrowablesHUD:hud_message_device = hud_message_device{}
    @editable HeightHUD:hud_message_device = hud_message_device{}
    @editable TrapTowerHUD:hud_message_device = hud_message_device{}
    @editable ZoneWarsHUD:hud_message_device = hud_message_device{}
    @editable BoatHUD:hud_message_device = hud_message_device{}
    @editable PrimalHUD:hud_message_device = hud_message_device{}
    @editable CubedHUD:hud_message_device = hud_message_device{}

    @editable Teleport1:teleporter_device = teleporter_device{}
    @editable Teleport2:teleporter_device = teleporter_device{}

    @editable LavaAnalytics:analytics_device = analytics_device{}
    @editable SlomoAnalytics:analytics_device = analytics_device{}
    @editable SpeedAnalytics:analytics_device = analytics_device{}
    @editable BladeAnalytics:analytics_device = analytics_device{}
    @editable FirstPersonAnalytics:analytics_device = analytics_device{}
    @editable MythicAnalytics:analytics_device = analytics_device{}
    @editable ExplosiveAnalytics:analytics_device = analytics_device{}
    @editable ExoticAnalytics:analytics_device = analytics_device{}
    @editable FishFightAnalytics:analytics_device = analytics_device{}
    @editable InstantReloadAnalytics:analytics_device = analytics_device{}
    @editable BalloonAnalytics:analytics_device = analytics_device{}
    @editable PlaneAnalytics:analytics_device = analytics_device{}
    @editable MysteryAnalytics:analytics_device = analytics_device{}
    @editable DoublePumpAnalytics:analytics_device = analytics_device{}
    @editable OneShotAnalytics:analytics_device = analytics_device{}
    @editable ObbyAnalytics:analytics_device = analytics_device{}
    @editable TimewarpAnalytics:analytics_device = analytics_device{}
    @editable OGAnalytics:analytics_device = analytics_device{}
    @editable TopdownAnalytics:analytics_device = analytics_device{}
    @editable InvisibleAnalytics:analytics_device = analytics_device{}
    @editable BouncehouseAnalytics:analytics_device = analytics_device{}
    @editable SniperduelAnalytics:analytics_device = analytics_device{}
    @editable ImpulseAnalytics:analytics_device = analytics_device{}
    @editable HideNSeekAnalytics:analytics_device = analytics_device{}
    @editable MazeAnalytics:analytics_device = analytics_device{}
    @editable BoxfightAnalytics:analytics_device = analytics_device{}
    @editable JunkAnalytics:analytics_device = analytics_device{}
    @editable BoogieAnalytics:analytics_device = analytics_device{}
    @editable PickaxeAnalytics:analytics_device = analytics_device{}
    @editable ThrowablesAnalytics:analytics_device = analytics_device{}
    @editable HeightAnalytics:analytics_device = analytics_device{}
    @editable TrapTowerAnalytics:analytics_device = analytics_device{}
    @editable ZoneWarsAnalytics:analytics_device = analytics_device{}
    @editable BoatAnalytics:analytics_device = analytics_device{}
    @editable PrimalAnalytics:analytics_device = analytics_device{}
    @editable CubedAnalytics:analytics_device = analytics_device{}

    @editable BladeRemover:item_remover_device = item_remover_device{}

    var CurrentMinigame:int = 0
    var InProgress:logic = false

    NewMinigameEvent : event() = event(){}

    OnBegin<override>()<suspends>:void=
        Barrier.Disable()
        MutatorZone.Disable()
        Volume.AgentEntersEvent.Subscribe(OnPlayerEntersVolume)
        PlayerCount.CountSucceedsEvent.Subscribe(StartGame)
        DBNO.AgentDownedEvent.Subscribe(ResetGame)
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            RemoteGranter.GrantItem(Player)

        if(Player1:=Players[0]):
            Teleport1.Teleport(Player1)

        if(Player2:=Players[1]):
            Teleport2.Teleport(Player2)

        if(IsTesting = true):
            PlayerCounter.SetTargetCount(1)

    OnPlayerEntersVolume(Agent:agent):void=
        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0]):
            if(Player1 = Agent):
                Teleport1.Teleport(Agent)

        if(Player2:=Players[1]):
            if(Player2 = Agent):
                Teleport2.Teleport(Agent)

    StartGame():void=
        if(InProgress = false):
            spawn{StartGameLoop()}

    StartGameLoop()<suspends>:void=
        NewMinigameEvent.Signal()
        SpinnigWheelHUD.Show()
        Sleep(2.0)
        SpinnigWheelHUD.Hide()
        if(PlayerCount.IsPassingTest[] and InProgress = false):
            set InProgress = true

            Players:=GetPlayspace().GetPlayers()
            for(Player:Players):
                RemoteRemover.Remove(Player)
            
            if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
                UtilsSystem.ChangeToStandardClass()

            Print("Starting Game")

            MinigameArray:=ToggleSystem.GetMinigameArray()
            RandomInt := GetRandomInt(0, MinigameArray.Length - 1)
            if(MinigameArray.Length = 0):
                Print("No minigames selected, normal 1v1")
                if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
                    UtilsSystem.GrantStandardItems()

                WallProp.HideProps()
                PlayerCount.Disable()
                PlayerCount.Reset()

                return

            if(MinigameInt := MinigameArray[RandomInt], Player1:=Players[0]):
                set CurrentMinigame = MinigameInt

                if(IsTesting = true):
                    if(TestingNumber <> 0):
                        set CurrentMinigame = TestingNumber

                if(CurrentMinigame = 1):
                    LavaAnalytics.Submit(Player1)
                    LavaChoosingHUD.Show()
                    Sleep(1.0)
                    LavaChoosingHUD.Hide()
                    LavaHUD.Show()
                    LavaMinigame.StartMinigame()
                    Print("Lava Minigame")
                else if(CurrentMinigame = 2):
                    SlomoAnalytics.Submit(Player1)
                    SlomoChoosingHUD.Show()
                    Sleep(1.0)
                    SlomoChoosingHUD.Hide()
                    SlomoHUD.Show()
                    SlomoMinigame.StartMinigame()
                    Print("Slomo Minigame")
                else if(CurrentMinigame = 3):
                    SpeedAnalytics.Submit(Player1)
                    SpeedChoosingHUD.Show()
                    Sleep(1.0)
                    SpeedChoosingHUD.Hide()
                    SpeedHUD.Show()
                    SpeedMinigame.StartMinigame()
                    Print("Speed Minigame")
                else if(CurrentMinigame = 4):
                    BladeAnalytics.Submit(Player1)
                    BladeChoosingHUD.Show()
                    Sleep(1.0)
                    BladeChoosingHUD.Hide()
                    BladeHUD.Show()
                    ItemMinigames.StartBlade()
                    Print("Blade Minigame")
                else if(CurrentMinigame = 5):
                    FirstPersonAnalytics.Submit(Player1)
                    FirstPersonChoosingHUD.Show()
                    Sleep(1.0)
                    FirstPersonChoosingHUD.Hide()
                    FirstPersonHUD.Show()
                    FirstPersonMinigame.StartMinigame()
                    Print("First Person Minigame")
                else if(CurrentMinigame = 6):
                    MythicAnalytics.Submit(Player1)
                    MythicChoosingHUD.Show()
                    Sleep(1.0)
                    MythicChoosingHUD.Hide()
                    MythicHUD.Show()
                    ItemMinigames.StartMythic()
                    Print("Mythic Minigame")
                else if(CurrentMinigame = 7):
                    ExplosiveAnalytics.Submit(Player1)
                    ExplosiveChoosingHUD.Show()
                    Sleep(1.0)
                    ExplosiveChoosingHUD.Hide()
                    ExplosiveHUD.Show()
                    ItemMinigames.StartExplosive()
                    Print("Explosive Minigame")
                else if(CurrentMinigame = 8):
                    ExoticAnalytics.Submit(Player1)
                    ExoticChoosingHUD.Show()
                    Sleep(1.0)
                    ExoticChoosingHUD.Hide()
                    ExoticHUD.Show()
                    ItemMinigames.StartExotic()
                    Print("Exotic Minigame")
                else if(CurrentMinigame = 9):
                    FishFightAnalytics.Submit(Player1)
                    FishFightChoosingHUD.Show()
                    Sleep(1.0)
                    FishFightChoosingHUD.Hide()
                    FishFightHUD.Show()
                    ItemMinigames.StartFishFight()
                    Print("Fish Fight Minigame")
                else if(CurrentMinigame = 10):
                    InstantReloadAnalytics.Submit(Player1)
                    InstantReloadChoosingHUD.Show()
                    Sleep(1.0)
                    InstantReloadChoosingHUD.Hide()
                    InstantReloadHUD.Show()
                    InstantReloadMinigame.StartMinigame()
                    Print("Instant Reload Minigame")
                else if(CurrentMinigame = 11):
                    BalloonAnalytics.Submit(Player1)
                    BalloonChoosingHUD.Show()
                    Sleep(1.0)
                    BalloonChoosingHUD.Hide()
                    BalloonHUD.Show()
                    BalloonMinigame.StartMinigame()
                    Print("Balloon Minigame")
                else if(CurrentMinigame = 12):
                    PlaneAnalytics.Submit(Player1)
                    PlaneChoosingHUD.Show()
                    Sleep(1.0)
                    PlaneChoosingHUD.Hide()
                    PlaneHUD.Show()
                    PlaneMinigame.StartMinigame()
                    Print("Plane Minigame")
                else if(CurrentMinigame = 13):
                    MysteryAnalytics.Submit(Player1)
                    MysteryChoosingHUD.Show()
                    Sleep(1.0)
                    MysteryChoosingHUD.Hide()
                    MysteryHUD.Show()
                    MysteryMinigame.StartMinigame()
                    Print("Mystery Minigame")
                else if(CurrentMinigame = 14):
                    DoublePumpAnalytics.Submit(Player1)
                    DoublePumpChoosingHUD.Show()
                    Sleep(1.0)
                    DoublePumpChoosingHUD.Hide()
                    DoublePumpHUD.Show()
                    DoublePumpMinigame.StartMinigame()
                    Print("Double Pump Minigame")
                else if(CurrentMinigame = 15):
                    OneShotAnalytics.Submit(Player1)
                    OneShotChoosingHUD.Show()
                    Sleep(1.0)
                    OneShotChoosingHUD.Hide()
                    OneShotHUD.Show()
                    OneShotMinigame.StartMinigame()
                    Print("One Shot Minigame")
                else if(CurrentMinigame = 16):
                    ObbyAnalytics.Submit(Player1)
                    ObbyChoosingHUD.Show()
                    Sleep(1.0)
                    ObbyChoosingHUD.Hide()
                    ObbyHUD.Show()
                    ObbyMinigame.StartMinigame()
                    Print("Obby Minigame")
                else if(CurrentMinigame = 17):
                    TimewarpAnalytics.Submit(Player1)
                    TimewarpChoosingHUD.Show()
                    Sleep(1.0)
                    TimewarpChoosingHUD.Hide()
                    TimewarpHUD.Show()
                    TimewarpMinigame.StartMinigame()
                    Print("Timewarp Minigame")
                else if(CurrentMinigame = 18):
                    OGAnalytics.Submit(Player1)
                    OGChoosingHUD.Show()
                    Sleep(1.0)
                    OGChoosingHUD.Hide()
                    OGHUD.Show()
                    ItemMinigames.StartOG()
                    Print("OG Minigame")
                else if(CurrentMinigame = 19):
                    TopdownAnalytics.Submit(Player1)
                    TopdownChoosingHUD.Show()
                    Sleep(1.0)
                    TopdownChoosingHUD.Hide()
                    TopdownHUD.Show()
                    TopdownMinigame.StartMinigame()
                    Print("Topdown Minigame")
                else if(CurrentMinigame = 20):
                    InvisibleAnalytics.Submit(Player1)
                    InvisibleChoosingHUD.Show()
                    Sleep(1.0)
                    InvisibleChoosingHUD.Hide()
                    InvisibleHUD.Show()
                    InvisibleMinigame.StartMinigame()
                    Print("Invisible Minigame")
                else if(CurrentMinigame = 21):
                    BouncehouseAnalytics.Submit(Player1)
                    BouncehouseChoosingHUD.Show()
                    Sleep(1.0)
                    BouncehouseChoosingHUD.Hide()
                    BouncehouseHUD.Show()
                    BouncehouseMinigame.StartMinigame()
                    Print("Bouncehouse Minigame")
                else if(CurrentMinigame = 22):
                    SniperduelAnalytics.Submit(Player1)
                    SniperduelChoosingHUD.Show()
                    Sleep(1.0)
                    SniperduelChoosingHUD.Hide()
                    SniperduelHUD.Show()
                    Sniperduel.StartMinigame()
                    Print("Sniperduel Minigame")
                else if(CurrentMinigame = 23):
                    ImpulseAnalytics.Submit(Player1)
                    ImpulseChoosingHUD.Show()
                    Sleep(1.0)
                    ImpulseChoosingHUD.Hide()
                    ImpulseHUD.Show()
                    ImpulseMinigame.StartMinigame()
                    Print("Impulse Minigame")
                else if(CurrentMinigame = 24):
                    HideNSeekAnalytics.Submit(Player1)
                    HideNSeekChoosingHUD.Show()
                    Sleep(1.0)
                    HideNSeekChoosingHUD.Hide()
                    HideNSeekHUD.Show()
                    HideNSeekMinigame.StartMinigame()
                    Print("HideNSeek Minigame")
                else if(CurrentMinigame = 25):
                    MazeAnalytics.Submit(Player1)
                    MazeChoosingHUD.Show()
                    Sleep(1.0)
                    MazeChoosingHUD.Hide()
                    MazeHUD.Show()
                    MazeMinigame.StartMinigame()
                    Print("Maze Minigame")
                else if(CurrentMinigame = 26):
                    BoxfightAnalytics.Submit(Player1)
                    BoxfightChoosingHUD.Show()
                    Sleep(1.0)
                    BoxfightChoosingHUD.Hide()
                    BoxfightHUD.Show()
                    BoxfightMinigame.StartMinigame()
                    Print("Boxfight Minigame")
                else if(CurrentMinigame = 27):
                    JunkAnalytics.Submit(Player1)
                    JunkChoosingHUD.Show()
                    Sleep(1.0)
                    JunkChoosingHUD.Hide()
                    JunkHUD.Show()
                    JunkMinigame.StartMinigame()
                    Print("Junk Minigame")
                else if(CurrentMinigame = 28):
                    BoogieAnalytics.Submit(Player1)
                    BoogieChoosingHUD.Show()
                    Sleep(1.0)
                    BoogieChoosingHUD.Hide()
                    BoogieHUD.Show()
                    BoogieMinigame.StartMinigame()
                    Print("Boogie Minigame")
                else if(CurrentMinigame = 29):
                    PickaxeAnalytics.Submit(Player1)
                    PickaxeChoosingHUD.Show()
                    Sleep(1.0)
                    PickaxeChoosingHUD.Hide()
                    PickaxeHUD.Show()
                    PickaxeMinigame.StartMinigame()
                    Print("Pickaxe Minigame")
                else if(CurrentMinigame = 30):
                    ThrowablesAnalytics.Submit(Player1)
                    ThrowablesChoosingHUD.Show()
                    Sleep(1.0)
                    ThrowablesChoosingHUD.Hide()
                    ThrowablesHUD.Show()
                    ThrowablesMinigame.StartMinigame()
                    Print("Throwables Minigame")
                else if(CurrentMinigame = 31):
                    HeightAnalytics.Submit(Player1)
                    HeightChoosingHUD.Show()
                    Sleep(1.0)
                    HeightChoosingHUD.Hide()
                    HeightHUD.Show()
                    HeightMinigame.StartMinigame()
                    Print("Height Minigame")
                else if(CurrentMinigame = 32):
                    TrapTowerAnalytics.Submit(Player1)
                    TrapTowerChoosingHUD.Show()
                    Sleep(1.0)
                    TrapTowerChoosingHUD.Hide()
                    TrapTowerHUD.Show()
                    TrapTowerMinigame.StartMinigame()
                    Print("Trap Tower Minigame")
                else if(CurrentMinigame = 33):
                    ZoneWarsAnalytics.Submit(Player1)
                    ZoneWarsChoosingHUD.Show()
                    Sleep(1.0)
                    ZoneWarsChoosingHUD.Hide()
                    ZoneWarsHUD.Show()
                    ZoneWarsMinigame.StartMinigame()
                    Print("Zone Wars Minigame")
                else if(CurrentMinigame = 34):
                    BoatAnalytics.Submit(Player1)
                    BoatChoosingHUD.Show()
                    Sleep(1.0)
                    BoatChoosingHUD.Hide()
                    BoatHUD.Show()
                    BoatMinigame.StartMinigame()
                    Print("Boat Minigame")
                else if(CurrentMinigame = 35):
                    PrimalAnalytics.Submit(Player1)
                    PrimalChoosingHUD.Show()
                    Sleep(1.0)
                    PrimalChoosingHUD.Hide()
                    PrimalHUD.Show()
                    Print("Primal Minigame")
                    ItemMinigames.StartPrimal()
                else if(CurrentMinigame = 36):
                    CubedAnalytics.Submit(Player1)
                    CubedChoosingHUD.Show()
                    Sleep(1.0)
                    CubedChoosingHUD.Hide()
                    CubedHUD.Show()
                    Print("Cubed Minigame")
                    ItemMinigames.StartCubed()
                    
            WallProp.HideProps()
            PlayerCount.Disable()
            PlayerCount.Reset()

            Sleep(1.0)

            Barrier.Enable()

            Sleep(3.0)

            Barrier.Disable()

    EndGame(WinningPlayer:agent):void=
        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0], Player2:=Players[1]):
            if(WinningPlayer = Player1):
                if(FortCharacter:=Player2.GetFortCharacter[]):
                    FortCharacter.Damage(300.0)
            else:
                if(FortCharacter:=Player1.GetFortCharacter[]):
                    FortCharacter.Damage(300.0)

    ResetGame(Agent:agent):void=
        if(CurrentMinigame = 12 or CurrentMinigame = 34):
            spawn{ResetGameLoop(Agent, 0.5, false)}
        else:
            spawn{ResetGameLoop(Agent, 0.0, false)}

    DrawGame():void=
        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0]):
            spawn{ResetGameLoop(Player1, 0.0, true)}

    ResetGameLoop(Agent:agent, Delay:float, Draw:logic)<suspends>:void=
        Sleep(Delay)
        set InProgress = false
        MutatorZone.Enable()
        MutatorZone.Disable()
        WallProp.ShowProps()
        PlayerCount.Enable()
        PlayerCount.Reset()
        Barrier.Disable()

        for(ResetBomb:ResetBombs):
            ResetBomb.Reset()
            ResetBomb.Explode(Agent)

        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0], Player2:=Players[1]):
            if(Draw = false):
                if(Player1 = Agent):
                    Print("Player 2 Wins")
                    ScoreManager.Activate(Player2)
                    RoundXP.Award(Player2)

                    RoundWonHUD.Show(Player2)
                    RoundLostHUD.Show(Player1)
                else:
                    Print("Player 1 Wins")
                    ScoreManager.Activate(Player1)
                    RoundXP.Award(Player1)

                    RoundWonHUD.Show(Player1)
                    RoundLostHUD.Show(Player2)

            if(Draw = true):
                RoundDrawHUD.Show(Player1)
                RoundDrawHUD.Show(Player2)

                DBNO.Revive(Player1)
                DBNO.Revive(Player2)
            else:
                DBNO.Revive(Agent)

            Teleport1.Teleport(Player1)
            Teleport2.Teleport(Player2)

        for(Player:Players):
            NoClass.ChangeClass(Player)
            RemoveItems.Remove(Player)
            RemoteGranter.GrantItem(Player)
            if(FC:=Player.GetFortCharacter[]):
                FC.SetHealth(FC.GetMaxHealth())
                FC.SetShield(FC.GetMaxShield())

        if(CurrentMinigame = 1):
            LavaMinigame.ResetMinigame()
            LavaHUD.Hide()
            Print("Resetting: Lava Minigame")
        else if(CurrentMinigame = 2):
            SlomoMinigame.ResetMinigame()
            SlomoHUD.Hide()
            Print("Resetting: Slomo Minigame")
        else if(CurrentMinigame = 3):
            SpeedMinigame.ResetMinigame()
            SpeedHUD.Hide()
            Print("Resetting: Speed Minigame")
        else if(CurrentMinigame = 4):
            BladeHUD.Hide()
            MutatorZone.Enable()
            MutatorZone.Disable()
            if(Player1:=Players[0]):
                BladeRemover.Remove(Player1)  
            Print("Resetting: Blade Minigame")
        else if(CurrentMinigame = 5):
            FirstPersonMinigame.ResetMinigame()
            FirstPersonHUD.Hide()
            Print("Resetting: First Person Minigame")
        else if(CurrentMinigame = 6):
            MythicHUD.Hide()
            Print("Resetting: Mythic Minigame")
        else if(CurrentMinigame = 7):
            ExplosiveHUD.Hide()
            Print("Resetting: Explosive Minigame")
        else if(CurrentMinigame = 8):
            ExoticHUD.Hide()
            Print("Resetting: Exotic Minigame")
        else if(CurrentMinigame = 9):
            FishFightHUD.Hide()
            Print("Resetting: Fish Fight Minigame")
        else if(CurrentMinigame = 10):
            InstantReloadMinigame.ResetMinigame()
            InstantReloadHUD.Hide()
            Print("Resetting: Instant Reload Minigame")
        else if(CurrentMinigame = 11):
            BalloonMinigame.ResetMinigame()
            BalloonHUD.Hide()
            Print("Resetting: Balloon Minigame")
        else if(CurrentMinigame = 12):
            PlaneMinigame.ResetMinigame()
            PlaneHUD.Hide()
            Print("Resetting: Plane Minigame")
        else if(CurrentMinigame = 13):
            MysteryMinigame.ResetMinigame()
            MysteryHUD.Hide()
            Print("Resetting: Mystery Minigame")
        else if(CurrentMinigame = 14):
            DoublePumpMinigame.ResetMinigame()
            DoublePumpHUD.Hide()
            Print("Resetting: Double Pump Minigame")
        else if(CurrentMinigame = 15):
            OneShotMinigame.ResetMinigame()
            OneShotHUD.Hide()
            Print("Resetting: One Shot Minigame")
        else if(CurrentMinigame = 16):
            ObbyMinigame.ResetMinigame()
            ObbyHUD.Hide()
            Print("Resetting: Obby Minigame")
        else if(CurrentMinigame = 17):
            TimewarpMinigame.ResetMinigame()
            TimewarpHUD.Hide()
            Print("Resetting: Timewarp Minigame")
        else if(CurrentMinigame = 18):
            OGHUD.Hide()
            Print("Resetting: OG Minigame")
        else if(CurrentMinigame = 19):
            TopdownMinigame.ResetMinigame()
            TopdownHUD.Hide()
            Print("Resetting: Topdown Minigame")
        else if(CurrentMinigame = 20):
            InvisibleMinigame.ResetMinigame()
            InvisibleHUD.Hide()
            Print("Resetting: Invisible Minigame")
        else if(CurrentMinigame = 21):
            BouncehouseMinigame.ResetMinigame()
            BouncehouseHUD.Hide()
            Print("Resetting: Bouncehouse Minigame")
        else if(CurrentMinigame = 22):
            Sniperduel.ResetMinigame()
            SniperduelHUD.Hide()
            Print("Resetting: Sniperduel Minigame")
        else if(CurrentMinigame = 23):
            ImpulseMinigame.ResetMinigame()
            ImpulseHUD.Hide()
            Print("Resetting: Impulse Minigame")
        else if(CurrentMinigame = 24):
            HideNSeekMinigame.ResetMinigame()
            HideNSeekHUD.Hide()
            Print("Resetting: HideNSeek Minigame")
        else if(CurrentMinigame = 25):
            MazeMinigame.ResetMinigame()
            MazeHUD.Hide()
            Print("Resetting: Maze Minigame")
        else if(CurrentMinigame = 26):
            BoxfightMinigame.ResetMinigame()
            BoxfightHUD.Hide()
            Print("Resetting: Boxfight Minigame")
        else if(CurrentMinigame = 27):
            JunkMinigame.ResetMinigame()
            JunkHUD.Hide()
            Print("Resetting: Junk Minigame")
        else if(CurrentMinigame = 28):
            BoogieMinigame.ResetMinigame()
            BoogieHUD.Hide()
            Print("Resetting: Boogie Minigame")
        else if(CurrentMinigame = 29):
            PickaxeMinigame.ResetMinigame()
            PickaxeHUD.Hide()
            Print("Resetting: Pickaxe Minigame")
        else if(CurrentMinigame = 30):
            ThrowablesMinigame.ResetMinigame()
            ThrowablesHUD.Hide()
            Print("Resetting: Throwables Minigame")
        else if(CurrentMinigame = 31):
            HeightMinigame.ResetMinigame()
            HeightHUD.Hide()
            Print("Resetting: Height Minigame")
        else if(CurrentMinigame = 32):
            TrapTowerMinigame.ResetMinigame()
            TrapTowerHUD.Hide()
            Print("Resetting: Trap Tower Minigame")
        else if(CurrentMinigame = 33):
            ZoneWarsMinigame.ResetMinigame()
            ZoneWarsHUD.Hide()
            Print("Resetting: Zone Wars Minigame")
        else if(CurrentMinigame = 34):
            BoatMinigame.ResetMinigame()
            BoatHUD.Hide()
            Print("Resetting: Boat Minigame")
        else if(CurrentMinigame = 35):
            PrimalHUD.Hide()
            Print("Resetting: Primal Minigame")
        else if(CurrentMinigame = 36):
            CubedHUD.Hide()
            Print("Resetting: Cubed Minigame")