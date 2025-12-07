
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

PropBeam := class(creative_device):
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable PropBeamTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    @editable PropBeamSound : audio_player_device = audio_player_device{}
    @editable PropBeamConditional : conditional_button_device = conditional_button_device{}
    @editable PropBeamExplosives : []explosive_device = array{}
    @editable PropBeamDMG : damage_volume_device = damage_volume_device{}
    @editable PropBeamProp : creative_prop = creative_prop{}
    @editable PropBeamTime : float = 0.0
    @editable PropBeamHitPlayerSound : audio_player_device = audio_player_device{}
    var Time : logic = false
    var InchForward : float = 1.0


    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        PropBeamTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        PropBeamTimer.SuccessEvent.Subscribe(ResetCooldown)
        PropBeamDMG.AgentEntersEvent.Subscribe(PlayHitSound)

    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
    
    PropBeamAbility(Agent:agent) <suspends> : void=
        if(MaybeCooldown = false):
            PropBeamTimer.Start(Agent)
            set MaybeCooldown=true

            set Time = false
            PropBeamSound.Play(Agent)

            spawn:
                Timer()
            loop:
                Sleep(0.01)
                if(PropBeamConditional.IsHoldingItem[Agent]):
                    if(Player:=player[Agent], FC:=Player.GetFortCharacter[]):
                        PlayerRot := FC.GetViewRotation()
                        PlayerPos := FC.GetTransform().Translation
                        PlayerForward := FC.GetViewRotation().GetLocalForward() * 1200.0

                        NewForward := FC.GetViewRotation().GetLocalForward() * 2250.0

                        ExplosiveForward := FC.GetViewRotation().GetLocalForward() * 300.0

                        SpawndmgPos := PlayerPos + NewForward
                        SpawnPos := PlayerPos + PlayerForward

                        NewRotation := PlayerRot.ApplyPitch(1.5708)
                        set InchForward = 1.0
                        for(Explosive : PropBeamExplosives):
                            if(Explosive.TeleportTo[(PlayerPos + (ExplosiveForward*InchForward)),PlayerRot]){}
                                set InchForward += 0.6
                        spawn:
                            ExplodeThem(Agent)
                        if(PropBeamProp.TeleportTo[SpawnPos,PlayerRot]){}
                        if(PropBeamDMG.TeleportTo[SpawndmgPos,NewRotation]){}


                else if(not PropBeamConditional.IsHoldingItem[Agent]):
                    if(PropBeamProp.TeleportTo[PropBeamProp.GetTransform().Translation + vector3{Z:=10000.0},PropBeamProp.GetTransform().Rotation]){}
                    if(PropBeamDMG.TeleportTo[PropBeamDMG.GetTransform().Translation + vector3{Z:=10000.0},PropBeamDMG.GetTransform().Rotation]):  
                    for(Explosive : PropBeamExplosives):
                        if(Explosive.TeleportTo[PropBeamDMG.GetTransform().Translation + vector3{Z:=10000.0},PropBeamDMG.GetTransform().Rotation]){}
                    break


                if(Time = true):
                    if(PropBeamProp.TeleportTo[PropBeamProp.GetTransform().Translation + vector3{Z:=10000.0},PropBeamProp.GetTransform().Rotation]){}
                    if(PropBeamDMG.TeleportTo[PropBeamDMG.GetTransform().Translation + vector3{Z:=10000.0},PropBeamDMG.GetTransform().Rotation]):  
                    for(Explosive : PropBeamExplosives):
                        if(Explosive.TeleportTo[PropBeamDMG.GetTransform().Translation + vector3{Z:=10000.0},PropBeamDMG.GetTransform().Rotation]){}
                    break
        else:
            CooldownMSG.Show(Agent)
    Timer()<suspends> : void=
        Sleep(PropBeamTime)
        set Time = true

    ExplodeThem(Agent: agent)<suspends> : void=
        for(Explosive : PropBeamExplosives):
            Explosive.Explode(Agent)
            Sleep(0.15)
            Explosive.Reset()
            
            
    PlayHitSound(Agent:agent) : void=
        PropBeamHitPlayerSound.Play(Agent)