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

#THIS ABILITY SUMMONS A BEAM INFRONT OF THE PLAYER THAT EXPLODES EVERYTHING IT TOUCHES AND DOES GAMAE

#Class for each preset beam projectile
BeamProjectile := class<concrete>():
    TT_BeamProp<localizes>:message = "Creative Prop Used To Summon\n*Required Settings*\nCollision Presets: No Collision\nAll 'Beam Explosives' & 'BeamDamage' Should be Attached to this Prop"
    TT_BeamExplosives<localizes>:message = "Array of Explosive Devices That Constantly Explode While Beam is Summoned\n*Required Settings*\nCan Be Damaged: False\nStructure Damage: 5000\nVisible During Game: False\nCollision During Games: Off\nShow Health Bar: False\nTime Until Reset Allowed: 0.1"
    TT_BeamDamage<localizes>:message = "Damage Volume Device That Damages Players When Intersecting With Beam\n*Required Settings*\nInvert Team Selection: True"
    @editable{ToolTip := TT_BeamProp} BeamProp : creative_prop = creative_prop{}
    @editable{ToolTip := TT_BeamExplosives} BeamExplosives : []explosive_device = array{}
    @editable{ToolTip := TT_BeamDamage} BeamDamage : damage_volume_device = damage_volume_device{}
    var IsAvailable : logic = true

#Main creative device class
P_DamageBeam := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_BeamProjectiles<localizes>:message = "Collection of Beams\n*Required Settings*\nCreate One Instance for Each Potential User of this Ability"
    TT_ActivateSoundSummonBeam<localizes>:message = "Plays Sound On Summon\n*Required Settings*\nPlay Location: Instigating Player"
    TT_BeamHitPlayerSound<localizes>:message = "Plays Sound On When Player Is Hit\n*Required Settings*\nPlay Location: Instigating Player"
    TT_PropBeamDuration<localizes>:message = "How Long the Beam Will last after summoned"
    @editable{ToolTip := TT_BeamProjectiles} BeamProjectiles : []BeamProjectile = array{}
    @editable{ToolTip := TT_ActivateSoundSummonBeam} BeamSummonSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_BeamHitPlayerSound} BeamHitPlayerSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_RemoteConditional} BeamConditional : conditional_button_device = conditional_button_device{}
    @editable{ToolTip := TT_PropBeamDuration} PropBeamDuration : float = 0.0

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
            if(NotOnCooldown?):
                spawn{PropBeamAbility(Agent)}
    
    #Activates a prop beam for the player
    PropBeamAbility(Agent:agent) <suspends> : void=
        if(FC:=Agent.GetFortCharacter[]):
            var IsFound : logic = false
            var Projectile : BeamProjectile = BeamProjectile{}
            for(P : BeamProjectiles, not IsFound?):
                if(P.IsAvailable?):
                    set IsFound = true
                    set Projectile = P
                    set P.IsAvailable = false
            BeamSummonSound.Play(Agent)
            Projectile.BeamDamage.UpdateSelectedTeam(Agent)
            race:
                block:
                    loop:
                        HitPlayer := Projectile.BeamDamage.AgentEntersEvent.Await()
                        BeamHitPlayerSound.Play(HitPlayer)
                block:
                    Sleep(PropBeamDuration)
                    if(Projectile.BeamProp.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},IdentityRotation()]){}
                    set Projectile.IsAvailable = true
                    return
                block:
                    loop:
                        Sleep(0.0)
                        if(not BeamConditional.IsHoldingItem[Agent]):
                            if(Projectile.BeamProp.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},IdentityRotation()]){}
                            set Projectile.IsAvailable = true
                            break
                block:
                    loop:
                        for(E : Projectile.BeamExplosives){E.Explode(Agent)}
                        Sleep(0.15)
                        for(E : Projectile.BeamExplosives){E.Reset()}
                block:
                    loop:
                        Sleep(0.0)
                        PlayerRot := FC.GetViewRotation()
                        PlayerPos := FC.GetTransform().Translation
                        PlayerForward := PlayerRot.GetLocalForward() * 1200.0
                        ExplosiveForward := PlayerRot.GetLocalForward() * 300.0
                        SpawnPos := PlayerPos + PlayerForward
                        if(Projectile.BeamProp.TeleportTo[SpawnPos,PlayerRot]){}