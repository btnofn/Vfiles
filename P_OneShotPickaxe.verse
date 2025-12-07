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

#THIS ABILITY WILL ONE SHOT OTHER PLAYERS IF EQUIPPED AND USING PICKAXE

#Main creative device class
P_OneShotPickaxe := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}

    TT_OneShotConditionals<localizes>:message = "Array of Conditional Button Device Used to Check if Player Is Holding a Weapon\n*Required Settings*\nKey Item 1: Weapon Accessible In Map\nShould Include an Element for Every Accessible Weapon In Map"
    @editable{ToolTip := TT_OneShotConditionals} OneShotConditionals : []conditional_button_device = array{}
    @editable{ToolTip := TT_ActivateSound} OneShotSound : audio_player_device = audio_player_device{}
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
        then:
            if(EquippedAgents.Find[InstigatorAgent]):
                var IsHoldingAnItem : logic = false
                for(Conditional : OneShotConditionals):
                    if(Conditional.IsHoldingItem[InstigatorAgent]){set IsHoldingAnItem = true}
                        
                if(IsHoldingAnItem = false):
                    OneShotSound.Play(InstigatorAgent)
                    Target.Damage(1000.0)