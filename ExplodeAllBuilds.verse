
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

ExplodeAllBuilds := class(creative_device):
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable ExplodeAllBuildsTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    @editable ExplodeAllBuildsExplosive : explosive_device = explosive_device{}
    @editable ExplodeAllBuildsSound : audio_player_device = audio_player_device{}
    @editable ExplodeAllBuildsVFXs : []vfx_spawner_device = array{}

 


    OnBegin<override>()<suspends>:void=
        ExplodeAllBuildsTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        ExplodeAllBuildsTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
    ExplodeAllBuildsAbility(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            ExplodeAllBuildsTimer.Start(Agent)
            set MaybeCooldown=true
            AllPlayers := GetPlayspace().GetPlayers()
            for(VFX : ExplodeAllBuildsVFXs):
                VFX.Enable()
            for(Player : AllPlayers):
                if(FC := Player.GetFortCharacter[],NewAgent := FC.GetAgent[]):
                    ExplodeAllBuildsSound.Play(NewAgent)
            ExplodeAllBuildsExplosive.Explode(Agent)
            Sleep(0.2)
            ExplodeAllBuildsExplosive.Reset()
            for(VFX : ExplodeAllBuildsVFXs):
                VFX.Disable()
        else:
            CooldownMSG.Show(Agent)