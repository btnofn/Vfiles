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
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

#THIS ABILITY FLOODS THE ARENA WITH WATER, BOOSTING THE EQUIPPED PLAYER WITH EFFECTS AND DAMAGING OTHER PLAYERS

#Class for different water devices that can be used by multiple players
WaterCollection := class<concrete>():
    @editable WaterDevice : water_device = water_device{}
    var IsAvailable : logic = true

#Settings to control water damage
WaterDamageSetting := class<concrete>():
    @editable Interval : float = 0.0
    @editable DamageAmount : float = 0.0

#Main creative device class
P_SummonWater := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_WaterCollections<localizes>:message = "Collection of Waters\n*Required Settings*\nCreate One Water Collection for Each Potential User of this Ability"
    TT_WaterZOffset<localizes>:message = "Z Axis Offset Applied to Water to Move Into Arena on Activation"
    TT_WaterRiseDuration<localizes>:message = "Duration of time for Water to move from its Initial Position to its New Position"
    TT_WaterIdleDuration<localizes>:message = "Duration of time for Water to remain idle in its New Position before moving back to its Initial Position"
    TT_WaterEquippedEffects<localizes>:message = "Effects applied to players with ability equipped whilst in Water"
    TT_WaterDamageSettings<localizes>:message = "Damage applied to players with ability not equipped whilst in Water"
    @editable{ToolTip := TT_WaterCollections} WaterCollections : []WaterCollection = array{}
    @editable{ToolTip := TT_ActivateSound} WaterSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_WaterZOffset} WaterZOffset : float = 0.0
    @editable{ToolTip := TT_WaterRiseDuration} WaterRiseDuration : float = 0.0
    @editable{ToolTip := TT_WaterIdleDuration} WaterIdleDuration : float = 0.0
    @editable{ToolTip := TT_WaterEquippedEffects} WaterEquippedEffects : DurationEffect = DurationEffect{}
    @editable{ToolTip := TT_WaterDamageSettings} WaterDamageSettings : ?WaterDamageSetting = false
    var EquippedAgents : []agent = array{} 


    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)
        EquippedTrigger.TriggeredEvent.Subscribe(EquipAbility)
        UnEquippedTrigger.TriggeredEvent.Subscribe(UnEquipAbility)
        for(W : WaterCollections){W.WaterDevice.AgentEntersWaterEvent.Subscribe(PreWaterEnter)}


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
                WaterSound.Play(Agent)
                var IsFound : logic = false
                var Water : WaterCollection = WaterCollection{}
                for(W : WaterCollections, not IsFound?):
                    if(W.IsAvailable?):
                        set IsFound = true
                        set Water = W
                        set W.IsAvailable = false

                Water.WaterDevice.MoveTo(Water.WaterDevice.GetTransform().Translation + vector3{Z:= WaterZOffset} , Water.WaterDevice.GetTransform().Rotation , WaterRiseDuration)
                Sleep(WaterIdleDuration)
                Water.WaterDevice.MoveTo(Water.WaterDevice.GetTransform().Translation - vector3{Z:= WaterZOffset} , Water.WaterDevice.GetTransform().Rotation , WaterRiseDuration)
                set Water.IsAvailable = true

    #Handles water entering for players
    PreWaterEnter(Agent:agent) : void = spawn{WaterEnter(Agent)}
    WaterEnter(Agent:agent)<suspends> : void=
        if(EquippedAgents.Find[Agent]):
            spawn{WaterEquippedEffects.Enable(Agent)}
        else:
            if(FC := Agent.GetFortCharacter[]):
                if(WD := WaterDamageSettings?):
                    race:
                        block:
                            Sleep((WaterRiseDuration * 2.0) + WaterIdleDuration)
                        loop:
                            if(FC.IsInWater[]):
                                FC.Damage(WD.DamageAmount)
                                Sleep(WD.Interval)
                            else:
                                break