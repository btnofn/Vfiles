<#
====================================================================================================
Copyright (c) 2024 MapAcademy. All rights reserved.

 

This software and its associated documentation files (the "Software") are the

proprietary property of MapAcademy and are protected by copyright law.

 

The Software is provided to you under the terms of the MapAcademy End User

License Agreement (the "License"). You may use, copy, distribute, and modify

the Software solely in accordance with the terms of the License.

 

BY USING THE SOFTWARE, YOU AGREE TO BE BOUND BY THE TERMS OF THE LICENSE.

IF YOU DO NOT AGREE TO THE TERMS OF THE LICENSE, DO NOT USE THE SOFTWARE.

 

The Software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND,

either express or implied, including without limitation any warranties of

MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, or NON-INFRINGEMENT.

For more details, please refer to the MapAcademy End User License Agreement.
====================================================================================================
#>
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath}
using { /Verse.org/Assets }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

#Class for spawners used to teleport players to specific locations
CustomSpawner := class<concrete>():
    @editable LocationProp : creative_prop = creative_prop{}
    var IsAvailable : logic = true

    #Checks to see if the spawner is available and teleports the teleporter if it is
    TrySpawn(TP : teleporter_device) : logic =
        if(IsAvailable?):
            RespawnPos := LocationProp.GetTransform().Translation
            RespawnRot := LocationProp.GetTransform().Rotation
            if(TP.TeleportTo[RespawnPos,RespawnRot]){}
            spawn{Reset()}
            return true
        else:
            return false

    #Resets the Spawner after 3 seconds
    Reset()<suspends> : void=
        set IsAvailable = false
        Sleep(3.0)
        set IsAvailable = true

#Settings to determine how winners are showcased
WinSetting := class<concrete>():
    @editable Duration : float = 0.0
    @editable Cinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable Teleporter : teleporter_device = teleporter_device{}
    @editable WinnerHUD : hud_message_device = hud_message_device{}
    @editable WinnerDisplayNameBB : billboard_device = billboard_device{}
    @editable FreezePlayers : FreezeTypes = FreezeTypes.NoFreeze
    @editable WinnerTrigger : trigger_device = trigger_device{}

#Different types of freezing a player
FreezeTypes := enum:
    NoFreeze
    FullFreeze
    AllowDancing

#Main Creative Device class
Manager_BoxPvP := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable TestAbility : ?int = false
    @editable SpawnerTP : teleporter_device = teleporter_device{}
    @editable LobbySpawners : []CustomSpawner = array{}
    @editable BoxPvPSpawners : []CustomSpawner = array{}
    var CurrentSpawners : []CustomSpawner = array{}
    @editable SpawnBarriers : []barrier_device = array{}
    @editable PreRoundTimer : timer_device = timer_device{}
    @editable LobbyTimer : timer_device = timer_device{}
    @editable ArenaStormController : basic_storm_controller_device = basic_storm_controller_device{}
    @editable ExtraStormControllers : []basic_storm_controller_device = array{}
    @editable ClearBoxExplosives : []explosive_device = array{}
    @editable ClearItemsMutator : mutator_zone_device = mutator_zone_device{}
    @editable RoundsUntilFullReset : int = 0
    @editable RoundEnder : round_settings_device = round_settings_device{}
    @editable WinSettings : WinSetting = WinSetting{}
    var CurrentRoundCount : int = 0
    RoundEndedEvent : event() = event(){}

    var LastEliminated : ?agent = false
    
    

    #Initializes players and initial round setup
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()){InitiatePlayer(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitiatePlayer)
        LobbyTimer.Start()
        LobbyTimer.SuccessEvent.Await()
        spawn{RoundSetup()}
        spawn{SpectatorUIChange()}
 
    #Tracks when players are eliminated
    InitiatePlayer(Agent:agent) : void=
        if(FC := Agent.GetFortCharacter[]){FC.EliminatedEvent().Subscribe(OnEliminated)}

    #Teleports players to lobby once eliminated and removes them from current players array
    OnEliminated(Result : elimination_result) : void=
        if(FC := Result.EliminatedCharacter, Agent := FC.GetAgent[] , Player := player[Agent] , CP := AbilityManager.PlayersMap[Agent]):



            CP.EquippedPower.PowerUnEquipTrigger.Trigger(Agent)
            CP.ResetCooldown()

            if(NewEffectedPlayers := AbilityManager.EffectedPlayers.RemoveFirstElement[Player]):
                set AbilityManager.EffectedPlayers = NewEffectedPlayers


            spawn{RespawnPlayer(Agent)}

    RespawnPlayer(Agent : agent)<suspends> : void=
        if(not AbilityManager.EffectedPlayers.Length = 1):
            Agent.Respawn(vector3{}, IdentityRotation())
            var HasFound : logic = false
            for(S : CurrentSpawners , not HasFound?):
                IsFound := S.TrySpawn(SpawnerTP)
                set HasFound = IsFound

           
    #Sets up to start a round
    RoundSetup()<suspends> : void=
        ArenaStormController.GenerateStorm()
        spawn{ResetExtraStorms()}
        set CurrentSpawners = BoxPvPSpawners
        spawn{SpawnAllPlayers()}
        spawn{AssignAbilities()}
        spawn{StartRound()}

    #Plays all extra storm controllers on a slight delay
    ResetExtraStorms()<suspends> : void=
        for(S : ExtraStormControllers){S.DestroyStorm()}
        Sleep(3.0)
        for(S : ExtraStormControllers){S.GenerateStorm()}
        

    #Resets everything
    Reset()<suspends> : void=
        ArenaStormController.DestroyStorm()
        for(S : SpawnBarriers){S.Enable()}
        if(Player1 := GetPlayspace().GetPlayers()[0]):
            for(E : ClearBoxExplosives){E.Explode(Player1)}

        for(Player : GetPlayspace().GetPlayers(),FC:=Player.GetFortCharacter[] , CP := AbilityManager.PlayersMap[Player]):
            FC.SetVulnerability(true)
            FC.Show()
            CP.EquippedPower.PowerUnEquipTrigger.Trigger(Player)
            
        ClearItemsMutator.Enable()
        Sleep(0.2)
        ClearItemsMutator.Disable()
        for(E : ClearBoxExplosives){E.Reset()}

    #Spawns all players to the current spawners
    SpawnAllPlayers()<suspends> : void=
        for(Player : GetPlayspace().GetPlayers()):
            Sleep(0.0)
            var HasFound : logic = false
            for(S : CurrentSpawners , not HasFound?):
                IsFound := S.TrySpawn(SpawnerTP)
                if(IsFound?):
                    SpawnerTP.Teleport(Player)
                    set HasFound = IsFound

    #Assigns random abilities to all players and adds them to the current players array
    AssignAbilities()<suspends> : void=
        var NewPowers : []Power = AbilityManager.AllPowers
        for(Player : GetPlayspace().GetPlayers(), FC:= Player.GetFortCharacter[]):
            FC.Heal(500.0)
            if(AbilityToTest := TestAbility?):
                if(SelectedPower := NewPowers[AbilityToTest]):
                    SelectedPower.PowerEquipTrigger.Trigger(Player)
            else:
                RandomPower := GetRandomInt(0 , NewPowers.Length-1)
                if(SelectedPower := NewPowers[RandomPower]):
                    SelectedPower.PowerEquipTrigger.Trigger(Player)
                    if(NewPowerArray := NewPowers.RemoveElement[RandomPower]){set NewPowers = NewPowerArray}

        set AbilityManager.EffectedPlayers = array{}
        for(Player : GetPlayspace().GetPlayers()){set AbilityManager.EffectedPlayers += array{Player}}

    #Starts the round
    StartRound()<suspends> : void=
        PreRoundTimer.Start()
        PreRoundTimer.SuccessEvent.Await()
        set CurrentRoundCount += 1
        for(Barrier : SpawnBarriers){Barrier.Disable()}
        set AbilityManager.AllowAbilityActivation = true
        set CurrentSpawners = LobbySpawners
        spawn{RoundCheck()}

    #Checks for remaining players
    RoundCheck()<suspends> : void=
        loop:
            Sleep(0.5)
            if(AbilityManager.EffectedPlayers.Length <= 1):
                var WinningPlayer : ?agent = false
                if(PlayerWhoWon := AbilityManager.EffectedPlayers[0]){set WinningPlayer = option{PlayerWhoWon}}
                spawn{EndRound(WinningPlayer)}
                break

    #Ends the current round
    EndRound(MaybeWinner : ?agent)<suspends> : void=
        RoundEndedEvent.Signal()
        if(CurrentRoundCount >= RoundsUntilFullReset):
            if(Player := GetPlayspace().GetPlayers()[0]):
                RoundEnder.EndRound(Player)
        else:
            set AbilityManager.AllowAbilityActivation = false
            if(Winner := MaybeWinner?){HandleWin(Winner)}
            set CurrentSpawners = LobbySpawners
            spawn{SpawnAllPlayers()}
            spawn{Reset()}
            LobbyTimer.Start()
            LobbyTimer.SuccessEvent.Await()
            spawn{RoundSetup()}
    BBAgentToMessage<localizes>(Agent : agent) : message = "{Agent}"

    #Handles what happens for the winning player
    HandleWin(Agent:agent)<suspends> : void=
        WinSettings.WinnerTrigger.Trigger(Agent)
        WinSettings.Teleporter.Teleport(Agent)

        WinSettings.Cinematic.Play()

        if(WinCP := AbilityManager.PlayersMap[Agent]):
            WinCP.ResetCooldown()

        for(Player : GetPlayspace().GetPlayers() , FC := Player.GetFortCharacter[]):
            FC.Heal(500.0)
            if(WinSettings.FreezePlayers = FreezeTypes.FullFreeze):
                FC.PutInStasis(stasis_args{})
            else if(WinSettings.FreezePlayers = FreezeTypes.AllowDancing):
                FC.PutInStasis(stasis_args{AllowTurning := false, AllowFalling := false , AllowEmotes := true})
        WinSettings.WinnerHUD.Show()
        WinSettings.WinnerDisplayNameBB.SetText(BBAgentToMessage(Agent))
        Sleep(WinSettings.Duration)
        WinSettings.Cinematic.Stop()
        for(Player : GetPlayspace().GetPlayers() , FC := Player.GetFortCharacter[]):
            FC.ReleaseFromStasis()

        # Sleep(0.5)
        # WinSettings.Cinematic.Play()
        # Sleep(0.2)
        # WinSettings.Cinematic.Stop()
        # # if(LE := LastEliminated?):
        # #     WinSettings.Cinematic.Stop(LE)

    #Changes Spectators UIs to the players UI who they are spectating
    SpectatorUIChange()<suspends> : void=
        loop:
            Sleep(1.0)
            for(Player : GetPlayspace().GetPlayers(),FC:=Player.GetFortCharacter[]):
                if(FC.IsActive[]):   
                    if(PlayersClass := AbilityManager.PlayersMap[Player].EquippedPower):  
                        SpectatingPlayers := Player.GetPlayersSpectating() 
                        for(Spectator : SpectatingPlayers): 
                            PlayersClass.PowerHUD.Show(Spectator) 