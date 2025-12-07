

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
ExchangeHealthForSpeedAndStrength := class(creative_device):

    @editable ExchangeSoundDevice : audio_player_device = audio_player_device{}
    @editable ExchangeDamageamp : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable ExchangeSpeedMod : movement_modulator_device = movement_modulator_device{}
    @editable ExchangeVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    var temphealth : float = 0.0
    var newhealth : float = 0.0
    var tempshield : float = 0.0
    var newshield : float = 0.0
    @editable ReduceHealthByAmount : float = 0.0
    @editable ScaleDMGByAmount : float = 0.0


    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable ExchangeTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}



    

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        ExchangeDamageamp.SetMagnitude(ScaleDMGByAmount)
        ExchangeTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        ExchangeTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false




    HealthtoStrength(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            
            ExchangeTimer.Start(Agent)
            set MaybeCooldown=true

            if (Player := player[Agent], FC := Player.GetFortCharacter[]):
                set tempshield = FC.GetShield()
                if (tempshield <= ReduceHealthByAmount):
                    set newshield = 0.0
                    set temphealth = FC.GetHealth()
                    set newhealth = temphealth - (ReduceHealthByAmount - tempshield)
                    FC.SetShield(newshield)
                    FC.SetHealth(newhealth)

                else:
                    set  tempshield = FC.GetShield()
                    set newshield = tempshield - ReduceHealthByAmount
                    FC.SetShield(newshield)

            ExchangeVFX.Pickup(Agent)
            ExchangeDamageamp.Pickup(Agent)  
            ExchangeSpeedMod.Activate(Agent)
        else:
            CooldownMSG.Show(Agent)
        