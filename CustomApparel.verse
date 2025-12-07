
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }


CustomApparel := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable CustomApparelClassNumber : int = 100

    @editable CustomApparelVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable CustomApparelTrigger : trigger_device = trigger_device{}
    

    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                CustomApparelTrigger.Trigger(Agent)
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = CustomApparelClassNumber):
                    spawn:
                        CustomApparelPlayer(Agent)
    CustomApparelPlayer(Agent:agent) <suspends> : void=
        CustomApparelVFX.Pickup(Agent)