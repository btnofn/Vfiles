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
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }

#THIS ABILITY PUSHES OR PULLS A PLAYER WHENEVER THEY DAMAGE ANOTHER PLAYER

#Main creative device class
P_PushPullAllWeapons := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}

    TT_PushPullDevice<localizes>:message = "Movement Modulator Device Used to apply Impulse to Target\n*Required Settings*\nAffecte Movement Speed: False\nApply Impulse : True\nApply Remote Impulse Relative To Player Direction: False"
    TT_PushOrPullOption<localizes>:message = "Controls if Target Should be Pushed Or Pulled Towards the Instigator"
    @editable{ToolTip := TT_PushPullDevice} PushPullDevice : movement_modulator_device = movement_modulator_device{}
    @editable{ToolTip := TT_PushOrPullOption} PushOrPullOption : PushOrPullType = PushOrPullType.Push
    @editable{ToolTip := TT_ActivateSound} PushPullSound : audio_player_device = audio_player_device{}
    var EquippedAgents : []agent = array{} 

    #Initializes events
    OnBegin<override>()<suspends>:void=
        EquippedTrigger.TriggeredEvent.Subscribe(EquipAbility)
        UnEquippedTrigger.TriggeredEvent.Subscribe(UnEquipAbility)
        for(Player : GetPlayspace().GetPlayers()){InitializeDamage(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitializeDamage)

    #Adjusts who this ability is equipped for when equipped
    EquipAbility(MAgent : ?agent) : void=
        if(Agent := MAgent?){set EquippedAgents += array{Agent}}
     
    #Adjusts who this ability is equipped for when unequipped
    UnEquipAbility(MAgent : ?agent) : void=
        if(Agent := MAgent?){if(NewArray := EquippedAgents.RemoveFirstElement[Agent]){set EquippedAgents = NewArray}}

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
            Amount := DamageResult.Amount
        then:
            if(EquippedAgents.Find[InstigatorAgent]):
                spawn{ActivateAbility(InstigatorAgent, TargetAgent)}

    #Activates the ability
    ActivateAbility(InstigatorAgent : agent , TargetAgent : agent)<suspends> : void=
        if:
            TargetFC := TargetAgent.GetFortCharacter[]
            InstigatorFC := InstigatorAgent.GetFortCharacter[]
        then:
            NewRotation := InstigatorFC.GetViewRotation()
            DeviceLocation := PushPullDevice.GetTransform().Translation
            if(PushOrPullOption = PushOrPullType.Push):
                if(PushPullDevice.TeleportTo[DeviceLocation,NewRotation]){}
                PushPullSound.Play(TargetAgent)
                PushPullDevice.Activate(TargetAgent)

            else if(PushOrPullOption = PushOrPullType.Pull):
                Rotation180 := NewRotation.ApplyYaw(3.14)
                if(PushPullDevice.TeleportTo[DeviceLocation,Rotation180]){}
                PushPullSound.Play(TargetAgent)
                PushPullDevice.Activate(TargetAgent)