
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

DamageChange := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable DamageClassNumber : int = 100
    @editable DamageAMP : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable IncreaseDMGBy : float = 0.0

    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = DamageClassNumber):
                    spawn:
                        DMGPlayer(Agent)
    DMGPlayer(Agent:agent)<suspends> : void=
        DamageAMP.SetMagnitude(IncreaseDMGBy)
        DamageAMP.Pickup(Agent)