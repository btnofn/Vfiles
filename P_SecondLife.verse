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

#THIS ABILITY GRANTS A PLAYER A SECOND LIFE AFTER THEY HAVE BEEN KNOCKED

#Main creative device class
P_SecondLife := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}

    TT_SecondLifeDownDevice<localizes>:message = "Down But Not Out Device used to down and revive the player\n*Required Settings*\nDBNO Enabled: Yes\nLast Man Standing Mode: True\nSelected Class: Special Class Slot Solely Used For This Device\nInvert Class Selection: False"
    TT_SecondLifeClass<localizes>:message = "Class Selector Device Used to Switch Player to Second Life Class\n*Required Settings*\nClass To Switch to: Class Slot Allocated to the Selected Class in 'SecondLifeDownDevice'"
    TT_BaseClass<localizes>:message = "Class Selector Device Used to Switch Player off of Second Life Class\n*Required Settings*\nClass To Switch to: Class Slot with General Game Settings"
    TT_TimeUntilRevive<localizes>:message = "Time In Between Player Being Downed, and Their Revival"
    TT_SecondLifeEffects<localizes>:message = "Effects Applied to player after being Revived"
    @editable{ToolTip := TT_ActivateSound} SecondLifeSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_SecondLifeDownDevice} SecondLifeDownDevice : down_but_not_out_device = down_but_not_out_device{}
    @editable{ToolTip := TT_SecondLifeClass} SecondLifeClass : class_and_team_selector_device = class_and_team_selector_device{}
    @editable{ToolTip := TT_BaseClass} BaseClass : class_and_team_selector_device = class_and_team_selector_device{}
    @editable{ToolTip := TT_TimeUntilRevive} TimeUntilRevive : float = 1.0
    @editable{ToolTip := TT_SecondLifeEffects} SecondLifeEffects : DurationEffect = DurationEffect{}
    
    #Initializes events
    OnBegin<override>()<suspends>:void=
        EquippedTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Handles the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            SecondLifeClass.ChangeClass(Agent)
            race:
                block:
                    loop:
                        MUnEquippedPlayer := UnEquippedTrigger.TriggeredEvent.Await()
                        if(UnEquippedPlayer := MUnEquippedPlayer? , UnEquippedPlayer = Agent):
                            BaseClass.ChangeClass(Agent)
                            break
                loop:
                    Sleep(0.0)
                    if(FC.IsDownButNotOut[]):
                        spawn{SecondLifeEffects.Enable(Agent)}
                        Sleep(TimeUntilRevive)
                        SecondLifeDownDevice.Revive(Agent)
                        SecondLifeSound.Play(Agent)
                        BaseClass.ChangeClass(Agent)
                        break