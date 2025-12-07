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

#THIS ABILITY ADDS A CUSTOM PLAYER MODEL FOR A PLAYER

#Main creative device class
P_CustomPlayerModel := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}

    TT_CustomModels<localizes>:message = "Collection of Models\n*Required Settings*\nCreate One Model for Each Potential User of this Ability"
    @editable{ToolTip := TT_CustomModels} CustomModels : []CustomModel = array{}
  
    #Initializes all events
    OnBegin<override>()<suspends>:void=
        EquippedTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Handles the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(FC:= Agent.GetFortCharacter[]):
            FC.Hide()
            var IsFound : logic = false
            var NewModel : CustomModel = CustomModel{}
            for(M : CustomModels, not IsFound?):
                if(not M.IsUsed?):
                    set IsFound = true
                    set M.IsUsed = true
                    set NewModel = M
            race:
                block:
                    loop:
                        MUnEquippedPlayer := UnEquippedTrigger.TriggeredEvent.Await()
                        if(UnEquippedPlayer := MUnEquippedPlayer? , UnEquippedPlayer = Agent):
                            FC.Show()
                            if(NewModel.ModelProp.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=-10000.0},NewModel.ModelProp.GetTransform().Rotation]){}
                            set NewModel.IsUsed = false
                            break
                block:
                    loop:
                        Sleep(0.0)
                        FC.EliminatedEvent().Await()
                        FC.Show()
                        if(NewModel.ModelProp.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=-10000.0},NewModel.ModelProp.GetTransform().Rotation]){}
                        set NewModel.IsUsed = false
                        break
                block:
                    loop:
                        Sleep(0.0)
                        if(FC.IsActive[]):
                            FC.Hide()
                            PlayerPos := FC.GetTransform().Translation
                            PlayerRot := FC.GetTransform().Rotation
                            NewModel.ModelProp.MoveTo(PlayerPos- vector3{Z:=60.0}, PlayerRot, 0.2)
                block:
                    loop:
                        Sleep(0.0)
                        IsSprintingTuple := FC.SprintedEvent().Await()
                        if (IsSprintingTuple(1)?):
                            NewModel.ModelRunningAnimationCin.Play()
                        else:
                            NewModel.ModelRunningAnimationCin.Stop()
