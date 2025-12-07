
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

SpawnClones := class(creative_device):
    @editable ClonePlayerRefs : []player_reference_device= array{}
    @editable SpawnClonesSound : audio_player_device = audio_player_device{}
    @editable CloneTime : float = 0.0



    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable CloneTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    OnBegin<override>()<suspends>:void=
       CloneTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        CloneTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
    SpawnAllClones(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            CloneTimer.Start(Agent)
            set MaybeCooldown=true
            for(Ref : ClonePlayerRefs):
                Ref.Register(Agent)
                Ref.Enable()
            Sleep(CloneTime)
            for(PlayerRef:ClonePlayerRefs):
                PlayerRef.Disable()
        else:
            CooldownMSG.Show(Agent)
