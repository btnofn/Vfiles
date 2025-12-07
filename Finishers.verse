
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
PlayerClass := class {
    AgentOB : agent

    var FinisherAvailable : logic = true

    var Finisher1Enabled : logic = true
    var Finisher2Enabled : logic = false
    var Finisher3Enabled : logic = false
    var Finisher4Enabled : logic = false
    var Finisher5Enabled : logic = false
}

FinisherScript := class(creative_device):

    @editable Anchor : creative_prop = creative_prop{}

    @editable WeaponConditionals : []conditional_button_device = array{}
    
    @editable FinisherConditionals : []conditional_button_device = array{}

    @editable FinisherAnim : []cinematic_sequence_device = array{}

    @editable Trigger1 : trigger_device = trigger_device{}
    @editable Trigger2 : trigger_device = trigger_device{}

    @editable LengthOfAnimation : float = 2.35

    @editable DistanceToFinisher : float = 100.0

    @editable FinisherInput : input_trigger_device = input_trigger_device{}

    @editable GUI : hud_message_device = hud_message_device{}

    @editable WaitBeforeCancel : float = 8.0

    var PlayerMap : [agent]PlayerClass = map{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers()) {
            PlayerJoined(Player)
        }

        Sleep(0.2)

        GetPlayspace().PlayerAddedEvent().Subscribe(PlayerJoined)

        if (Button1 := FinisherConditionals[0]) {
            Button1.ActivatedEvent.Subscribe(Button1Activated)
        }
        if (Button2 := FinisherConditionals[1]) {
            Button2.ActivatedEvent.Subscribe(Button2Activated)
        }
        if (Button3 := FinisherConditionals[2]) {
            Button3.ActivatedEvent.Subscribe(Button3Activated)
        }
        if (Button4 := FinisherConditionals[3]) {
            Button4.ActivatedEvent.Subscribe(Button4Activated)
        }
        if (Button5 := FinisherConditionals[4]) {
            Button5.ActivatedEvent.Subscribe(Button5Activated)
        }

    
    Button1Activated(Agent : agent) : void = {
        if (PC := PlayerMap[Agent]) {
            set PC.Finisher1Enabled = true
            set PC.Finisher2Enabled = false
            set PC.Finisher3Enabled = false
            set PC.Finisher4Enabled = false
            set PC.Finisher5Enabled = false
        }
    }

    Button2Activated(Agent : agent) : void = {
        if (PC := PlayerMap[Agent]) {
            set PC.Finisher1Enabled = false
            set PC.Finisher2Enabled = true
            set PC.Finisher3Enabled = false
            set PC.Finisher4Enabled = false
            set PC.Finisher5Enabled = false
        }
    }

    Button3Activated(Agent : agent) : void = {
        if (PC := PlayerMap[Agent]) {
            set PC.Finisher1Enabled = false
            set PC.Finisher2Enabled = false
            set PC.Finisher3Enabled = true
            set PC.Finisher4Enabled = false
            set PC.Finisher5Enabled = false
        }
    }

    Button4Activated(Agent : agent) : void = {
        if (PC := PlayerMap[Agent]) {
            set PC.Finisher1Enabled = false
            set PC.Finisher2Enabled = false
            set PC.Finisher3Enabled = false
            set PC.Finisher4Enabled = true
            set PC.Finisher5Enabled = false
        }
    }

    Button5Activated(Agent : agent) : void = {
        if (PC := PlayerMap[Agent]) {
            set PC.Finisher1Enabled = false
            set PC.Finisher2Enabled = false
            set PC.Finisher3Enabled = false
            set PC.Finisher4Enabled = false
            set PC.Finisher5Enabled = true
        }
    }
    
    PlayerJoined(Player : player) : void = {
        if (FortChar := Player.GetFortCharacter[], Agent := agent[Player]) {
            FortChar.DamagedEvent().Subscribe(PlayerDamaged)

            FinisherInput.UnregisterAll()

            if (not PlayerMap[Agent]) {
                if (set PlayerMap[Agent] = PlayerClass{AgentOB := Agent}) {}
                if (PC := PlayerMap[Agent]) {
                    set PC.FinisherAvailable = true
                }
            }
        }
    }


    PlayerDamaged(Result : damage_result) : void = {
        if {
            Instigator := Result.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            TargetFortChar := fort_character[Result.Target]
            InstigatorFortChar := Agent.GetFortCharacter[]
            PC := PlayerMap[Agent]
        } then {
            if (PC.FinisherAvailable = true) {
                set PC.FinisherAvailable = false
                spawn{CheckIfPlayerIsCloseToEnemy(TargetFortChar, InstigatorFortChar, Agent, PC)}
            }
        }
    }

    CheckIfPlayerIsCloseToEnemy(TargetFortChar : fort_character, InstigatorFortChar : fort_character, Agent : agent, PC : PlayerClass) <suspends> : void = {
        loop:
            Sleep(0.2)
            if (TargetFortChar.IsActive[] and InstigatorFortChar.IsActive[]) {
                    TargetLocation := TargetFortChar.GetTransform().Translation
                    InstigatorLocation := InstigatorFortChar.GetTransform().Translation
        
                    DistanceBetweenPlayers := Distance(TargetLocation, InstigatorLocation)
                    TargetHealth := TargetFortChar.GetHealth()
                
                    if (TargetHealth <= 40.0) {
                        FinisherInput.Register(Agent)
                        if (DistanceBetweenPlayers <= DistanceToFinisher) {
                            GUI.Show(Agent)
                            sync {
                                block:
                                    FinisherInput.PressedEvent.Await()
                                    set PC.FinisherAvailable = true
                                    InitiateFinisher(TargetFortChar, InstigatorFortChar, Agent, PC)
                                    FinisherInput.Unregister(Agent)
                                    GUI.Hide(Agent)
                                block:
                                    Sleep(WaitBeforeCancel)
                                    FinisherInput.Unregister(Agent)
                                    set PC.FinisherAvailable = true
                            }
                        } else {
                            FinisherInput.Unregister(Agent)
                            set PC.FinisherAvailable = true
                            GUI.Hide(Agent)
                            break
                        }
                    } else {
                        FinisherInput.Unregister(Agent)
                        set PC.FinisherAvailable = true
                        GUI.Hide(Agent)
                        break
                    }
            } else {
                FinisherInput.Unregister(Agent)
                set PC.FinisherAvailable = true
                GUI.Hide(Agent)
                break
            }    
    }


    InitiateFinisher(TargetFortChar : fort_character, InstigatorFortChar : fort_character, Agent : agent, PC : PlayerClass) : void = {
        if (not InstigatorFortChar = TargetFortChar) {
            var IsHolding : logic = false
            for (Conditional : WeaponConditionals) {
                if (Conditional.IsHoldingItem[Agent]) {
                    set IsHolding = true
                }
            }

            if (IsHolding = false) {
                spawn{StartFinisherAnimation(TargetFortChar, InstigatorFortChar, PC)}
            }
        }
    }


    StartFinisherAnimation(TargetFortChar : fort_character, InstigatorFortChar : fort_character, PC : PlayerClass) <suspends>: void = {
        if {
            TargetAgent := TargetFortChar.GetAgent[]
            InstigatorAgent := InstigatorFortChar.GetAgent[]
        } then {
            sync {
                block:
                    Sleep(0.1)
                    InstigatorFortChar.PutInStasis(stasis_args{})

                block:
                    TargetFortChar.PutInStasis(stasis_args{})
        
                    TargetFortChar.SetVulnerability(false)
                    InstigatorFortChar.SetVulnerability(false)
        
                    TargetFortChar.Hide()
                    InstigatorFortChar.Hide()
        
                    Trigger1.Trigger(TargetAgent)
                    Trigger2.Trigger(InstigatorAgent)

                    var CinematicAnimation : ?cinematic_sequence_device = false
        
                    if (PC.Finisher1Enabled = true, Sequence := FinisherAnim[0]) {
                        set CinematicAnimation = option{Sequence}
                        Sequence.Play()
                    } else if (PC.Finisher2Enabled = true, Sequence := FinisherAnim[1]) {
                        set CinematicAnimation = option{Sequence}
                        Sequence.Play()
                    } else if (PC.Finisher3Enabled = true, Sequence := FinisherAnim[2]) {
                        set CinematicAnimation = option{Sequence}
                        Sequence.Play()
                    } else if (PC.Finisher4Enabled = true, Sequence := FinisherAnim[3]) {
                        set CinematicAnimation = option{Sequence}
                        Sequence.Play()
                    } else if (PC.Finisher5Enabled = true, Sequence := FinisherAnim[4]) {
                        set CinematicAnimation = option{Sequence}
                        Sequence.Play()
                    }
        
                    InstigatorLocation := InstigatorFortChar.GetTransform().Translation
                    InstigatorRotation := InstigatorFortChar.GetTransform().Rotation
        
                    if (Anchor.TeleportTo[InstigatorLocation, InstigatorRotation]) {}
        
                    Sleep(LengthOfAnimation)
        
                    StopFinisherAnimation(TargetFortChar, InstigatorFortChar, CinematicAnimation)
            }
        }
    }

    StopFinisherAnimation(TargetFortChar : fort_character, InstigatorFortChar : fort_character, CinematicAnimation : ?cinematic_sequence_device) <suspends>: void = {
        TargetFortChar.ReleaseFromStasis()
        InstigatorFortChar.ReleaseFromStasis()

        TargetFortChar.SetVulnerability(true)
        InstigatorFortChar.SetVulnerability(true)

        TargetFortChar.Show()
        InstigatorFortChar.Show()
        
        if (AnimationDevice := CinematicAnimation?) {
            AnimationDevice.Stop()
        }

        TargetFortChar.Damage(500.0)
    }


<#

# PLAYER REFERENCE AND ANCHOR PROP IN VIEWPORT - https://pastebin.com/zyn4S7d9

# OTHER DEVICES - https://pastebin.com/sR38xPN1

#>