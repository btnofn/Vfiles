using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
SpeedRounds := class(creative_device):

    var NumberPlayersTeam1 : int = 0
    var NumberPlayersTeam2 : int = 0
    var NumberPlayersTeam3 : int = 0
    var NumberPlayersTeam4 : int = 0
    var NumberPlayersTeam5 : int = 0
    var NumberPlayersTeam6 : int = 0
    var NumberPlayersTeam7 : int = 0
    var NumberPlayersTeam8 : int = 0
    var NumberPlayersTeam9 : int = 0
    var NumberPlayersTeam10 : int = 0
    var NumberPlayersTeam11 : int = 0
    var NumberPlayersTeam12 : int = 0
    var NumberPlayersTeam13 : int = 0
    var NumberPlayersTeam14 : int = 0
    var NumberPlayersTeam15 : int = 0

    var TeamDied1 : logic = false
    var TeamDied2 : logic = false
    var TeamDied3 : logic = false
    var TeamDied4 : logic = false
    var TeamDied5 : logic = false
    var TeamDied6 : logic = false
    var TeamDied7 : logic = false
    var TeamDied8 : logic = false
    var TeamDied9 : logic = false
    var TeamDied10 : logic = false
    var TeamDied11 : logic = false
    var TeamDied12 : logic = false
    var TeamDied13 : logic = false
    var TeamDied14 : logic = false
    var TeamDied15 : logic = false

    @editable PlayerSpawnDevices : []player_spawner_device = array{}
    @editable TeleporterStart : teleporter_device = teleporter_device{}
    @editable StartTimer : timer_device = timer_device{}

    @editable ElimManager1 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager2 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager3 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager4 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager5 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager6 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager7 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager8 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager9 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager10 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager11 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager12 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager13 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager14 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManager15 : elimination_manager_device = elimination_manager_device{}
    @editable ElimManagerAll : elimination_manager_device = elimination_manager_device{}

    @editable HudTeam1 : hud_message_device = hud_message_device{}
    @editable HudTeam2 : hud_message_device = hud_message_device{}
    @editable HudTeam3 : hud_message_device = hud_message_device{}
    @editable HudTeam4 : hud_message_device = hud_message_device{}
    @editable HudTeam5 : hud_message_device = hud_message_device{}
    @editable HudTeam6 : hud_message_device = hud_message_device{}
    @editable HudTeam7 : hud_message_device = hud_message_device{}
    @editable HudTeam8 : hud_message_device = hud_message_device{}
    @editable HudTeam9 : hud_message_device = hud_message_device{}
    @editable HudTeam10 : hud_message_device = hud_message_device{}
    @editable HudTeam11 : hud_message_device = hud_message_device{}
    @editable HudTeam12 : hud_message_device = hud_message_device{}
    @editable HudTeam13 : hud_message_device = hud_message_device{}
    @editable HudTeam14 : hud_message_device = hud_message_device{}
    @editable HudTeam15 : hud_message_device = hud_message_device{}

    OnBegin<override>()<suspends>:void=
        Print("Hello, world!")
        Print("2 + 2 = {2 + 2}")
        #StartTimer.CompletedEvent.Subscribe(UpdateNumberOfPlayers)

        ElimManager1.EliminatedEvent.Subscribe(PostElim1)
        ElimManager2.EliminatedEvent.Subscribe(PostElim2)
        ElimManager3.EliminatedEvent.Subscribe(PostElim3)
        ElimManager4.EliminatedEvent.Subscribe(PostElim4)
        ElimManager5.EliminatedEvent.Subscribe(PostElim5)
        ElimManager6.EliminatedEvent.Subscribe(PostElim6)
        ElimManager7.EliminatedEvent.Subscribe(PostElim7)
        ElimManager8.EliminatedEvent.Subscribe(PostElim8)
        ElimManager9.EliminatedEvent.Subscribe(PostElim9)
        ElimManager10.EliminatedEvent.Subscribe(PostElim10)
        ElimManager11.EliminatedEvent.Subscribe(PostElim11)
        ElimManager12.EliminatedEvent.Subscribe(PostElim12)
        ElimManager13.EliminatedEvent.Subscribe(PostElim13)
        ElimManager14.EliminatedEvent.Subscribe(PostElim14)
        ElimManager15.EliminatedEvent.Subscribe(PostElim15)
        ElimManagerAll.EliminatedEvent.Subscribe(PostElimAll)
        

        Sleep(1.0)
        for(SpawnDev : PlayerSpawnDevices):
            SpawnDev.SpawnedEvent.Subscribe(AgentRespawned)

        DisableRespawns()
        
        Sleep(0.5)
        StartTimer.SuccessEvent.Subscribe(UpdateNumberOfPlayers)

################################ ################################ ################################ ################################ ################################

    UpdateNumberOfPlayers(MaybeAgent : ?agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        set TeamDied1 = false
        set TeamDied2 = false
        set TeamDied3 = false
        set TeamDied4 = false
        set TeamDied5 = false
        set TeamDied6 = false
        set TeamDied7 = false
        set TeamDied8 = false
        set TeamDied9 = false
        set TeamDied10 = false
        set TeamDied11 = false
        set TeamDied12 = false
        set TeamDied13 = false
        set TeamDied14 = false
        set TeamDied15 = false
        loop:
            if(
                Team1 := TeamCollection.GetTeams()[0]
                Value1 := TeamCollection.GetAgents[Team1].Length
                set NumberPlayersTeam1 = Value1
                Team2 := TeamCollection.GetTeams()[1]
                Value2 := TeamCollection.GetAgents[Team2].Length
                set NumberPlayersTeam2 = Value2
                Team3 := TeamCollection.GetTeams()[2]
                Value3 := TeamCollection.GetAgents[Team3].Length
                set NumberPlayersTeam3 = Value3
                Team4 := TeamCollection.GetTeams()[3]
                Value4 := TeamCollection.GetAgents[Team4].Length
                set NumberPlayersTeam4 = Value4
                Team5 := TeamCollection.GetTeams()[4]
                Value5 := TeamCollection.GetAgents[Team5].Length
                set NumberPlayersTeam5 = Value5
                Team6 := TeamCollection.GetTeams()[5]
                Value6 := TeamCollection.GetAgents[Team6].Length
                set NumberPlayersTeam6 = Value6
                Team7 := TeamCollection.GetTeams()[6]
                Value7 := TeamCollection.GetAgents[Team7].Length
                set NumberPlayersTeam7 = Value7
                Team8 := TeamCollection.GetTeams()[7]
                Value8 := TeamCollection.GetAgents[Team8].Length
                set NumberPlayersTeam8 = Value8
                Team9 := TeamCollection.GetTeams()[8]
                Value9 := TeamCollection.GetAgents[Team9].Length
                set NumberPlayersTeam9 = Value9
                Team10 := TeamCollection.GetTeams()[9]
                Value10 := TeamCollection.GetAgents[Team10].Length
                set NumberPlayersTeam10 = Value10
                Team11 := TeamCollection.GetTeams()[10]
                Value11 := TeamCollection.GetAgents[Team11].Length
                set NumberPlayersTeam11 = Value11
                Team12 := TeamCollection.GetTeams()[11]
                Value12 := TeamCollection.GetAgents[Team12].Length
                set NumberPlayersTeam12 = Value12
                Team13 := TeamCollection.GetTeams()[12]
                Value13 := TeamCollection.GetAgents[Team13].Length
                set NumberPlayersTeam13 = Value13
                Team14 := TeamCollection.GetTeams()[13]
                Value14 := TeamCollection.GetAgents[Team14].Length
                set NumberPlayersTeam14 = Value14
                Team15 := TeamCollection.GetTeams()[14]
                Value15 := TeamCollection.GetAgents[Team15].Length
                set NumberPlayersTeam15= Value15
            ):
            Print("Players Team 1: {NumberPlayersTeam1}")
            Print("Players Team 2: {NumberPlayersTeam2}")
            Print("Players Team 3: {NumberPlayersTeam3}")
            Print("Players Team 4: {NumberPlayersTeam4}")
            Print("Players Team 5: {NumberPlayersTeam5}")
            Print("Players Team 6: {NumberPlayersTeam6}")
            Print("Players Team 7: {NumberPlayersTeam7}")
            Print("Players Team 8: {NumberPlayersTeam8}")
            Print("Players Team 9: {NumberPlayersTeam9}")
            Print("Players Team 10: {NumberPlayersTeam10}")
            Print("Players Team 11: {NumberPlayersTeam11}")
            Print("Players Team 12: {NumberPlayersTeam12}")
            Print("Players Team 13: {NumberPlayersTeam13}")
            Print("Players Team 14: {NumberPlayersTeam14}")
            Print("Players Team 15: {NumberPlayersTeam15}")
            break

 ################################ ################################ ################################ ################################ ################################

    Respawn()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers(), FortCharachter := Player.GetFortCharacter[], Agent := FortCharachter.GetAgent[]):
            Sleep(0.01)
            TeleporterStart.Teleport(Agent)

        Print("Start respawn")
        Sleep(0.1)

        for(SpawnDev : PlayerSpawnDevices):
            SpawnDev.Enable()

        for(Player : GetPlayspace().GetPlayers(), FortCharachter := not Player.GetFortCharacter[].IsActive[]): #Get agent maybe            
            Player.Respawn(vector3{X := -8658.0, Y := -22055.0, Z := 512.0}, rotation{})
            Sleep(0.01)

            if(PChar := Player.GetFortCharacter[], Agent := PChar.GetAgent[]):
                PChar.SetVulnerability(true)
                Sleep(0.01)
                PChar.Damage(damage_args{Amount := 999999999.0, Instigator := option{PChar}, Source := option{PChar}})
                Agent.Respawn(vector3{X := -8658.0, Y := -22055.0, Z := 512.0}, rotation{})
                Sleep(0.1)
                TeleporterStart.Teleport(Agent)
                Print("KILLED PLAYERS")  

    OnPlayerEliminated1(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 1: {NumberPlayersTeam1}")
        set NumberPlayersTeam1 -= 1
        Print("Player Eliminated, New Team 1: {NumberPlayersTeam1}")

        if (NumberPlayersTeam1 <= 0):
            set TeamDied1 = true

    OnPlayerEliminated2(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 2: {NumberPlayersTeam2}")
        set NumberPlayersTeam2 -= 1
        Print("Player Eliminated, New Team 2: {NumberPlayersTeam2}")
        
        if (NumberPlayersTeam2 <= 0):
            set TeamDied2 = true

    OnPlayerEliminated3(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 3: {NumberPlayersTeam3}")
        set NumberPlayersTeam3 -= 1
        Print("Player Eliminated, New Team 3: {NumberPlayersTeam3}")
        
        if (NumberPlayersTeam3 <= 0):
            set TeamDied3 = true

    OnPlayerEliminated4(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 4: {NumberPlayersTeam4}")
        set NumberPlayersTeam4 -= 1
        Print("Player Eliminated, New Team 4: {NumberPlayersTeam4}")
        
        if (NumberPlayersTeam4 <= 0):
            set TeamDied4 = true

    OnPlayerEliminated5(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 5: {NumberPlayersTeam5}")
        set NumberPlayersTeam5 -= 1
        Print("Player Eliminated, New Team 5: {NumberPlayersTeam5}")
        
        if (NumberPlayersTeam5 <= 0):
            set TeamDied5 = true

    OnPlayerEliminated6(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 6: {NumberPlayersTeam6}")
        set NumberPlayersTeam6 -= 1
        Print("Player Eliminated, New Team 6: {NumberPlayersTeam6}")
        
        if (NumberPlayersTeam6 <= 0):
            set TeamDied6 = true

    OnPlayerEliminated7(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 7: {NumberPlayersTeam7}")
        set NumberPlayersTeam7 -= 1
        Print("Player Eliminated, New Team 7: {NumberPlayersTeam7}")
        
        if (NumberPlayersTeam7 <= 0):
            set TeamDied7 = true

    OnPlayerEliminated8(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 8: {NumberPlayersTeam8}")
        set NumberPlayersTeam8 -= 1
        Print("Player Eliminated, New Team 8: {NumberPlayersTeam8}")
        
        if (NumberPlayersTeam8 <= 0):
            set TeamDied8 = true

    OnPlayerEliminated9(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 9: {NumberPlayersTeam9}")
        set NumberPlayersTeam9 -= 1
        Print("Player Eliminated, New Team 9: {NumberPlayersTeam9}")
        
        if (NumberPlayersTeam9 <= 0):
            set TeamDied9 = true

    OnPlayerEliminated10(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 10: {NumberPlayersTeam10}")
        set NumberPlayersTeam10 -= 1
        Print("Player Eliminated, New Team 10: {NumberPlayersTeam10}")
        
        if (NumberPlayersTeam10 <= 0):
            set TeamDied10 = true

    OnPlayerEliminated11(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 11: {NumberPlayersTeam11}")
        set NumberPlayersTeam11 -= 1
        Print("Player Eliminated, New Team 11: {NumberPlayersTeam11}")
        
        if (NumberPlayersTeam11 <= 0):
            set TeamDied11 = true

    OnPlayerEliminated12(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 12: {NumberPlayersTeam12}")
        set NumberPlayersTeam12 -= 1
        Print("Player Eliminated, New Team 12: {NumberPlayersTeam12}")
        
        if (NumberPlayersTeam12 <= 0):
            set TeamDied12 = true

    OnPlayerEliminated13(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 13: {NumberPlayersTeam13}")
        set NumberPlayersTeam13 -= 1
        Print("Player Eliminated, New Team 13: {NumberPlayersTeam13}")
        
        if (NumberPlayersTeam13 <= 0):
            set TeamDied13 = true

    OnPlayerEliminated14(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 14: {NumberPlayersTeam14}")
        set NumberPlayersTeam14 -= 1
        Print("Player Eliminated, New Team 14: {NumberPlayersTeam14}")
        
        if (NumberPlayersTeam14 <= 0):
            set TeamDied14 = true

    
    OnPlayerEliminated15(ElimAgent : agent)<suspends>:void=
        Print("Player Eliminated, Pre Team 15: {NumberPlayersTeam15}")
        set NumberPlayersTeam15 -= 1
        Print("Player Eliminated, New Team 15: {NumberPlayersTeam15}")
        
        if (NumberPlayersTeam15 <= 0):
            set TeamDied15 = true

    
  
    OnPlayerEliminatedAll(ElimAgent : agent)<suspends>:void=
        Print("Players Team 1: {NumberPlayersTeam1}")
        Print("Players Team 2: {NumberPlayersTeam2}")
        Print("Players Team 3: {NumberPlayersTeam3}")
        Print("Players Team 4: {NumberPlayersTeam4}")
        Print("Players Team 5: {NumberPlayersTeam5}")
        Print("Players Team 6: {NumberPlayersTeam6}")
        Print("Players Team 7: {NumberPlayersTeam7}")
        Print("Players Team 8: {NumberPlayersTeam8}")
        Print("Players Team 9: {NumberPlayersTeam9}")
        Print("Players Team 10: {NumberPlayersTeam10}")
        Print("Players Team 11: {NumberPlayersTeam11}")
        Print("Players Team 12: {NumberPlayersTeam12}")
        Print("Players Team 13: {NumberPlayersTeam13}")
        Print("Players Team 14: {NumberPlayersTeam14}")
        Print("Players Team 15: {NumberPlayersTeam15}")

        Sleep(0.1)

        if (NumberPlayersTeam1 > 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            #Hud Msg device saying team 1 won the game, etc...
            HudTeam1.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 > 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam2.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 > 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam3.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 > 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam4.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 > 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam5.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 > 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam6.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 > 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam7.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 > 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam8.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 > 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam9.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 > 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam10.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 > 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam11.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 > 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam12.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 > 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 = 0):
            HudTeam13.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 > 0 and NumberPlayersTeam15 = 0):
            HudTeam14.Show()
            Sleep(3.0)
            Respawn()
            
        else if (NumberPlayersTeam1 = 0 and NumberPlayersTeam2 = 0 and NumberPlayersTeam3 = 0 and NumberPlayersTeam4 = 0 and NumberPlayersTeam5 = 0 and NumberPlayersTeam6 = 0 and NumberPlayersTeam7 = 0 and NumberPlayersTeam8 = 0 and NumberPlayersTeam9 = 0 and NumberPlayersTeam10 = 0 and NumberPlayersTeam11 = 0 and NumberPlayersTeam12 = 0 and NumberPlayersTeam13 = 0 and NumberPlayersTeam14 = 0 and NumberPlayersTeam15 > 0):
            HudTeam15.Show()
            Sleep(3.0)
            Respawn()
            
        
        






    PostElim1<public>(Agent : agent):void=
        spawn{OnPlayerEliminated1(Agent)}

    PostElim2<public>(Agent : agent):void=
        spawn{OnPlayerEliminated2(Agent)}

    PostElim3<public>(Agent : agent):void=
        spawn{OnPlayerEliminated3(Agent)}
    
    PostElim4<public>(Agent : agent):void=
        spawn{OnPlayerEliminated4(Agent)}

    PostElim5<public>(Agent : agent):void=
        spawn{OnPlayerEliminated5(Agent)}

    PostElim6<public>(Agent : agent):void=
        spawn{OnPlayerEliminated6(Agent)}

    PostElim7<public>(Agent : agent):void=
        spawn{OnPlayerEliminated7(Agent)}

    PostElim8<public>(Agent : agent):void=
        spawn{OnPlayerEliminated8(Agent)}

    PostElim9<public>(Agent : agent):void=
        spawn{OnPlayerEliminated9(Agent)}

    PostElim10<public>(Agent : agent):void=
        spawn{OnPlayerEliminated10(Agent)}

    PostElim11<public>(Agent : agent):void=
        spawn{OnPlayerEliminated11(Agent)}

    PostElim12<public>(Agent : agent):void=
        spawn{OnPlayerEliminated12(Agent)}

    PostElim13<public>(Agent : agent):void=
        spawn{OnPlayerEliminated13(Agent)}

    PostElim14<public>(Agent : agent):void=
        spawn{OnPlayerEliminated14(Agent)}

    PostElim15<public>(Agent : agent):void=
        spawn{OnPlayerEliminated15(Agent)}

    PostElimAll<public>(Agent : agent):void=
        spawn{OnPlayerEliminatedAll(Agent)}

    AgentRespawned(Agent : agent):void=
        var bCanDisableSpawnPads : logic = true
        for(Player : GetPlayspace().GetPlayers(), not Player.GetFortCharacter[].IsActive[]):
            set bCanDisableSpawnPads = false

        if(bCanDisableSpawnPads?):
            DisableRespawns()
    
    DisableRespawns<public>():void=
        for(SpawnDev : PlayerSpawnDevices):
            SpawnDev.Disable()