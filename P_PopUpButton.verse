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
using { /Verse.org/Random }

#THIS ABILITY IS USED TO JUMP SCARE DIFFERENT PLAYERS

#Main creative device class
P_PopUpButton := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_PopUpHUD<localizes>:message = "Hud Message Device that displays a message to targets\n*Required Settings*\nMessage Recipient: Triggering Player"
    TT_PopUpSound<localizes>:message = "Plays Sound To Targets Activation\n*Required Settings*\nPlay Location: Instigating Player"
    TT_PopUpDuration<localizes>:message = "Duration of Pop Up"
    TT_ShouldFreezeDuringPopUp<localizes>:message = "Controls if Targets are Frozen During Ability"
    TT_WhoDoesItEffectSetting<localizes>:message = "Controls Who This Ability Effects"
    @editable{ToolTip := TT_PopUpHUD} PopUpHUD : hud_message_device = hud_message_device{}
    @editable{ToolTip := TT_PopUpSound} PopUpSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_PopUpDuration} PopUpDuration : float = 0.0
    @editable{ToolTip := TT_ShouldFreezeDuringPopUp} ShouldFreezeDuringPopUp : logic = false
    @editable{ToolTip := TT_WhoDoesItEffectSetting} WhoDoesItEffectSetting : OptionsEffected = OptionsEffected.ClosestPlayer

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)
        PopUpHUD.SetDisplayTime(PopUpDuration)

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
            if(NotOnCooldown?):
                var Targets : []fort_character = array{}
                for(Player : AbilityManager.GetPlayers() , EveryFC := Player.GetFortCharacter[] , not FC = EveryFC){set Targets += array{EveryFC}}

                if(WhoDoesItEffectSetting = OptionsEffected.ClosestPlayer):
                    if(Target := FindNearestTarget[FC , Targets] , TargetAgent := Target.GetAgent[]){spawn{JumpScarePlayer(TargetAgent)}}
                        
                else if(WhoDoesItEffectSetting = OptionsEffected.AllPlayers):
                    for(T : Targets , TargetAgent := T.GetAgent[]){spawn{JumpScarePlayer(TargetAgent)}}

                else if(WhoDoesItEffectSetting = OptionsEffected.RandomPlayer):
                    if(RandomTarget := Targets[GetRandomInt(0,Targets.Length-1)], TargetAgent := RandomTarget.GetAgent[]){spawn{JumpScarePlayer(TargetAgent)}}

    #Jump scares the player
    JumpScarePlayer(Agent:agent)<suspends> : void=
        PopUpHUD.Show(Agent)
        PopUpSound.Play(Agent)
        if(ShouldFreezeDuringPopUp?):
            if(FC := Agent.GetFortCharacter[]):
                FC.PutInStasis(stasis_args{})
                Sleep(PopUpDuration)
                FC.ReleaseFromStasis()