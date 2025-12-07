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

#THIS ABILITY ALLOWS PLAYERS TO DOUBLE JUMP

#Main Creative Device Class
P_DoubleJump := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}

    TT_ImpulseModulator<localizes>:message = "Movement Modulator Device used to apply impulse / 'double jump' to player\n*Required Settings*\nAffect Movement Speed: false\n Apply Impulse: True"
    TT_InputTrigger<localizes>:message = "Input Trigger device used to track player jumps\n*Required Settings*\nCreative Input: Jump\nRegistered Player Behavior: Require Registered"
    @editable{ToolTip := TT_ImpulseModulator} ImpulseModulator : movement_modulator_device = movement_modulator_device{}
    @editable{ToolTip := TT_InputTrigger} InputTrigger : input_trigger_device = input_trigger_device{}

    var PlayerJumpsMap : [player]int = map{}

    #Initializes all subs
    OnBegin<override>()<suspends>:void=
        EquippedTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Handles the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(Player := player[Agent], FC:= Agent.GetFortCharacter[]):
            if(set PlayerJumpsMap[Player] = 1){}
            InputTrigger.Register(Agent)
            race:
                block:
                    loop:
                        MUnEquippedPlayer := UnEquippedTrigger.TriggeredEvent.Await()
                        if(UnEquippedPlayer := MUnEquippedPlayer? , UnEquippedPlayer = Agent):
                            InputTrigger.Unregister(Agent)
                            if(NewMap := PlayerJumpsMap.WithRemovedKey(Player)?):
                                set PlayerJumpsMap = NewMap
                            break
                loop:
                    NewAgent := InputTrigger.PressedEvent.Await()
                    if(NewAgent = Agent):
                        if(FC.IsInAir[]):
                            if(PlayerJumpsMap[Player] > 0):
                                if(set PlayerJumpsMap[Player] = 0){}
                                ImpulseModulator.Activate(Agent)
                                spawn{WaitForLanding(Agent)}

    #Waits for the player to land and resets their available jumps
    WaitForLanding(Agent:agent) <suspends> : void=
        if(Player := player[Agent],PJ := PlayerJumpsMap[Player], FC := Agent.GetFortCharacter[]):
            loop:
                Sleep(0.0)
                if(FC.IsOnGround[]):
                    if(set PlayerJumpsMap[Player] = 1){}
                    break
                    