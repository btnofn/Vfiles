
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }

TeleportInFront := class(creative_device):
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable TeleportInFrontTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    @editable GameStartDevice : GameStart = GameStart{}
    @editable TeleportInFrontClassNumber : int = 100

    @editable TeleportInFrontTP : teleporter_device = teleporter_device{}
    @editable TeleportInFrontSound : audio_player_device = audio_player_device{}
    @editable TeleportInFrontConditional : conditional_button_device = conditional_button_device{}





    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        TeleportInFrontTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        TeleportInFrontTimer.SuccessEvent.Subscribe(ResetCooldown)

        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = TeleportInFrontClassNumber):
                    spawn:
                        TeleportInFrontPlayer(Agent)

    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
    TeleportInFrontAbility(Agent : agent) <suspends> : void=
        if(MaybeCooldown = false):
            TeleportInFrontTimer.Start(Agent)
            set MaybeCooldown=true
            TeleportInFrontTP.Teleport(Agent)
            TeleportInFrontSound.Play(Agent)

        else:
            CooldownMSG.Show(Agent)
    TeleportInFrontPlayer(Agent:agent)<suspends> : void=
        loop:
            Sleep(0.01)
            if(TeleportInFrontConditional.IsHoldingItem[Agent]):
                if(Player:=player[Agent], FC:=Player.GetFortCharacter[]):
                    PlayerRot := FC.GetTransform().Rotation
                    PlayerPos := FC.GetTransform().Translation
                    # PlayerPos := FC.GetViewLocation()

                    PlayerForward := FC.GetViewRotation().GetLocalForward() * 400.0
                    SpawnPos := PlayerPos + PlayerForward
                    var XCord : float = SpawnPos.X
                    var YCord : float = SpawnPos.Y
                    var ZCord : float = SpawnPos.Z
                    
                    if(SpawnPos.X >= 3264.0):
                        set XCord = 3264.0
                    if(SpawnPos.X <= -224.0):
                        set XCord = -224.0
                    if(SpawnPos.Y >= 2256.0):
                        set YCord = 2256.0
                    if(SpawnPos.Y <= -1232.0):
                        set YCord = -1232.0
                    if(SpawnPos.Z >= 704.0):
                        set ZCord = 704.0
                    if(SpawnPos.Z <= 64.0):
                        set ZCord = 64.0


                    NewSpawnPos := vector3{X:=XCord,Y:=YCord,Z:=ZCord}
                    if(TeleportInFrontTP.TeleportTo[NewSpawnPos,PlayerRot]){}
            else if(not TeleportInFrontConditional.IsHoldingItem[Agent]):
                if(TeleportInFrontTP.TeleportTo[TeleportInFrontTP.GetTransform().Translation + vector3{Z:=1000.0},TeleportInFrontTP.GetTransform().Rotation]):


