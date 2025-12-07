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

#THIS ABILITY SUMMONS VFX AND A DAMAGE ZONE OVER THE ARENA OR AT THE PLAYERS LOCATION. THE DAMAGE ZONE CAN HEAL, DAMAGE, AND GRANTE EFFECTS OVER TIME

#Main creative device class
P_SummonCloud := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0
    var EquippedAgents : []agent = array{} 

    TT_VFXs<localizes>:message = "Array of VFX Spawner Devices that enable on activation\n*Required Settings*\nEnabled On Phase: None"
    TT_DamageMutatorZone<localizes>:message = "Mutator Zone Used To Determine What Players Should be Effected"
    TT_SpawnVFXDamLength<localizes>:message = "Duration of Ability"
    TT_ActivateOneVFXAtPlayer<localizes>:message = "If Enabled, will teleport one VFX & 'DamageMutatorZone' to instigators location on activation"
    TT_InstigatorEffectsInZone<localizes>:message = "Effects Granted to Instigator While in 'DamageMutatorZone'"
    TT_ZoneTickRate<localizes>:message = "Tickrate In Which Players Are Checked In Zone"
    TT_DamageTargetsInZone<localizes>:message = "If Enabled, will damage all non instigators for specified amount while in 'DamageMutatorZone'"
    TT_HealInstigatorInZone<localizes>:message = "If Enabled, will heal instigators for specified amount while in 'DamageMutatorZone'"

    @editable{ToolTip := TT_ActivateSound} SpawnVFXDamSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_VFXs} VFXs : []vfx_spawner_device = array{}
    @editable{ToolTip := TT_DamageMutatorZone} DamageMutatorZone : mutator_zone_device = mutator_zone_device{}
    @editable{ToolTip := TT_SpawnVFXDamLength} SpawnVFXDamLength : float = 0.0
    @editable{ToolTip := TT_ActivateOneVFXAtPlayer} ActivateOneVFXAtPlayer : logic = false
    @editable{ToolTip := TT_InstigatorEffectsInZone} InstigatorEffectsInZone : ?DurationEffect = false
    @editable{ToolTip := TT_ZoneTickRate} ZoneTickRate : float = 0.0
    @editable{ToolTip := TT_DamageTargetsInZone} DamageTargetsInZone : ?float = false
    @editable{ToolTip := TT_HealInstigatorInZone} HealInstigatorInZone : ?float = false

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)
        EquippedTrigger.TriggeredEvent.Subscribe(EquipAbility)
        UnEquippedTrigger.TriggeredEvent.Subscribe(UnEquipAbility)
        spawn{ZoneCheck()}
            
    #Adjusts who this ability is equipped for when equipped
    EquipAbility(MAgent : ?agent) : void=
        if(Agent := MAgent?){set EquippedAgents += array{Agent}}
     
    #Adjusts who this ability is equipped for when unequipped
    UnEquipAbility(MAgent : ?agent) : void=
        if(Agent := MAgent?){if(NewArray := EquippedAgents.RemoveFirstElement[Agent]){set EquippedAgents = NewArray}}
            
    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
            if(NotOnCooldown?):
                SpawnVFXDamSound.Play(Agent)
                if(ActivateOneVFXAtPlayer? , VFX1 := VFXs[0]):
                    if(VFX1.TeleportTo[FC.GetTransform().Translation,FC.GetTransform().Rotation]){VFX1.Enable()}
                    if(DamageMutatorZone.TeleportTo[FC.GetTransform().Translation,FC.GetTransform().Rotation]){DamageMutatorZone.Enable()}
                    Sleep(SpawnVFXDamLength)
                    VFX1.Disable()
                    DamageMutatorZone.Disable()
                else:
                    DamageMutatorZone.Enable()
                    for(VFX : VFXs){VFX.Enable()}
                    Sleep(SpawnVFXDamLength)
                    for(VFX : VFXs){VFX.Disable()}
                    DamageMutatorZone.Disable()

    #Handles what happens to all players in the zone
    ZoneCheck()<suspends> : void=
        loop:
            Sleep(ZoneTickRate)
            for(Player : AbilityManager.GetPlayers(),FC := Player.GetFortCharacter[]):
                if(DamageMutatorZone.IsInVolume[Player]):
                    if(EquippedAgents.Find[Player]):
                        if(Effects := InstigatorEffectsInZone?):
                            spawn{Effects.Enable(Player)}

                        if(AmountToHeal := HealInstigatorInZone?):
                            SheildAmount := FC.GetShield()
                            HealthAmount := FC.GetHealth()
                            ShieldHealAmount := (AmountToHeal - (100.0 - HealthAmount))
                            FC.Heal(AmountToHeal)
                            if(ShieldHealAmount > 0.0){FC.SetShield(SheildAmount + ShieldHealAmount)}
                    else:
                        if(AmountToDamage := DamageTargetsInZone?):
                            FC.Damage(AmountToDamage)