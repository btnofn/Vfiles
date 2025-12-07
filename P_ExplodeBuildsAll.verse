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

#THIS ABILITY EXPLODES ALL BUILDS, PLAYS VFXS, AND PLAYS A SOUND FOR ALL PLAYERS 

P_ExplodeBuildsAll := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_ExplodeAllBuildsExplosives<localizes>:message = "Explosive devices that explodes on activation\n*Required Settings*\nCan Be Damaged: False\nStructure Damage: 5000\nVisible During Game: False\nCollision During Games: Off\nShow Health Bar: False\nTime Until Reset Allowed: 0.1"
    TT_ExplodeAllBuildsSound<localizes>:message = "Plays Sound For All Players On Activation\n*Required Settings*\nPlay Location: Instigating Player"
    TT_ExplodeAllBuildsVFXs<localizes>:message = "Array of VFX Spawner Devices that enable on activation\n*Required Settings*\nEnabled On Phase: None\nClear Particles On Disable: False"
    @editable{ToolTip := TT_ExplodeAllBuildsExplosives} ExplodeAllBuildsExplosives : []explosive_device = array{}
    @editable{ToolTip := TT_ExplodeAllBuildsSound} ExplodeAllBuildsSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_ExplodeAllBuildsVFXs} ExplodeAllBuildsVFXs : []vfx_spawner_device = array{}

 
    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
            if(NotOnCooldown?):
                for(Player : AbilityManager.GetPlayers()){ExplodeAllBuildsSound.Play(Player)}
                for(E : ExplodeAllBuildsExplosives){E.Explode(Agent)}
                for(VFX : ExplodeAllBuildsVFXs){VFX.Enable()}
                Sleep(0.2)
                for(E : ExplodeAllBuildsExplosives){E.Reset()}
                for(VFX : ExplodeAllBuildsVFXs){VFX.Disable()}