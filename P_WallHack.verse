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

#THIS ABILITY GRANTS THE EQUIPPED PLAYER WALL HACKS

#Main creative device class
P_WallHack := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_HelperFunctions} Helper : Helper_Ability = Helper_Ability{}

    TT_WallHackClassSelector<localizes>:message = "Class Selector Device Used to Switch Player to Wall Hack Class\n*Required Settings*\nClass To Switch to: Class Slot Allocated To WallHack VFX in 'Ability Helper'"
    TT_BaseClassSelector<localizes>:message = "Class Selector Device Used to Switch Player off of Wall Hack Class\n*Required Settings*\nClass To Switch to: Class Slot with General Game Settings"
    @editable{ToolTip := TT_WallHackClassSelector} WallHackClassSelector : class_and_team_selector_device = class_and_team_selector_device{}
    @editable{ToolTip := TT_BaseClassSelector} BaseClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        EquippedTrigger.TriggeredEvent.Subscribe(EquipAbility)
        UnEquippedTrigger.TriggeredEvent.Subscribe(UnEquipAbility)

    #Adjusts who this ability is equipped for when equipped
    EquipAbility(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            WallHackClassSelector.ChangeClass(Agent)
            spawn{Helper.DisableVFXForPlayer(Agent)}
    
    #Adjusts who this ability is equipped for when unequipped
    UnEquipAbility(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            BaseClassSelector.ChangeClass(Agent)
            spawn{Helper.EnableVFXForPlayer(Agent)}
