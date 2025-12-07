
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

JumpToBreakBuilds := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable JumpToBreakClassNumber : int = 100

    @editable JumpToBreakExplosive : explosive_device = explosive_device{}
    @editable JumpToBreakVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable JumpToBreakSound : audio_player_device = audio_player_device{}
  
    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = JumpToBreakClassNumber):
                    spawn:
                        JumpToBreakBuildsPlayer(Agent)
    JumpToBreakBuildsPlayer(Agent:agent) <suspends>: void=
        if(Player := player[Agent] , FC:= Player.GetFortCharacter[]):
            FC.JumpedEvent().Subscribe(OnJump)
    OnJump(FC : fort_character) : void=
        if(Agent := FC.GetAgent[]):
            PlayerPos := FC.GetTransform().Translation
            if(JumpToBreakExplosive.TeleportTo[PlayerPos,IdentityRotation()]){}
            if(JumpToBreakVFX.TeleportTo[PlayerPos,IdentityRotation()]){}
            JumpToBreakVFX.Enable()
            JumpToBreakSound.Play(Agent)
            JumpToBreakExplosive.Explode(Agent)

            
            spawn:
                ResetExplosive()
    ResetExplosive()<suspends> : void=
        Sleep(0.2)
        JumpToBreakExplosive.Reset()
        JumpToBreakVFX.Disable()

            