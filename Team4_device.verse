using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
Team4_device := class(creative_device):
    
    CoinsT1<localizes>(Point : int) : message ="Coins : {Point}"
    LoveT1<localizes>(Point : int) : message ="Love : {Point}"
    @editable 
    chest : button_device = button_device {}
    @editable
    AnimTrigger:trigger_device=trigger_device{}
    @editable
    Prop1:creative_prop=creative_prop{}
    @editable
    Prop2:creative_prop=creative_prop{}
    @editable
    Prop3:creative_prop=creative_prop{}
    @editable
    Prop1Location:creative_prop=creative_prop{}
    @editable
    Prop2Location:creative_prop=creative_prop{}
    @editable
    Prop3Location:creative_prop=creative_prop{}
    @editable
    Trigger:trigger_device=trigger_device{}
    @editable
    PricesHolder : [] creative_prop = array {}
    @editable
    zone : [] mutator_zone_device = array {}
    @editable
    Pricese : [] creative_prop = array {}
    @editable
    propMini : [] prop_manipulator_device = array {}
    @editable
    carpet : [] creative_prop = array {}
    @editable
    switcherZone : []mutator_zone_device = array {}
    @editable
    EmotingZone : mutator_zone_device = mutator_zone_device {}
    @editable
    dancing : dance_mannequin_device = dance_mannequin_device {}
    @editable
    HudT1:hud_message_device=hud_message_device{}
    @editable
    LoveHud:hud_message_device=hud_message_device{}
    @editable
    TeddyAnimes : [] cinematic_sequence_device = array {}

    @editable
    grilfriends : [] creative_prop = array {}

    @editable
    popUp : popup_dialog_device = popup_dialog_device {}
    @editable
    CarnavalWheel:creative_prop=creative_prop{}
    @editable
    WheelButton:button_device=button_device{}

    @editable
    guardElims : elimination_manager_device = elimination_manager_device {}

    @editable
    wheelActivator : button_device = button_device {}

    @editable
    WepAnime:[] cinematic_sequence_device = array {}
    @editable
    Guards:[]guard_spawner_device=array{}

    @editable
    Kids:[] creative_prop= array {}

    @editable
    RingActive : switch_device = switch_device {}

    @editable
    Granter: item_granter_device = item_granter_device {}

    @editable
    Teleport : teleporter_device= teleporter_device {}

    @editable
    Signal : signal_remote_manager_device = signal_remote_manager_device {}

    @editable
    GrantWings : item_granter_device = item_granter_device {}
    @editable
    GrantiThunder : item_granter_device = item_granter_device {}

    
    @editable
    GrantGrapler : item_granter_device = item_granter_device {}

    @editable
    EmoteText : creative_prop = creative_prop{}

    @editable
    AUDIO : audio_player_device = audio_player_device {}
    @editable
    Track : tracker_device = tracker_device {}

    @editable 
    RemoteHud : hud_message_device = hud_message_device {}
    



    var IsRotating:logic=false
    var playercoins :int =0
    var playerLovePoint : int =0
    var dropper1 : int =0
    var dropper2 : int =0
    var dropper3 : int =0
    var dropper4 : int =0
    var dropper5 : int =0
    var dropper6 : int =0
    var dropper7 : int =0
    var dropper8 : int =0
    var dropper9 : int =0
    var dropper10 : int =0
    var dropper11 : int =0
    var emoting : int =0
    var ButtonNum:int=0
    var Girl1 : int = 0 
    var Girl2 : int = 0
    var Girl3 : int = 0
    var guardCoint : int = 0
    var Prop1Selected : logic =false 
    var Prop2Selected : logic =false 
    var Prop3Selected : logic =false
    var LocationProp : vector3= vector3{}
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        initial()
        Self.GetPlayspace().PlayerRemovedEvent().Subscribe(Renitialisation)
        chest.InteractedWithEvent.Subscribe(OnChestOpened)
        EmotingZone.AgentBeginsEmotingEvent.Subscribe(OnPlayerStartDacing)
        EmotingZone.AgentEndsEmotingEvent.Subscribe(OnPlayerEndDacing)
        WheelButton.InteractedWithEvent.Subscribe(OnSpinButtonClick)
        Signal.PrimarySignalEvent.Subscribe(OnRemotePressed)
        for(GuardSpawner:Guards):
            GuardSpawner.SpawnedEvent.Subscribe(OnGuardSpawned)
        for(SwitcherTeam:switcherZone):
            SwitcherTeam.AgentEntersEvent.Subscribe(onPlayerSwitched)
        Trigger.TriggeredEvent.Subscribe(CountingCoins)
        if (zone0 := zone[0],zone1 := zone[1],zone2 := zone[2],zone3 := zone[3],zone4 := zone[4],zone5 := zone[5],zone6 := zone[6],zone7 := zone[7],zone8 := zone[8],zone9 := zone[9],zone10 := zone[10]):
            zone0.AgentEntersEvent.Subscribe(onPlayerClaimLand_showBelt)
            zone1.AgentEntersEvent.Subscribe(onBeltActive_showDropper)
            zone2.AgentEntersEvent.Subscribe(onDropper0Activate_ShowDROPP2_Wall)
            zone3.AgentEntersEvent.Subscribe(onPlayerActiveDropper1_ShowDroper2_gamingRom)
            zone4.AgentEntersEvent.Subscribe(onWALL1Active_ShowKitch_ShowKitchenFloor)
            zone5.AgentEntersEvent.Subscribe(onDropper3Active_ShowDropper4_showWall2)
            zone6.AgentEntersEvent.Subscribe(onGamingActive_ShowGameFloor_showUpgrad1)
            zone7.AgentEntersEvent.Subscribe(onKitchenActive_ShowUpWall)
            zone8.AgentEntersEvent.Subscribe(onKitchenFloorActive_ShowUpKitchen)
            zone9.AgentEntersEvent.Subscribe(onDropper4Active_ShowUpWall)
            zone10.AgentEntersEvent.Subscribe(onWall2Active_showallGlass)
        if (zone11 := zone[11],zone12 := zone[12],zone13 := zone[13],zone14 := zone[14],zone15 := zone[15],zone16 := zone[16],zone17 := zone[17],zone18 := zone[18],zone19 := zone[19],zone20 := zone[20]):
            zone11.AgentEntersEvent.Subscribe(onGameFloorActive_showUpgrade2_upgrade3_Upgrade4)
            zone12.AgentEntersEvent.Subscribe(onGamingUpdate1_ShowGameDor)
            zone13.AgentEntersEvent.Subscribe(onUpgradWallActive_showDoor)
            zone14.AgentEntersEvent.Subscribe(onKitchenUp1Active_ShowUp2_up3_up4_wall)
            zone15.AgentEntersEvent.Subscribe(OnKitchenDoorActive)
            zone16.AgentEntersEvent.Subscribe(onGlassActive)
            zone17.AgentEntersEvent.Subscribe(onGamingUpgrade2)
            zone18.AgentEntersEvent.Subscribe(onGamingUpgrade3)
            zone19.AgentEntersEvent.Subscribe(onGamingUpgrade4)
            zone20.AgentEntersEvent.Subscribe(onGamingUpgrade5)
        if (zone21 := zone[21],zone22 := zone[22],zone23 := zone[23],zone24 := zone[24],zone25 := zone[25],zone26 := zone[26],zone27 := zone[27],zone28 := zone[28],zone29 := zone[29],zone30 := zone[30]):
            zone21.AgentEntersEvent.Subscribe(onKitchenUp2)
            zone22.AgentEntersEvent.Subscribe(onKitchenUp3)
            zone23.AgentEntersEvent.Subscribe(onKitchenUp4)
            zone24.AgentEntersEvent.Subscribe(onKitchenUp5)
            zone25.AgentEntersEvent.Subscribe(onGamingDoorActivate)
            zone26.AgentEntersEvent.Subscribe(onHousDoorActivate_ShowStairs)
            zone27.AgentEntersEvent.Subscribe(onKitchenWallActive)
            zone28.AgentEntersEvent.Subscribe(onKitchenGlassActive)
            zone29.AgentEntersEvent.Subscribe(onStairsActive_ShowBelt)
            zone30.AgentEntersEvent.Subscribe(OnBeltActiveF2_ShowDrope1_ShowBalcon_ShowLivRoom_ShowBed)
        if (zone31 := zone[31],zone32 := zone[32],zone33 := zone[33],zone34 := zone[34],zone35 := zone[35],zone36 := zone[36],zone37 := zone[37],zone38 := zone[38],zone39 := zone[39],zone40 := zone[40]):
            zone31.AgentEntersEvent.Subscribe(OndropperF2_1_ShowDR2)
            zone32.AgentEntersEvent.Subscribe(onBalcony1Active_ShowUp1_up2_Roof)
            zone33.AgentEntersEvent.Subscribe(onLivingRooActive_ShowFloor)
            zone34.AgentEntersEvent.Subscribe(onBedActive_showFloor)
            zone35.AgentEntersEvent.Subscribe(onF2_DropperActive_showDR3)
            zone36.AgentEntersEvent.Subscribe(onBalconUP1Active)
            zone37.AgentEntersEvent.Subscribe(onBalconUP2Active)
            zone38.AgentEntersEvent.Subscribe(onBalconRoofActive)
            zone39.AgentEntersEvent.Subscribe(OnLivingRoomFloorActive)
            zone40.AgentEntersEvent.Subscribe(OnBedFloorActive)
        if (zone41 := zone[41],zone42 := zone[42],zone43 := zone[43],zone44 := zone[44],zone45 := zone[45],zone46 := zone[46],zone47 := zone[47],zone48 := zone[48],zone49 := zone[49],zone50 := zone[50]):
            zone41.AgentEntersEvent.Subscribe(OnDropper3Active)
            zone42.AgentEntersEvent.Subscribe(OnLivingRoomUP1Active)
            zone43.AgentEntersEvent.Subscribe(OnLivingRoomUP2Active)
            zone44.AgentEntersEvent.Subscribe(OnWallActive)
            zone45.AgentEntersEvent.Subscribe(OnTeddy1Active)
            zone46.AgentEntersEvent.Subscribe(OnBedRoomUP1Active)
            zone47.AgentEntersEvent.Subscribe(onBedRoomWallActivate)
            zone48.AgentEntersEvent.Subscribe(onFloor2WallsActive)
            zone49.AgentEntersEvent.Subscribe(OnEmotingActive)
            zone50.AgentEntersEvent.Subscribe(OnFloor2WallUpgraded)
        if (zone51 := zone[51],zone52 := zone[52],zone53 := zone[53],zone54 := zone[54],zone55 := zone[55],zone56 := zone[56],zone57 := zone[57],zone58 := zone[58],zone59 := zone[59],zone60 := zone[60]):
            zone51.AgentEntersEvent.Subscribe(OnLivingRoomUpgrade3)
            zone52.AgentEntersEvent.Subscribe(OnLivingRoomUpgrad4)
            zone53.AgentEntersEvent.Subscribe(OnLivingRoomUpgrad5)
            zone54.AgentEntersEvent.Subscribe(ssOnGlassActive)
            zone55.AgentEntersEvent.Subscribe(OnLivingRoomDoorActive)
            zone56.AgentEntersEvent.Subscribe(OnTeddy2Active)
            zone57.AgentEntersEvent.Subscribe(OnWallUpgraded2Active)
            zone58.AgentEntersEvent.Subscribe(ONUpgradeBedRoom3)
            zone59.AgentEntersEvent.Subscribe(OnStairs2Active)
            zone60.AgentEntersEvent.Subscribe(OnBalcony2Active)
        if (zone61 := zone[61],zone62 := zone[62],zone63 := zone[63],zone64 := zone[64],zone65 := zone[65],zone66 := zone[66],zone67 := zone[67],zone68 := zone[68],zone69 := zone[69],zone70 := zone[70]):
            zone61.AgentEntersEvent.Subscribe(OnRoofBeltActive_ShowDropper1)
            zone62.AgentEntersEvent.Subscribe(OnBalconyUpgrad1_Active)
            zone63.AgentEntersEvent.Subscribe(OnBalconyUpgrad2_Active)
            zone64.AgentEntersEvent.Subscribe(OnBalconyUpgrad3_Active)
            zone65.AgentEntersEvent.Subscribe(OnRoofDropper1Active_ShowDropper2_Weeding_Roofglass)
            zone66.AgentEntersEvent.Subscribe(OnRoofDropper2_Active_showDropper3_showPool)
            zone67.AgentEntersEvent.Subscribe(OnWeddingActive_showUpWeding1_showUPWedding2_ShowUp3Weding)
            zone68.AgentEntersEvent.Subscribe(OnRoofGlassActive)
            zone69.AgentEntersEvent.Subscribe(OnRoofDropper3Active)
            zone70.AgentEntersEvent.Subscribe(OnPoolActive_ShowPoolUP)
        if (zone71 := zone[71],zone72 := zone[72],zone73 := zone[73],zone74 := zone[74],zone75 := zone[75],zone76 := zone[76],zone77 := zone[77],zone78 := zone[78],zone79 := zone[79],zone80 := zone[80]):
            zone71.AgentEntersEvent.Subscribe(OnWeddingUpgrade1Active)
            zone72.AgentEntersEvent.Subscribe(OnWeddingUpgrade2Active)
            zone73.AgentEntersEvent.Subscribe(OnWeddingUpgrade3Active)
            zone74.AgentEntersEvent.Subscribe(OnRoofDropper4Active)
            zone75.AgentEntersEvent.Subscribe(OnPoolUpgradeActive)
            zone76.AgentEntersEvent.Subscribe(OnStatuActive)
            zone77.AgentEntersEvent.Subscribe(OnBasseGlassActive)
            zone78.AgentEntersEvent.Subscribe(OnPlant1Active)
            zone79.AgentEntersEvent.Subscribe(OnPlant2Active)
            zone80.AgentEntersEvent.Subscribe(OnRelaxAreaActive)
        if (zone81 := zone[81],zone82 := zone[82],zone83 := zone[83],zone84 := zone[84],zone85 := zone[85],zone86 := zone[86],zone87 := zone[87]):
            zone81.AgentEntersEvent.Subscribe(OnChillAreaActive)
            zone82.AgentEntersEvent.Subscribe(OnChillAreaUpgrade)
            zone83.AgentEntersEvent.Subscribe(OnWheelActive)
            zone84.AgentEntersEvent.Subscribe(OnWeaponActive1)
            zone85.AgentEntersEvent.Subscribe(OnWeaponActive2)
            zone86.AgentEntersEvent.Subscribe(OnGetMarriedActive)
            zone87.AgentEntersEvent.Subscribe(OnStartFamilyActive)
        popUp.RespondingButtonEvent.Subscribe(PopUpPress2)

    OnRemotePressed(Agent:agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        if (AgentsTeam := TeamCollection.GetTeam[Agent]):
            TeamArray := TeamCollection.GetTeams()
            for (TeamNumber->Team : TeamArray):
                if (AgentsTeam = Team,TeamNumber = 7):
                    Teleport.Teleport(Agent)
    OnGuardSpawned(Agent:agent):void=
        if(GuardObj:=agent[Agent]):
            if(FortCharacter:fort_character=Agent.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Subscribe(CheckElimiator)
    CheckElimiator(Result:elimination_result):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        Eliminator:=Result.EliminatingCharacter
        if(FortCharacter:=Eliminator?,ElimiatorAgent:=FortCharacter.GetAgent[]):
            if (AgentsTeam := TeamCollection.GetTeam[ElimiatorAgent]):
                for (TeamNumber->Team : TeamArray):
                    if (AgentsTeam = Team,TeamNumber = 7):
                        set playercoins = playercoins + 10
    Renitialisation(Agent:agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        if (AgentsTeam := TeamCollection.GetTeam[Agent]):
            TeamArray := TeamCollection.GetTeams()
            for (TeamNumber->Team : TeamArray):
                if (AgentsTeam = Team,TeamNumber = 7):
                    RingActive.TurnOff(Agent)
                    initial()
                    Track.Reset(Agent)

    OnPlayerStartDacing(Agent:agent):void=
        set emoting = 500


    OnChestOpened(Agent:agent):void=
        set playercoins = playercoins + 100000 

    OnPlayerEndDacing(Agent:agent):void=
        set emoting = 0
    Prop1MoveToPlayer(Agent:agent)<suspends>:void=
        Sleep(0.3)
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        var YPosition: float = 0.0
        loop:
            if(Prop1Selected = true and Prop2Selected = false and Prop3Selected = false):
                if (AgentsTeam := TeamCollection.GetTeam[Agent]):
                    for (TeamNumber->Team : TeamArray):
                        if (AgentsTeam = Team,TeamNumber = 7,Fort:= Agent.GetFortCharacter[]):
                            Rotation :=Fort.GetTransform().Rotation
                            set LocationProp=Fort.GetTransform().Translation+ vector3{Y:=120.0,Z:=-30.0, X:=-10.0}
                                    
                            Prop1.Show()
                            Prop1.MoveTo(LocationProp,Rotation,0.2)
                        
            else:
                Prop1.Hide()
                IntialLocation:= Prop1Location.GetTransform().Translation
                Rotation:=Prop1Location.GetTransform().Rotation
                Prop1.MoveTo(IntialLocation,Rotation,0.2)
                break
    Prop2MoveToPlayer(Agent:agent)<suspends>:void=
        Sleep(0.3)
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        var YPosition: float = 0.0
        loop:
            if(Prop2Selected = true and Prop1Selected = false and Prop3Selected = false):
                if (AgentsTeam := TeamCollection.GetTeam[Agent]):
                    for (TeamNumber->Team : TeamArray):
                        if (AgentsTeam = Team,TeamNumber = 7,Fort:= Agent.GetFortCharacter[]):
                            Rotation :=Fort.GetTransform().Rotation
                            set LocationProp=Fort.GetTransform().Translation+ vector3{Y:=120.0,Z:=-30.0,X:=-10.0}
                            Prop2.Show()
                            Prop2.MoveTo(LocationProp,Rotation,0.2)
            else:
                Prop2.Hide()
                IntialLocation:= Prop2Location.GetTransform().Translation
                Rotation:=Prop2Location.GetTransform().Rotation
                Prop2.MoveTo(IntialLocation,Rotation,0.2)
                break
    Prop3MoveToPlayer(Agent:agent)<suspends>:void=
        Sleep(0.3)
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        var YPosition: float = 0.0
        loop:
            if(Prop3Selected = true and Prop1Selected = false and Prop2Selected = false):
                if (AgentsTeam := TeamCollection.GetTeam[Agent]):
                    for (TeamNumber->Team : TeamArray):
                        if (AgentsTeam = Team,TeamNumber = 7,Fort:= Agent.GetFortCharacter[]):
                            Rotation :=Fort.GetTransform().Rotation
                            set LocationProp=Fort.GetTransform().Translation+ vector3{Y:=120.0,Z:=-30.0,X:=-10.0}
                            Prop3.Show()
                            Prop3.MoveTo(LocationProp,Rotation,0.2)
            else:
                Prop3.Hide()
                IntialLocation:= Prop3Location.GetTransform().Translation
                Rotation:=Prop3Location.GetTransform().Rotation
                Prop3.MoveTo(IntialLocation,Rotation,0.2)
                break
    
            
    OnGuardElims(Agent: ?agent):void=
        set guardCoint = 10
        set playercoins = playercoins + guardCoint
    OnSpinButtonClick(Agent:agent):void=
        if(IsRotating = false):
            if (playerLovePoint >= 500):
                set playerLovePoint = playerLovePoint - 500
                    spawn:
                        RotatWheel(Agent)
    RotatWheel(Agent:agent)<suspends>:void=
        var RotateDegrees:float = 150.0
        set IsRotating = true
        loop:
            CarnavalWheel.MoveTo(CarnavalWheel.GetTransform().Translation,CarnavalWheel.GetTransform().Rotation.ApplyRoll(DegreesToRadians(RotateDegrees)),1.0)
            var RandomInt:int=GetRandomInt(5,25)
            RandomFloat:float=RandomInt*1.0

            set RotateDegrees -= RandomFloat
            if(RotateDegrees< 0.0):
                
                
                set IsRotating = false
                WheelRotation:[]float=CarnavalWheel.GetTransform().Rotation.GetYawPitchRollDegrees()
                if(Roll:float = WheelRotation[2]):
                    if(Roll>=0.0 and Roll <=44.9):
                        set playercoins = playercoins + 25
                    else if(Roll>=45.0 and Roll <=89.9):
                        GrantWings.GrantItem(Agent)
                    else if(Roll>=90.0 and Roll <=134.9):
                        set playercoins = playercoins + 45000
                    else if(Roll>=135.0 and Roll <=180.0):
                        set playercoins = playercoins + 100000
                    else if(Roll<=0.0 and Roll >=-44.9):
                        set playercoins = playercoins + 150000
                    else if(Roll<=-45.0 and Roll >=-89.9):
                        GrantiThunder.GrantItem(Agent)
                    else if(Roll<=-90.0 and Roll >=-134.9):
                        set playercoins = playercoins + 35000
                    else if(Roll<=-135.0 and Roll >=-180.0):
                        GrantGrapler.GrantItem(Agent)
                break
    
    initial():void=
        for (Kidss : Kids):
            Kidss.Hide()
        set Prop3Selected = false
        set Prop1Selected = false
        set Prop2Selected = false
        set Girl1 = 0
        set Girl2 = 0
        set Girl3 = 0
        EmoteText.Hide()
        Prop1.Hide()
        Prop2.Hide()
        Prop3.Hide()
        for(SwitcherTeam:switcherZone):
            SwitcherTeam.Enable()
        for(weaponAnim : WepAnime):
            weaponAnim.Stop()
        wheelActivator.Disable()
        for (girlfriend : grilfriends):
            girlfriend.Hide()
        for (animations : TeddyAnimes):
            animations.Stop()
        dancing.Disable()
        EmotingZone.Disable()
        for (mutator : zone):
            mutator.Disable()
        for (manip : propMini):
            manip.HideProps()
        for (Price : Pricese):
            Price.Hide()
        for (carpets : carpet):
            carpets.Hide()
        for (A:=0..PricesHolder.Length):
                if(HOLDERS:=PricesHolder[A]):
                    HOLDERS.Hide()
        for (carpets : carpet):
            carpets.Hide()
        set playercoins = 0
        set playerLovePoint = 0
        set dropper1 = 0
        set dropper2 = 0 
        set dropper3 = 0 
        set dropper4 = 0
        set dropper5 = 0
        set dropper6 = 0 
        set dropper7 = 0
        set dropper8 = 0
        set dropper9 = 0
        set dropper10 = 0 
        set dropper11 = 0
        set emoting = 0
        HudT1.SetText(CoinsT1(playercoins))
        LoveHud.SetText(LoveT1(playerLovePoint))
    grantingcoins()<suspends>:void=
        set playercoins =  playercoins + dropper1 + dropper2 + dropper3 + dropper4 + dropper5 + dropper6 + dropper7 + dropper8 + dropper9 + dropper10 + dropper11 + emoting + Girl1 + Girl2 + Girl3 
        HudT1.SetText(CoinsT1(playercoins))
        LoveHud.SetText(LoveT1(playerLovePoint))
        Sleep(1.0)
        Trigger.Trigger()    
    CountingCoins(Agent:?agent):void=
        spawn:
            grantingcoins()        
    HideButoone():void=
        if (price := Pricese[ButtonNum]):
            price.Hide()
        if (PricesHolders := PricesHolder[ButtonNum]):
            PricesHolders.Hide()
        if (zones := zone [ButtonNum]):
            zones.Disable()
    onPlayerSwitched(Agent : agent): void=
        Track.Assign(Agent)
        if (price0 := Pricese[0]):
            price0.Show()
        if (PricesHolder0 := PricesHolder[0]):
            PricesHolder0.Show()
        if (zone0 := zone [0]):
            zone0.Enable()
        for(SwitcherTeam:switcherZone):
            SwitcherTeam.Disable()
    onPlayerClaimLand_showBelt(Agent : agent): void=
        set ButtonNum = 0
        HideButoone()
        AUDIO.Play(Agent)
        Granter.GrantItem(Agent)
        set playerLovePoint = playerLovePoint
        RemoteHud.Show() 
        
        if (price1 := Pricese[1]):
            price1.Show()
        if(holder1 := PricesHolder [1]):
            holder1.Show()
        if(Zone1 := zone[1]):
            Zone1.Enable()
        if(props0 := propMini[0], props1 := propMini [1],props2 := propMini[2]):
            props0.ShowProps()
            props1.ShowProps()
            props2.ShowProps()
    onBeltActive_showDropper(Agent:agent):void=
        set ButtonNum = 1
        HideButoone()
        AUDIO.Play(Agent)
        set playerLovePoint = playerLovePoint 
        if (props3 :=  propMini[3]):
            props3.ShowProps()
        if (price2 := Pricese[2]):
            price2.Show()
        if(holder2 := PricesHolder [2]):
            holder2.Show()
        if(Zone2 := zone[2]):
            Zone2.Enable()
    onDropper0Activate_ShowDROPP2_Wall(Agent:agent):void=
        set ButtonNum = 2
        HideButoone()
        AUDIO.Play(Agent)
        set dropper1 = 5
        set playerLovePoint = playerLovePoint + 200
        if (animations0 := TeddyAnimes[0]):
            animations0.Play()
        
        if (props4 :=  propMini[4]):
            props4.ShowProps()
        # dropper 2
        if (price3 := Pricese[3]):
            price3.Show()
        if(holder3 := PricesHolder [3]):
            holder3.Show()
        if(Zone3 := zone[3]):
            Zone3.Enable()
        # wall
        if (price4 := Pricese[4]):
            price4.Show()
        if(holder4 := PricesHolder [4]):
            holder4.Show()
        if(Zone4 := zone[4]):
            Zone4.Enable()
    onPlayerActiveDropper1_ShowDroper2_gamingRom(Agent : agent):void=
        
        if (playercoins >= 100):
            set playercoins = playercoins-100
            set dropper2 = 50
            set ButtonNum = 3
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (animations1 := TeddyAnimes[1]):
                animations1.Play()
            
            # dropper 3
            if (props5 :=  propMini[5]):
                props5.ShowProps()
            if (price5 := Pricese[5]):
                price5.Show()
            if(holder5 := PricesHolder [5]):
                holder5.Show()
            if(Zone5 := zone[5]):
                Zone5.Enable()
            # gaming room
            
            if (price6 := Pricese[6]):
                price6.Show()
            if(holder6 := PricesHolder [6]):
                holder6.Show()
            if(Zone6 := zone[6]):
                Zone6.Enable()
    onWALL1Active_ShowKitch_ShowKitchenFloor(Agent : agent):void=
        
        if (playercoins >= 500):
            set playercoins = playercoins - 500
            set ButtonNum = 4
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            
            if (props6 :=  propMini[6]):
                props6.ShowProps()
            # show kitchen
            if (price7 := Pricese[7]):
                price7.Show()
            if(holder7 := PricesHolder [7]):
                holder7.Show()
            if(Zone7 := zone[7]):
                Zone7.Enable()
            # show kitchen Floor
            if (price8 := Pricese[8]):
                price8.Show()
            if(holder8 := PricesHolder [8]):
                holder8.Show()
            if(Zone8 := zone[8]):
                Zone8.Enable()
    onDropper3Active_ShowDropper4_showWall2(Agent : agent):void=
        
        if (playercoins >= 1000):
            set playercoins = playercoins - 1000
            set dropper3 = 100
            set ButtonNum = 5
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (animations2 := TeddyAnimes[2]):
                animations2.Play()
            if (props7 :=  propMini[7]):
                props7.ShowProps()
            # show dropper4
            if (price9 := Pricese[9]):
                price9.Show()
            if(holder9 := PricesHolder [9]):
                holder9.Show()
            if(Zone9 := zone[9]):
                Zone9.Enable()
            # show wall 2
            if (price10 := Pricese[10]):
                price10.Show()
            if(holder10 := PricesHolder [10]):
                holder10.Show()
            if(Zone10 := zone[10]):
                Zone10.Enable()
    onGamingActive_ShowGameFloor_showUpgrad1(Agent:agent):void=
        
        if (playercoins >=5000):
            set playercoins = playercoins - 5000
            set ButtonNum = 6
            HideButoone()
            AUDIO.Play(Agent)
            if (props8 :=  propMini[8]):
                props8.ShowProps()
                set playerLovePoint = playerLovePoint + 500

            #show game floor
            if (price11 := Pricese[11]):
                price11.Show()
            if(holder11 := PricesHolder [11]):
                holder11.Show()
            if(Zone11 := zone[11]):
                Zone11.Enable()
            #show update 1
            if (price12 := Pricese[12]):
                price12.Show()
            if(holder12 := PricesHolder [12]):
                holder12.Show()
            if(Zone12 := zone[12]):
                Zone12.Enable()
            # show game
            if (price84 := Pricese[84]):
                price84.Show()
            if(holder84 := PricesHolder [84]):
                holder84.Show()
            if(Zone84 := zone[84]):
                Zone84.Enable()
    onKitchenActive_ShowUpWall(Agent : agent ):void=
        
        if (playercoins >=5000):
            set playercoins = playercoins - 5000
            set ButtonNum = 7
            HideButoone()
            AUDIO.Play(Agent) 
            if (props9 :=  propMini[9]):
                props9.ShowProps()
            set playerLovePoint = playerLovePoint + 500
                
            # show upgrade wall
            if (price13 := Pricese[13]):
                price13.Show()
            if(holder13 := PricesHolder [13]):
                holder13.Show()
            if(Zone13 := zone[13]):
                Zone13.Enable()
            # show wheel 
            if(price83 := Pricese[83]):
                price83.Show()
            if(holder83 := PricesHolder [83]):
                holder83.Show()
            if(Zone83 := zone[83]):
                Zone83.Enable() 
    onKitchenFloorActive_ShowUpKitchen(Agent : agent ):void=
        
        if (playercoins >= 2500):
            set playercoins = playercoins - 2500
            set ButtonNum = 8
            HideButoone()
            AUDIO.Play(Agent)
            if (props10 :=  propMini[10]):
                props10.ShowProps()
            set playerLovePoint = playerLovePoint + 200
            # show upgrade 1
            if (price14 := Pricese[14]):
                price14.Show()
            if(holder14 := PricesHolder [14]):
                holder14.Show()
            if(Zone14 := zone[14]):
                Zone14.Enable()
    onDropper4Active_ShowUpWall(Agent : agent):void=
        
        if (playercoins >= 1500):
            set playercoins = playercoins - 1500
            set dropper4 = 150
            set ButtonNum = 9
            HideButoone()
            AUDIO.Play(Agent)
            if (animations3 := TeddyAnimes[3]):
                animations3.Play()

            if (props11 :=  propMini[11]):
                props11.ShowProps()
            set playerLovePoint = playerLovePoint + 200
            # show upgrade wall 1
            <##>
    onWall2Active_showallGlass(Agent : agent):void=
        if (playercoins >= 500):
            set playercoins = playercoins - 500
            set ButtonNum = 10
            HideButoone()
            AUDIO.Play(Agent)
            if (props12 :=  propMini[12],props13 :=  propMini[13],props14 :=  propMini[14]):
                props12.ShowProps()
                props13.ShowProps()
                props14.ShowProps()
            # show glass wall
            set playerLovePoint = playerLovePoint + 200 
            if (price16 := Pricese[16]):
                price16.Show()
            if(holder16 := PricesHolder [16]):
                holder16.Show()
            if(Zone16 := zone[16]):
                Zone16.Enable()
    onGameFloorActive_showUpgrade2_upgrade3_Upgrade4(Agent : agent):void=
        if (playercoins >= 5000):
            set playercoins = playercoins - 5000
            set ButtonNum = 11
            HideButoone()
            AUDIO.Play(Agent)
            if (props15 :=  propMini[15]):
                props15.ShowProps()
            # show upgrade 2
            set playerLovePoint = playerLovePoint + 500
            if (price17 := Pricese[17]):
                price17.Show()
            if(holder17 := PricesHolder [17]):
                holder17.Show()
            if(Zone17 := zone[17]):
                Zone17.Enable()
            # show upgrade 3
            if (price18 := Pricese[18]):
                price18.Show()
            if(holder18 := PricesHolder [18]):
                holder18.Show()
            if(Zone18 := zone[18]):
                Zone18.Enable()
            # show upgrade 4 
            if (price19 := Pricese[19]):
                price19.Show()
            if(holder19 := PricesHolder [19]):
                holder19.Show()
            if(Zone19 := zone[19]):
                Zone19.Enable()
            # show upgrade 4 
            if (price20 := Pricese[20]):
                price20.Show()
            if(holder20 := PricesHolder [20]):
                holder20.Show()
            if(Zone20 := zone[20]):
                Zone20.Enable()
    onKitchenUp1Active_ShowUp2_up3_up4_wall(Agent:agent):void=
        if (playercoins >= 5000):
            set playercoins = playercoins - 5000
            set ButtonNum = 14
            HideButoone()
            AUDIO.Play(Agent)
            if (props16 :=  propMini[16],props17 :=  propMini[17]):
                props16.ShowProps()
                props17.ShowProps()
            # show up 2
            set playerLovePoint = playerLovePoint + 500
            if (price21 := Pricese[21]):
                price21.Show()
            if(holder21 := PricesHolder [21]):
                holder21.Show()
            if(Zone21 := zone[21]):
                Zone21.Enable()
            # show up 3
            if (price22 := Pricese[22]):
                price22.Show()
            if(holder22 := PricesHolder [22]):
                holder22.Show()
            if(Zone22 := zone[22]):
                Zone22.Enable()
            # show up 4
            if (price23 := Pricese[23]):
                price23.Show()
            if(holder23 := PricesHolder [23]):
                holder23.Show()
            if(Zone23 := zone[23]):
                Zone23.Enable()
            # show wall
            if (price24 := Pricese[24]):
                price24.Show()
            if(holder24 := PricesHolder [24]):
                holder24.Show()
            if(Zone24 := zone[24]):
                Zone24.Enable()
    onGamingUpdate1_ShowGameDor(Agent : agent ): void=
        if (playercoins >= 1500):
            set playercoins = playercoins - 1500
            set ButtonNum = 12
            HideButoone() 
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props18 :=  propMini[18]):
                props18.ShowProps()
            # show gaming room
            if (price25 := Pricese[25]):
                price25.Show()
            if(holder25 := PricesHolder [25]):
                holder25.Show()
            if(Zone25 := zone[25]):
                Zone25.Enable()
    onUpgradWallActive_showDoor(Agent : agent):void=
        if (playercoins >= 2500):
            set playercoins = playercoins - 2500
            set ButtonNum = 13
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props19 :=  propMini[19],props20 :=  propMini[20],props21 :=  propMini[21]):
                props19.ShowProps()
                props20.ShowProps()
                props21.ShowProps()
            # show Door
            if (price26 := Pricese[26]):
                price26.Show()
            if(holder26 := PricesHolder [26]):
                holder26.Show()
            if(Zone26 := zone[26]):
                Zone26.Enable()
    onGlassActive(Agent:agent):void=
        if (playercoins >=3500):
            set playercoins = playercoins -3500
            set ButtonNum = 16
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props22 :=  propMini[22]):
                props22.ShowProps()
    onGamingUpgrade2(Agnet:agent):void=
        if (playercoins>=1500):
            set playercoins = playercoins - 1500
            set ButtonNum = 17
            HideButoone()
            AUDIO.Play(Agnet)
            set playerLovePoint = playerLovePoint + 200
            if (props23 :=  propMini[23], props24 :=  propMini[24]):
                props23.ShowProps()
                props24.ShowProps()
    onGamingUpgrade3(Agnet:agent):void=
        if (playercoins>=1500):
            set playercoins = playercoins - 1500
            set ButtonNum = 18
            HideButoone()
            AUDIO.Play(Agnet)
            set playerLovePoint = playerLovePoint + 200
            if (props25 :=  propMini[25]):
                props25.ShowProps()
    onGamingUpgrade4(Agnet:agent):void=
        if (playercoins>=1500):
            set playercoins = playercoins - 1500
            set ButtonNum = 19
            HideButoone()
            AUDIO.Play(Agnet)
            set playerLovePoint = playerLovePoint + 200
            if (props26 :=  propMini[26]):
                props26.ShowProps()
    onGamingUpgrade5(Agnet:agent):void=
        if (playercoins>=1500):
            set playercoins = playercoins - 1500
            set ButtonNum = 20
            HideButoone()
            AUDIO.Play(Agnet)
            set playerLovePoint = playerLovePoint + 200
            if (props27 :=  propMini[27],props28 :=  propMini[28] , props29 :=  propMini[29],props30 :=  propMini[30]):
                props27.ShowProps()
                props28.ShowProps()
                props29.ShowProps()
                props30.ShowProps()
            if (carpet0 := carpet[0]):
                carpet0.Show()
    onKitchenUp2(Agent : agent):void=
        if (playercoins >= 5000):
            set playercoins = playercoins - 5000
            set ButtonNum = 21
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props31 :=  propMini[31]):
                props31.ShowProps()
            if (carpet1 := carpet[1]):
                carpet1.Show()
    onKitchenUp3(Agent : agent):void=
        if (playercoins >= 5000):
            set playercoins = playercoins - 5000
            set ButtonNum = 22
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 500
            if (props32 :=  propMini[32]):
                props32.ShowProps()
    onKitchenUp4(Agent : agent):void=
        if (playercoins >= 5000):
            set playercoins = playercoins - 5000
            set ButtonNum = 23
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props33 :=  propMini[33]):
                props33.ShowProps()
    onKitchenUp5(Agent : agent):void=
        if (playercoins >= 5500):
            set playercoins = playercoins - 5500
            set ButtonNum = 24
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props34 :=  propMini[34],props35 :=  propMini[35] ):
                props34.ShowProps()
                props35.ShowProps()
            # upgrade kitchen wall
            if (price27 := Pricese[27]):
                price27.Show()
            if(holder27 := PricesHolder [27]):
                holder27.Show()
            if(Zone27 := zone[27]):
                Zone27.Enable()
            # glass
            if (price28 := Pricese[28]):
                price28.Show()
            if(holder28 := PricesHolder [28]):
                holder28.Show()
            if(Zone28 := zone[28]):
                Zone28.Enable()
    onGamingDoorActivate(Agent:agent):void=
        if(playercoins >= 1500):
            set playercoins = playercoins - 1500
            set ButtonNum = 25
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props36 :=  propMini[36]):
                props36.ShowProps()
    onHousDoorActivate_ShowStairs(Agent:agent):void=
        if(playercoins >= 25000):
            set playercoins = playercoins - 25000
            set ButtonNum = 26
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 600
            if (props37 :=  propMini[37]):
                props37.ShowProps()
            # Show Stairs 
            if (price29 := Pricese[29]):
                price29.Show()
            if(holder29 := PricesHolder [29]):
                holder29.Show()
            if(Zone29 := zone[29]):
                Zone29.Enable()
    onKitchenWallActive(Agent : agent):void=
        if (playercoins >= 2500):
            set playercoins = playercoins - 2500
            set ButtonNum = 27
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props38 :=  propMini[38],props39 :=  propMini[39],props40 :=  propMini[40]):
                props38.ShowProps()
                props39.ShowProps()
                props40.ShowProps()
    onKitchenGlassActive(Agent:agent):void=
        if (playercoins >= 3500):
            set playercoins = playercoins - 3500
            set ButtonNum = 28
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if(props41:=  propMini[41]):
                props41.ShowProps()
            # show door 
            if (price15 := Pricese[15]):
                price15.Show()
            if(holder15 := PricesHolder [15]):
                holder15.Show()
            if(Zone15 := zone[15]):
                Zone15.Enable()

    onStairsActive_ShowBelt(Agent:agent):void=
        if (playercoins >= 15000):
            set playercoins = playercoins - 15000
            set ButtonNum = 29
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 800
            if (props42 :=  propMini[42],props43 :=  propMini[43],props44 :=  propMini[44]):
                props42.ShowProps()
                props43.ShowProps()
                props44.ShowProps()
            # show belt f2
            if (price30 := Pricese[30]):
                price30.Show()
            if(holder30 := PricesHolder [30]):
                holder30.Show()
            if(Zone30 := zone[30]):
                Zone30.Enable()

    OnKitchenDoorActive(Agent:agent):void=
        if (playercoins >= 1500):
            set playercoins = playercoins - 1500
            set ButtonNum = 15
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props46 :=  propMini[46]):
                props46.ShowProps()


    OnBeltActiveF2_ShowDrope1_ShowBalcon_ShowLivRoom_ShowBed(Agent:agent):void=
        if(playercoins >= 1000):
            set playercoins = playercoins - 1000
            set ButtonNum = 30
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props45 :=  propMini[45]):
                props45.ShowProps()
            #SHOW DROPPER1
            if (price31 := Pricese[31]):
                price31.Show()
            if(holder31 := PricesHolder [31]):
                holder31.Show()
            if(Zone31 := zone[31]):
                Zone31.Enable()
            # show balcony 
            if (price32 := Pricese[32]):
                price32.Show()
            if(holder32 := PricesHolder [32]):
                holder32.Show()
            if(Zone32 := zone[32]):
                Zone32.Enable()
            # show bliving room
            if (price33 := Pricese[33]):
                price33.Show()
            if(holder33 := PricesHolder [33]):
                holder33.Show()
            if(Zone33 := zone[33]):
                Zone33.Enable()
            # show bed
            if (price34 := Pricese[34]):
                price34.Show()
            if(holder34 := PricesHolder [34]):
                holder34.Show()
            if(Zone34 := zone[34]):
                Zone34.Enable()
    OndropperF2_1_ShowDR2(Agent:agent):void=
        if (playercoins>= 5000):
            set playercoins = playercoins - 5000
            set dropper5 = 500
            set playerLovePoint = playerLovePoint + 200

            set ButtonNum = 31
            HideButoone()
            AUDIO.Play(Agent)

            if (animations4 := TeddyAnimes[4]):
                animations4.Play()


            if (props47 :=  propMini[47]):
                props47.ShowProps()
            # show Dr2
            if (price35 := Pricese[35]):
                price35.Show()
            if(holder35 := PricesHolder [35]):
                holder35.Show()
            if(Zone35 := zone[35]):
                Zone35.Enable()
    onBalcony1Active_ShowUp1_up2_Roof(Agent:agent):void=
        if (playercoins >=45000):
            set playercoins = playercoins - 45000
            set ButtonNum = 32
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 800
            if (props48 :=  propMini[48],props123 :=  propMini[123],props124 :=  propMini[124]):
                props48.ShowProps()
                props123.ShowProps()
                props124.ShowProps()
            # show up 1
            if (price36 := Pricese[36]):
                price36.Show()
            if(holder36 := PricesHolder [36]):
                holder36.Show()
            if(Zone36 := zone[36]):
                Zone36.Enable()
            # show up 2
            if (price37 := Pricese[37]):
                price37.Show()
            if(holder37 := PricesHolder [37]):
                holder37.Show()
            if(Zone37 := zone[37]):
                Zone37.Enable()
            # show roof
            if (price38 := Pricese[38]):
                price38.Show()
            if(holder38 := PricesHolder [38]):
                holder38.Show()
            if(Zone38 := zone[38]):
                Zone38.Enable()
    onLivingRooActive_ShowFloor(Agent : agent): void=
        if (playercoins >=35000):
            set playercoins = playercoins - 35000
            set ButtonNum = 33
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 500
            if (props49 :=  propMini[49]):
                props49.ShowProps()
            #Show Floor
            if (price39 := Pricese[39]):
                price39.Show()
            if(holder39 := PricesHolder [39]):
                holder39.Show()
            if(Zone39 := zone[39]):
                Zone39.Enable()
    onBedActive_showFloor(Agent :agent):void=
        if (playerLovePoint >= 500):
            set playerLovePoint = playerLovePoint - 500
            set ButtonNum = 34
            HideButoone()
            AUDIO.Play(Agent)
            if (props50 :=  propMini[50]):
                props50.ShowProps()
            # show bed floor 
            if (price40 := Pricese[40]):
                price40.Show()
            if(holder40 := PricesHolder [40]):
                holder40.Show()
            if(Zone40 := zone[40]):
                Zone40.Enable()
    onF2_DropperActive_showDR3(Agent : agent):void=
        if (playercoins >= 15000):
            set playercoins = playercoins - 15000
            set dropper6 = 850
            set ButtonNum = 35
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200

            if (animations5 := TeddyAnimes[5]):
                animations5.Play()


            if (props51 :=  propMini[51]):
                props51.ShowProps()
            # show dropper 3
            if (price41 := Pricese[41]):
                price41.Show()
            if(holder41 := PricesHolder [41]):
                holder41.Show()
            if(Zone41 := zone[41]):
                Zone41.Enable()
    onBalconUP1Active(Agent : agent): void=
        if (playercoins >= 25000):
            set playercoins = playercoins -25000
            set ButtonNum = 36
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 500
            if (props52 :=  propMini[52]):
                props52.ShowProps() 
    onBalconUP2Active(Agent : agent): void=
        if (playercoins >= 25000):
            set playercoins = playercoins -25000
            set ButtonNum = 37
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props53 :=  propMini[53],props54 :=  propMini[54]):
                props53.ShowProps()
                props54.ShowProps()
    onBalconRoofActive(Agent:agent):void=
        if (playercoins >= 35000):
            set playercoins = playercoins -35000
            set ButtonNum = 38
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props55 :=  propMini[55]):
                props55.ShowProps()
    OnLivingRoomFloorActive(Agent:agent):void=    
        #show upgrad 1 , show up 2 , wall 3 
        if (playercoins >=35000):
            set playercoins = playercoins -35000
            set ButtonNum = 39
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props56 :=  propMini[56]):
                props56.ShowProps()
            # show up 1
            if (price42 := Pricese[42]):
                price42.Show()
            if(holder42 := PricesHolder [42]):
                holder42.Show()
            if(Zone42 := zone[42]):
                Zone42.Enable()
            # show up 2
            if (price43 := Pricese[43]):
                price43.Show()
            if(holder43 := PricesHolder [43]):
                holder43.Show()
            if(Zone43 := zone[43]):
                Zone43.Enable()
            # show wall 
            if (price44 := Pricese[44]):
                price44.Show()
            if(holder44 := PricesHolder [44]):
                holder44.Show()
            if(Zone44 := zone[44]):
                Zone44.Enable()
    OnBedFloorActive(Agent:agent):void=
        if (playerLovePoint >= 500):
            set playerLovePoint = playerLovePoint - 500
            set ButtonNum = 40
            HideButoone()
            AUDIO.Play(Agent)
            if (props57 :=  propMini[57]):
                props57.ShowProps()
            # show teddy 1
            if (price45 := Pricese[45]):
                price45.Show()
            if(holder45 := PricesHolder [45]):
                holder45.Show()
            if(Zone45 := zone[45]):
                Zone45.Enable()
            # show up1
            if (price46 := Pricese[46]):
                price46.Show()
            if(holder46 := PricesHolder [46]):
                holder46.Show()
            if(Zone46 := zone[46]):
                Zone46.Enable()
            # show wall
            if (price47 := Pricese[47]):
                price47.Show()
            if(holder47 := PricesHolder [47]):
                holder47.Show()
            if(Zone47 := zone[47]):
                Zone47.Enable()
    OnDropper3Active(Agent:agent):void=
        # show wall and emoting and upgrade wall
        if (playercoins >=35000):
            set playercoins = playercoins - 35000
            set dropper7 = 1000
            set ButtonNum = 41
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200

            if (animations6 := TeddyAnimes[6]):
                animations6.Play()

            if (props58 :=  propMini[58]):
                props58.ShowProps()
            # show wall 
            if (price48 := Pricese[48]):
                price48.Show()
            if(holder48 := PricesHolder [48]):
                holder48.Show()
            if(Zone48 := zone[48]):
                Zone48.Enable()
            # show emoting
            if (price49 := Pricese[49]):
                price49.Show()
            if(holder49 := PricesHolder [49]):
                holder49.Show()
            if(Zone49 := zone[49]):
                Zone49.Enable() 
            # show upgrade wall 
            if (price50 := Pricese[50]):
                price50.Show()
            if(holder50 := PricesHolder [50]):
                holder50.Show()
            if(Zone50 := zone[50]):
                Zone50.Enable() 
    OnLivingRoomUP1Active(Agent : agent):void=
        if (playercoins >=55000):
            set playercoins = playercoins - 55000
            set ButtonNum = 42
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props59 :=  propMini[59]):
                props59.ShowProps()
            if (carpets2 := carpet[2]):
                carpets2.Show()
    OnLivingRoomUP2Active(Agent : agent):void=
        # show up 4 show up 5
        if (playercoins >=55000):
            set playercoins = playercoins - 55000
            set ButtonNum = 43
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props60 :=  propMini[60],props61 :=  propMini[61],props62 :=  propMini[62]):
                props60.ShowProps()
                props61.ShowProps()
                props62.ShowProps()
            if (carpets3 := carpet[3]):
                carpets3.Show()
            # show up3
            if (price51 := Pricese[51]):
                price51.Show()
            if(holder51 := PricesHolder [51]):
                holder51.Show()
            if(Zone51 := zone[51]):
                Zone51.Enable() 

            # show up4
            if (price52 := Pricese[52]):
                price52.Show()
            if(holder52 := PricesHolder [52]):
                holder52.Show()
            if(Zone52 := zone[52]):
                Zone52.Enable() 
    OnWallActive(Agent : agent):void=
        # show up 6 , glass , door 
        if (playercoins >=35000):
            set playercoins = playercoins - 35000
            set ButtonNum = 44
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props63 :=  propMini[63],props64 :=  propMini[64],props65 :=  propMini[65]):
                props63.ShowProps()
                props64.ShowProps()
                props65.ShowProps()
            # show up 4
            if (price53 := Pricese[53]):
                price53.Show()
            if(holder53 := PricesHolder [53]):
                holder53.Show()
            if(Zone53 := zone[53]):
                Zone53.Enable() 
            # show Glass
            if (price54 := Pricese[54]):
                price54.Show()
            if(holder54 := PricesHolder [54]):
                holder54.Show()
            if(Zone54 := zone[54]):
                Zone54.Enable()
            # show door  
            if (price55 := Pricese[55]):
                price55.Show()
            if(holder55 := PricesHolder [55]):
                holder55.Show()
            if(Zone55 := zone[55]):
                Zone55.Enable()
    OnTeddy1Active(Agent : agent):void=
        if (playerLovePoint >= 500):
            set playerLovePoint = playerLovePoint - 500
            set ButtonNum = 45
            HideButoone()
            AUDIO.Play(Agent)
            if (props66 :=  propMini[66]):
                props66.ShowProps()
    OnBedRoomUP1Active(Agent : agent): void=
        if (playerLovePoint>= 500):
            set playerLovePoint = playerLovePoint - 500
            set ButtonNum = 46
            HideButoone()
            AUDIO.Play(Agent)
            if (props67 :=  propMini[67],props68 :=  propMini[68]):
                props67.ShowProps()
                props68.ShowProps()
            if (carpets4 := carpet[4]):
                carpets4.Show()

            # SHOW TEDDY 2
            if (price56 := Pricese[56]):
                price56.Show()
            if(holder56 := PricesHolder [56]):
                holder56.Show()
            if(Zone56 := zone[56]):
                Zone56.Enable()
    onBedRoomWallActivate(Agent : agent):void=
        if (playerLovePoint >= 500):
            set playerLovePoint = playerLovePoint - 500
            set ButtonNum = 47
            HideButoone()
            AUDIO.Play(Agent)
            if (props69 :=  propMini[69]):
                props69.ShowProps()

            # show upgrade walls 
            if (price57 := Pricese[57]):
                price57.Show()
            if(holder57 := PricesHolder [57]):
                holder57.Show()
            if(Zone57 := zone[57]):
                Zone57.Enable()
            # show upgrade bed room 3
            if (price58 := Pricese[58]):
                price58.Show()
            if(holder58 := PricesHolder [58]):
                holder58.Show()
            if(Zone58 := zone[58]):
                Zone58.Enable()
    onFloor2WallsActive(Agent : agent):void=
        if (playercoins >=35000):
            set playercoins = playercoins - 35000
            set ButtonNum = 48
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props70 :=  propMini[70],props71 :=  propMini[71]):
                props70.ShowProps()
                props71.ShowProps()


            # show weapons2
            if (price85 := Pricese[85]):
                price85.Show()
            if(holder85 := PricesHolder [85]):
                holder85.Show()
            if(Zone85 := zone[85]):
                Zone85.Enable()
    OnEmotingActive(Agent:agent):void=
        if (playercoins >=75000):
            set playercoins = playercoins - 75000
            set ButtonNum = 49
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 500
            dancing.Enable()
            EmotingZone.Enable()
            EmoteText.Show()
            if(props72 :=  propMini[72]):
                props72.ShowProps()
            # show stairs 
            if (price59 := Pricese[59]):
                price59.Show()
            if(holder59 := PricesHolder [59]):
                holder59.Show()
            if(Zone59 := zone[59]):
                Zone59.Enable()
    OnFloor2WallUpgraded(Agent:agent):void=
        if (playercoins >=35000):
            set playercoins = playercoins - 35000
            set ButtonNum = 50
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if(props73 :=  propMini[73],props74 :=  propMini[74]):
                props73.ShowProps()
                props74.ShowProps()
    OnLivingRoomUpgrade3(Agent : agent):void=
        if (playercoins >= 55000):
            set playercoins = playercoins - 55000
            set ButtonNum = 51
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if(props75 :=  propMini[75]):
                props75.ShowProps()
    OnLivingRoomUpgrad4(Agent:agent):void=
        if(playercoins >= 55000):
            set playercoins = playercoins - 55000
            set ButtonNum = 52
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if(props76 :=  propMini[76]):
                props76.ShowProps()
    OnLivingRoomUpgrad5(Agent:agent):void=
        if (playercoins >=55000):
            set playercoins = playercoins -55000
            set ButtonNum = 53
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 500
            if(props77 :=  propMini[77],props78 :=  propMini[78]):
                props77.ShowProps()
                props78.ShowProps()
    ssOnGlassActive(Agent:agent):void=
        if(playercoins >=100000):
            set playercoins = playercoins - 100000
            set ButtonNum = 54
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 500
            if(props79 :=  propMini[79]):
                props79.ShowProps()
    OnLivingRoomDoorActive(Agent:agent):void=
        if(playercoins >=100000):
            set playercoins = playercoins - 100000
            set ButtonNum = 55
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 500
            if(props80 :=  propMini[80]):
                props80.ShowProps()
    OnTeddy2Active(Agent:agent):void=
        if (playerLovePoint >= 500):
            set playerLovePoint = playerLovePoint - 500
            set ButtonNum = 56
            HideButoone()
            AUDIO.Play(Agent)
            if(props81 :=  propMini[81]):
                props81.ShowProps()
    OnWallUpgraded2Active(Agent : agent):void=
        if (playerLovePoint >= 500):
            set playerLovePoint = playerLovePoint - 500
            set ButtonNum = 57
            HideButoone()
            AUDIO.Play(Agent)
            if(props82 :=  propMini[82],props83 :=  propMini[83],props84 :=  propMini[84],props85 :=  propMini[85],props86 :=  propMini[86],props87 :=  propMini[87] ):
                props82.ShowProps()
                props83.ShowProps()
                props84.ShowProps()
                props85.ShowProps()
                props86.ShowProps()
                props87.ShowProps()
    ONUpgradeBedRoom3(Agent:agent):void=
        if (playerLovePoint >= 500):
            set playerLovePoint = playerLovePoint - 500
            set ButtonNum = 58
            HideButoone()
            AUDIO.Play(Agent)
            if (props88 :=  propMini[88],props89 :=  propMini[89],props90 :=  propMini[90],props91 :=  propMini[91],props125 :=  propMini[125]):
                props88.ShowProps()
                props89.ShowProps()
                props90.ShowProps()
                props91.ShowProps()
                props125.ShowProps()
            #ShowBalcony
            if (price60 := Pricese[60]):
                price60.Show()
                
            if(holder60 := PricesHolder [60]):
                holder60.Show()
            if(Zone60 := zone[60]):
                Zone60.Enable()
    OnStairs2Active(Agent : agent):void=
        if (playercoins >= 250000):
            set playercoins = playercoins - 250000
            set ButtonNum = 59
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 900
            if(props92 :=  propMini[92],props93 :=  propMini[93],props94 :=  propMini[94]):
                props92.ShowProps()
                props93.ShowProps()
                props94.ShowProps()
            # Show belt 1
            if (price61 := Pricese[61]):
                price61.Show()
            if(holder61 := PricesHolder [61]):
                holder61.Show()
            if(Zone61 := zone[61]):
                Zone61.Enable()
    OnBalcony2Active(Agent : agent):void=
        if(playercoins>= 150000):
            set playercoins = playercoins - 150000
            set ButtonNum = 60
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if(props95 :=  propMini[95]):
                props95.ShowProps()
            # upgrade 1 
            if(price62 := Pricese[62]):
                price62.Show()
            if(holder62 := PricesHolder [62]):
                holder62.Show()
            if(Zone62 := zone[62]):
                Zone62.Enable()
            # upgrade 2 
            if(price63 := Pricese[63]):
                price63.Show()
            if(holder63 := PricesHolder [63]):
                holder63.Show()
            if(Zone63 := zone[63]):
                Zone63.Enable()
            # upgrade 3 
            if(price64 := Pricese[64]):
                price64.Show()
            if(holder64 := PricesHolder [64]):
                holder64.Show()
            if(Zone64 := zone[64]):
                Zone64.Enable()
    OnRoofBeltActive_ShowDropper1(Agent : agent):void=
        if (playercoins>= 200000):
            set playercoins = playercoins - 200000
            set ButtonNum = 61
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if(props96 :=  propMini[96]):
                props96.ShowProps()
            # show dropper 1
            if(price65 := Pricese[65]):
                price65.Show()
            if(holder65 := PricesHolder [65]):
                holder65.Show()
            if(Zone65 := zone[65]):
                Zone65.Enable()
    OnBalconyUpgrad1_Active(Agent:agent):void=
        if (playercoins >= 100000):
            set playercoins = playercoins - 100000
            set ButtonNum = 62
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if(props97 :=  propMini[97],props98 :=  propMini[98]):
                props97.ShowProps()
                props98.ShowProps()
    OnBalconyUpgrad2_Active(Agent:agent):void=
        if (playercoins >= 100000):
            set playercoins = playercoins - 100000
            set ButtonNum = 63
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props99 :=  propMini[99]):
                props99.ShowProps()
            if (carpet5 := carpet[5]):
                carpet5.Show()
    OnBalconyUpgrad3_Active(Agent:agent):void=
        if (playercoins >= 100000):
            set playercoins = playercoins - 100000
            set ButtonNum = 64
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200
            if (props100 :=  propMini[100]):
                props100.ShowProps()
    OnRoofDropper1Active_ShowDropper2_Weeding_Roofglass(Agent:agent):void=
        if (playercoins >= 200000):
            set playercoins = playercoins - 200000
            set dropper8 = 5000
            set ButtonNum = 65
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200

            if (animations7 := TeddyAnimes[7]):
                animations7.Play()

            if (props101 :=  propMini[101]):
                props101.ShowProps()
            # show dropper 2
            if(price66 := Pricese[66]):
                price66.Show()
            if(holder66 := PricesHolder [66]):
                holder66.Show()
            if(Zone66 := zone[66]):
                Zone66.Enable()
            # show weeding 2
            if(price67 := Pricese[67]):
                price67.Show()
            if(holder67 := PricesHolder [67]):
                holder67.Show()
            if(Zone67 := zone[67]):
                Zone67.Enable()
            # show glassss
            if(price68 := Pricese[68]):
                price68.Show()
            if(holder68 := PricesHolder [68]):
                holder68.Show()
            if(Zone68 := zone[68]):
                Zone68.Enable()
    OnRoofDropper2_Active_showDropper3_showPool(Agent:agent):void=
        if (playercoins >=250000):
            set playercoins = playercoins - 250000
            set dropper9 = 10000
            set ButtonNum = 66
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 200

            if (animations8 := TeddyAnimes[8]):
                animations8.Play()

            if (props102 :=  propMini[102]):
                props102.ShowProps()
            # show dr3
            if(price69 := Pricese[69]):
                price69.Show()
            if(holder69 := PricesHolder [69]):
                holder69.Show()
            if(Zone69 := zone[69]):
                Zone69.Enable()
            # show Pool
            if(price70 := Pricese[70]):
                price70.Show()
            if(holder70 := PricesHolder [70]):
                holder70.Show()
            if(Zone70 := zone[70]):
                Zone70.Enable()
    OnWeddingActive_showUpWeding1_showUPWedding2_ShowUp3Weding(Agent : agent):void=
        if (playerLovePoint >= 1000):
            set playerLovePoint = playerLovePoint - 1000
            set ButtonNum = 67
            HideButoone()
            AUDIO.Play(Agent)
            if (props103 :=  propMini[103]):
                props103.ShowProps()
            # show up 1
            if(price71 := Pricese[71]):
                price71.Show()
            if(holder71 := PricesHolder [71]):
                holder71.Show()
            if(Zone71 := zone[71]):
                Zone71.Enable()
            # show up 2
            if(price72 := Pricese[72]):
                price72.Show()
            if(holder72 := PricesHolder [72]):
                holder72.Show()
            if(Zone72 := zone[72]):
                Zone72.Enable()
            # show up 3
            if(price73 := Pricese[73]):
                price73.Show()
            if(holder73 := PricesHolder [73]):
                holder73.Show()
            if(Zone73 := zone[73]):
                Zone73.Enable()
    OnRoofGlassActive(Agent:agent):void=
        if (playercoins >= 500000):
            set playercoins = playercoins - 500000
            set ButtonNum = 68
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000
            if (props104 :=  propMini[104]):
                props104.ShowProps()
    OnRoofDropper3Active(Agent:agent):void=
        if (playercoins >= 300000):
            set playercoins = playercoins - 300000
            set dropper10 = 15000
            set ButtonNum = 69
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000

            if (animations9 := TeddyAnimes[9]):
                animations9.Play()


            if (props105 :=  propMini[105]):
                props105.ShowProps()
            # show dropper 4
            if(price74 := Pricese[74]):
                price74.Show()
            if(holder74 := PricesHolder [74]):
                holder74.Show()
            if(Zone74 := zone[74]):
                Zone74.Enable()
    OnPoolActive_ShowPoolUP(Agent : agent):void=
        if (playercoins >= 1500000):
            set playercoins = playercoins - 1500000
            set ButtonNum = 70
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000
            if (props106 :=  propMini[106]):
                props106.ShowProps()
            # show pool Upgrad
            if(price75 := Pricese[75]):
                price75.Show()
            if(holder75 := PricesHolder [75]):
                holder75.Show()
            if(Zone75 := zone[75]):
                Zone75.Enable()
            # show statu
            if(price76 := Pricese[76]):
                price76.Show()
            if(holder76 := PricesHolder [76]):
                holder76.Show()
            if(Zone76 := zone[76]):
                Zone76.Enable()
            # show base glass
            if(price77 := Pricese[77]):
                price77.Show()
            if(holder77 := PricesHolder [77]):
                holder77.Show()
            if(Zone77 := zone[77]):
                Zone77.Enable()
            # show plants 1
            if(price78 := Pricese[78]):
                price78.Show()
            if(holder78 := PricesHolder [78]):
                holder78.Show()
            if(Zone78 := zone[78]):
                Zone78.Enable()
            # show plants 2
            if(price79 := Pricese[79]):
                price79.Show()
            if(holder79 := PricesHolder [79]):
                holder79.Show()
            if(Zone79 := zone[79]):
                Zone79.Enable()
    OnWeddingUpgrade1Active(Agent : agent):void=
        if (playerLovePoint >= 1000):
            set playerLovePoint = playerLovePoint - 1000
            set ButtonNum = 71
            HideButoone()
            AUDIO.Play(Agent)
            if (props107 :=  propMini[107]):
                props107.ShowProps()
    OnWeddingUpgrade2Active(Agent : agent):void=
        if (playerLovePoint >= 1000):
            set playerLovePoint = playerLovePoint - 1000
            set ButtonNum = 72
            HideButoone()
            AUDIO.Play(Agent)
            if (props108 :=  propMini[108]):
                props108.ShowProps()
    OnWeddingUpgrade3Active(Agent : agent):void=
        if (playerLovePoint >= 1000):
            set playerLovePoint = playerLovePoint - 1000
            set ButtonNum = 73
            HideButoone()
            AUDIO.Play(Agent)
            if (props109 :=  propMini[109]):
                props109.ShowProps()

            # show get married
            if(price86 := Pricese[86]):
                price86.Show()
            if(holder86 := PricesHolder [86]):
                holder86.Show()
            if(Zone86 := zone[86]):
                Zone86.Enable() 
    OnRoofDropper4Active(Agent:agent):void=
        if (playercoins >= 350000):
            set playercoins = playercoins - 350000
            set dropper11 = 20000
            set ButtonNum = 74
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000

            if (animations10 := TeddyAnimes[10]):
                animations10.Play()


            if (props110 :=  propMini[110]):
                props110.ShowProps()
    OnPoolUpgradeActive(Agent:agent):void=
        if (playercoins >= 2500000):
            set playercoins = playercoins - 2500000
            set ButtonNum = 75
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000
            if (props111 :=  propMini[111]):
                props111.ShowProps()
    OnStatuActive(Agent:agent):void=
        if (playercoins >= 1500000):
            set playercoins = playercoins - 1500000
            set ButtonNum = 76
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000
            if (props112 :=  propMini[112]):
                props112.ShowProps()
    OnBasseGlassActive(Agent:agent):void=
        if(playercoins >= 500000):
            set playercoins = playercoins - 500000
            set ButtonNum = 77
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000
            if (props113 :=  propMini[113],props114 :=  propMini[114],props115 :=  propMini[115],props116 :=  propMini[116]):
                props113.ShowProps()
                props114.ShowProps()
                props115.ShowProps()
                props116.ShowProps()
            # show relax area 
            if(price80 := Pricese[80]):
                price80.Show()
            if(holder80 := PricesHolder [80]):
                holder80.Show()
            if(Zone80 := zone[80]):
                Zone80.Enable()
            # show chill area
            if(price81 := Pricese[81]):
                price81.Show()
            if(holder81 := PricesHolder [81]):
                holder81.Show()
            if(Zone81 := zone[81]):
                Zone81.Enable() 
    OnPlant1Active(Agent:agent):void=
        if(playercoins >= 500000):
            set playercoins = playercoins - 500000
            set ButtonNum = 78
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000
            if (props117 :=  propMini[117]):
                props117.ShowProps()
    OnPlant2Active(Agent:agent):void=
        if(playercoins >= 500000):
            set playercoins = playercoins - 500000
            set ButtonNum = 79
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000
            if (props118 :=  propMini[118]):
                props118.ShowProps()
    OnRelaxAreaActive(Agent:agent):void=
        if(playercoins >= 500000):
            set playercoins = playercoins - 500000
            set ButtonNum = 80
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000
            if (props119 :=  propMini[119],props120 :=  propMini[120]):
                props119.ShowProps()
                props120.ShowProps()
    OnChillAreaActive(Agent:agent):void=
        if(playercoins >= 1500000):
            set playercoins = playercoins - 1500000
            set ButtonNum = 81
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000
            if (props121 :=  propMini[121]):
                props121.ShowProps()
            #show upgrade 
            if(price82 := Pricese[82]):
                price82.Show()
            if(holder82 := PricesHolder [82]):
                holder82.Show()
            if(Zone82 := zone[82]):
                Zone82.Enable() 
    OnChillAreaUpgrade(Agent:agent):void=
        if(playercoins >= 2000000):
            set playercoins = playercoins - 2000000
            set ButtonNum = 82
            HideButoone()
            AUDIO.Play(Agent)
            set playerLovePoint = playerLovePoint + 1000
            if (props122 :=  propMini[122]):
                props122.ShowProps()
    OnWheelActive(Agent : agent):void=
        if (playercoins >= 35000):
            set playercoins = playercoins - 35000
            set ButtonNum = 83
            HideButoone()
            AUDIO.Play(Agent)
            wheelActivator.Enable()
            if (props126 :=  propMini[126]):
                props126.ShowProps()
    OnWeaponActive1(Agent : agent):void=
        if (playercoins >= 10000):
            set playercoins = playercoins - 10000
            if(weaponAnim0 := WepAnime[0]):
                weaponAnim0.Play()
            set ButtonNum = 84
            HideButoone()
            AUDIO.Play(Agent)
    OnWeaponActive2(Agent : agent):void=
        if (playercoins >= 100000):
            set playercoins = playercoins - 100000
            if(weaponAnim1 := WepAnime[1]):
                weaponAnim1.Play()
            set ButtonNum = 85
            HideButoone()
            AUDIO.Play(Agent)


    OnGetMarriedActive(Agent : agent):void=
        if (playercoins>= 10000000):
            set playercoins = playercoins - 10000000
            set ButtonNum = 86
            AnimTrigger.Trigger()
            HideButoone()
            AUDIO.Play(Agent)
            RingActive.TurnOn(Agent)

            # show start family
            if(price87 := Pricese[87]):
                price87.Show()
            if(holder87 := PricesHolder [87]):
                holder87.Show()
            if(Zone87 := zone[87]):
                Zone87.Enable() 
    OnStartFamilyActive(Agent : agent):void=
        if (playercoins>= 15000000):
            set playercoins = playercoins - 15000000
            set ButtonNum = 87
            HideButoone()
            AUDIO.Play(Agent)
            for (Kidss : Kids):
                Kidss.Show()


    PopUpPress2(Agent : agent, num : int) : void =
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        if (AgentsTeam := TeamCollection.GetTeam[Agent]):
            for (TeamNumber->Team : TeamArray):
                if (AgentsTeam = Team ,TeamNumber = 7 ):
                    if (num = 1):
                        if (playercoins>= 100000):
                            set playercoins = playercoins - 100000
                            set Prop1Selected = true
                            set Girl1 = 1000
                            set Prop2Selected = false
                            set Prop3Selected = false
                            spawn:
                                Prop1MoveToPlayer(Agent)
                            Track.Complete(Agent)
                            AUDIO.Play(Agent)
                    if (num = 2):
                        if (playercoins >= 500000):

                            set playercoins = playercoins - 500000
                            set Prop2Selected = true
                            set Girl2 = 5000
                            set Prop1Selected = false
                            set Prop3Selected = false
                            spawn:
                                Prop2MoveToPlayer(Agent)
                            Track.Complete(Agent)
                            AUDIO.Play(Agent)
                    if (num = 3):
                        if (playercoins >= 5000000):
                            set playercoins = playercoins - 5000000
                            set Girl3 = 50000
                            set Prop3Selected = true
                            set Prop1Selected = false
                            set Prop2Selected = false
                            spawn:
                                Prop3MoveToPlayer(Agent)
                            Track.Complete(Agent)
                            AUDIO.Play(Agent)