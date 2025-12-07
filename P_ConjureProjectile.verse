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

#THIS ABILITY ALLOWS A PLAYER TO PRESS ONCE TO SUMMON A PROJECTILE AND THEN PRESS AGAIN TO SHOOT THE PROJECTILE. THIS PROJECT EXPLODES, DOES DAMAGE, AND PLAYS SFX & VFX

#Main creative device class
P_ConjureProjectile := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_BallProjectiles<localizes>:message = "Collection of Projectiles\n*Required Settings*\nCreate One Projectile for Each Potential User of this Ability"
    TT_ActivateSoundSummonBall<localizes>:message = "Plays Sound On Summon\n*Required Settings*\nPlay Location: Instigating Player"
    TT_ActivateSoundShootBall<localizes>:message = "Plays Sound On Fire\n*Required Settings*\nPlay Location: Instigating Player"
    TT_ExplosionSetting<localizes>:message = "How the Projectile Will Explode"
    TT_PauseBallSpeed<localizes>:message = "Speed/Duration of the Ball. Lower Number -> Faster"
    @editable{ToolTip := TT_BallProjectiles} BallProjectiles : []BallProjectile = array{}
    @editable{ToolTip := TT_RemoteConditional} RemoteConditional : conditional_button_device = conditional_button_device{}
    @editable{ToolTip := TT_ActivateSoundSummonBall} PauseBallSummonBallSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_ActivateSoundShootBall} PauseBallShootSound :audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_ExplosionSetting} ExplosionSetting : ExplosionType = ExplosionType.None
    @editable{ToolTip := TT_PauseBallSpeed} PauseBallSpeed : float = 0.0 
    BallShotEvent : event(agent) = event(agent){}
    BallEndedEvent : event(agent) = event(agent){}
    var PlayerSummonedMap : [agent]logic = map{}

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)
        for(Player : GetPlayspace().GetPlayers()){InitializePlayerInMap(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitializePlayerInMap)

    #Initializes damage events for a player
    InitializePlayerInMap(Agent:agent) : void =
        if(IsInMap := PlayerSummonedMap[Agent]):
        else:
            if(set PlayerSummonedMap[Agent] = false){}

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            if(IsSummoned := PlayerSummonedMap[Agent]):
                if(IsSummoned?):
                    BallShotEvent.Signal(Agent)
                else:
                    NotOnCooldown := CP.HandleCooldown(Cooldown)
                    if(NotOnCooldown?):
                        spawn{Summon(Agent)}

    #Summons a projectile for a player
    Summon(Agent:agent)<suspends> : void=
        if(FC:=Agent.GetFortCharacter[]):
            if(set PlayerSummonedMap[Agent] = true){}
            var IsFound : logic = false
            var NewProjectile : BallProjectile = BallProjectile{}
            for(P : BallProjectiles, not IsFound?):
                if(P.IsAvailable?):
                    set IsFound = true
                    set NewProjectile = P
                    set P.IsAvailable = false
            PauseBallSummonBallSound.Play(Agent)
            PlayerInitialRot := FC.GetTransform().Rotation
            PlayerInitialPos := FC.GetTransform().Translation
            PlayerInitialForward := FC.GetViewRotation().GetLocalForward() * 400.0
            SpawnInitialPos := PlayerInitialPos + PlayerInitialForward
            race:
                block:
                    loop:
                        ShootingBallPlayer := BallShotEvent.Await()
                        if(ShootingBallPlayer = Agent):
                            spawn{Shoot(Agent ,  NewProjectile)}
                            break
                block:
                    loop:
                        Sleep(0.0)
                        if(not RemoteConditional.IsHoldingItem[Agent]):
                            if(NewProjectile.BallProp.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},IdentityRotation()]){}
                            set NewProjectile.IsAvailable = true
                            if(set PlayerSummonedMap[Agent] = false){}
                            break
                loop:
                    Sleep(0.0)
                    PlayerRot := FC.GetTransform().Rotation
                    PlayerPos := FC.GetTransform().Translation
                    PlayerForward := FC.GetViewRotation().GetLocalForward() * 400.0
                    SpawnPos := PlayerPos + PlayerForward
                    NewProjectile.BallProp.MoveTo(SpawnPos,PlayerRot,0.2)

    #Shoots the projectile in the direction the player is looking
    Shoot(Agent:agent , Projectile : BallProjectile)<suspends> : void=
        if(FC:=Agent.GetFortCharacter[]):
            if(set PlayerSummonedMap[Agent] = false){}
            Projectile.BallDamage.UpdateSelectedTeam(Agent)
            Projectile.BallDamage.Enable()
            PauseBallShootSound.Play(Agent)
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
                    Projectile.BallProp.MoveTo(FinishPos,PlayerRot,PauseBallSpeed)
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