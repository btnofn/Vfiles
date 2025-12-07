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


P_HiddenArea := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_HelperFunctions} Helper : Helper_Ability = Helper_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_HiddenAreaMutatorZones<localizes>:message = "Array of Mutator Zone Devices Used To Teleport Out From Hidden Area"
    TT_HiddenAreaInitialTP<localizes>:message = "Teleporter Device Instigator is Teleported To On Activation\n*Required Settings*\nTeleporter Group: None\nTeleporter Target Group: None"
    TT_HiddenAreaDynamicTP<localizes>:message = "Teleporter Device Used To Teleport Instigator Back to Arena\n*Required Settings*\nTeleporter Group: None\nTeleporter Target Group: None"
    TT_WallHackClassSelector<localizes>:message = "Class Selector Device Used to Switch Player to Wall Hack Class\n*Required Settings*\nClass To Switch to: Class Slot Allocated To WallHack VFX in 'Ability Helper'"
    TT_BaseClassSelector<localizes>:message = "Class Selector Device Used to Switch Player off of Wall Hack Class\n*Required Settings*\nClass To Switch to: Class Slot with General Game Settings"
    TT_HiddenAreaHideSFX<localizes>:message = "Plays Sound For Instigator On Activation\n*Required Settings*\nPlay Location: Instigating Player"
    TT_HiddenAreaComeOutSFX<localizes>:message = "Plays Sound For Instigator When Leaving Hidden Area\n*Required Settings*\nPlay Location: Instigating Player"
    TT_HiddenAreaHideTimer<localizes>:message = "Timer Device used to control duration allowed in Hidden Area\n*Required Settings*\nApplies To: Player\nCompletion Behavior: Reset"
    TT_HiddenAreaComeOutOffset<localizes>:message = "Vector 3 Offset Applied to the Location of the Mutator Zone Entered To Teleport Player Back To Arena"
    TT_ShowPlayersThroughWalls<localizes>:message = "Controls Whether Instigator Can See Other Players Through Walls While in Hidden Area"
    @editable{ToolTip := TT_HiddenAreaMutatorZones} HiddenAreaMutatorZones : []mutator_zone_device = array{}
    @editable{ToolTip := TT_HiddenAreaInitialTP} HiddenAreaInitialTP : teleporter_device = teleporter_device{}
    @editable{ToolTip := TT_HiddenAreaDynamicTP} HiddenAreaDynamicTP : teleporter_device = teleporter_device{}
    @editable{ToolTip := TT_WallHackClassSelector} WallHackClassSelector : class_and_team_selector_device = class_and_team_selector_device{}
    @editable{ToolTip := TT_BaseClassSelector} BaseClassSelector : class_and_team_selector_device = class_and_team_selector_device{}
    @editable{ToolTip := TT_HiddenAreaHideSFX} HiddenAreaHideSFX: audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_HiddenAreaComeOutSFX} HiddenAreaComeOutSFX : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_HiddenAreaHideTimer} HiddenAreaHideTimer : timer_device = timer_device{}
    @editable{ToolTip := TT_HiddenAreaComeOutOffset} HiddenAreaComeOutOffset : vector3 = vector3{}
    @editable{ToolTip := TT_ShowPlayersThroughWalls} ShowPlayersThroughWalls : logic = false
    LeftEvent : event(agent) = event(agent){}
    
    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)
        for(Zone : HiddenAreaMutatorZones){Zone.AgentEntersEvent.Subscribe(TeleportUp)}


     

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
         
            if(NotOnCooldown?):
                race:
                    block:
                        loop:
                            LeavingPlayer := LeftEvent.Await()
                            if(LeavingPlayer = Agent):
                                break
                    loop:
                        StartPlayerPos := FC.GetTransform().Translation
                        StartTPPos := HiddenAreaInitialTP.GetTransform().Translation
                        HiddenAreaInitialTP.Teleport(Agent)
                        HiddenAreaHideSFX.Play(Agent)
       
                        
                        if(ShowPlayersThroughWalls?):
                            WallHackClassSelector.ChangeClass(Agent)
                            Helper.DisableVFXForPlayer(Agent)
                        HiddenAreaHideTimer.Start(Agent)
                        HiddenAreaHideTimer.SuccessEvent.Await()
                        BaseClassSelector.ChangeClass(Agent)
                        Helper.EnableVFXForPlayer(Agent)
                        if(HiddenAreaInitialTP.TeleportTo[StartPlayerPos,IdentityRotation()]){}
                        HiddenAreaInitialTP.Teleport(Agent)
                        HiddenAreaComeOutSFX.Play(Agent)
                        Sleep(0.1)
                        if(HiddenAreaInitialTP.TeleportTo[StartTPPos,IdentityRotation()]){}
                        break

    TeleportUp(Agent:agent) : void=
        if(Player:=player[Agent], FC:= Player.GetFortCharacter[]):
            PlayerPos := FC.GetTransform().Translation
            PlayerRot := FC.GetTransform().Rotation
            TeleportPos := PlayerPos + HiddenAreaComeOutOffset
            if(HiddenAreaDynamicTP.TeleportTo[TeleportPos,PlayerRot]){}

            HiddenAreaDynamicTP.Teleport(Agent)
            HiddenAreaComeOutSFX.Play(Agent)
            LeftEvent.Signal(Agent)
            HiddenAreaHideTimer.Complete(Agent)
