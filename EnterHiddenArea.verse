
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
EnterHiddenArea := class(creative_device):

    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable HiddenAreaTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    @editable HiddenAreaMutatorZones : []mutator_zone_device = array{}
    @editable HiddenAreaInitialTP : teleporter_device = teleporter_device{}
    @editable HiddenAreaDynamicTP : teleporter_device = teleporter_device{}
    @editable HiddenAreaNoBuildMutatorZone : mutator_zone_device = mutator_zone_device{}
    @editable HiddenAreaHideSound : audio_player_device = audio_player_device{}
    @editable HiddenAreaComeOutSound : audio_player_device = audio_player_device{}

    @editable HiddenAreaHideTime : float = 0.0
    @editable HiddenAreaHideTimer : timer_device = timer_device{}
    var HasTPd : logic = false


    @editable HiddenAreaTrackerVFXs : []vfx_spawner_device = array{}
    var TrackerIDX : int = 0

    @editable HiddenAreaSetting : int =0
    #0 = Dont See Players Through Walls
    #1 = See Players Through Walls When Under

    


    OnBegin<override>()<suspends>:void=
        HiddenAreaTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        HiddenAreaTimer.SuccessEvent.Subscribe(ResetCooldown)


        HiddenAreaHideTimer.SetMaxDuration(HiddenAreaHideTime)

        for(Zone : HiddenAreaMutatorZones):
            Zone.AgentEntersEvent.Subscribe(TeleportUp)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false

    EnterHiddenAreaAbility(Agent:agent)<suspends> :void=
        if(MaybeCooldown = false):
            HiddenAreaTimer.Start(Agent)
            set MaybeCooldown=true

            set HasTPd = false
            if(Player := player[Agent], FC:=Player.GetFortCharacter[]):
                StartPos := FC.GetTransform().Translation
                StartTPPos := HiddenAreaInitialTP.GetTransform().Translation
                HiddenAreaInitialTP.Teleport(Agent)
                HiddenAreaHideSound.Play(Agent)
                HiddenAreaHideTimer.Start(Agent)
                for(Zone : HiddenAreaMutatorZones):
                    Zone.Enable()

                if(HiddenAreaSetting = 1):
                    for (NewPlayer : GetPlayspace().GetPlayers()):
                        if(NewFC := NewPlayer.GetFortCharacter[], NewAgent := FC.GetAgent[]):
                            if(NewFC = FC):
                            else:
                                if(CurrentVFX := HiddenAreaTrackerVFXs[TrackerIDX]):
                                    spawn:
                                        TrackPlayer(NewFC,CurrentVFX)
                                    set TrackerIDX += 1
                
                Sleep(HiddenAreaHideTime)

                if(HasTPd = false):
                    set HasTPd = true
                    if(HiddenAreaInitialTP.TeleportTo[StartPos,IdentityRotation()]){}
                    HiddenAreaInitialTP.Teleport(Agent)
                    HiddenAreaComeOutSound.Play(Agent)
                    Sleep(0.1)
                    if(HiddenAreaInitialTP.TeleportTo[StartTPPos,IdentityRotation()]){}
                else:

        else:
            CooldownMSG.Show(Agent)



    TeleportUp(Agent:agent) : void=
        if(Player:=player[Agent], FC:= Player.GetFortCharacter[]):
            PlayerPos := FC.GetTransform().Translation
            TeleportPos := vector3{X:=PlayerPos.X, Y:=PlayerPos.Y,Z:=60.0}
            if(HiddenAreaDynamicTP.TeleportTo[TeleportPos,IdentityRotation()]){}
            HiddenAreaDynamicTP.Teleport(Agent)
            HiddenAreaComeOutSound.Play(Agent)
            set HasTPd = true
            HiddenAreaHideTimer.Complete(Agent)

    TrackPlayer(FC:fort_character, VFX : vfx_spawner_device)<suspends>: void=
        VFX.Enable()
        loop:
            Sleep(0.0)
            if(VFX.TeleportTo[FC.GetTransform().Translation,IdentityRotation()]){}
            if(HasTPd = true):
                if(VFX.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=10000.0},IdentityRotation()]){}
                VFX.Disable