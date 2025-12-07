
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }


SecondLife := class(creative_device):

    @editable GameStartDevice : GameStart = GameStart{}
    @editable SecondLifeClassNumber : int = 100
    @editable SecondLifeSound : audio_player_device = audio_player_device{}


    @editable SecondLifeTimeUntilRevive : float = 1.0
    @editable SecondLifeDownDevice : down_but_not_out_device = down_but_not_out_device{}



    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        SecondLifeDownDevice.Disable()
        SecondLifeDownDevice.Enable()
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = SecondLifeClassNumber):
                    spawn:
                        CheckForDowned(FC)

    CheckForDowned(FC : fort_character)<suspends> : void=
        if(Agent := FC.GetAgent[]):
            loop:
                Sleep(0.1)
                if(FC.IsDownButNotOut[]):
                    Sleep(SecondLifeTimeUntilRevive)
                    SecondLifeDownDevice.Revive(Agent)
                    SecondLifeSound.Play(Agent)
                    SecondLifeDownDevice.Disable()
                    break



            