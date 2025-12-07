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

#THIS ABILITY ALLOWS THE PLAYER TO TELEPORT IN FRONT OF THEM

#Class for each preset clone
TPInFrontTeleporter := class<concrete>():
    TT_TeleportInFrontTP<localizes>:message = "Teleporter Device Used To Teleport Instigator\n*Required Settings*\nTeleporter Group: None\nTeleporter Target Group: None"
    @editable{ToolTip := TT_TeleportInFrontTP} TeleportInFrontTP : teleporter_device = teleporter_device{}
    var IsAvailable : logic = true

#Main creative device class
P_TeleportDash := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_Teleporters<localizes>:message = "Collection of Teleporters\n*Required Settings*\nCreate One Teleporter Collection for Each Potential User of this Ability"
    TT_BoundsCornerPosition<localizes>:message = "Creative Prop Used to Define Bounds\n*Required Settings*\nPlace One Prop in Corner, then place other in complete opposite corner"
    TT_TeleportationDistance<localizes>:message = "Distance Instigator Is Teleported to In Front of Them"
    
    @editable{ToolTip := TT_Teleporters} Teleporters : []TPInFrontTeleporter = array{}
    @editable{ToolTip := TT_ActivateSound} TeleportInFrontSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_RemoteConditional} TeleportInFrontConditional : conditional_button_device = conditional_button_device{}
    @editable{ToolTip := TT_BoundsCornerPosition} BoundsCorner1Position : creative_prop = creative_prop{}
    @editable{ToolTip := TT_BoundsCornerPosition} BoundsCorner2Position : creative_prop = creative_prop{}
    @editable{ToolTip := TT_TeleportationDistance} TeleportationDistance : float = 0.0
    var PlayerTPMap : [agent]?TPInFrontTeleporter = map{}

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)
        EquippedTrigger.TriggeredEvent.Subscribe(PreEquipAbility)
        
    #Activates the ability for the player
    PreEquipAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{EquipAbility(Agent)}}
    EquipAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            var IsFound : logic = false
            var NewTP : TPInFrontTeleporter = TPInFrontTeleporter{}
            for(T : Teleporters, not IsFound?):
                if(T.IsAvailable?):
                    set IsFound = true
                    set NewTP = T
                    set T.IsAvailable = false
                    if(set PlayerTPMap[Agent] = option{T}){}
            if(IsFound?):
                race:
                    loop:
                        MUnEquippedPlayer := UnEquippedTrigger.TriggeredEvent.Await()
                        if(UnEquippedPlayer := MUnEquippedPlayer? , UnEquippedPlayer = Agent):
                            set NewTP.IsAvailable = true
                            if(NewTP.TeleportInFrontTP.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=-10000.0},NewTP.TeleportInFrontTP.GetTransform().Rotation]){}
                            if(set PlayerTPMap[Agent] = false){}
                            break
                    loop:
                        Sleep(0.0)
                        if(TeleportInFrontConditional.IsHoldingItem[Agent]):
                            PlayerRot := FC.GetTransform().Rotation
                            PlayerPos := FC.GetTransform().Translation
                            PlayerForward := FC.GetViewRotation().GetLocalForward() * TeleportationDistance
                            TrySpawnPos := PlayerPos + PlayerForward
                            NewSpawnPos := GetBoundedPosition(TrySpawnPos)
                            if(NewTP.TeleportInFrontTP.TeleportTo[NewSpawnPos,PlayerRot]){}
                        else:
                            if(NewTP.TeleportInFrontTP.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=-10000.0},NewTP.TeleportInFrontTP.GetTransform().Rotation]){}

    #Returns a position that is inside of the bounds               
    GetBoundedPosition(TrySpawnPos : vector3) : vector3=
        var FinalSpawnPos : vector3 = TrySpawnPos
        Corner1Pos := BoundsCorner1Position.GetTransform().Translation
        Corner2Pos := BoundsCorner2Position.GetTransform().Translation
        MaxVector := vector3{
            X := Max(Corner1Pos.X,Corner2Pos.X)
            Y := Max(Corner1Pos.Y,Corner2Pos.Y)
            Z := Max(Corner1Pos.Z,Corner2Pos.Z)
        }
        MinVector := vector3{
            X := Min(Corner1Pos.X,Corner2Pos.X)
            Y := Min(Corner1Pos.Y,Corner2Pos.Y)
            Z := Min(Corner1Pos.Z,Corner2Pos.Z)
        }
        if(TrySpawnPos.X >= MaxVector.X){set FinalSpawnPos.X = MaxVector.X}
        if(TrySpawnPos.X <= MinVector.X){set FinalSpawnPos.X = MinVector.X}
        if(TrySpawnPos.Y >= MaxVector.Y){set FinalSpawnPos.Y = MaxVector.Y}
        if(TrySpawnPos.Y <= MinVector.Y){set FinalSpawnPos.Y = MinVector.Y}
        if(TrySpawnPos.Z >= MaxVector.Z){set FinalSpawnPos.Z = MaxVector.Z}
        if(TrySpawnPos.Z <= MinVector.Z){set FinalSpawnPos.Z = MinVector.Z}
        return FinalSpawnPos

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
            if(NotOnCooldown?):
                if(NewTP := PlayerTPMap[Agent]?):
                    NewTP.TeleportInFrontTP.Teleport(Agent)
                    TeleportInFrontSound.Play(Agent)