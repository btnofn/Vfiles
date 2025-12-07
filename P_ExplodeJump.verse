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

#THIS ABILITY EXPLODES AND PLAYS SFX & VFX AROUND A PLAYER WHENEVER THEY JUMP

#Main creative device class
P_ExplodeJump := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}

    TT_JumpToBreakExplosive<localizes>:message = "Explosive device that explodes at the instigator's location on activation\n*Required Settings*\nCan Be Damaged: False\nStructure Damage: 5000\nVisible During Game: False\nCollision During Games: Off\nShow Health Bar: False\nTime Until Reset Allowed: 0.1"
    TT_JumpToBreakVFX<localizes>:message = "VFX Spawner Device that enables at instigator's location on activation\n*Required Settings*\nEnabled On Phase: None\nClear Particles On Disable: False"
    TT_JumpToBreakSound<localizes>:message = "Plays Sound For Instigator On Activation\n*Required Settings*\nPlay Location: Instigating Player"
    @editable{ToolTip := TT_JumpToBreakExplosive} JumpToBreakExplosive : explosive_device = explosive_device{}
    @editable{ToolTip := TT_JumpToBreakVFX} JumpToBreakVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable{ToolTip := TT_JumpToBreakSound} JumpToBreakSound : audio_player_device = audio_player_device{}
  
    #Initializes events
    OnBegin<override>()<suspends>:void=
        EquippedTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Handles the ability activation for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            race:
                block:
                    loop:
                        MUnEquippedPlayer := UnEquippedTrigger.TriggeredEvent.Await()
                        if(UnEquippedPlayer := MUnEquippedPlayer? , UnEquippedPlayer = Agent):
                            break
                loop:
                    Sleep(0.0)
                    FC.JumpedEvent().Await()
                    spawn{OnJump(FC)}
            
    #Handles all devices upon jump
    OnJump(FC : fort_character)<suspends> : void=
        if(Agent := FC.GetAgent[]):
            PlayerPos := FC.GetTransform().Translation
            if(JumpToBreakExplosive.TeleportTo[PlayerPos,IdentityRotation()]){}
            if(JumpToBreakVFX.TeleportTo[PlayerPos,IdentityRotation()]){}
            JumpToBreakSound.Play(Agent)
            JumpToBreakExplosive.Explode(Agent)
            JumpToBreakVFX.Enable()
            Sleep(0.2)
            JumpToBreakExplosive.Reset()
            JumpToBreakVFX.Disable()