
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

TempApparelOrCharacter := class(creative_device):
    @editable BasicFuncs : BasicFunctions = BasicFunctions{}
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable TempAorCTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    @editable TempAorCTime : float = 0.0
    @editable TempAorCSound : audio_player_device = audio_player_device{}

    @editable TempApparelVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable TempApparelTrigger : trigger_device = trigger_device{}

    @editable TempCharacterProp : creative_prop = creative_prop{}
    @editable TempCharacterRunningAnimation : cinematic_sequence_device = cinematic_sequence_device{}

    var Time : logic = false




    @editable TempAorCSetting : int = 0
    #1 = Custom Apparel
    #2 = Custom Character

    @editable TempAorCBuffSetting : int = 0
    #if 1: DMG Boost
    #if 2: Speed Boost
    #if 3: DMG and Speed
    #if 4: Invincible


    @editable DMGBoostAmount : float = 0.0
    @editable BuffTime : float = 0.0
    @editable TempAorCInvincibilityVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable TempAorCSpeedDevice : movement_modulator_device = movement_modulator_device{}


    OnBegin<override>()<suspends>:void=
        TempAorCTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        TempAorCTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false

    TempApparelOrCharacterAbility(Agent:agent)<suspends> :void=
        if(MaybeCooldown = false):
            TempAorCTimer.Start(Agent)
            set MaybeCooldown=true
            if(TempAorCSetting = 1):
                spawn:
                    TempCustomApparel(Agent)
            else if(TempAorCSetting = 2):
                spawn:
                    TempCustomCharacter(Agent)
        else:
            CooldownMSG.Show(Agent)




    TempCustomApparel(Agent:agent)<suspends> : void=
        TempAorCSound.Play(Agent)
        TempApparelVFX.Pickup(Agent)
        spawn:
            BuffCheck(Agent)
        Sleep(TempAorCTime)
        TempApparelTrigger.Trigger(Agent)
        TempAorCSound.Stop(Agent)

    TempCustomCharacter(Agent:agent)<suspends> : void=
        if(Player := player[Agent], FC:= Player.GetFortCharacter[]):
            FC.Hide()
            set Time = false
            spawn:
                Timer()
            TempAorCSound.Play(Agent)
            spawn:
                BuffCheck(Agent)
            branch:
                loop:
                    Sleep(0.0)
                    if(FC.IsActive[]):
                        PlayerPos := FC.GetTransform().Translation
                        PlayerRot := FC.GetTransform().Rotation

                        TempCharacterProp.MoveTo(PlayerPos- vector3{Z:=60.0}, PlayerRot, 0.1)

                    else if(not FC.IsActive[]):
                        if(TempCharacterProp.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=-10000.0},TempCharacterProp.GetTransform().Rotation]){}
                        FC.Show()
                        break
                    if(Time = true):
                        if(TempCharacterProp.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=-10000.0},TempCharacterProp.GetTransform().Rotation]){}
                        FC.Show()
                        break
            loop:
                if (not FC.IsActive[]):
                    break
                if(Time = true):
                    break
                Sleep(0.0)
                IsSprintingTuple := FC.SprintedEvent().Await()
                if (IsSprintingTuple(1)?):
                    TempCharacterRunningAnimation.Play()
                else:
                    TempCharacterRunningAnimation.Stop()


    Timer()<suspends>: void=
        Sleep(TempAorCTime)
        set Time = true


    BuffCheck(Agent:agent)<suspends> : void=   
        if(Player := player[Agent],FC:=Player.GetFortCharacter[]): 
            if(TempAorCBuffSetting = 1):
                BasicFuncs.DoDamageBuff(Agent,BuffTime,DMGBoostAmount)
            else if(TempAorCBuffSetting = 2):
                TempAorCSpeedDevice.Activate(Agent)
            else if(TempAorCBuffSetting = 3):
                BasicFuncs.DoDamageBuff(Agent,BuffTime,DMGBoostAmount)
                TempAorCSpeedDevice.Activate(Agent)
            else if(TempAorCBuffSetting = 4):
                Print("Setting 4")
                TempAorCInvincibilityVFX.SetDuration(BuffTime)
                TempAorCInvincibilityVFX.Pickup(Agent)
                # FC.SetVulnerability(false)
                # Sleep(TempAorCTime)
                # FC.SetVulnerability(true)
                spawn:
                    BasicFuncs.DoInvcibilityBuff(Agent, BuffTime)
            else:
