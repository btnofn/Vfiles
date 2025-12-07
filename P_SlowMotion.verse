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

#THIS ABILITY SLOWS DOWN TIME FOR A SPECIFIED AMOUNT OF TIME

#Main creative device class
P_SlowMotion := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_SlowMotionSequence<localizes>:message = "Cinematic Sequence Used to Start Slow Motion\n*Required Settings*\nSequence: Cinematic Sequence w/ Time Dilation Track Added at Desired Multiplier. Include Keypoints at 0.0 & 60.0\nLoop Playback: True\nFinish Completion State Override: Force Restore State"
    TT_SlowMotionMSG<localizes>:message = "Hud Message Device that displays a message to Entire Lobby\n*Required Settings*\nMessage Recipient: All"
    TT_SlowMoLength<localizes>:message = "Duration of Slow Motion Sequence"
    @editable{ToolTip := TT_SlowMotionSequence} SlowMotionSequence : cinematic_sequence_device = cinematic_sequence_device{}
    @editable{ToolTip := TT_SlowMotionMSG} SlowMotionMSG : hud_message_device = hud_message_device{}
    @editable{ToolTip := TT_SlowMoLength} SlowMoLength : float = 0.0

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)
        SlowMotionMSG.SetDisplayTime(SlowMoLength)

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
            if(NotOnCooldown?):
                SlowMotionMSG.Show()
                SlowMotionSequence.Play()
                Sleep(SlowMoLength)
                SlowMotionSequence.Stop()