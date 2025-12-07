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

#THIS ABILITY SHOOTS A PROJECTILE INFRONT OF THE PLAYER THAT EXPLODES, DOES DAMAGE, AND PLAYS VFX & SFX

#Main creative device class
P_ShootProjectile := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_BallProjectiles<localizes>:message = "Collection of Projectiles\n*Required Settings*\nCreate One Projectile for Each Potential User of this Ability"
    TT_ActivateSoundShootBall<localizes>:message = "Plays Sound On Fire\n*Required Settings*\nPlay Location: Instigating Player"
    TT_ExplosionSetting<localizes>:message = "How the Projectile Will Explode"
    TT_BallSpeed<localizes>:message = "Speed/Duration of the Ball. Lower Number -> Faster"
    @editable{ToolTip := TT_BallProjectiles} BallProjectiles : []BallProjectile = array{}
    @editable{ToolTip := TT_RemoteConditional} RemoteConditional : conditional_button_device = conditional_button_device{}
    @editable{ToolTip := TT_ActivateSoundShootBall} BallShootSound :audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_ExplosionSetting} ExplosionSetting : ExplosionType = ExplosionType.None
    @editable{ToolTip := TT_BallSpeed} BallSpeed : float = 0.0 
    BallEndedEvent : event(agent) = event(agent){}


    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
            if(NotOnCooldown?):
                spawn{Shoot(Agent)}


    #Shoots the projectile in the direction the player is looking
    Shoot(Agent:agent)<suspends> : void=
        if(FC:=Agent.GetFortCharacter[]):
            var IsFound : logic = false
            var Projectile : BallProjectile = BallProjectile{}
            for(P : BallProjectiles, not IsFound?):
                if(P.IsAvailable?):
                    set IsFound = true
                    set Projectile = P
                    set P.IsAvailable = false

            Projectile.BallDamage.UpdateSelectedTeam(Agent)
            Projectile.BallDamage.Enable()
            BallShootSound.Play(Agent)
            PlayerRot := FC.GetTransform().Rotation
            PlayerPos := FC.GetTransform().Translation
            PlayerForward := FC.GetViewRotation().GetLocalForward() * 400.0
            BallFinishLocation := FC.GetViewRotation().GetLocalForward() * 10000.0
            FinishPos := PlayerPos + BallFinishLocation
            SpawnPos := PlayerPos + PlayerForward
            if(Projectile.BallProp.TeleportTo[SpawnPos,PlayerRot]){}
            spawn{HandleExplosion(Agent , Projectile)}
            race:
                block:
                    loop:
                        BallWithContactPlayer := Projectile.BallDamage.AgentEntersEvent.Await()
                        if(BallWithContactPlayer = Agent):
                            Sleep(0.2)
                            if(Projectile.BallProp.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},IdentityRotation()]){}
                            Projectile.BallDamage.Disable()
                            set Projectile.IsAvailable = true
                            BallEndedEvent.Signal(Agent)
                            break
                block:
                    Projectile.BallProp.MoveTo(FinishPos,PlayerRot,BallSpeed)
                    if(Projectile.BallProp.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},IdentityRotation()]){}
                    BallEndedEvent.Signal(Agent)
                    Projectile.BallDamage.Disable()
                    set Projectile.IsAvailable = true

    #Handles all explosions for the projectile
    HandleExplosion(Agent:agent , Projectile : BallProjectile)<suspends> : void=
        if(ExplosionSetting = ExplosionType.Contact):
            Projectile.BallDamage.AgentEntersEvent.Await()
            Projectile.BallExplosive.Explode(Agent)
            spawn{PlayVFX(Projectile.BallProp.GetTransform().Translation , Projectile.BallExplodeVFX)}
            Projectile.LocationSound.Play()
            
        else if(ExplosionSetting = ExplosionType.Looping):
            race:
                block:
                    loop:
                        BallEndedPlayer := BallEndedEvent.Await()
                        if(BallEndedPlayer = Agent):
                            break
                loop:
                    Projectile.BallExplosive.Explode(Agent)
                    Projectile.LocationSound.Play()
                    spawn{PlayVFX(Projectile.BallProp.GetTransform().Translation , Projectile.BallExplodeVFX)}
                    Sleep(0.2)
                    Projectile.BallExplosive.Reset()