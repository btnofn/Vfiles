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

#THIS ABILITY ALLOWS A SPECIFIC WEAPON TO EXPLODE ON CONTACT WITH OTHER PLAYERS
        
#Main creative device class
P_ExplodeBuildsWeapon := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_GunSettings} GunAbilitySettings : GunAbility = GunAbility{}

    TT_ExplodeGUNExploder<localizes>:message = "Explosive device that explodes at the targets location on activation\n*Required Settings*\nCan Be Damaged: False\nStructure Damage: 5000\nVisible During Game: False\nCollision During Games: Off\nShow Health Bar: False\nTime Until Reset Allowed: 0.1"
    TT_ExplodeGUNVFX<localizes>:message = "VFX Spawner Device that enables at target's location on activation\n*Required Settings*\nEnabled On Phase: None\nClear Particles On Disable: False"
    TT_ExplodeGUNSound<localizes>:message = "Plays Sound For Target On Activation\n*Required Settings*\nPlay Location: Instigating Player"
    @editable{ToolTip := TT_ExplodeGUNExploder} ExplodeGUNExploder : explosive_device = explosive_device{}
    @editable{ToolTip := TT_ExplodeGUNVFX} ExplodeGUNVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable{ToolTip := TT_ExplodeGUNSound}ExplodeGUNSound : audio_player_device = audio_player_device{}

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
            ShouldActivate := GunAbilitySettings.Check(InstigatorAgent)
            if(ShouldActivate?):
                spawn{ActivateGunAbility(InstigatorAgent, TargetAgent)}

    #Activates the ability
    ActivateGunAbility(InstigatorAgent : agent , TargetAgent : agent)<suspends> : void=
        if:
            TargetFC := TargetAgent.GetFortCharacter[]
            InstigatorFC := InstigatorAgent.GetFortCharacter[]
        then:
            TargetPos := TargetFC.GetTransform().Translation
            if(ExplodeGUNExploder.TeleportTo[TargetPos,ExplodeGUNExploder.GetTransform().Rotation]){}
            if(ExplodeGUNVFX.TeleportTo[TargetPos,ExplodeGUNVFX.GetTransform().Rotation]){}
            ExplodeGUNSound.Play(TargetAgent)
            ExplodeGUNExploder.Explode(InstigatorAgent)
            ExplodeGUNVFX.Enable()
            Sleep(0.2)
            if(ExplodeGUNExploder.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=-10000.0},ExplodeGUNExploder.GetTransform().Rotation]){}
            if(ExplodeGUNVFX.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=-10000.0},ExplodeGUNVFX.GetTransform().Rotation]){}
            ExplodeGUNVFX.Disable()
            ExplodeGUNExploder.Reset()