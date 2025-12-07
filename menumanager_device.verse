using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Fortnite.com/FortPlayerUtilities }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
 
########  ########     ###     ######    #######  ##    ## ########     ###     ######   ######## 
##     ## ##     ##   ## ##   ##    ##  ##     ## ###   ## ##     ##   ## ##   ##    ##  ##       
##     ## ##     ##  ##   ##  ##        ##     ## ####  ## ##     ##  ##   ##  ##        ##       
##     ## ########  ##     ## ##   #### ##     ## ## ## ## ########  ##     ## ##   #### ######   
##     ## ##   ##   ######### ##    ##  ##     ## ##  #### ##   ##   ######### ##    ##  ##       
##     ## ##    ##  ##     ## ##    ##  ##     ## ##   ### ##    ##  ##     ## ##    ##  ##       
########  ##     ## ##     ##  ######    #######  ##    ## ##     ## ##     ##  ######   ########
 
<# 
  - UI Device Version: 3.0 -
    Patch notes:
        NEW TextUI class! Allows for addition of non-interactable text!
        The TextUI Class can:
            -Display custom text
            -Display text in a set color range of RBG values
            -Display text in a set opacity range between 0 and 1
            -Disable and Hide (and vice versa)
        
    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    BIG SHOUT OUT TO - @NoahUEFN - ON TWITTER!
    They did a majority of the TextUI class and reached out to me to implement it here!
    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
    Complete up-to-date snippet can be found here: https://dev.epicgames.com/community/snippets/0pVb/fortnite-fully-customizable-ui-button-verse-device
 
    Need help setting up the device? Follow the tutorial found here: https://www.youtube.com/watch?v=BciWUt_RXcc
#>
 
# Locks the choice of button styles to the current three: {button_loud = 1, button_quiet = 2, button_regular = 3}
buttonstyle_int := type{_X : int where 1 <= _X, 3 >= _X}
color_range := type{_X : int where 0 <= _X, 255 >= _X}
opacity_range := type{_X:float where 0.000000 <= _X, _X <= 1.000000}
 
menudevice := class(creative_device):
 
    # The trigger that will open up this ui menu
    @editable ShowUIOnTrigger : trigger_device = trigger_device{}
 
    # The trigger that will hide this ui menu
    @editable HideUIOnTrigger : trigger_device = trigger_device{}
 
    # Do we want this UI to be interactable?
    # Keep this on if you want players to be able to click buttons!
    @editable IsInteractable : logic = true
 
    # Do we want to remove players who are cheating by using an auto clicker?
    # IT IS RECOMMENDED YOU LEAVE THIS SETTING TRUE, AS AUTO CLICKERS ON THIS UI DEVICE CAN PREVENT OTHERS FROM CLICKING/ACCESSING BUTTONS!
    @editable UseAntiAutoClickerDetection : logic = true
 
    # Toggles Debug mode, which Prints out which triggers are activated when clicking a button
    @editable ToggleDebugMode : logic = false
 
    # An array of button ui, configurable via the editor
    @editable var ButtonUI : []buttonui = array{}
 
    # An array of text ui, configurable via the editor
    @editable var TextUI : []textui = array{}
 
    # A map of type ?canvas used to find the canvas tied to a player
    var MaybeMyUIPerPlayer : [player]?canvas = map{}
 
    var ClickCountPerAgent : [agent]int = map{}
    var ClickTimePerAgent : [agent]float = map{}
 
    StringToMessage<localizes>(String : string):message = "{String}"
 
    OnBegin<override>()<suspends>:void=
        InitButtonFunctions()
        ShowUIOnTrigger.TriggeredEvent.Subscribe(OpenUI)
        HideUIOnTrigger.TriggeredEvent.Subscribe(HideUI)
 
    # Opens the UI
    OpenUI(Agent : ?agent):void=
        if(ValidAgent := Agent?, Player := player[ValidAgent], PlayerUI := GetPlayerUI[Player]):
            if(MyUI := MaybeMyUIPerPlayer[Player]?):
                PlayerUI.RemoveWidget(MyUI)
                if(set MaybeMyUIPerPlayer[Player] = false) {}
            else:
                NewUI := CreateMyUI(ValidAgent)
                if(IsInteractable?):
                    PlayerUI.AddWidget(NewUI, player_ui_slot{InputMode := ui_input_mode.All})
                else:
                    PlayerUI.AddWidget(NewUI, player_ui_slot{InputMode := ui_input_mode.None})
                if(set MaybeMyUIPerPlayer[Player] = option{NewUI}) {}
 
    # Increments the current click count of this agent
    (Agent : agent).IncrementClickCount():void=
        if(CurrentClickCount := ClickCountPerAgent[Agent]):
            if(set ClickCountPerAgent[Agent] = (CurrentClickCount + 1)){}
        else:
            set ClickCountPerAgent = ConcatenateMaps(ClickCountPerAgent, map{Agent => 1})
 
    (Agent : agent).ResetClickCount():void=
        if(set ClickCountPerAgent[Agent] = 0){}
 
    # Tracks the click count
    # Kicks the player if they click a button 20 times in under 1.5 seconds (Only possible via an Auto-Clicker cheating program)
    (Agent : agent).TrackClickCount():void=
        CurrentTime := GetSimulationElapsedTime()
        if(StartTime := ClickTimePerAgent[Agent]):
            if((CurrentTime - StartTime) < 1.5):
                if(CurrentClickCount := ClickCountPerAgent[Agent]):
                    if(CurrentClickCount > 20):
                        # Kicks the player for excessive spamming of a button (using an auto-clicker)
                        Agent.SendAgentToLobby()
            else:
                Agent.ResetClickCount()
                if(set ClickTimePerAgent[Agent] = CurrentTime){}
        else:
            set ClickTimePerAgent = ConcatenateMaps(ClickTimePerAgent, map{Agent => CurrentTime})
 
    # Sends the agent to the lobby
    (Agent : agent).SendAgentToLobby():void=
        if(ThisPlayer := player[Agent]):
            ThisPlayer.SendToLobby()
 
    # Deletes the UI. Used with 'HideUIOnTrigger'
    HideUI(Agent : ?agent):void=
        if(ValidAgent := Agent?):
            ValidAgent.DeleteCanvas()
 
    # Creates the UI
    CreateMyUI(Agent : agent) : canvas = 
        for(CurrButtonUI : ButtonUI):
            ThisText := CurrButtonUI.ButtonText
            case(CurrButtonUI.ButtonStyle):
                1 => 
                    ThisButtonUI := button_loud{DefaultText := StringToMessage(ThisText)}
                    ThisButtonUI.OnClick().Subscribe(HandleSelectedUIButton)
                    if(set CurrButtonUI.WidgetPerPlayer[Agent] = ThisButtonUI){}
                2 =>
                    ThisButtonUI := button_quiet{DefaultText := StringToMessage(ThisText)}
                    ThisButtonUI.OnClick().Subscribe(HandleSelectedUIButton)
                    if(set CurrButtonUI.WidgetPerPlayer[Agent] = ThisButtonUI){}
 
                3 =>
                    ThisButtonUI := button_regular{DefaultText := StringToMessage(ThisText)}
                    ThisButtonUI.OnClick().Subscribe(HandleSelectedUIButton)
                    if(set CurrButtonUI.WidgetPerPlayer[Agent] = ThisButtonUI){}
 
                _ => 
                    Print("~ERROR: ButtonStyle integer over/under-flow")
            Agent.LoadButtonState(CurrButtonUI)
 
        for(CurrTextUI : TextUI):
            ThisText := CurrTextUI.MainText
            ThisTextUI := text_block{DefaultText := StringToMessage(ThisText), DefaultTextColor := MakeColorFromSRGBValues(CurrTextUI.TextColor.Red, CurrTextUI.TextColor.Green, CurrTextUI.TextColor.Blue), DefaultTextOpacity := CurrTextUI.TextOpacity}
            if(set CurrTextUI.TextWidgetPerPlayer[Agent] = ThisTextUI){}
 
        CanvasArray := ReturnCanvasSlots(Agent)
        MyInteractableButtons : canvas = canvas:
            Slots := CanvasArray
        return MyInteractableButtons
 
    # Returns an array of canvas_slot
    ReturnCanvasSlots(Agent : agent):[]canvas_slot=
        var CanvasSlotArray : []canvas_slot = array{}
        for(ThisButtonUI : ButtonUI):
            if(ThisWidget := ThisButtonUI.WidgetPerPlayer[Agent]):
                ThisSlot := canvas_slot:
                    Offsets := margin{Top := ThisButtonUI.ButtonPosition.Y, Left := ThisButtonUI.ButtonPosition.X, Bottom := ThisButtonUI.ButtonSize.Y, Right := ThisButtonUI.ButtonSize.X}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := ThisWidget
                set CanvasSlotArray += array{ThisSlot}
        for(ThisTextUI : TextUI):
            if(ThisWidget := ThisTextUI.TextWidgetPerPlayer[Agent]):
                ThisSlot := canvas_slot:
                    Offsets := margin{Top := ThisTextUI.TextPosition.Y, Left := ThisTextUI.TextPosition.X, Bottom := ThisTextUI.TextSize.Y, Right := ThisTextUI.TextSize.X}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := ThisWidget
                set CanvasSlotArray += CanvasSlotArray + array{ThisSlot}
        return CanvasSlotArray
 
    # Deletes the canvas using a widget_message
    DeleteUI(Message : widget_message) : void=
        if(PlayerUI := GetPlayerUI[Message.Player], MyUI := MaybeMyUIPerPlayer[Message.Player]?):
            PlayerUI.RemoveWidget(MyUI)
            if(set MaybeMyUIPerPlayer[Message.Player] = false) {}
 
    # Deletes the canvas
    (Agent : agent).DeleteCanvas() : void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            if(MyUI := MaybeMyUIPerPlayer[Player]?):
                PlayerUI.RemoveWidget(MyUI)
                if(set MaybeMyUIPerPlayer[Player] = false) {}
 
    # Handles the button click
    HandleSelectedUIButton(Message : widget_message):void=
        Player := Message.Player
        if(UseAntiAutoClickerDetection?):
            Player.IncrementClickCount()
            Player.TrackClickCount()
        if(PlayerUI := GetPlayerUI[Message.Player], MyUI := MaybeMyUIPerPlayer[Message.Player]?):
            ThisWidget := Message.Source
            StaleButtonUI := Player.FindButtonUI(ThisWidget)
            if(ThisButtonUI := StaleButtonUI?):
                if(ThisButtonUI.RemovesUIOnClick?):
                    DeleteUI(Message)
                ThisButtonUI.ActivateTrigger(Player)
            else if(ToggleDebugMode?):
                Print("~ERROR: No buttonui found!")
 
    # Finds the button with the agent information
    (Agent : agent).FindButtonUI(ThisWidget : widget):?buttonui=
        for(ThisButtonUI : ButtonUI):
            if(StaleWidget := ThisButtonUI.WidgetPerPlayer[Agent]):
                if(ThisWidget = StaleWidget):
                    return option{ThisButtonUI}
        return false
 
    # Activates all triggers associated with this button click
    (ThisButtonUI : buttonui).ActivateTrigger(Player : player):void=
        ThisSignalPackage := ThisButtonUI.FindTrigger(Player)
        # Checks the buttonui if player information should be sent to the trigger destination
        if(ThisSignalPackage(1)?):
            ThisSignalPackage(0).Trigger(Player)
            if(ToggleDebugMode?):
                Print("~LOG: Activated trigger(s) via instigator")
            return
        ThisSignalPackage(0).Trigger()
        if(ToggleDebugMode?):
            Print("~LOG: Activated trigger(s) without instigator")
 
    (ThisButtonUI : buttonui).FindTrigger(Player : player):tuple(trigger_device, logic)=
        return (ThisButtonUI.ButtonSignal_Send.TriggerToActivate, ThisButtonUI.ButtonSignal_Send.SendInstigator)
 
    # Loads the states of all buttonui's that have 'SaveButtonState' turned on
    (Agent : agent).LoadButtonState(ThisButtonUI : buttonui):void=
        if(ThisWidget := ThisButtonUI.WidgetPerPlayer[Agent]):
            if(ThisButtonUI.GetInitialEnabledState(Agent)?):
                ThisWidget.SetEnabled(false)
            if(ThisButtonUI.GetInitialVisibleState(Agent)?):
                ThisWidget.SetVisibility(widget_visibility.Collapsed)
 
            if(ThisButtonUI.SaveButtonState?):
                if(ThisEnabledState := ThisButtonUI.EnabledStateMap[Agent]):
                    ThisButtonUI.SetEnabledState(ThisWidget, ThisEnabledState)
                if(ThisVisibleState := ThisButtonUI.VisibleStateMap[Agent]):
                    ThisButtonUI.SetVisibleState(ThisWidget, ThisVisibleState)
        else if(ToggleDebugMode?):
            Print("~ERROR: Failed to fetch widget!")
 
    # Process for reloading the ui when a button must change text
    ReloadUI(Agent : ?agent):void=
        if(ThisAgent := Agent?):
            ThisAgent.DeleteCanvas()
            OpenUI(option{ThisAgent})
 
    # Initializes the 'Signal_Recieve' tab for each button ui
    InitButtonFunctions():void=
        for(ThisButtonUI : ButtonUI):
            ThisButtonUI.ButtonSignal_Recieve.EnableButtonOnTrigger.TriggeredEvent.Subscribe(ThisButtonUI.EnableWidget) 
            ThisButtonUI.ButtonSignal_Recieve.DisableButtonOnTrigger.TriggeredEvent.Subscribe(ThisButtonUI.DisableWidget) 
 
            ThisButtonUI.ButtonSignal_Recieve.ShowButtonOnTrigger.TriggeredEvent.Subscribe(ThisButtonUI.ShowWidget)
            ThisButtonUI.ButtonSignal_Recieve.HideButtonOnTrigger.TriggeredEvent.Subscribe(ThisButtonUI.HideWidget)
        for(ThisTextUI : TextUI):
            ThisTextUI.TextSignal_Recieve.EnableTextOnTrigger.TriggeredEvent.Subscribe(ThisTextUI.EnableWidget) 
            ThisTextUI.TextSignal_Recieve.DisableTextOnTrigger.TriggeredEvent.Subscribe(ThisTextUI.DisableWidget) 
 
            ThisTextUI.TextSignal_Recieve.ShowTextOnTrigger.TriggeredEvent.Subscribe(ThisTextUI.ShowWidget) 
            ThisTextUI.TextSignal_Recieve.HideTextOnTrigger.TriggeredEvent.Subscribe(ThisTextUI.HideWidget) 
 
 
 
buttonui := class<concrete>():
 
    @editable var ButtonText : string = "Main Text"
    @editable var ButtonPosition : vector2 = vector2{}
    @editable var ButtonSize : vector2 = vector2{X := 475.0, Y:= 80.0}
 
    # 'ButtonStyle' key: {button_loud = 1, button_quiet = 2, button_regular = 3}
    @editable var ButtonStyle : buttonstyle_int = 3
 
    # Do we want this button to remove the entire UI on click? (Ex: An exit button)
    @editable RemovesUIOnClick : logic = true
 
    # Do we want this button to be disabled when this UI is shown?
    # NOTE: If 'SaveButtonState' is NOT turned on for this button, the button will ALWAYS be disabled upon opening the menu!
    @editable IsInitiallyDisabled : logic = false
 
    # Do we want this button to be hidden when this UI is shown? 
    # NOTE: If 'SaveButtonState' is NOT turned on for this button, the button will ALWAYS be hidden upon opening the menu!
    @editable IsInitiallyHidden : logic = false
 
    # Saves the state the button is in even after exiting the UI. Example: Hiding a button, exiting the UI, and then opening the UI will still have that button hidden
    @editable SaveButtonState : logic = true
 
    # The module that holds all Recieving signals used to manipulate the UI buttons
    @editable ButtonSignal_Recieve : ButtonUI_UserOptions_Functions = ButtonUI_UserOptions_Functions{}
 
    # The module that holds all Sending signal attributes
    @editable ButtonSignal_Send : ButtonUI_UserOptions_Events = ButtonUI_UserOptions_Events{}
 
    var WidgetPerPlayer : [agent]widget = map{}
 
    var EnabledStateMap : [agent]logic = map{}
    var VisibleStateMap : [agent]logic = map{}
 
    var InitialEnabledState : [agent]logic = map{}
    var InitialVisibleState : [agent]logic = map{}
 
    # Un-fades the button
    EnableWidget(Agent : ?agent):void=
        if(ValidAgent := Agent?, ThisButtonWidget := WidgetPerPlayer[ValidAgent]):
            ThisButtonWidget.SetEnabled(true)
            if(SaveButtonState?):
                ValidAgent.SaveEnabledState(true)
 
    # Fades the button
    DisableWidget(Agent : ?agent):void=
        if(ValidAgent := Agent?, ThisButtonWidget := WidgetPerPlayer[ValidAgent]):
            ThisButtonWidget.SetEnabled(false)
            if(SaveButtonState?):
                ValidAgent.SaveEnabledState(false)
 
    # Sets the enabled state to the InState
    SetEnabledState(ThisWidget : widget, InState : logic):void=
        ThisWidget.SetEnabled(InState)
 
    # Saves the enabled state the button is currently in
    (Agent : agent).SaveEnabledState(State : logic):void=
        if(CurrentState := EnabledStateMap[Agent]):
            if(set EnabledStateMap[Agent] = State){}
        else:
            set EnabledStateMap = ConcatenateMaps(EnabledStateMap, map{Agent => State})
 
    # Gets the initial enabled state
    GetInitialEnabledState(Agent : agent)<transacts>:logic=
        if(IsInitiallyDisabled?):
            if(CurrentState := EnabledStateMap[Agent]):
                return false
            else:
                return true
        return false
 
    # Shows the button
    ShowWidget(Agent : ?agent):void=
        if(ValidAgent := Agent?, ThisButtonWidget := WidgetPerPlayer[ValidAgent]):
            ThisButtonWidget.SetVisibility(widget_visibility.Visible)
            if(SaveButtonState?):
                ValidAgent.SaveVisibleState(true)
 
    # Hides the button
    HideWidget(Agent : ?agent):void=
        if(ValidAgent := Agent?, ThisButtonWidget := WidgetPerPlayer[ValidAgent]):
            ThisButtonWidget.SetVisibility(widget_visibility.Collapsed)
            if(SaveButtonState?):
                ValidAgent.SaveVisibleState(false)
 
    # Sets the visible state to InState
    SetVisibleState(ThisWidget : widget, InState : logic):void=
        case(InState):
            true => ThisWidget.SetVisibility(widget_visibility.Visible)
            false => ThisWidget.SetVisibility(widget_visibility.Collapsed)
            _ => Print("~ERROR: 'InState' failed")
 
    # Saves the visible state the button is currently in
    (Agent : agent).SaveVisibleState(State : logic):void=
        if(CurrentState := VisibleStateMap[Agent]):
            if(set VisibleStateMap[Agent] = State){}
        else:
            set VisibleStateMap = ConcatenateMaps(VisibleStateMap, map{Agent => State})
 
    # Gets the initial visible state
    GetInitialVisibleState(Agent : agent)<transacts>:logic=
        if(IsInitiallyHidden?):
            if(CurrentState := VisibleStateMap[Agent]):
                return false
            else:
                return true
        return false
 
ButtonUI_UserOptions_Functions := class<concrete>():
 
    # The trigger that will enable this ui button, making it 'un-fade' and clickable
    @editable EnableButtonOnTrigger : trigger_device = trigger_device{}
 
    # The trigger that will disable this ui button, making it 'fade' and unclickable
    @editable DisableButtonOnTrigger : trigger_device = trigger_device{}
 
    # The trigger that will show this ui button, making it visible and clickable
    @editable ShowButtonOnTrigger : trigger_device = trigger_device{}
 
    # The trigger that will hide this ui button, making it not visible at all and therefore unclickable
    @editable HideButtonOnTrigger : trigger_device = trigger_device{}
 
ButtonUI_UserOptions_Events := class<concrete>():
 
    # The trigger/destination to activate
    @editable TriggerToActivate : trigger_device  = trigger_device{}
 
    # Do we send the instigator of the UI button?
    @editable SendInstigator : logic = true
 
 
 
textui := class<concrete>():
    @editable var MainText : string = "Main Text"
    @editable var TextPosition : vector2 = vector2{}
    @editable var TextSize : vector2 = vector2{X := 475.0, Y:= 80.0}
    @editable var TextColor : colorclass = colorclass{}
    @editable var TextOpacity : opacity_range = 1.0
 
    var TextWidgetPerPlayer : [agent]widget = map{}
 
    # Do we want this button to be disabled when this UI is shown?
    # NOTE: If 'SaveButtonState' is NOT turned on for this button, the button will ALWAYS be disabled upon opening the menu!
    @editable IsInitiallyDisabled : logic = false
 
    # Do we want this button to be hidden when this UI is shown? 
    # NOTE: If 'SaveButtonState' is NOT turned on for this button, the button will ALWAYS be hidden upon opening the menu!
    @editable IsInitiallyHidden : logic = false
 
    # Saves the state the button is in even after exiting the UI. Example: Hiding a button, exiting the UI, and then opening the UI will still have that button hidden
    @editable SaveTextState : logic = true
 
    # The module that holds all Recieving signals used to manipulate the UI buttons
    @editable TextSignal_Recieve : TextUI_UserOptions_Functions = TextUI_UserOptions_Functions{}
 
    var EnabledStateMap : [agent]logic = map{}
    var VisibleStateMap : [agent]logic = map{}
 
    var InitialEnabledState : [agent]logic = map{}
    var InitialVisibleState : [agent]logic = map{}
 
    # Un-fades the button
    EnableWidget(Agent : ?agent):void=
        if(ValidAgent := Agent?, ThisButtonWidget := TextWidgetPerPlayer[ValidAgent]):
            ThisButtonWidget.SetEnabled(true)
            if(SaveTextState?):
                ValidAgent.SaveEnabledState(true)
 
    # Fades the button
    DisableWidget(Agent : ?agent):void=
        if(ValidAgent := Agent?, ThisButtonWidget := TextWidgetPerPlayer[ValidAgent]):
            ThisButtonWidget.SetEnabled(false)
            if(SaveTextState?):
                ValidAgent.SaveEnabledState(false)
 
    # Sets the enabled state to the InState
    SetEnabledState(ThisWidget : widget, InState : logic):void=
        ThisWidget.SetEnabled(InState)
 
    # Saves the enabled state the button is currently in
    (Agent : agent).SaveEnabledState(State : logic):void=
        if(CurrentState := EnabledStateMap[Agent]):
            if(set EnabledStateMap[Agent] = State){}
        else:
            set EnabledStateMap = ConcatenateMaps(EnabledStateMap, map{Agent => State})
 
    # Gets the initial enabled state
    GetInitialEnabledState(Agent : agent)<transacts>:logic=
        if(IsInitiallyDisabled?):
            if(CurrentState := EnabledStateMap[Agent]):
                return false
            else:
                return true
        return false
 
    # Shows the button
    ShowWidget(Agent : ?agent):void=
        if(ValidAgent := Agent?, ThisButtonWidget := TextWidgetPerPlayer[ValidAgent]):
            ThisButtonWidget.SetVisibility(widget_visibility.Visible)
            if(SaveTextState?):
                ValidAgent.SaveVisibleState(true)
 
    # Hides the button
    HideWidget(Agent : ?agent):void=
        if(ValidAgent := Agent?, ThisButtonWidget := TextWidgetPerPlayer[ValidAgent]):
            ThisButtonWidget.SetVisibility(widget_visibility.Collapsed)
            if(SaveTextState?):
                ValidAgent.SaveVisibleState(false)
 
    # Sets the visible state to InState
    SetVisibleState(ThisWidget : widget, InState : logic):void=
        case(InState):
            true => ThisWidget.SetVisibility(widget_visibility.Visible)
            false => ThisWidget.SetVisibility(widget_visibility.Collapsed)
            _ => Print("~ERROR: 'InState' failed")
 
    # Saves the visible state the button is currently in
    (Agent : agent).SaveVisibleState(State : logic):void=
        if(CurrentState := VisibleStateMap[Agent]):
            if(set VisibleStateMap[Agent] = State){}
        else:
            set VisibleStateMap = ConcatenateMaps(VisibleStateMap, map{Agent => State})
 
    # Gets the initial visible state
    GetInitialVisibleState(Agent : agent)<transacts>:logic=
        if(IsInitiallyHidden?):
            if(CurrentState := VisibleStateMap[Agent]):
                return false
            else:
                return true
        return false
 
TextUI_UserOptions_Functions := class<concrete>():
 
    # The trigger that will enable this ui button, making it 'un-fade' and clickable
    @editable EnableTextOnTrigger : trigger_device = trigger_device{}
    # The trigger that will disable this ui button, making it 'fade' and unclickable
    @editable DisableTextOnTrigger : trigger_device = trigger_device{}
    # The trigger that will show this ui button, making it visible and clickable
    @editable ShowTextOnTrigger : trigger_device = trigger_device{}
    # The trigger that will hide this ui button, making it not visible at all and therefore unclickable
    @editable HideTextOnTrigger : trigger_device = trigger_device{}

colorclass := class<concrete>():

    @editable Red : color_range = 255
    @editable Green : color_range = 255
    @editable Blue : color_range = 255