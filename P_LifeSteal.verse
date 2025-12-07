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
using { /Fortnite.com/Game }

#THIS ABILITY STEALS HEALTH FROM OTHER PLAYERS IF EQUIPPED

#Main creative device class
P_LifeSteal := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}

    TT_StealPercent<localizes>:message = "If Enabled, Steals Percentage of Damage Inflicted\n*Required Settings*\nOnly Select One Out Of 'StealPercent' & 'StealSetAmount'"
    TT_StealSetAmount<localizes>:message = "If Enabled, Steals Specific Amount Every Time Damage is Inflicted\n*Required Settings*\nOnly Select One Out Of 'StealPercent' & 'StealSetAmount'"
    @editable{ToolTip := TT_ActivateSound} LifeStealSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_StealPercent} StealPercent : ?type{_X : float where _X >= 0.0, _X <= 1.0} = false
    @editable{ToolTip := TT_StealSetAmount} StealSetAmount : ?float = false
    var EquippedAgents : []agent = array{} 

    #Initializes events
    OnBegin<override>()<suspends>:void=
        EquippedTrigger.TriggeredEvent.Subscribe(EquipAbility)
        UnEquippedTrigger.TriggeredEvent.Subscribe(UnEquipAbility)
        for(Player : GetPlayspace().GetPlayers()){InitializeDamage(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitializeDamage)

    #Adjusts who this ability is equipped for when equipped
    EquipAbility(MAgent : ?agent) : void=
        if(Agent := MAgent?){set EquippedAgents += array{Agent}}
     
    #Adjusts who this ability is equipped for when unequipped
    UnEquipAbility(MAgent : ?agent) : void=
        if(Agent := MAgent?){if(NewArray := EquippedAgents.RemoveFirstElement[Agent]){set EquippedAgents = NewArray}}

    #Initializes damage events for a player
    InitializeDamage(Agent:agent) : void =
        if(FC := Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnPlayerDamaged)
            FC.DamagedShieldEvent().Subscribe(OnPlayerDamaged)

    #Checks to see if the ability should activate
    OnPlayerDamaged(DamageResult: damage_result): void = 
        if: 
            Instigator := DamageResult.Instigator?
            InstigatorAgent := Instigator.GetInstigatorAgent[]
            Target := fort_character[DamageResult.Target]
            TargetAgent := Target.GetAgent[]
            not TargetAgent = InstigatorAgent
            Amount := DamageResult.Amount
        then:
            if(EquippedAgents.Find[InstigatorAgent]):
                HealPlayer(InstigatorAgent,Amount)
                LifeStealSound.Play(InstigatorAgent)

    #Heals the player a set amount
    HealPlayer(Agent:agent , Amount : float) : void =
        if(FC := Agent.GetFortCharacter[]):
            SheildAmount := FC.GetShield()
            HealthAmount := FC.GetHealth()
            if(Percentage := StealPercent?):
                IncreaseAmount := Amount * Percentage
                ShieldHealAmount := (IncreaseAmount - (100.0 - HealthAmount))
                FC.Heal(IncreaseAmount)
                if(ShieldHealAmount > 0.0){FC.SetShield(SheildAmount + ShieldHealAmount)}

            else if(StealAmount := StealSetAmount?):
                ShieldHealAmount := (StealAmount - (100.0 - HealthAmount))
                FC.Heal(StealAmount)
                if(ShieldHealAmount > 0.0){FC.SetShield(SheildAmount + ShieldHealAmount)}