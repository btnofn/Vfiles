
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

ShootBall := class(creative_device):
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable ShootBallTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}


    @editable ShootBallSpeed : float = 0.0
    @editable ShootBallProp : creative_prop = creative_prop{}
    @editable ShootBallSound : audio_player_device = audio_player_device{}
    @editable ShootBallDMG : damage_volume_device = damage_volume_device{}


    var EndExploding : logic = false
    @editable ShootBallExplodeVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable ShootBallContactExplosive : explosive_device = explosive_device{}
    @editable ShootBallConstantExplosive : explosive_device = explosive_device{}
    @editable ShootBallContactSound : audio_player_device = audio_player_device{}


    @editable ShouldBallExplodeSetting : int = 0
    # 0 = No Explosions
    # 1 = Explode On Contact
    # 2 = Constant Explosions


    OnBegin<override>()<suspends>:void=
        ShootBallTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        ShootBallTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
    ShootBallAbility(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            ShootBallTimer.Start(Agent)
            set MaybeCooldown=true
            if(Player := player[Agent],FC:=Player.GetFortCharacter[]):
                PlayerRot := FC.GetTransform().Rotation
                PlayerPos := FC.GetTransform().Translation
                PlayerForward := FC.GetViewRotation().GetLocalForward() * 300.0
                BallFinishLocation := FC.GetViewRotation().GetLocalForward() * 10000.0
                FinishPos := PlayerPos + BallFinishLocation
                SpawnPos := PlayerPos + PlayerForward
                ShootBallSound.Play(Agent)
                if(ShootBallConstantExplosive.TeleportTo[SpawnPos,PlayerRot]){}
                if(ShootBallProp.TeleportTo[SpawnPos,PlayerRot]){}
                if(ShootBallDMG.TeleportTo[SpawnPos,PlayerRot]){}
                if(ShootBallExplodeVFX.TeleportTo[SpawnPos,PlayerRot]){}
                spawn:
                    ExplodingBall(Agent)
                spawn:
                    ShootBallExplodeVFX.MoveTo(FinishPos,PlayerRot,ShootBallSpeed)
                spawn:
                    ShootBallConstantExplosive.MoveTo(FinishPos,PlayerRot,ShootBallSpeed)
                spawn:
                    ShootBallDMG.MoveTo(FinishPos,PlayerRot,ShootBallSpeed)
                spawn:
                    ShootBallProp.MoveTo(FinishPos,PlayerRot,ShootBallSpeed)
        else:
            CooldownMSG.Show(Agent)


    ExplodingBall(Agent:agent)<suspends> : void=
        if(ShouldBallExplodeSetting = 1):
            ShootBallDMG.AgentEntersEvent.Subscribe(HandleBallHitPlayer)
        if(ShouldBallExplodeSetting = 2):
            set EndExploding = false
            spawn:
                ExplodeTimer()
            loop:
                Sleep(0.0)
                ShootBallExplodeVFX.Enable()
                ShootBallExplodeVFX.Disable()
                ShootBallConstantExplosive.Explode(Agent)
                ShootBallConstantExplosive.Reset()
                if(EndExploding = true):
                    break
        else:


    ExplodeTimer()<suspends>: void=
        Sleep(ShootBallSpeed)
        set EndExploding = true

    HandleBallHitPlayer(Agent:agent) : void=
        spawn:
            BallHitPlayer(Agent)
    BallHitPlayer(Agent:agent)<suspends>: void=
        if(ShootBallContactExplosive.TeleportTo[ShootBallProp.GetTransform().Translation,ShootBallProp.GetTransform().Rotation]):
            ShootBallContactExplosive.Explode(Agent)
            ShootBallContactExplosive.Reset()
        if(ShootBallExplodeVFX.TeleportTo[ShootBallProp.GetTransform().Translation,ShootBallProp.GetTransform().Rotation]):
            ShootBallExplodeVFX.Enable()
        ShootBallContactSound.Play(Agent)
        

        Sleep(0.1)
        ShootBallExplodeVFX.Disable()
        if(ShootBallContactExplosive.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},ShootBallContactExplosive.GetTransform().Rotation]){}
        if(ShootBallProp.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},ShootBallProp.GetTransform().Rotation]){}
        if(ShootBallDMG.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},ShootBallDMG.GetTransform().Rotation]){}
            