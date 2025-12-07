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

#THIS ABLIITY SPAWNS CLONES AROUND THE ARENA OR AT THE PLAYERS LOCATION

#Class for each preset clone
Clone := class<concrete>():
    @editable PlayerReference : player_reference_device = player_reference_device{}
    var IsAvailable : logic = true

P_SummonClones := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_ClonePlayerRefs<localizes>:message = "Collection of Cages\n*Required Settings*\nCreate One Projectile for Each Potential User of this Ability"
    TT_CloneTimeDuration<localizes>:message = "Duration the Clones Appear For"
    TT_SummonCageTargetEffect<localizes>:message = "Effects Applied to Target on Activation"
    TT_SpawnOneClone<localizes>:message = "If Enabled, only one clone will spawn, and will be teleported to the Instigators Location"
    TT_CloneZOffset<localizes>:message = "Z axis Offset added to clone when teleported to Instigator if 'SpawnOneClone' is enabled"
    TT_NoClonesAvailableHUD<localizes>:message = "Hud Message Device that displays a message to a instigator if there are no clones currently available to use\n*Required Settings*\nMessage Recipient: Triggering Player"
    @editable{ToolTip := TT_ClonePlayerRefs} ClonePlayerRefs : []Clone = array{}
    @editable{ToolTip := TT_ActivateSound} SpawnClonesSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_CloneTimeDuration} CloneTime : float = 0.0
    @editable{ToolTip := TT_SpawnOneClone} SpawnOneClone : logic = false
    @editable{ToolTip := TT_CloneZOffset} CloneZOffset : float = 0.0
    @editable{ToolTip := TT_NoClonesAvailableHUD} NoClonesAvailableHUD : hud_message_device = hud_message_device{}

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
            if(NotOnCooldown?):
                SpawnClonesSound.Play(Agent)
                if(SpawnOneClone?):
                    var IsFound : logic = false
                    var NewClone : Clone = Clone{}
                    for(C : ClonePlayerRefs, not IsFound?):
                        if(C.IsAvailable?):
                            set IsFound = true
                            set NewClone = C
                            set C.IsAvailable = false
                    if(IsFound?):
                        if(NewClone.PlayerReference.TeleportTo[FC.GetTransform().Translation + vector3{Z:=CloneZOffset} , FC.GetTransform().Rotation]):
                            NewClone.PlayerReference.Register(Agent)
                            Sleep(CloneTime)
                            NewClone.PlayerReference.Clear()
                            set NewClone.IsAvailable = true
                    else:
                        NoClonesAvailableHUD.Show(Agent)

                else:
                    var NewClones : []Clone = array{}
                    for(Ref : ClonePlayerRefs):
                        if(Ref.IsAvailable?):
                            set NewClones += array{Ref}
                    if(NewClones.Length > 0):
                        for(Ref : NewClones):
                            set Ref.IsAvailable = false
                            Ref.PlayerReference.Register(Agent)
                        Sleep(CloneTime)
                        for(Ref:NewClones):
                            set Ref.IsAvailable = true
                            Ref.PlayerReference.Clear()
                    else:
                        NoClonesAvailableHUD.Show(Agent)