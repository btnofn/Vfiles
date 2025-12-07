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

#THIS DEVICE CHANGES THE ENVIORNMENT AROUND THE PLAYER AND GRANTS A BUFF

#Main creative device class
P_ChangeRoom := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0
    @editable{ToolTip := TT_HelperFunctions} Helper : Helper_Ability = Helper_Ability{}
 
    TT_DisableBuilds<localizes>:message = "Disables builds while room is changed"
    TT_ChangeRoomBarrier<localizes>:message = "Barrier device enabled during room change\n*Required Settings*\nEnabled On Phase: None\nZone Shape: Hollow Box"
    TT_ChangeRoomVFXs<localizes>:message = "Array of VFX Spawner Devices that enable during room change\n*Required Settings*\nEnabled On Phase: None"
    TT_ChangeRoomCin<localizes>:message = "Cinemtatic Sequence Device that plays for all players at the ability activation\n*Required Settings*\nFinish Completion State Override: Force Restore State"
    TT_ChangeRoomTime<localizes>:message = "Duration the room is changed for"


    @editable{ToolTip := TT_DisableBuilds} DisableBuilds : logic = false
    @editable{ToolTip := TT_Effects} Effects : DurationEffect = DurationEffect{}
    @editable{ToolTip := TT_ChangeRoomBarrier} ChangeRoomBarrier : barrier_device = barrier_device{}
    @editable{ToolTip := TT_ChangeRoomVFXs} ChangeRoomVFXs : []vfx_spawner_device = array{}
    @editable{ToolTip := TT_ChangeRoomCin} ChangeRoomCin : cinematic_sequence_device = cinematic_sequence_device{}
    @editable{ToolTip := TT_ActivateSound} ChangeRoomSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_Explosive} ChangeRoomExplosive : explosive_device = explosive_device{}
    @editable{ToolTip := TT_ChangeRoomTime} ChangeRoomTime : float = 0.0
    @editable{ToolTip := TT_OnlyWork1v1} OnlyWork1v1 : logic = false

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent]):
            if(OnlyWork1v1?):
                if(AbilityManager.GetPlayers().Length <= 2):
                    NotOnCooldown := CP.HandleCooldown(Cooldown)
                    if(NotOnCooldown?):
                        spawn{ActivateChangeRoom(Agent)}
            else:
                NotOnCooldown := CP.HandleCooldown(Cooldown)
                if(NotOnCooldown?):
                    spawn{ActivateChangeRoom(Agent)}

    #Activates all ability devices
    ActivateChangeRoom(Agent:agent) <suspends> : void=
        ChangeRoomSound.Play(Agent)
        for(Player:AbilityManager.GetPlayers()){ChangeRoomCin.Play(Player)}
        for(VFX : ChangeRoomVFXs){VFX.Enable()}
        ChangeRoomBarrier.Enable()
        if(DisableBuilds?){spawn{Helper.DisableBuilds(ChangeRoomTime)}}
        ChangeRoomExplosive.Explode(Agent)
        ChangeRoomExplosive.Reset()
        spawn{Effects.Enable(Agent)}

        Sleep(ChangeRoomTime)

        for(VFX : ChangeRoomVFXs){VFX.Disable()}
        ChangeRoomBarrier.Disable()
        for(Player:AbilityManager.GetPlayers()){ChangeRoomCin.Play(Player)}