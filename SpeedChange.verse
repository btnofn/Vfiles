
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

SpeedChange := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable SpeedClassNumber : int = 100
    @editable SpeedModulator : movement_modulator_device = movement_modulator_device{}

    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = SpeedClassNumber):
                    spawn:
                        SpeedPlayer(Agent)
    SpeedPlayer(Agent:agent)<suspends> : void=
        SpeedModulator.Activate(Agent)