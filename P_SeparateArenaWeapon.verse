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
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }

#THIS ABILITY USES A WEAPON TO TELEPORT TWO PLAYERS INTO A SEPARATE ARENA, PLAYS A CINEMATIC, AND ADDS EFFECTS

#Main creative device class
P_SeparateArenaWeapon := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_GunSettings} GunAbilitySettings : GunAbility = GunAbility{}

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
    @editable{ToolTip := TT_TimeInArena} TimeInArena : float = 0.0
    @editable{ToolTip := TT_FreezePlayersForDuration} FreezePlayersForDuration : ?float = false
    @editable{ToolTip := TT_OnlyWork1v1} OnlyWorkIn1v1 : logic = false

    #Initializes damage events for all players and sets up weapon equip/unequip events
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()){InitializeDamage(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitializeDamage)
        GunAbilitySettings.Setup(EquippedTrigger , UnEquippedTrigger, AbilityManager)
          
    #Initializes damage events for a player
    InitializeDamage(Agent:agent) : void =
        if(FC := Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnPlayerDamaged)
            FC.DamagedShieldEvent().Subscribe(OnPlayerDamaged)

    #Checks to see if the ability should activate
    OnPlayerDamaged(DamageResult: damage_result): void = 
        if: 
            Instigator := DamageResult.Instigator?
            InstigatorAgent := Instigator.GetInstigatorAgent[]
            Target := fort_character[DamageResult.Target]
            TargetAgent := Target.GetAgent[]
            not TargetAgent = InstigatorAgent
        then:
            if(OnlyWorkIn1v1?):
                if(AbilityManager.GetPlayers().Length <= 2):
                    ShouldActivate := GunAbilitySettings.Check(InstigatorAgent)
                    if(ShouldActivate?):
                        spawn{ActivateGunAbility(InstigatorAgent, TargetAgent)}
            else:
                ShouldActivate := GunAbilitySettings.Check(InstigatorAgent)
                if(ShouldActivate?):
                    spawn{ActivateGunAbility(InstigatorAgent, TargetAgent)}

    #Activates the ability
    ActivateGunAbility(Instigator : agent , Target : agent)<suspends> : void=
        if:
            TargetFC := Target.GetFortCharacter[]
            InstigatorFC := Instigator.GetFortCharacter[]
        then:
            InstigatorInitTransform := InstigatorFC.GetTransform()
            TargetInitTransform := TargetFC.GetTransform()
            var InstigatorProp : creative_prop = creative_prop{}
            var TargetProp : creative_prop = creative_prop{}
            TeleportPlayersBack : event() = event(){}
            branch:
                if(Insti := InstigatorSettings?):
                    Insti.ArenaTP.Teleport(Instigator)
                    Sleep(0.1)
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
                    TargetProp.Dispose()
                    if(DynamicTP.TeleportTo[TargetInitTransform]){}
                    DynamicTP.Teleport(Target)