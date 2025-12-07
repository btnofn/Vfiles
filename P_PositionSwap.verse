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
using { /Verse.org/Random }

#THIS ABILITY SWITCHES THE POSITION OF TWO PLAYERS

#Main creative device class
P_PositionSwap := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_WhoDoesItEffectSetting<localizes>:message = "Controls Who This Ability Effects"
    TT_SwitchPosTP<localizes>:message = "Teleporter Device Used To Teleport Instigator and Target\n*Required Settings*\nTeleporter Group: None\nTeleporter Target Group: None"
    @editable{ToolTip := TT_WhoDoesItEffectSetting} WhoDoesItEffect : OptionsEffectedNotAll = OptionsEffectedNotAll.ClosestPlayer
    @editable{ToolTip := TT_ActivateSound} SwitchPosSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_SwitchPosTP} SwitchPosTP : teleporter_device = teleporter_device{}

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
            if(NotOnCooldown?):
                var Targets : []fort_character = array{}
                for(Player : AbilityManager.GetPlayers() , EveryFC := Player.GetFortCharacter[] , not FC = EveryFC){set Targets += array{EveryFC}}

                if(WhoDoesItEffect = OptionsEffectedNotAll.ClosestPlayer):
                    if(Target := FindNearestTarget[FC , Targets] , TargetAgent := Target.GetAgent[]){spawn{SwitchPositions(Agent,TargetAgent)}}

                else if(WhoDoesItEffect = OptionsEffectedNotAll.RandomPlayer):
                    if(RandomTarget := Targets[GetRandomInt(0,Targets.Length-1)], TargetAgent := RandomTarget.GetAgent[]){spawn{SwitchPositions(Agent,TargetAgent)}}

    #Switches the positions of two players
    SwitchPositions(Instigator : agent , Target : agent)<suspends> : void=
        if:
            TargetFC := Target.GetFortCharacter[]
            InstigatorFC := Instigator.GetFortCharacter[]
        then:
            InstigatorTransform := InstigatorFC.GetTransform()
            TargetTransform := TargetFC.GetTransform()
            SwitchPosSound.Play(Target)
            SwitchPosSound.Play(Instigator)
            if(SwitchPosTP.TeleportTo[InstigatorTransform]){SwitchPosTP.Teleport(Target)}
            if(SwitchPosTP.TeleportTo[TargetTransform]){SwitchPosTP.Teleport(Instigator)}
            if(SwitchPosTP.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=-10000.0},IdentityRotation()]){}