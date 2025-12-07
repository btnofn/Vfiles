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
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
using { /Verse.org/Random }

#THIS ABILITY TELEPORTS TWO PLAYERS INTO A SEPARATE ARENA FOR A LIMITED TIME, PLAYS CINEMATICS, SFX, AND GRANTS EFFECTS

#Main creative device class
P_SeparateArenaButton := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_DynamicTP<localizes>:message = "Teleporter Device Used To Teleport Players\n*Required Settings*\nTeleporter Group: None\nTeleporter Target Group: None"
    TT_SeparateArenaSound<localizes>:message = "Plays Sound For Both Players On Activation\n*Required Settings*\nPlay Location: Instigating Player"
    TT_SeparateArenaCin<localizes>:message = "Cinemtatic Sequence Device that plays for players on ability activation\n*Required Settings*\nFinish Completion State Override: Force Restore State"
    TT_InstigatorSettings<localizes>:message = "Controls if Instigator Should be Teleported to Seperate Arena and How"
    TT_TargetSettings<localizes>:message = "Controls if Target Should be Teleported to Seperate Arena and How"
    TT_WhoIsTargetSetting<localizes>:message = "Controls how Target is Selected"
    TT_TimeInArena<localizes>:message = "Controls how long players can exist in separate arena before being teleported back"
    TT_FreezePlayersForDuration<localizes>:message = "If Enabled, Freezes players for duration upon teleportation"
    @editable{ToolTip := TT_DynamicTP} DynamicTP : teleporter_device = teleporter_device{}
    @editable{ToolTip := TT_SeparateArenaSound} SeparateArenaSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_SeparateArenaCin} SeparateArenaInstigatorCin : cinematic_sequence_device = cinematic_sequence_device{}
    @editable{ToolTip := TT_SeparateArenaCin} SeparateArenaTargetCin : cinematic_sequence_device = cinematic_sequence_device{}
    @editable{ToolTip := TT_InstigatorSettings} InstigatorSettings : ?ArenaActivateSetting = false
    @editable{ToolTip := TT_TargetSettings} TargetSettings : ?ArenaActivateSetting = false
    @editable{ToolTip := TT_WhoIsTargetSetting} WhoIsTargetSetting : OptionsEffectedNotAll = OptionsEffectedNotAll.ClosestPlayer
    @editable{ToolTip := TT_TimeInArena} TimeInArena : float = 0.0
    @editable{ToolTip := TT_FreezePlayersForDuration} FreezePlayersForDuration : ?float = false
    @editable{ToolTip := TT_OnlyWork1v1} OnlyWorkIn1v1 : logic = false

   #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)
            
    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            if(OnlyWorkIn1v1?):
                if(AbilityManager.GetPlayers().Length <= 2):
                    NotOnCooldown := CP.HandleCooldown(Cooldown)
                    if(NotOnCooldown?):
                        var Targets : []fort_character = array{}
                        for(Player : AbilityManager.GetPlayers() , EveryFC := Player.GetFortCharacter[] , not FC = EveryFC){set Targets += array{EveryFC}}
    
                        if(WhoIsTargetSetting = OptionsEffectedNotAll.ClosestPlayer):
                            if(Target := FindNearestTarget[FC , Targets] , TargetAgent := Target.GetAgent[]){spawn{ActivateSeparateArena(Agent,TargetAgent)}}
    
                        else if(WhoIsTargetSetting = OptionsEffectedNotAll.RandomPlayer):
                            if(RandomTarget := Targets[GetRandomInt(0,Targets.Length-1)], TargetAgent := RandomTarget.GetAgent[]){spawn{ActivateSeparateArena(Agent,TargetAgent)}}

            else:
                NotOnCooldown := CP.HandleCooldown(Cooldown)
                if(NotOnCooldown?):
                    var Targets : []fort_character = array{}
                    for(Player : AbilityManager.GetPlayers() , EveryFC := Player.GetFortCharacter[] , not FC = EveryFC){set Targets += array{EveryFC}}

                    if(WhoIsTargetSetting = OptionsEffectedNotAll.ClosestPlayer):
                        if(Target := FindNearestTarget[FC , Targets] , TargetAgent := Target.GetAgent[]){spawn{ActivateSeparateArena(Agent,TargetAgent)}}

                    else if(WhoIsTargetSetting = OptionsEffectedNotAll.RandomPlayer):
                        if(RandomTarget := Targets[GetRandomInt(0,Targets.Length-1)], TargetAgent := RandomTarget.GetAgent[]){spawn{ActivateSeparateArena(Agent,TargetAgent)}}

    #Teleports players to arena and handles different settings
    ActivateSeparateArena(Instigator : agent , Target : agent)<suspends> : void=
        if(InstigatorFC := Instigator.GetFortCharacter[] , TargetFC := Target.GetFortCharacter[]):
            InstigatorInitTransform := InstigatorFC.GetTransform()
            TargetInitTransform := TargetFC.GetTransform()
            var InstigatorProp : creative_prop = creative_prop{}
            var TargetProp : creative_prop = creative_prop{}
            TeleportPlayersBack : event() = event(){}
            if(Insti := InstigatorSettings?):
                Insti.ArenaTP.Teleport(Instigator)
                if(Duration := FreezePlayersForDuration?){spawn{FreezePlayerDuration(InstigatorFC,Duration)}}
                SeparateArenaSound.Play(Instigator)
                SeparateArenaInstigatorCin.Play(Instigator)
                spawn{Insti.Effects.Enable(Instigator)}
                if(NewAsset := Insti.LeavePropAtInitialPosition?):
                    if(NewProp := SpawnProp(NewAsset,InstigatorInitTransform)(0)?):
                        set InstigatorProp = NewProp
            if(Targ := TargetSettings?):
                Targ.ArenaTP.Teleport(Target)
                if(Duration := FreezePlayersForDuration?){spawn{FreezePlayerDuration(TargetFC,Duration)}}
                SeparateArenaSound.Play(Target)
                SeparateArenaTargetCin.Play(Target)
                spawn{Targ.Effects.Enable(Target)}
                if(NewAsset := Targ.LeavePropAtInitialPosition?):
                    if(NewProp := SpawnProp(NewAsset,TargetInitTransform)(0)?):
                        set TargetProp = NewProp
            race:
                block:
                    Sleep(TimeInArena)
                    TeleportPlayersBack.Signal()
                    Sleep(0.5)
                block:
                    loop:
                        Sleep(0.0)
                        if(Targ := TargetSettings?):
                            TargetFC.EliminatedEvent().Await()
                            TeleportPlayersBack.Signal()
                block:
                    loop:
                        Sleep(0.0)
                        if(Insti := InstigatorSettings?):
                            InstigatorFC.EliminatedEvent().Await()
                            TeleportPlayersBack.Signal()
                block:
                    TeleportPlayersBack.Await()
                    InstigatorProp.Dispose()
                    if(DynamicTP.TeleportTo[InstigatorInitTransform]){}
                    DynamicTP.Teleport(Instigator)
                    Sleep(0.1)
                    TargetProp.Dispose()
                    if(DynamicTP.TeleportTo[TargetInitTransform]){}
                    DynamicTP.Teleport(Target)
               
