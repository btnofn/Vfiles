
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }


PauseBall := class(creative_device):
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable PauseBallTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    @editable GameStartDevice : GameStart = GameStart{}
    @editable PauseBallClassNumber : int = 100
    @editable MainRemoteMan : signal_remote_manager_device = signal_remote_manager_device{}

    @editable PauseBallProp : creative_prop = creative_prop{}
    @editable PauseBallDMG : damage_volume_device = damage_volume_device{}
    @editable PauseBallContactExplosive : explosive_device = explosive_device{}
    @editable PauseBallConstantExplosive : explosive_device = explosive_device{}
    @editable PauseBallShootSound :audio_player_device = audio_player_device{}
    @editable PauseBallSpeed : float = 0.0
    @editable PauseBallExplodeVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable PauseBallSummonBallSound : audio_player_device = audio_player_device{}
    @editable PauseBallContactSound : audio_player_device = audio_player_device{}
    var BallIsShot : logic = false
    var EndExploding : logic = false

    @editable PauseBallSetting : int = 0
    # 0 = No Explosions
    # 1 = Explode On Contact
    # 2 = Constant Explosions

    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        PauseBallTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        PauseBallTimer.SuccessEvent.Subscribe(ResetCooldown)

        MainRemoteMan.PrimarySignalEvent.Subscribe(ShootSetup)
        MainRemoteMan.SecondarySignalEvent.Subscribe(SummonSetup)

    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false



    Shoot(Agent:agent)<suspends> : void=
        if(GameStartDevice.EachPlayerMap[Agent].ClassNum = PauseBallClassNumber):
            if(BallIsShot = false):
                set BallIsShot = true
                PauseBallTimer.Start(Agent)
                set MaybeCooldown=true
                Sleep(0.2)
                if(Player := player[Agent],FC:=Player.GetFortCharacter[]):
                    PlayerRot := FC.GetTransform().Rotation
                    PlayerPos := FC.GetTransform().Translation
                    PlayerForward := FC.GetViewRotation().GetLocalForward() * 300.0
                    BallFinishLocation := FC.GetViewRotation().GetLocalForward() * 10000.0
                    FinishPos := PlayerPos + BallFinishLocation
                    SpawnPos := PlayerPos + PlayerForward
                    PauseBallShootSound.Play(Agent)
                    if(PauseBallConstantExplosive.TeleportTo[SpawnPos,PlayerRot]){}
                    if(PauseBallProp.TeleportTo[SpawnPos,PlayerRot]){}
                    if(PauseBallDMG.TeleportTo[SpawnPos,PlayerRot]){}
                    PauseBallDMG.Enable()
                    spawn:
                        ExplodingBall(Agent)
                    spawn:
                        PauseBallConstantExplosive.MoveTo(FinishPos,PlayerRot,PauseBallSpeed)
                    spawn:
                        PauseBallDMG.MoveTo(FinishPos,PlayerRot,PauseBallSpeed)
                    spawn:
                        PauseBallProp.MoveTo(FinishPos,PlayerRot,PauseBallSpeed)




    ExplodingBall(Agent:agent)<suspends> : void=
        if(PauseBallSetting = 1):
            PauseBallDMG.AgentEntersEvent.Subscribe(HandleBallHitPlayer)
        if(PauseBallSetting = 2):
            set EndExploding = false
            spawn:
                ExplodeTimer()
            loop:
                Sleep(0.0)
                PauseBallConstantExplosive.Explode(Agent)
                PauseBallConstantExplosive.Reset()
                if(EndExploding = true):
                    break
        else:


    ExplodeTimer()<suspends>: void=
        Sleep(PauseBallSpeed)
        set EndExploding = true

    HandleBallHitPlayer(Agent:agent) : void=
        spawn:
            BallHitPlayer(Agent)
    BallHitPlayer(Agent:agent)<suspends>: void=
        if(PauseBallContactExplosive.TeleportTo[PauseBallProp.GetTransform().Translation,PauseBallProp.GetTransform().Rotation]):
            PauseBallContactExplosive.Explode(Agent)
            PauseBallContactExplosive.Reset()
        if(PauseBallExplodeVFX.TeleportTo[PauseBallProp.GetTransform().Translation,PauseBallProp.GetTransform().Rotation]):
            PauseBallExplodeVFX.Enable()
        PauseBallContactSound.Play(Agent)
        Sleep(0.1)
        PauseBallExplodeVFX.Disable()
        if(PauseBallContactExplosive.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},PauseBallContactExplosive.GetTransform().Rotation]){}
        if(PauseBallProp.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},PauseBallProp.GetTransform().Rotation]){}
        if(PauseBallDMG.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},PauseBallDMG.GetTransform().Rotation]){}
        



    Summon(Agent:agent)<suspends> : void=
        if(GameStartDevice.EachPlayerMap[Agent].ClassNum = PauseBallClassNumber):
            if(MaybeCooldown = false):
                set BallIsShot = false
                PauseBallDMG.Disable()
                spawn:
                    PauseBallCheck(Agent)
                PauseBallSummonBallSound.Play(Agent)
            else:
                CooldownMSG.Show(Agent)


    PauseBallCheck(Agent:agent)<suspends> : void=
        loop:
            Sleep(0.01)
                if(Player:=player[Agent], FC:=Player.GetFortCharacter[]):
                    PlayerRot := FC.GetTransform().Rotation
                    PlayerPos := FC.GetTransform().Translation
                    PlayerForward := FC.GetViewRotation().GetLocalForward() * 400.0
                    SpawnPos := PlayerPos + PlayerForward
                    if(PauseBallConstantExplosive.TeleportTo[SpawnPos,PlayerRot]){}
                    if(PauseBallProp.TeleportTo[SpawnPos,PlayerRot]){}
                    if(PauseBallDMG.TeleportTo[SpawnPos,PlayerRot]){}
            if(BallIsShot = true):
                break
                # else if(not TeleportInFrontConditional.IsHoldingItem[Agent]):
                #     if(TeleportInFrontTP.TeleportTo[TeleportInFrontTP.GetTransform().Translation + vector3{Z:=1000.0},TeleportInFrontTP.GetTransform().Rotation]):







    ShootSetup(Agent:agent) : void=
        spawn:
            Shoot(Agent)
    SummonSetup(Agent:agent) : void=
        spawn:
            Summon(Agent)
