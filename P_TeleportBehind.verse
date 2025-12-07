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

#THIS ABILITY TELEPORTS THE ACTIVATING PLAYER BEHIND ANOTHER PLAYER

#Main creative device class
P_TeleportBehind := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_WhoDoesItEffect<localizes>:message = "Controls How Target is Chosen"
    TT_TeleportBehindRandomTP<localizes>:message = "Teleporter Device Used To Teleport Instigator\n*Required Settings*\nTeleporter Group: None\nTeleporter Target Group: None"
    TT_FreezeInstigatorForDuration<localizes>:message = "If Enabled, freezes instigator for set duration upon teleportation"
    TT_TeleportationDistance<localizes>:message = "Distance Behind Target instigator is teleported to"
    @editable{ToolTip := TT_WhoDoesItEffect} WhoDoesItEffect : OptionsEffectedNotAll = OptionsEffectedNotAll.ClosestPlayer
    @editable{ToolTip := TT_ActivateSound} TeleportBehindRandomSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_TeleportBehindRandomTP} TeleportBehindRandomTP : teleporter_device = teleporter_device{}
    @editable{ToolTip := TT_FreezeInstigatorForDuration} FreezeInstigatorForDuration : ?float = false
    @editable{ToolTip := TT_TeleportationDistance} TeleportationDistance : float = 0.0

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
                    if(Target := FindNearestTarget[FC , Targets] , TargetAgent := Target.GetAgent[]){spawn{HandleTeleport(Agent,TargetAgent)}}

                else if(WhoDoesItEffect = OptionsEffectedNotAll.RandomPlayer):
                    if(RandomTarget := Targets[GetRandomInt(0,Targets.Length-1)], TargetAgent := RandomTarget.GetAgent[]){spawn{HandleTeleport(Agent,TargetAgent)}}

    #Handles the teleportation of the player and other devices
    HandleTeleport(Instigator : agent , Target : agent)<suspends> : void=
        if:
            TargetFC := Target.GetFortCharacter[]
            InstigatorFC := Instigator.GetFortCharacter[]
        then:
            TargetPos := TargetFC.GetTransform().Translation
            TargetRot := TargetFC.GetTransform().Rotation
            PlayerBackward := TargetRot.GetLocalForward() * (TeleportationDistance * -1.0)
            SpawnLocation := TargetPos + PlayerBackward
            if(TeleportBehindRandomTP.TeleportTo[SpawnLocation, TargetRot]):
                TeleportBehindRandomTP.Teleport(Instigator)
                TeleportBehindRandomSound.Play(Instigator)
                if(TeleportBehindRandomTP.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=-10000.0},TeleportBehindRandomTP.GetTransform().Rotation]){}
                if(Duration := FreezeInstigatorForDuration?):
                    InstigatorFC.PutInStasis(stasis_args{})
                    Sleep(Duration)
                    InstigatorFC.ReleaseFromStasis()