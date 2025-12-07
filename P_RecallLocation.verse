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
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

#THIS DEVICE ALLOWS THE PLAYER TO TELEPORT BACK TO A LOCATION THEY HAVE PREVIOUS BEEN IN

#Settings for setting a location on activation
SetLocationSetting := class<concrete>():
    @editable ShowTPSetHUD : hud_message_device = hud_message_device{}
    @editable SetTPSound : audio_player_device = audio_player_device{}

#Main creative device class
P_RecallLocation := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_TravelBackTP<localizes>:message = "Teleporter Device Used To Teleport Instigator\n*Required Settings*\nTeleporter Group: None\nTeleporter Target Group: None"
    TT_ShowPropAtTeleportLocation<localizes>:message = "Should a Prop Be Spawned at the Players Teleport Location\n*Required Settings*\nCollision Preset: No Collision"
    TT_SaveLocationOnFirstActivation<localizes>:message = "Should Location Be Saved When a Player Pressed Once, then Teleported Back to Location when Pressed Twice\n*Required Settings*\nChoose One Option Between: 'SaveLocationOnFirstActivation' & 'SaveLocationOnLoop'"
    TT_SaveLocationOnLoop<localizes>:message = "Should Location Be Saved Periodically on a Loop\n*Required Settings*\nChoose One Option Between: 'SaveLocationOnFirstActivation' & 'SaveLocationOnLoop'"
    @editable{ToolTip := TT_TravelBackTP} TravelBackTP : teleporter_device = teleporter_device{}
    @editable{ToolTip := TT_ActivateSound} TravelBackTPSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_ShowPropAtTeleportLocation} ShowPropAtTeleportLocation : ?creative_prop_asset = false
    @editable{ToolTip := TT_SaveLocationOnFirstActivation} SaveLocationOnFirstActivation : ?SetLocationSetting = false
    @editable{ToolTip := TT_SaveLocationOnLoop} SaveLocationOnLoop : ?float = false
    var PlayerLocationMap : [agent]?transform = map{}
    var PlayerPropMap : [agent]creative_prop = map{}

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)
        EquippedTrigger.TriggeredEvent.Subscribe(PreEquipAbility)
    
    #Activates the ability for the player
    PreEquipAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{EquipAbility(Agent)}}
    EquipAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            if(LoopInterval := SaveLocationOnLoop?):
                if(set PlayerLocationMap[Agent] = option{FC.GetTransform()}):
                    race:
                        block:
                            loop:
                                MUnEquippedPlayer := UnEquippedTrigger.TriggeredEvent.Await()
                                if(UnEquippedPlayer := MUnEquippedPlayer? , UnEquippedPlayer = Agent):
                                    if(PlayersProp := PlayerPropMap[Agent]){PlayersProp.Dispose}
                                    if(set PlayerLocationMap[Agent] = false){}
                                    break
                        loop:
                            if(PlayersProp := PlayerPropMap[Agent]){PlayersProp.Dispose()}
                            if(set PlayerLocationMap[Agent] = option{FC.GetTransform()}){}
                            if(NewAsset := ShowPropAtTeleportLocation?):
                                if(NewProp := SpawnProp(NewAsset , FC.GetTransform())(0)?):
                                    if(set PlayerPropMap[Agent] = NewProp){}
                            Sleep(LoopInterval)

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            if(SetTPSettings := SaveLocationOnFirstActivation?):
                if(SavedLocation := PlayerLocationMap[Agent]?):
                    NotOnCooldown := CP.HandleCooldown(Cooldown)
                    if(NotOnCooldown?):
                        spawn{TravelBack(Agent)}
                else:
                    SetTPSettings.SetTPSound.Play(Agent)
                    SetTPSettings.ShowTPSetHUD.Show(Agent)
                    if(set PlayerLocationMap[Agent] = option{FC.GetTransform()}){}
                    if(NewAsset := ShowPropAtTeleportLocation?):
                        if(NewProp := SpawnProp(NewAsset , FC.GetTransform())(0)?):
                            if(set PlayerPropMap[Agent] = NewProp){}
            else:
                NotOnCooldown := CP.HandleCooldown(Cooldown)
                if(NotOnCooldown?):
                    spawn{TravelBack(Agent)}

    #Travels the player back to their previous location and removes it as a saved location
    TravelBack(Agent:agent)<suspends> : void=
        if(SavedLocation := PlayerLocationMap[Agent]?):
            if(TravelBackTP.TeleportTo[SavedLocation]){}
            TravelBackTP.Teleport(Agent)
            TravelBackTPSound.Play(Agent)
            if(PlayersProp := PlayerPropMap[Agent]){PlayersProp.Dispose()}
            if(set PlayerLocationMap[Agent] = false){}