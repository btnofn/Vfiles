<#
====================================================================================================
Copyright (c) 2024 MapAcademy. All rights reserved.

 

This software and its associated documentation files (the "Software") are the

proprietary property of MapAcademy and are protected by copyright law.

 

The Software is provided to you under the terms of the MapAcademy End User

License Agreement (the "License"). You may use, copy, distribute, and modify

the Software solely in accordance with the terms of the License.

 

BY USING THE SOFTWARE, YOU AGREE TO BE BOUND BY THE TERMS OF THE LICENSE.

IF YOU DO NOT AGREE TO THE TERMS OF THE LICENSE, DO NOT USE THE SOFTWARE.

 

The Software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND,

either express or implied, including without limitation any warranties of

MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, or NON-INFRINGEMENT.

For more details, please refer to the MapAcademy End User License Agreement.
====================================================================================================
#>
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

#THIS DEVICE HEALS A PLAYER WITH THIS CLASS SELECTED WHENEVER THEY CROUCH

#Settings to control what type of health is healed when crouched
CrouchToHealType := enum:
    Both
    HealthOnly
    ShieldOnly

#Settings to controlled when part of crouching heals the player
CrouchType := enum:
    Both
    CrouchedOnly
    UncrouchedOnly

#Main Creative Device class
P_CrouchToHeal := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}

    TT_CrouchToHealVFX<localizes>:message = "VFX Spawner that will appear at players location on activation\n*Required Settings*\nEnabled On Phase: None\nClear Particles On Disable: False"
    TT_AmountToHeal<localizes>:message = "Amount To Heal on Activation"
    TT_CrouchSetting<localizes>:message = "Which Type of Crouch Should Activate Ability"
    TT_CrouchToHealSetting<localizes>:message = "What Type of Health Should be Recovered on Ability Activation"
    @editable{ToolTip := TT_CrouchToHealVFX} CrouchToHealVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable{ToolTip := TT_ActivateSound} CrouchToHealSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_AmountToHeal} AmountToHeal : float = 0.0
    @editable{ToolTip := TT_CrouchSetting} CrouchSetting : CrouchType = CrouchType.Both
    @editable{ToolTip := TT_CrouchToHealSetting} CrouchToHealSetting : CrouchToHealType = CrouchToHealType.Both

    #Initializes events
    OnBegin<override>()<suspends>:void=
        EquippedTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Handles the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(FC:= Agent.GetFortCharacter[]):
            race:
                block:
                    loop:
                        MUnEquippedPlayer := UnEquippedTrigger.TriggeredEvent.Await()
                        if(UnEquippedPlayer := MUnEquippedPlayer? , UnEquippedPlayer = Agent):
                            break
                loop:
                    Sleep(0.0)
                    IsCrouched := FC.CrouchedEvent().Await()(1)

                    if(CrouchSetting = CrouchType.Both):
                        ActivateHeal(Agent)

                    else if(CrouchSetting = CrouchType.CrouchedOnly):
                        if(IsCrouched?):
                            ActivateHeal(Agent)
                    else if(CrouchSetting = CrouchType.UncrouchedOnly):
                        if(not IsCrouched?):
                            ActivateHeal(Agent)

    #Plays heal vfx at player location
    PlayVFXAtPlayer(Agent:agent)<suspends> : void=
        if(FC:= Agent.GetFortCharacter[]):  
            PlayerPos := FC.GetTransform().Translation
            if(CrouchToHealVFX.TeleportTo[PlayerPos,IdentityRotation()]){}
            CrouchToHealVFX.Enable()
            Sleep(0.2)
            CrouchToHealVFX.Disable()

    #Heals the player
    ActivateHeal(Agent : agent) : void=
        if(FC:= Agent.GetFortCharacter[]):  
            spawn{PlayVFXAtPlayer(Agent)}
            CrouchToHealSound.Play(Agent)

            SheildAmount := FC.GetShield()
            HealthAmount := FC.GetHealth()
            ShieldHealAmount := (AmountToHeal - (100.0 - HealthAmount))

            if(CrouchToHealSetting = CrouchToHealType.Both):
                FC.Heal(AmountToHeal)
                if(ShieldHealAmount > 0.0){FC.SetShield(SheildAmount + ShieldHealAmount)}

            else if(CrouchToHealSetting = CrouchToHealType.ShieldOnly):
                FC.SetShield(SheildAmount + AmountToHeal)

            else if(CrouchToHealSetting = CrouchToHealType.HealthOnly):
                FC.Heal(AmountToHeal)