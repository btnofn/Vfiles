using { /Fortnite.com/Playspaces  }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Vehicles }

using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level


simonsays := class(creative_device):
    ## Variables/Devices
    var SubscriptionEvent: ?cancelable = false
    var SubscriptionEvent2: ?cancelable = false
    var jumpedplayers : []player = array{}
    var crouchedplayers : []player = array{}
    var sprintingplayers : []player = array{}
    var supplydropplayers : []player = array{}
    var chairplayers : []player = array{}
    var pickupplayers : []player = array{}

    var explodedplayers : []player = array{}
    var gaveappleplayers : []player = array{}
    var finishedparkour : []player = array{}
    var enteredplatform : []player = array{}
    var didemote : []player = array{}
    var didhoop : []player = array{}
    var didmove : []player = array{}

    var infinityswordplayer : []player = array{}

    var cancelledsprintingplayers : []player = array{}
    var incarplayers : []player = array{}


    var Minigames :[]int = array:
       
        26
        26
    

        
       
   

     




    var MinigamesCopy :[]int = array:
        0
        1
        2
        3
        4
        19
        17  
        5
        6
        15
        7
        18
        8
        9
        10
        12
        13
        14
        0
        1
        21
        22
        23
        2
        15
        3
        4
        5
        6
        7
        8
        9
        10
        12
        13
        18
        20
        14
        24
        24
        25
        26
        26
    

   
        
 

    @editable
    wonaccolade :  accolades_device =  accolades_device{}
    @editable
    passedaccolade :  accolades_device =  accolades_device{}
    @editable
    playerreference : player_reference_device = player_reference_device{}
    @editable
    cb : conditional_button_device = conditional_button_device{}
    @editable
    sportscars : []vehicle_spawner_sports_car_device = array{}
    @editable
    chairs : []chair_device = array{}
    @editable
    powerups : []health_powerup_device = array{}
    @editable
    explosives : []explosive_device = array{}
    @editable
    supplydrops : []supply_drop_spawner_device = array{}
    @editable
    houseparts : creative_prop = creative_prop{}
    @editable
    chairparts : creative_prop = creative_prop{}
    @editable
    wheel : creative_prop = creative_prop{}
    @editable
    wheelprops : creative_prop = creative_prop{}
    @editable
    welcome : creative_prop = creative_prop{}
    @editable
    platform1 : creative_prop = creative_prop{}
    @editable
    itemgranter5  : item_granter_device = item_granter_device{}

    @editable
    parkour : creative_prop = creative_prop{}
    @editable
    hoop : creative_prop = creative_prop{}
    @editable
    roundwinner : creative_prop = creative_prop{}
    @editable
    infinity : creative_prop = creative_prop{}
    @editable
    tp : teleporter_device = teleporter_device{}
    @editable
    field1 :  elimination_feed_device =  elimination_feed_device{}
    @editable
    field2 :  elimination_feed_device =  elimination_feed_device{}
    @editable
    hudinfinitysword : hud_message_device = hud_message_device{}
    
    @editable
    hudsupplydrop : hud_message_device = hud_message_device{}
    @editable
    huddontgrandma : hud_message_device = hud_message_device{}

    @editable
    hudparkour : hud_message_device = hud_message_device{}
    @editable
    hudcrouch : hud_message_device = hud_message_device{}
    @editable
    hudmini : hud_message_device = hud_message_device{}
    @editable
    hudcar : hud_message_device = hud_message_device{}
    @editable
    huddontemote : hud_message_device = hud_message_device{}
    @editable
    hudmedkit : hud_message_device = hud_message_device{}
    @editable
    hudjump : hud_message_device = hud_message_device{}
    @editable
    huddontcrouch : hud_message_device = hud_message_device{}
    @editable
    hudpickup : hud_message_device = hud_message_device{}
    @editable
    huddontcar : hud_message_device = hud_message_device{}
    @editable
    huddontjump : hud_message_device = hud_message_device{}
    @editable
    hudgrandma : hud_message_device = hud_message_device{}
    @editable
    hudemote : hud_message_device = hud_message_device{}
    @editable
    hudsky : hud_message_device = hud_message_device{}
    @editable
    hudplatform : hud_message_device = hud_message_device{}
    @editable
    huddontplatform : hud_message_device = hud_message_device{}
    @editable
    startinginhud : hud_message_device = hud_message_device{}
    @editable
    hudhoop : hud_message_device = hud_message_device{}
    @editable
    hudsprint : hud_message_device = hud_message_device{}
    @editable
    hudpassed : hud_message_device = hud_message_device{}
    @editable
    huddontmove : hud_message_device = hud_message_device{}
    @editable
    huddontsky : hud_message_device = hud_message_device{}
    @editable
    hudfailed : hud_message_device = hud_message_device{}
    @editable
    hudtricked : hud_message_device = hud_message_device{}
    @editable
    hudexplode : hud_message_device = hud_message_device{}
    @editable
    huddontmini : hud_message_device = hud_message_device{}
    @editable
    hudchair : hud_message_device = hud_message_device{}
    @editable
    huddontchair : hud_message_device = hud_message_device{}
    @editable
    itemgranter : item_granter_device = item_granter_device{}
    @editable
    itemgranter1 : item_granter_device = item_granter_device{}
    @editable
    itemgranter6 : item_granter_device = item_granter_device{}
    @editable
    gold : item_granter_device = item_granter_device{}
    @editable
    vfxx :     vfx_spawner_device =     vfx_spawner_device{}
    @editable
    beacon : beacon_device = beacon_device{}
    @editable
    timercrouch : timer_device = timer_device{}
    @editable
    timerdontmove : timer_device = timer_device{}
    @editable
    timermini : timer_device = timer_device{}
    
    @editable
    timercar : timer_device = timer_device{}
    @editable
    timersky : timer_device = timer_device{}
    @editable
    timerdontjump : timer_device = timer_device{}
    @editable
    timerexplode : timer_device = timer_device{}
    @editable
    timermedkit : timer_device = timer_device{}
    @editable
    timerinfinitysword : timer_device = timer_device{}
    @editable
    timerplatform : timer_device = timer_device{}
    @editable
    timerparkour : timer_device = timer_device{}
    @editable
    apple : conditional_button_device = conditional_button_device{}
    @editable
    timersprint : timer_device = timer_device{}
    @editable   
    timergrandma : timer_device = timer_device{}
    @editable
    timerjump : timer_device = timer_device{}
    @editable
    timerhoop : timer_device = timer_device{}
    @editable
    timeremote : timer_device = timer_device{}
    @editable
    timetillnextminigame : timer_device = timer_device{}
    @editable
    hoopdevice : nitro_hoop_device = nitro_hoop_device{}
    var jumpoff2 : logic = false
    var didexplode : logic = false
    var ranout : logic = false
    var crouchon : logic = false

    var sprinton : logic = false
    BoardText<localizes>(Value: int) : message = "Lifetime Wins: {Value}"
    @editable
    Tracker1 : tracker_device = tracker_device{}
    @editable
    billboard :  billboard_device =  billboard_device{}
    @editable
    TimerDevice:round_timer_device = round_timer_device {}
    @editable
    Scoreboard:custom_scoreboard_device = custom_scoreboard_device {}
    @editable
    mutator : mutator_zone_device = mutator_zone_device{}
    @editable
    mutator2 : mutator_zone_device = mutator_zone_device{}
    @editable
    mutator3 : mutator_zone_device = mutator_zone_device{}
    @editable
    mutator4 : mutator_zone_device = mutator_zone_device{}
    @editable
    ScoreManager:score_manager_device = score_manager_device{}
    @editable
    ScoreManager2:score_manager_device = score_manager_device{}
    ## Functions
        
    (Array:[]value where value:type).GetRandomElement()<transacts><decides>:value = 
        {
            return Array[GetRandomInt(0, Array.Length - 1)]
        }

    PlayerPassed(Player: player):void=
        if(Player.IsActive[]):
          hudpassed.Show(Player)
          ScoreManager.Activate(Player)
          field1.Activate(Player)
          passedaccolade.Award(Player)
          gold.GrantItem(Player)


    PlayerFailed(Player: player):void=
        if(Player.IsActive[]):
            hudfailed.Show(Player)
            field2.Activate(Player)

    PlayerTricked(Player: player):void=
        if(Player.IsActive[]):
            hudtricked.Show(Player)
            field2.Activate(Player)

    ChooseMinigame()<suspends>:void = 

        RandomMinigameIndex := GetRandomInt(0, Minigames.Length-1)
        AllPlayers := GetPlayspace().GetPlayers()
        for(nextplayer : AllPlayers):
            if(nextplayer.IsActive[]):
               tp.Teleport(nextplayer)
        if(RandomMinigameChooser := Minigames[RandomMinigameIndex]) {
            # RandomPOIChooser()
            case(RandomMinigameChooser):
                0=>
                   CrouchMinigame()
                1=>
                    SprintMinigame()
                2=>
                    JumpOffMinigame()
                3=>
                    CarMinigame()
                4=>
                   SkyMinigame()
                5=>
                   ExplodeMinigame()
                6=>
                 GrandmaMinigame()
                7=>
                   ParkourMinigame()
                8=>
                  EmoteMinigame()
                9=>
                  HoopMinigame()
                10=>
                  DontMoveMinigame()
                11=>
                 InfinitySword()
                12=>
                 PlatformMinigame()
                13=>
                 MiniMinigame()
                14=>
                 MedkitMinigame()
                15=>
                 DontJumpOffMinigame()
                16=>
                 SupplyDropMinigame()
                17=>
                 DontCrouchMinigame()
                18=>
                 DontCarMinigame()
                19=>
                    DontEmoteMinigame()
                20=>
                 DontSkyMinigame()
                21=>
                  DontGrandmaMinigame()
                22=>
                  DontMiniMinigame()
                23=>
                  DontPlatformMinigame()
                24=>
                 ChairMinigame()
                25=> 
                 DontChairMinigame()
                26=> 
                 PowerupMinigame()
                _=>


            if(Removes := Minigames.RemoveElement[RandomMinigameIndex]):
                set Minigames = Removes
            spawn{Scoreboard.ShowScoreboard(false)}


    
   
        }  else {

             
                  }
    GetBestPlayer(PlayersData:[]tuple(agent, int)):tuple(?agent, int)= 
        var BestPlayer : tuple(?agent, int) = (false, 0)
        for(PlayerData:PlayersData):
            if(PlayerData(1) > BestPlayer(1)):
                set BestPlayer = (option{PlayerData(0)}, PlayerData(1))
        BestPlayer
    
            
    TheEnd()<suspends>:void=
        # Fallback once array is empty
     

        set ranout = true
        Print("empty")
        TimerDevice.HideTimer(false)
        PlayerData := for(Player:GetPlayspace().GetPlayers()) do (Player, ScoreManager.GetCurrentScore(Player))
        MaybeBestPlayer := GetBestPlayer(PlayerData)
        if(BestAgent := MaybeBestPlayer(0)?):
           Sleep(2.0)
           Tracker1.Increment(BestAgent)
           playerreference.Register(BestAgent)
           Location3 := roundwinner.GetTransform().Translation + vector3{ Z:= 100000.0 }
           Rotation4 := roundwinner.GetTransform().Rotation
           if(roundwinner.TeleportTo[Location3, Rotation4]):
               Print("teleported")
           for(nextplayer :  GetPlayspace().GetPlayers()):
            if(nextplayer.IsActive[]):
               tp.Teleport(nextplayer)
           wonaccolade.Award(BestAgent)
           billboard.ShowText()
           Value := Tracker1.GetValue(BestAgent)
           billboard.SetText(BoardText(Value))
           Sleep(3.0)
           TimerDevice.AddTimer()
           set Minigames = MinigamesCopy

           spawn{OnGameStart()}
        else:
            TimerDevice.AddTimer()
            set Minigames = MinigamesCopy
 
            spawn{OnGameStart()}
      
    Start()<suspends>:void=
        loop:
                SetArrays()
                ChooseMinigame()
                if(Minigames.Length = 0):
                    TheEnd()
                    break;
                TimerDevice.StartTimer(5)
               

 
            


    

    OnPlayerEnterCar(Agent: agent):void=
        Print("player entered a car")
        if(FC := Agent.GetFortCharacter[]):
         if(FC.IsActive[]):
            FC.PutInStasis(stasis_args{AllowTurning:=true, AllowFalling := false, AllowEmotes := false})   
            Print("put in stasis")

    SetArrays():void=
        set supplydropplayers = array{}
        set pickupplayers = array{}
        set enteredplatform = array{}
        set jumpedplayers = array{}
        set crouchedplayers = array{}
        set sprintingplayers  = array{}
        set explodedplayers  = array{}
        set gaveappleplayers  = array{}
        set finishedparkour  = array{}
        set didemote  = array{}
        set didhoop  = array{}
        set didmove  = array{}
        set chairplayers  = array{}

    OnPlayerSprint(FortChar : fort_character, IsSprinting : logic):void={ 
    if(sprinton=true):   
        Print("sprint minigame")
     if(IsSprinting = true):
        Print("Is sprintingm adding to array")
       if(SprintAgent := FortChar.GetAgent[]):
        if(SprintedPlayer := player[SprintAgent]):
         if (cancelledsprintingplayers.Find[SprintedPlayer]):
            Print("cancelled sprint, already failed")
         else:
            if (sprintingplayers.Find[SprintedPlayer]):
                Print("Already in array")
            else:   
              set sprintingplayers += array{SprintedPlayer}
              Print("Registered.") 
     if(IsSprinting = false):
        if(SprintAgent := FortChar.GetAgent[]):
            if(SprintedPlayer := player[SprintAgent]):
                if (sprintingplayers.Find[SprintedPlayer]; NewArray := sprintingplayers.RemoveElement[sprintingplayers.Find[SprintedPlayer]]):
                    set sprintingplayers = NewArray
                    Print("removed from array")
                    if (cancelledsprintingplayers.Find[SprintedPlayer]):
                        Print("Already in second array")
                    else:   
                      set cancelledsprintingplayers += array{SprintedPlayer}
                      Print("added to second array")
                else:
                    Print("wasnt sprinting before, did nothing")

    
    



    } 
    InfinitySwordCheck(Agent: agent):void   =
        if(InfinityPlayer := player[Agent], not infinityswordplayer.Find[InfinityPlayer]):
           set infinityswordplayer += array{InfinityPlayer}
    CheckPickup(Agent: agent):void   =
        if(InfinityPlayer := player[Agent], not pickupplayers.Find[InfinityPlayer]):
            set pickupplayers += array{InfinityPlayer}
    InfinitySword()<suspends>:void=
        Location2 := infinity.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation := infinity.GetTransform().Rotation
        if(infinity.TeleportTo[Location2, Rotation]):
            Print("teleported")
  
        cb.Enable()
        spawn{TimerDevice.StartTimer(13 )}
        AllPlayers := GetPlayspace().GetPlayers()
         for(playerinfinitysword : AllPlayers):
           if(playerinfinitysword.IsActive[]):
            hudinfinitysword.Show(playerinfinitysword)
            timerinfinitysword.Start()
    
        timerinfinitysword.SuccessEvent.Await()
        timerinfinitysword.Reset()
        cb.ActivatedEvent.Subscribe(InfinitySwordCheck)
        for(playerinfinitysword : AllPlayers):
            if(playerinfinitysword.IsActive[]):
             cb.Activate(playerinfinitysword)
             Sleep(0.1)
             for(Player:GetPlayspace().GetPlayers(), Player.IsActive[]):
                if(infinityswordplayer.Find[Player]):   
                   PlayerPassed(Player)
                   Print("Player passed")
                if(not infinityswordplayer.Find[Player]):
                    Print("Player failed]")
                    PlayerFailed(Player)
        Location1 := infinity.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation2 := infinity.GetTransform().Rotation
        if(infinity.TeleportTo[Location1, Rotation2]):
            Print("teleported")
        for(nextplayer : AllPlayers):
            if(nextplayer.IsActive[]):
                tp.Teleport(nextplayer)
        set infinityswordplayer = array{}
    PlatformMinigame()<suspends>:void=
        mutator3.Enable()
        Location3 := platform1.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation2 := platform1.GetTransform().Rotation
        if(platform1.TeleportTo[Location3, Rotation2]):
            Print("teleported")
        spawn{TimerDevice.StartTimer(6)}
        AllPlayers := GetPlayspace().GetPlayers()
        for(playerplatform : AllPlayers):
            if(playerplatform.IsActive[]):
             itemgranter5.GrantItem(playerplatform)

             hudplatform.Show(playerplatform)
             timerplatform.Start()
        timerplatform.SuccessEvent.Await()
        timerplatform.Reset()
        for(playerplatform : AllPlayers):
            if(playerplatform.IsActive[]):
                if(enteredplatform.Find[playerplatform]):
                    PlayerPassed(playerplatform)
                else:
                    PlayerFailed(playerplatform)
                itemgranter1.GrantItem(playerplatform)

        Location2 := platform1.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation := platform1.GetTransform().Rotation
        if(platform1.TeleportTo[Location2, Rotation]):
            Print("teleported")
        mutator3.Disable()

    DontPlatformMinigame()<suspends>:void=
        mutator3.Enable()
        Location3 := platform1.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation2 := platform1.GetTransform().Rotation
        if(platform1.TeleportTo[Location3, Rotation2]):
            Print("teleported")
        spawn{TimerDevice.StartTimer(6)}
        AllPlayers := GetPlayspace().GetPlayers()
        for(playerplatform : AllPlayers):
            if(playerplatform.IsActive[]):
                itemgranter5.GrantItem(playerplatform)

                huddontplatform.Show(playerplatform)
                timerplatform.Start()
        timerplatform.SuccessEvent.Await()
        timerplatform.Reset()
        for(playerplatform : AllPlayers):
            if(playerplatform.IsActive[]):
                if(enteredplatform.Find[playerplatform]):
                    PlayerTricked(playerplatform)
                else:
                    PlayerPassed(playerplatform)
                itemgranter1.GrantItem(playerplatform)

        Location2 := platform1.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation := platform1.GetTransform().Rotation
        if(platform1.TeleportTo[Location2, Rotation]):
            Print("teleported")
        mutator3.Disable()
    DontMoveMinigame()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()
        spawn{TimerDevice.StartTimer(10)}

         for(playerdontmove : AllPlayers):
           if(playerdontmove.IsActive[]):
            huddontmove.Show(playerdontmove)
            timerdontmove.Start()
            spawn{CheckMove(playerdontmove)}
        timerdontmove.SuccessEvent.Await()
        timerdontmove.Reset()
        Sleep(0.1)
        for(playerdontmove : AllPlayers):
            if(playerdontmove.IsActive[]):
                if(didmove.Find[playerdontmove]):
                    PlayerFailed(playerdontmove)
                else:
                    PlayerPassed(playerdontmove)
    CheckMove(playerdontmove : player)<suspends>:void=
        if(FortCharacter := playerdontmove.GetFortCharacter[]):
            Sleep(0.7)
            InitialPosition:vector3 = FortCharacter.GetTransform().Translation
            timerdontmove.SuccessEvent.Await()
            NewPos:vector3 = FortCharacter.GetTransform().Translation
            if(Distance(InitialPosition, NewPos) > 1.0):
                set didmove += array{playerdontmove}
            
    MiniMinigame()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()

        spawn{TimerDevice.StartTimer(4)}
        for(playerminigame : AllPlayers):
            if(playerminigame.IsActive[]):
             hudmini.Show(playerminigame)
             itemgranter6.GrantItem(playerminigame)
             timermini.Start()
        Sleep(4.0)
      for(playerminigame : AllPlayers):
        if(FortCharacter := playerminigame.GetFortCharacter[]):
                 NewShield:float = FortCharacter.GetShield()
                 if(NewShield = 25.0):
                   Print("Player passed]")
                   PlayerPassed(playerminigame)
                 else:
                    PlayerFailed(playerminigame)
                    Print("Player failed]")
                itemgranter1.GrantItem(playerminigame)

                 FortCharacter.SetShield(0.0)
    PowerupMinigame()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()

        for(playerminigame : AllPlayers):
            if(playerminigame.IsActive[]):
                hudpickup.Show(playerminigame)
        for(powerup : powerups):
            powerup.Spawn()
        TimerDevice.StartTimer(4)
        for(powerup : powerups):
            powerup.Despawn()
        for(Player : AllPlayers):
            if(FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.SetShield(0.0)
            if(pickupplayers.Find[Player]):
                PlayerPassed(Player)
                Print("Player passed")
            else:
                 Print("Player Failed")
                 PlayerFailed(Player)
   
    DontMiniMinigame()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()

        spawn{TimerDevice.StartTimer(4)}
        for(playerminigame : AllPlayers):
            if(playerminigame.IsActive[]):
                huddontmini.Show(playerminigame)
                itemgranter6.GrantItem(playerminigame)
                timermini.Start()
        Sleep(4.0)
       for(playerminigame : AllPlayers):
        if(FortCharacter := playerminigame.GetFortCharacter[]):
            NewShield:float = FortCharacter.GetShield()
                if(NewShield = 25.0):
                        Print("Player passed]")
                        PlayerTricked(playerminigame)
                else:
                        PlayerPassed(playerminigame)
                        Print("Player failed]")
         itemgranter1.GrantItem(playerminigame)
         FortCharacter.SetShield(0.0)
              
                    

    MedkitMinigame()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()

        spawn{TimerDevice.StartTimer(9)}
        for(playerminigame : AllPlayers):
            if(playerminigame.IsActive[]):
                hudmedkit.Show(playerminigame)
                itemgranter6.GrantItem(playerminigame)
                timermedkit.Start()
            if(FortCharacter := playerminigame.GetFortCharacter[]):
                FortCharacter.SetHealth(50.0)


        Sleep(9.0)
     for(playerminigame : AllPlayers):
        if(FortCharacter := playerminigame.GetFortCharacter[]):
                    NewShield:float = FortCharacter.GetHealth()
            if(NewShield = 100.0):
                    Print("Player passed]")
                    PlayerPassed(playerminigame)
            else:
                    PlayerFailed(playerminigame)
                    Print("Player failed]")
            itemgranter1.GrantItem(playerminigame)

         FortCharacter.SetHealth(100.0)
         FortCharacter.SetShield(0.0)


    Printz(Agent: agent):void=
        Print("z")

    GrandmaMinigame()<suspends>:void=
        spawn{TimerDevice.StartTimer(8)}

        beacon.Enable()
        Location2 := houseparts.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation := houseparts.GetTransform().Rotation
        if(houseparts.TeleportTo[Location2, Rotation]):
         Print("teleported")
         AllPlayers := GetPlayspace().GetPlayers()
         for(playergrandma : AllPlayers):
           if(playergrandma.IsActive[]):
             beacon.AddToShowList(playergrandma)
             hudgrandma.Show(playergrandma)
             timergrandma.Start()
             itemgranter.GrantItem(playergrandma)
         apple.Enable()
         timergrandma.SuccessEvent.Await()
         timergrandma.Reset()
         for(Player:GetPlayspace().GetPlayers(), Player.IsActive[]):
            if(gaveappleplayers.Find[Player]):
               PlayerPassed(Player)
               Print("Player passed")
            if(not gaveappleplayers.Find[Player]):
                Print("Player Failed")
                PlayerFailed(Player)
            itemgranter1.GrantItem(Player)

        beacon.RemoveAllFromShowList()
        beacon.Disable()    
        Location1 := houseparts.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation2 := houseparts.GetTransform().Rotation
        if(houseparts.TeleportTo[Location1, Rotation2]):
            Print("teleported")
    DontGrandmaMinigame()<suspends>:void=
        spawn{TimerDevice.StartTimer(8)}

        beacon.Enable()
        Location2 := houseparts.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation := houseparts.GetTransform().Rotation
        if(houseparts.TeleportTo[Location2, Rotation]):
            Print("teleported")
        AllPlayers := GetPlayspace().GetPlayers()
        for(playergrandma : AllPlayers):
         if(playergrandma.IsActive[]):
            beacon.AddToShowList(playergrandma)
            huddontgrandma.Show(playergrandma)
            timergrandma.Start()
            itemgranter.GrantItem(playergrandma)
        apple.Enable()
        timergrandma.SuccessEvent.Await()
        timergrandma.Reset()
           for(Player:GetPlayspace().GetPlayers(), Player.IsActive[]):
            if(gaveappleplayers.Find[Player]):
                PlayerTricked(Player)
                Print("Player passed")
            if(not gaveappleplayers.Find[Player]):
                Print("Player Failed")
                PlayerPassed(Player)
            itemgranter1.GrantItem(Player)

        beacon.RemoveAllFromShowList()
        beacon.Disable()    
        Location1 := houseparts.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation2 := houseparts.GetTransform().Rotation
        if(houseparts.TeleportTo[Location1, Rotation2]):
            Print("teleported")
             
    OnPlayerCrouched(FortChar : fort_character, IsCrouching : logic):void={ 
        

    if(crouchon = true):
        if(IsCrouching = true):
            Print("Crouched")
        if(CrouchAgent := FortChar.GetAgent[]):
            if(CrouchedPlayer := player[CrouchAgent]):
                if (crouchedplayers.Find[CrouchedPlayer]):
                    Print("Already in array")
                else:   
                set crouchedplayers += array{CrouchedPlayer}
                Print("Registered.") 
    else:
        Print("crouch not on")

  
  }
    CrouchMinigame()<suspends>:void=
        spawn{TimerDevice.StartTimer(2)}
        AllPlayers := GetPlayspace().GetPlayers()
        set crouchon = true
        for(playercrouch : AllPlayers):
         if(playercrouch.IsActive[]):
            if (playercrouchz := playercrouch.GetFortCharacter[]):
                SubEvent := playercrouchz.CrouchedEvent().Subscribe(OnPlayerCrouched)
                set SubscriptionEvent = option{SubEvent}
            hudcrouch.Show(playercrouch)
            timercrouch.Start()

  
        timercrouch.SuccessEvent.Await()
        timercrouch.Reset()
        for(playercrouch : AllPlayers):
         if(playercrouch.IsActive[]):
            if (playercrouchz := playercrouch.GetFortCharacter[]):
                CancelCrouch()
            if(crouchedplayers.Find[playercrouch]):
                PlayerPassed(playercrouch)
            else:
                PlayerFailed(playercrouch)
        set crouchedplayers = array{}
        set crouchon = false
    DontCrouchMinigame()<suspends>:void=
        spawn{TimerDevice.StartTimer(2)}
        AllPlayers := GetPlayspace().GetPlayers()
        set crouchon = true
        for(playercrouch : AllPlayers):
            if(playercrouch.IsActive[]):
            if (playercrouchz := playercrouch.GetFortCharacter[]):
                SubEvent := playercrouchz.CrouchedEvent().Subscribe(OnPlayerCrouched)
                set SubscriptionEvent = option{SubEvent}
            huddontcrouch.Show(playercrouch)
            timercrouch.Start()

    
        timercrouch.SuccessEvent.Await()
        timercrouch.Reset()
        for(playercrouch : AllPlayers):
            if(playercrouch.IsActive[]):
            if (playercrouchz := playercrouch.GetFortCharacter[]):
                CancelCrouch()
            if(crouchedplayers.Find[playercrouch]):
                PlayerTricked(playercrouch)
            else:
                PlayerPassed(playercrouch)
        set crouchedplayers = array{}
        set crouchon = false

    

               
    ExplodeMinigame()<suspends>:void=
        spawn{ TimerDevice.StartTimer(20)}

        set didexplode = true
        AllPlayers := GetPlayspace().GetPlayers()
        for(playerexplode : AllPlayers):
            if(playerexplode.IsActive[]):
                hudexplode.Show(playerexplode)
                timerexplode.Start()
        for(explodes : explosives):
            Sleep(1.0)
            if(Player1 := AllPlayers[0]):
                if(Player1.IsActive[]):
                    explodes.Explode(Player1)
                    explodes.Reset()
                else:
                    if(Player2 := AllPlayers[1]):
                        explodes.Explode(Player2)
                        explodes.Reset()

        timerexplode.SuccessEvent.Await()
        timerexplode.Reset()
        for(Player:GetPlayspace().GetPlayers(), Player.IsActive[]):
            if(explodedplayers.Find[Player]):
                PlayerFailed(Player)
               Print("Player Failed"    )
            else:
                Print("Player Passed")
                PlayerPassed(Player)
        set didexplode = false

    ChairMinigame()<suspends>:void=
        Location2 := chairparts.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation := chairparts.GetTransform().Rotation
        if(chairparts.TeleportTo[Location2, Rotation]):
            Print("teleported")
        AllPlayers := GetPlayspace().GetPlayers()
        for(playerexplode : AllPlayers):
            if(playerexplode.IsActive[]):
                hudchair.Show(playerexplode)
        for(chairz : chairs):
            chairz.Enable()
        TimerDevice.StartTimer(5)

        for(Player:GetPlayspace().GetPlayers(), Player.IsActive[]):
            if(chairplayers.Find[Player]):
                PlayerPassed(Player)
                Print("Player Failed"    )
            else:
                Print("Player Passed")
                PlayerFailed(Player)
        for(chairz : chairs):
            chairz.Disable()
        Location1 := chairparts.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation2 := chairparts.GetTransform().Rotation
        if(chairparts.TeleportTo[Location1, Rotation2]):
            Print("teleported")
    DontChairMinigame()<suspends>:void=
        Location2 := chairparts.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation := chairparts.GetTransform().Rotation
        if(chairparts.TeleportTo[Location2, Rotation]):
            Print("teleported")
        set didexplode = true
        AllPlayers := GetPlayspace().GetPlayers()
        for(playerexplode : AllPlayers):
            if(playerexplode.IsActive[]):
                huddontchair.Show(playerexplode)
        for(chairz : chairs):
            chairz.Enable()
        TimerDevice.StartTimer(5)

        for(Player:GetPlayspace().GetPlayers(), Player.IsActive[]):
            if(chairplayers.Find[Player]):
                PlayerTricked(Player)
                Print("Player Failed"    )
            else:
                Print("Player Passed")
                PlayerPassed(Player)
        for(chairz : chairs):
            chairz.Disable()
        Location1 := chairparts.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation2 := chairparts.GetTransform().Rotation
        if(chairparts.TeleportTo[Location1, Rotation2]):
            Print("teleported")
    SupplyDropMinigame()<suspends>:void=
        set supplydropplayers = array{}
        AllPlayers := GetPlayspace().GetPlayers()
        for(playerexplode : AllPlayers):
            if(playerexplode.IsActive[]):
                hudsupplydrop.Show(playerexplode)
        for(supplydropz : supplydrops):
             supplydropz.Spawn()
             supplydropz.OpenedEvent.Subscribe(Opened)
       
        
        TimerDevice.StartTimer(6)
        for(Player:GetPlayspace().GetPlayers(), Player.IsActive[]):
            if(supplydropplayers.Find[Player]):
                PlayerPassed(Player)
                Print("Player Failed")
            
            else:
                Print("Player Passed")
                PlayerFailed(Player)
                
         if(Player1 := AllPlayers[0]):
            if(supplydropz := supplydrops[0]):
                supplydropz.Open(Player1)
               
    EmoteMinigame()<suspends>:void=
        spawn{ TimerDevice.StartTimer(3)}
        mutator3.Enable()
        AllPlayers := GetPlayspace().GetPlayers()
        for(playeremote : AllPlayers):
         if(playeremote.IsActive[]):
            hudemote.Show(playeremote)
            timeremote.Start()
        timeremote.SuccessEvent.Await()
        timeremote.Reset()
        for(playeremote : AllPlayers):
            if(playeremote.IsActive[]):
                if(didemote.Find[playeremote]):
                    PlayerPassed(playeremote)
                else:
                    PlayerFailed(playeremote)
        set didemote = array{}
        mutator3.Disable()
    DontEmoteMinigame()<suspends>:void=
        spawn{ TimerDevice.StartTimer(3)}
        mutator3.Enable()
        AllPlayers := GetPlayspace().GetPlayers()
        for(playeremote : AllPlayers):
            if(playeremote.IsActive[]):
            huddontemote.Show(playeremote)
            timeremote.Start()
        timeremote.SuccessEvent.Await()
        timeremote.Reset()
        for(playeremote : AllPlayers):
            if(playeremote.IsActive[]):
                if(didemote.Find[playeremote]):
                    PlayerTricked(playeremote)
                else:
                    PlayerPassed(playeremote)
        set didemote = array{}
        mutator3.Disable()
    ParkourMinigame()<suspends>:void=
        spawn{ TimerDevice.StartTimer(10)}

        mutator2.Enable()
        Location2 := parkour.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation := parkour.GetTransform().Rotation
        if(parkour.TeleportTo[Location2, Rotation]):
         Print("teleported")
        AllPlayers := GetPlayspace().GetPlayers()
        for(playerparkour : AllPlayers):
         if(playerparkour.IsActive[]):
            hudparkour.Show(playerparkour)
            timerparkour.Start()
        timerparkour.SuccessEvent.Await()
        timerparkour.Reset()
        for(playerparkour : AllPlayers):
            if(playerparkour.IsActive[]):
                if(finishedparkour.Find[playerparkour]):
                    PlayerPassed(playerparkour)
                else:
                    PlayerFailed(playerparkour)
        Location1 := parkour.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation2 := parkour.GetTransform().Rotation
        if(parkour.TeleportTo[Location1, Rotation2]):
            Print("teleported")
        mutator2.Disable()
        set finishedparkour = array{}
    HoopMinigame()<suspends>:void=
        spawn{ TimerDevice.StartTimer(5)}

        AllPlayers := GetPlayspace().GetPlayers()
        hoopdevice.Enable()
        Location2 := hoop.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation := hoop.GetTransform().Rotation
        if(hoop.TeleportTo[Location2, Rotation]):
         Print("teleported")
        for(playerhoop : AllPlayers):
           if(playerhoop.IsActive[]):
            hudhoop.Show(playerhoop)
            timerhoop.Start()
        TimerDevice.StartTimer(5)
        for(playerhoop : AllPlayers):
            if(playerhoop.IsActive[]):
                if(didhoop.Find[playerhoop]):
                    PlayerPassed(playerhoop)
                else:
                    PlayerFailed(playerhoop)
                    
        Location1 := hoop.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation2 := hoop.GetTransform().Rotation
        if(hoop.TeleportTo[Location1, Rotation2]):
            Print("teleported")
        hoopdevice.Disable()
        set didhoop = array{}
    SprintMinigame()<suspends>:void=
        spawn{ TimerDevice.StartTimer(5)}

        AllPlayers := GetPlayspace().GetPlayers()
        set sprinton = true
        for(playersprint : AllPlayers):
           if(playersprint.IsActive[]):
            if (playersprintz := playersprint.GetFortCharacter[]):
                SubEvent2 := playersprintz.SprintedEvent().Subscribe(OnPlayerSprint)
                set SubscriptionEvent2 = option{SubEvent2}
            hudsprint.Show(playersprint)
            timersprint.Start()

    
        timersprint.SuccessEvent.Await()
        timersprint.Reset()
        CancelSprint()

        for(playersprint : AllPlayers):
          if(playersprint.IsActive[]):
            if(sprintingplayers.Find[playersprint]):
                PlayerPassed(playersprint)
            else:
                PlayerFailed(playersprint)
        
        set sprintingplayers = array{}
        set cancelledsprintingplayers = array{}
        set sprinton = false

    CheckChair(Agent: agent):void=
        Print("someone entered the chair")
        if(PlatformPlayer := player[Agent]):
            if(chairplayers.Find[PlatformPlayer]):
                Print("already in array")
            else:
                set chairplayers += array{PlatformPlayer}
    CheckForJump(Agent: agent):void=
        Print("Someone jumped")
        if(jumpoff2 = true):
            if(JumpedPlayer := player[Agent], not jumpedplayers.Find[JumpedPlayer]):
                set jumpedplayers += array{JumpedPlayer}
                Print("Registered.") 
        else:
            Print("minigame jump not activated")
        if(didexplode = true):
            if(JumpedPlayer := player[Agent], not explodedplayers.Find[JumpedPlayer]):
                set explodedplayers += array{JumpedPlayer}
                Print("Registered to explosive.") 
        else:
            Print("minigame explode not activated")
    CheckForPlatform(Agent: agent):void=
        Print("someone entered the platform")
        if(PlatformPlayer := player[Agent]):
            if(enteredplatform.Find[PlatformPlayer]):
                Print("already in array")
            else:
                set enteredplatform += array{PlatformPlayer}
    CheckForParkour(Agent: agent):void=
        Print("Someone parkour")
            if(JumpedPlayer := player[Agent]):
                if (finishedparkour.Find[JumpedPlayer]):
                    Print("Already in array")
                else:   
                    set finishedparkour += array{JumpedPlayer}
                    Print("Registered.") 
    CheckForEmote(Agent: agent):void=
        Print("Someone emoted")
            if(Emoteplayer := player[Agent]):
                if (didemote.Find[Emoteplayer]):
                    Print("Already in array")
                else:   
                    set didemote += array{Emoteplayer}
                    Print("Registered.") 

    RegisterApple(Agent: agent):void=
        Print("test")
        if(GrandmaPlayer := player[Agent], not gaveappleplayers.Find[GrandmaPlayer]):
            set gaveappleplayers += array{GrandmaPlayer}
            Print("Registered to apple.") 
    Hoop(Agent: agent):void=
        Print("test")
        if(HoopPlayer := player[Agent], not didhoop.Find[HoopPlayer]):
            set didhoop += array{HoopPlayer}
            Print("Registered to hoop.") 
    JumpOffMinigame()<suspends>:void=
        spawn{  TimerDevice.StartTimer(7)}

        AllPlayers := GetPlayspace().GetPlayers()
        set jumpoff2 = true
        for(playerjump : AllPlayers):
            if(playerjump.IsActive[]):
                hudjump.Show(playerjump)
                timerjump.Start()
       houseparts.Show()
       timerjump.SuccessEvent.Await()
       timerjump.Reset()
       set jumpoff2 = false

       for(playerjump : AllPlayers):
        if(playerjump.IsActive[]):
            if(jumpedplayers.Find[playerjump]):
                PlayerPassed(playerjump)
            else:
                PlayerFailed(playerjump)
       set jumpedplayers = array{}
    DontJumpOffMinigame()<suspends>:void=
        spawn{  TimerDevice.StartTimer(7)}

        AllPlayers := GetPlayspace().GetPlayers()
        set jumpoff2 = true
        
        for(playerjump : AllPlayers):
            if(playerjump.IsActive[]):
                huddontjump .Show(playerjump)
                timerjump.Start()
        houseparts.Show()
        timerjump.SuccessEvent.Await()
        timerjump.Reset()
        set jumpoff2 = false

      for(playerjump : AllPlayers):
        if(playerjump.IsActive[]):
            if(jumpedplayers.Find[playerjump]):
                PlayerTricked(playerjump)
            else:
                PlayerPassed(playerjump)
        set jumpedplayers = array{}



    DontCarMinigame()<suspends>:void=
        spawn{TimerDevice.StartTimer(5)}

        AllPlayers := GetPlayspace().GetPlayers()
        for(sportscar : sportscars):
            sportscar.Enable()
        Print("enabling"    )
        
        for(playercar : AllPlayers):
            if(playercar.IsActive[]):
            huddontcar.Show(playercar)
            timercar.Start()
        
        timercar.SuccessEvent.Await()
        timercar.Reset()

        for(playercar : AllPlayers):
            if(playercar.IsActive[]):
                if(playercarz := playercar.GetFortCharacter[]):
                    if(playercarz.GetVehicle[]):
                        PlayerTricked(playercar)
                        playercarz.ReleaseFromStasis()
                    else:
                        PlayerPassed(playercar)

        for(sportscar : sportscars):
            sportscar.Disable()

    CarMinigame()<suspends>:void=
        spawn{TimerDevice.StartTimer(5)}

        AllPlayers := GetPlayspace().GetPlayers()
        for(sportscar : sportscars):
         sportscar.Enable()
        Print("enabling"    )
      
        for(playercar : AllPlayers):
          if(playercar.IsActive[]):
            hudcar.Show(playercar)
            timercar.Start()
        
        timercar.SuccessEvent.Await()
        timercar.Reset()

        for(playercar : AllPlayers):
            if(playercar.IsActive[]):
                if(playercarz := playercar.GetFortCharacter[]):
                    if(playercarz.GetVehicle[]):
                        PlayerPassed(playercar)
                        playercarz.ReleaseFromStasis()
                    else:
                        PlayerFailed(playercar)

        for(sportscar : sportscars):
            sportscar.Disable()
    
    SkyMinigame()<suspends>:void=
        spawn{  TimerDevice.StartTimer(2)}

        AllPlayers := GetPlayspace().GetPlayers()
        for(playersky : AllPlayers):
         if(playersky.IsActive[]):
            hudsky.Show(playersky)
            timersky.Start()

        timersky.SuccessEvent.Await()
        timersky.Reset()
        for(playersky : AllPlayers):
         if(playersky.IsActive[]):
            if(playerskyz := playersky.GetFortCharacter[]):
                if(DotProduct(playerskyz.GetViewRotation().GetLocalForward(), vector3{Z := 1.0}) > 0.3):   
                    PlayerPassed(playersky)
                else:
                    PlayerFailed(playersky)
        
  # Next()<suspends>:void=
  #     AllPlayers := GetPlayspace().GetPlayers()
  #  
  #     timetillnextminigame.Reset()
  #     timetillnextminigame.Start()
  #     Sleep(5.0)
  #     for(nextplayer : AllPlayers):
  #      if(nextplayer.IsActive[]):
  #         tp.Teleport(nextplayer)
  #     ChooseMinigame()
    
    DontSkyMinigame()<suspends>:void=
        spawn{  TimerDevice.StartTimer(2)}

        AllPlayers := GetPlayspace().GetPlayers()
      for(playersky : AllPlayers):
        if(playersky.IsActive[]):
            huddontsky.Show(playersky)
            timersky.Start()

     timersky.SuccessEvent.Await()
     timersky.Reset()
      for(playersky : AllPlayers):
        if(playersky.IsActive[]):
            if(playerskyz := playersky.GetFortCharacter[]):
                if(DotProduct(playerskyz.GetViewRotation().GetLocalForward(), vector3{Z := 1.0}) > 0.3):   
                    PlayerTricked(playersky)
                else:
                    PlayerPassed(playersky)


    Opened(Agent: agent):void=
      Print("opened")

        if(Emoteplayer := player[Agent]):
            if (supplydropplayers.Find[Emoteplayer]):
                Print("Already in array")
            else:   
                set supplydropplayers += array{Emoteplayer}
                Print("Registered.") 
    CancelCrouch():void=
     if (SubEvent := SubscriptionEvent?) :
        SubEvent.Cancel()
    
    CancelSprint():void=
        if (SubEvent := SubscriptionEvent2?):
            SubEvent.Cancel()
    OnGameStart()<suspends>:void=
        Location5 := wheel.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation6 := wheel.GetTransform().Rotation
        if(wheel.TeleportTo[Location5, Rotation6]):
            Print("teleported")
        Location7 := wheelprops.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation8 := wheelprops.GetTransform().Rotation
        if(wheelprops.TeleportTo[Location7, Rotation8]):
            Print("teleported")
        Location44:= welcome.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation22 := welcome.GetTransform().Rotation
        if(welcome.TeleportTo[Location44, Rotation22]):
            Print("teleported")
        AllPlayers := GetPlayspace().GetPlayers()
        for(playerstart : AllPlayers):
         if(playerstart.IsActive[]):
            startinginhud.Show(playerstart)
        spawn{TimerDevice.StartTimer(30)}
        Sleep(25.0)
        Location2 := wheel.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation := wheel.GetTransform().Rotation
        if(wheel.TeleportTo[Location2, Rotation]):
            Print("teleported")
        Location3 := wheelprops.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation4 := wheelprops.GetTransform().Rotation
        if(wheelprops.TeleportTo[Location3, Rotation4]):
            Print("teleported")
        Sleep(5.0)
        for(Player:GetPlayspace().GetPlayers()):
            ScoreManager2.Activate(Player)
        Location4:= welcome.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation2 := welcome.GetTransform().Rotation
        if(welcome.TeleportTo[Location4, Rotation2]):
            Print("teleported")
        Location12 := roundwinner.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation7 := roundwinner.GetTransform().Rotation
        if(roundwinner.TeleportTo[Location12, Rotation7]):
            Print("teleported")
        playerreference.Clear()
        billboard.HideText()
        vfxx.Disable()
        spawn{Start()}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void= 
            beacon.Disable()
            apple.ActivatedEvent.Subscribe(RegisterApple)
        # TODO: Replace this with your code
        spawn{OnGameStart()}
       
        mutator.AgentEntersEvent.Subscribe(CheckForJump)
        mutator2.AgentEntersEvent.Subscribe(CheckForParkour)
        mutator3.AgentBeginsEmotingEvent.Subscribe(CheckForEmote)
        mutator4.AgentEntersEvent.Subscribe(CheckForPlatform)
        hoopdevice.PlayerTriggeredEvent.Subscribe(Hoop)
        for(sportscar : sportscars):
          sportscar.AgentEntersVehicleEvent.Subscribe(OnPlayerEnterCar)
          for(chairz : chairs):
            chairz.SeatedEvent.Subscribe(CheckChair)
        for(powerup : powerups):
                powerup.ItemPickedUpEvent.Subscribe(CheckPickup)
     
        billboard.HideText()
        Location1 := billboard.GetTransform().Translation + vector3{ Z:= 100000.0 }
        Rotation2 := billboard.GetTransform().Rotation
        if(billboard.TeleportTo[Location1, Rotation2]):
            Print("teleported")
        Location4:= welcome.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation3 := welcome.GetTransform().Rotation
        if(welcome.TeleportTo[Location4, Rotation3]):
            Print("teleported")
        Location2 := wheel.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation := wheel.GetTransform().Rotation
        if(wheel.TeleportTo[Location2, Rotation]):
            Print("teleported")
        Location3 := wheelprops.GetTransform().Translation - vector3{ Z:= 100000.0 }
        Rotation4 := wheelprops.GetTransform().Rotation
        if(wheelprops.TeleportTo[Location3, Rotation4]):
            Print("teleported")