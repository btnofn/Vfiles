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
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }

#THIS DEVICE MANAGES ALL ABILITIES

#Class for each player that holds their current power
Custom_PlayerPower := class<unique>(): 
    Player : player
    var EquippedPower : Power = Power{}
    var CooldownSettings : CooldownSetting = CooldownSetting{}
    var OnCooldown : logic = false
    var CurrentTimer : UITimer = UITimer{}

    #Handles the cooldown for abilities
    HandleCooldown(Duration : float) : logic=
        if(OnCooldown?):
            CooldownSettings.OnCooldownHUD.Show(Player)
            return false
        else:
            set OnCooldown = true
            if(NewTimer := CooldownSettings.TimerSettings?):
                spawn{HandleTimer(NewTimer,Duration)}

            if(NewBar := CooldownSettings.BarSettings?):
                spawn{HandleBar(NewBar,Duration)}
            return true
    
    #Resets the cooldown
    ResetCooldown() : void=
        CurrentTimer.CancelEvent.Signal()

    #Handles the UI Timer if enabled for cooldown
    HandleTimer(TimerSettings : TimerSetting , Duration : float)<suspends> : void=
        if:
            NewMinutes := Int[Duration / 60.0]
            NewSeconds := Int[Duration - (NewMinutes * 60.0)]
        then:
            NewUITimer := UITimer{Minutes := NewMinutes, Seconds := NewSeconds, TimerMessage := TimerSettings.TimerMessage}
            NewUITimer.TimerCanvas.AddWidget(TimerSettings.TimerPosition.MakeCanvasSlot(NewUITimer.TimerText,false))
            if(PlayerUI := GetPlayerUI[Player]):
                set CurrentTimer = NewUITimer
                PlayerUI.AddWidget(NewUITimer.TimerCanvas)
                spawn{NewUITimer.HandleTimer(Player)}
                NewUITimer.TimerEndEvent.Await()
                NewUITimer.TimerCanvas.SetVisibility(widget_visibility.Hidden)
                PlayerUI.RemoveWidget(NewUITimer.TimerCanvas)
                set OnCooldown = false
                
    #Handles the UI Bar if enabled for cooldown
    HandleBar(BarSettings : BoxPvPBarSetting , Duration : float)<suspends> : void=
        if(PlayerUI := GetPlayerUI[Player]):
            var BarCanvas : canvas = canvas{}
            var BackgroundBarWid : color_block = color_block{}
            var ProgressBarWid : color_block = color_block{}
            var BarStackBox : stack_box = stack_box{Orientation := orientation.Horizontal}
            var ProgressBarScalar : color_block = color_block{DefaultColor := White, DefaultOpacity := 0.0}
            var XValue : float = 0.0
            BackgroundBarWid.SetColor(BarSettings.BackgroundBarColor)
            ProgressBarWid.SetColor(BarSettings.ProgressBarColor)
            BackgroundBarWid.SetOpacity(BarSettings.BackgroundBarOpacity)
            ProgressBarScalar.SetDesiredSize(vector2{X:=BarSettings.BarPosition.Right, Y:= BarSettings.BarPosition.Bottom})
            set BarCanvas = canvas:
                Slots := array:
                    BarSettings.BarPosition.MakeCanvasSlot(BackgroundBarWid, option{CanvasPosition{MaybeZOrder := option{0}}})
                    BarSettings.BarPosition.MakeCanvasSlot(BarStackBox, option{CanvasPosition{MaybeZOrder := option{1}}})      
            BarStackBox.AddWidget(stack_box_slot:
                Widget := ProgressBarWid
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
                Distribution := option{1.0}
            )
            BarStackBox.AddWidget(stack_box_slot:
                Widget := ProgressBarScalar
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
            )
            PlayerUI.AddWidget(BarCanvas)
            IncreaseAmount := (BarSettings.BarPosition.Right/30.0) * (1.0/Duration)
            loop:
                Sleep(0.0)
                set XValue += IncreaseAmount
                ProgressBarScalar.SetDesiredSize(vector2{X:=BarSettings.BarPosition.Right - XValue, Y:= BarSettings.BarPosition.Bottom})
                if(XValue >= BarSettings.BarPosition.Right):
                    BarCanvas.SetVisibility(widget_visibility.Hidden)
                    PlayerUI.RemoveWidget(BarCanvas)
                    set OnCooldown = false
                    break

#Settings for the cooldown
CooldownSetting := class<concrete>():
    TT_TimerSettings<localizes>:message = "Enables and Controls how a timer will appear on the UI"
    TT_BarSettings<localizes>:message = "Enables and Controls how a progress bar will appear on the UI"
    TT_OnCooldownHUD<localizes>:message = "Shows Message To Player If On Cooldown\n*Required Settings*\nMessage Recipient: Triggering Player"
    @editable{ToolTip := TT_TimerSettings} TimerSettings : ?TimerSetting = false
    @editable{ToolTip := TT_BarSettings} BarSettings : ?BoxPvPBarSetting = false
    @editable{ToolTip := TT_OnCooldownHUD} OnCooldownHUD : hud_message_device = hud_message_device{}

#Settings for the timer
TimerSetting := class<concrete>():
    TT_TimerMessage<localizes>:message = "Message to Display Before Timer"
    @editable{ToolTip := TT_Position} TimerPosition : CanvasPosition = CanvasPosition{}
    @editable{ToolTip := TT_TimerMessage} TimerMessage : string = ""

#Settings for the bar
BoxPvPBarSetting := class<concrete>():
    @editable{ToolTip := TT_Position} BarPosition : CanvasPosition = CanvasPosition{}
    @editable BackgroundBarColor : color = color{}
    @editable BackgroundBarOpacity : type{_X:float where 0.000000 <= _X, _X <= 1.000000} = 1.0
    @editable ProgressBarColor : color = color{}

#Class for each power the holds a unique identifier and activating triggers
Power := class<concrete>():
    TT_PowerHUD<localizes>:message = "Shows UI Image To Player With Power Equipped\n*Required Settings*\nMessage Recipient: Triggering Player\nShow for Duration: False\nPriority: Disabled\nLayer: 1"
    TT_PowerItems<localizes>:message = "Items Granted To Player When Power Equipped\n*Required Settings*\nOn Grant Action: Clear Inventory\nGrant: All Items\nReceiving Players: Triggering Player"
    TT_PowerEffects<localizes>:message = "Effects Applied to Player While Power Is Equipped"
    TT_PowerEliminationEffects<localizes>:message = "Effects Activated Upon a Player Eliminating Another Player or Being Eliminated With this Power Equipped"
    var AbilityManager : Manager_Ability = Manager_Ability{}
    var ResetDevices : ResetDevice = ResetDevice{}
    @editable{ToolTip := TT_ActivateTrigger} PowerActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_EquipTrigger} PowerEquipTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} PowerUnEquipTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_PowerHUD} PowerHUD : hud_message_device = hud_message_device{}
    @editable{ToolTip := TT_PowerItems} PowerItems : item_granter_device = item_granter_device{}
    @editable{ToolTip := TT_PowerEffects} PowerEffects : AbilityEffect = AbilityEffect{}
    @editable{ToolTip := TT_PowerEliminationEffects} PowerEliminationEffects : EliminationEffect = EliminationEffect{}
    var Identifier : int = 0

    #Equips the power for a player
    EquipPower(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            if(CP := AbilityManager.PlayersMap[Agent]):
                set CP.EquippedPower = Self
                PowerHUD.Show(Agent)
                PowerItems.GrantItem(Agent)
                spawn{PowerEffects.Enable(Agent)}

    #Unequip Power
    UnEquipPower(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            if(CP := AbilityManager.PlayersMap[Agent]):
                PowerHUD.Hide(Agent)
                set CP.EquippedPower = Power{}
                ResetDevices.Reset(Agent)

#Class for each power the holds a unique identifier and activating triggers
ResetDevice := class<concrete>():
    TT_ClearAllVFXTrigger<localizes>:message = "Trigger to Clear all VFX Powerups\n*Required Settings*\nConnect All VFX Powerup's 'Clear' function to this Trigger's 'TriggeredEvent'"
    TT_BaseDamageAmp<localizes>:message = "Damage Amplifier Powerup to reset damage amplifiers\n*Required Settings*\nDamage Multiplier: 1.0\nInfinite Effect Duration: True\nRespawn: True\nTime To Respawn: 0.0"
    TT_BaseMovementModulator<localizes>:message = "Movement Modulator to reset movement modulators\n*Required Settings*\nSpeed: 1.0\nInfinite Duration: True"
    @editable{ToolTip := TT_ClearAllVFXTrigger} ClearAllVFXTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_BaseDamageAmp} BaseDamageAmp : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable{ToolTip := TT_BaseMovementModulator} BaseMovementModulator : movement_modulator_device = movement_modulator_device{}
    @editable BaseClassSelector : class_and_team_selector_device = class_and_team_selector_device{}
    @editable ClearItemsRemover : item_remover_device = item_remover_device{}

    Reset(Agent:agent) : void=
        ClearAllVFXTrigger.Trigger(Agent)
        BaseDamageAmp.Pickup(Agent)
        BaseMovementModulator.Activate(Agent)
        BaseClassSelector.ChangeTeamAndClass(Agent)
        ClearItemsRemover.Remove(Agent)
  
#Main creative device class
Manager_Ability := class(creative_device):
    @editable RemoteManager : signal_remote_manager_device = signal_remote_manager_device{}
    @editable AllPowers : []Power = array{}
    @editable ResetDevices : ResetDevice = ResetDevice{}
    @editable UsingBoxPvP : logic = false
    var AllowAbilityActivation : logic = false

    @editable CooldownSettings : CooldownSetting = CooldownSetting{}
    var PlayersMap : [player]Custom_PlayerPower = map{}  
    var EffectedPlayers : []player = array{}
    
    #Initializes all players and events
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()){InitiatePlayer(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitiatePlayer)
        GetPlayspace().PlayerRemovedEvent().Subscribe(RemoveFromPlayersMap)
        SetUpPowers()
        RemoteManager.PrimarySignalEvent.Subscribe(ActivatePower)
        RemoteManager.SecondarySignalEvent.Subscribe(ActivatePower)

    #Removes the player from a map
    RemoveFromPlayersMap(Agent:agent) : void=
        if(Player := player[Agent], Exists := PlayersMap[Player]):
            if(NewMap := PlayersMap.WithRemovedKey(Player)?):
                set PlayersMap = NewMap

    #Initializes the player into the playermap
    InitiatePlayer(Agent:agent): void=
        if(Player := player[Agent]):    
            if(PlayerExists := PlayersMap[Player]):     
            else:
                if(set PlayersMap[Player] = Custom_PlayerPower{       
                    Player := Player
                    CooldownSettings := CooldownSettings
                    }){}

    #Initializes all powers
    SetUpPowers() : void=
        for(idx -> P : AllPowers):
            set P.AbilityManager = Self
            set P.Identifier = idx + 1
            set P.ResetDevices = ResetDevices
            P.PowerEquipTrigger.TriggeredEvent.Subscribe(P.EquipPower)
            P.PowerUnEquipTrigger.TriggeredEvent.Subscribe(P.UnEquipPower)

    #Activates the power for an agent
    ActivatePower(Agent:agent) : void=
        if(CP := PlayersMap[Agent]):
            if(UsingBoxPvP?):
                if(AllowAbilityActivation?):
                    CP.EquippedPower.PowerActivateTrigger.Trigger(Agent)
            else:
                CP.EquippedPower.PowerActivateTrigger.Trigger(Agent)

    #Returns the current effected players
    GetPlayers()<transacts> : []player=
        if(UsingBoxPvP?):
            return EffectedPlayers
        else:
            return GetPlayspace().GetPlayers()