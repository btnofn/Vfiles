
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

BasicFunctions := class(creative_device):
    @editable BasicDMGInc : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}


    OnBegin<override>()<suspends>:void=
        block:


    DoDamageBuff(NewAgent : agent, TimeLast : float, IncreaseBy : float) : void=
        BasicDMGInc.SetMagnitude(IncreaseBy)
        BasicDMGInc.SetDuration(TimeLast)
        BasicDMGInc.Pickup(NewAgent)

    DoInvcibilityBuff(NewAgent : agent, TimeLast : float) <suspends>: void=
        if(Player := player[NewAgent], FC:=Player.GetFortCharacter[]):
            FC.SetVulnerability(false)
            Sleep(TimeLast)
            FC.SetVulnerability(true)



 
