
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

JumpScare := class(creative_device):
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable JumpScareTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}


    var Targets : []fort_character = array{}
    var NewTargets : []fort_character = array{}

    @editable JumpScareImage : hud_message_device = hud_message_device{}
    @editable JumpScareSoundAll : audio_player_device = audio_player_device{}
    @editable JumpScareSoundOne : audio_player_device = audio_player_device{}
    @editable JumpScareTime : float = 0.0

    @editable ShouldFreezeSetting : int =0
    # 0 = Doesnt Freeze When Scare
    # 1 - Does Freeze When Scare

    


    @editable WhoDoesItEffectSetting : int = 0
    # 0 = Closest Player
    # 1 = All Players


    OnBegin<override>()<suspends>:void=
        JumpScareImage.SetDisplayTime(JumpScareTime)
        JumpScareTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        JumpScareTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false

    JumpScareAbility(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            JumpScareTimer.Start(Agent)
            set MaybeCooldown=true

            if(ActivatorPlayer := player[Agent], ActivatorChar := ActivatorPlayer.GetFortCharacter[]):
                set Targets = array{}
                for(Player : GetPlayspace().GetPlayers(),FC:=Player.GetFortCharacter[],EveryAgent:=FC.GetAgent[]):
                    set Targets += array{FC}
                    if(WhoDoesItEffectSetting = 0):
                        if(ActivatorIDX := Targets.Find[ActivatorChar]):
                            if(NEWTARGET := Targets.RemoveElement[ActivatorIDX]):
                                set NewTargets = NEWTARGET

                        if(Target := ActivatorChar.FindNearestTarget[],TargetAgent := Target.GetAgent[]):
                            spawn:
                                FreezeCheck(Target)
                            JumpScareImage.Show(TargetAgent)
                            JumpScareSoundOne.Play(TargetAgent)
                            Sleep(JumpScareTime)
                            JumpScareSoundOne.Stop(TargetAgent)




                    if(WhoDoesItEffectSetting = 1):
                        if(not EveryAgent = Agent):
                            spawn:
                                FreezeCheck(FC)
                            JumpScareImage.Show(EveryAgent)
                            JumpScareSoundAll.Play(EveryAgent)
                            Sleep(JumpScareTime)
                            JumpScareSoundAll.Stop(EveryAgent)






        else:
            CooldownMSG.Show()

    FreezeCheck(FC : fort_character)<suspends> : void=
        if(ShouldFreezeSetting = 1):
            FC.PutInStasis(stasis_args{})
            Sleep(JumpScareTime)
            FC.ReleaseFromStasis()
        else:




    (FortCharacter : fort_character).FindNearestTarget()<transacts><decides> : fort_character =
        var MaybeTarget : ?fort_character = false
        var NearestLocation : float = 1000000.0
        for (Target : NewTargets):
            if (DistancePlayerToTarget := Distance(Target.GetTransform().Translation, FortCharacter.GetTransform().Translation) < NearestLocation):
                set MaybeTarget = option{Target}
                set NearestLocation = DistancePlayerToTarget
        return MaybeTarget?