
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

round_timer_device := class(creative_device):

    # Canvas and Timer text block
    var TimerPerAgent:[agent]tuple(widget, text_block) = map{}
    @editable
    var sizex : float = 0.0
    @editable
    var sizey : float = 0.0
    @editable
    var paddingvalue : float = -7.0
    @editable
    var leftalignment : float = 21.0

    # String to Message
    TimerStringToMessage<localizes>(value:string) : message = "{value}"

    CancelTimerEvent:event() = event(){}
    
    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerAddedEvent().Subscribe(AddTimerUI)
        GetPlayspace().PlayerRemovedEvent().Subscribe(RemoveUI)
        AddTimer()
    AddTimer():void=
        for(Player : GetPlayspace().GetPlayers()):
            AddTimerUI(Player)

    StartTimer(Duration:int)<suspends>:void=
        CancelTimerEvent.Signal()
        var TimeRemaining:int = Duration
        race:
            CancelTimerEvent.Await()
            loop:
                for(Wrapper : TimerPerAgent):
                    Wrapper(1).SetText(TimerStringToMessage("{TimeRemaining}s"))

                if(TimeRemaining <= 0):
                    break

                Sleep(1.0)
                set TimeRemaining -= 1

    AddTimerUI(Agent:agent):void=
        RemoveUI(Agent)
        if:
            PlayerUI := GetPlayerUI[player[Agent]]
        then:
            Wrapper := CreateTimer(Agent)
            PlayerUI.AddWidget(Wrapper(0))
            if(set TimerPerAgent[Agent] = Wrapper){}
    HideTimer(Agent:?agent):void=
        for(Player : GetPlayspace().GetPlayers()):
            RemoveUI(Player)
    RemoveUI(Agent:agent):void=
        if:
            PlayerUI := GetPlayerUI[player[Agent]]
            Canvas := TimerPerAgent[Agent](0)
        then:
            PlayerUI.RemoveWidget(Canvas)
            Canvas.SetVisibility(widget_visibility.Hidden)


            # Removes the playtime component from the map
            var NewMap:[agent]tuple(widget, text_block) = map{}
            for (Key -> Value : TimerPerAgent, Key <> Agent):
                set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
            set TimerPerAgent = NewMap

    CreateTimer(Agent:agent):tuple(widget, text_block)=
        TimerTextBlock := text_block:
            DefaultTextColor := NamedColors.White
            DefaultShadowColor := NamedColors.Black
            DefaultShadowOffset := option{vector2{X := 2.0, Y := 2.0}}
            DefaultText := TimerStringToMessage("N/A")
        TimerTextBlock.SetShadowOpacity(1.0)

        MyCanvas := canvas: 
            Slots := array:
                # Scoreboard
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.18},Maximum:=vector2{X:=0.5,Y:=0.18}}
                    Offsets := margin{Left := 25.0, Top := 0.0}
                    Alignment := vector2{X:=0.5,Y:=0.18  }
                    SizeToContent := true
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := array:
                            # Timer Icon
                            stack_box_slot:
                                Widget := texture_block:
                                    DefaultImage := time
                                    DefaultDesiredSize := vector2{X := 60.0, Y := 60.0}
                                    DefaultTint := NamedColors.White
                            # Timer Text and Background
                            stack_box_slot:
                                Padding := margin{Left := paddingvalue}
                                Widget := overlay:  
                                    Slots := array:
                                        overlay_slot:
                                            Widget := texture_block:
                                                DefaultImage := pngegg
                                                DefaultDesiredSize := vector2{X := sizex, Y := sizey}
                                                DefaultTint := NamedColors.White
                                        overlay_slot:
                                            Widget := TimerTextBlock

        return (MyCanvas, TimerTextBlock)