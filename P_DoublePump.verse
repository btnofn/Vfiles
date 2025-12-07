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

#THIS SCIPRT ALLOWS A PLAYER TO USE DOUBLE PUMP

#Main creative device class
P_DoublePump := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}

    TT_DoublePumpInputTrigger<localizes>:message = "Input Trigger Device Used to Track when the Player Fires\n*Required Settings*\nInput Type: Standard Action\nStandard Input: Fire\nRegistered Player Behavior: Require Registered"
    @editable{ToolTip := TT_ItemConditional} DoublePumpConditional : conditional_button_device = conditional_button_device{}                
    @editable{ToolTip := TT_ItemGranter} DoublePumpItemGranter : item_granter_device = item_granter_device{}                     
    @editable{ToolTip := TT_ItemRemover} DoublePumpItemRemover : item_remover_device = item_remover_device{}          
    @editable{ToolTip := TT_DoublePumpInputTrigger} DoublePumpInputTrigger : input_trigger_device = input_trigger_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        EquippedTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Handles the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        DoublePumpInputTrigger.Register(Agent) 
        race:
            block:
                loop:
                    MUnEquippedPlayer := UnEquippedTrigger.TriggeredEvent.Await()
                    if(UnEquippedPlayer := MUnEquippedPlayer? , UnEquippedPlayer = Agent):
                        DoublePumpInputTrigger.Unregister(Agent) 
                        break
            loop:
                Sleep(0.57)
                PressingPlayer := DoublePumpInputTrigger.PressedEvent.Await()
                if(PressingPlayer = Agent):
                    if(DoublePumpConditional.IsHoldingItem[Agent]):
                        Sleep(0.0)
                        RemoveAndGive(Agent)

    #Removes and Grants the shotgun from the player
    RemoveAndGive(Agent:agent) : void=
        DoublePumpItemRemover.Remove(Agent)                                               
        DoublePumpItemGranter.GrantItem(Agent)