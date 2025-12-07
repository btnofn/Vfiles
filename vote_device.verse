using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Assets }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }

ui_voting_class := class<unique>():

    Player : player

    TextToMessage<localizes>(InText : string) : message = "{InText}"
    VoteTextLocalized<localizes> : message = "VOTE"
    CloseTextLocalized<localizes> : message = "CLOSE"
    var UIPerPlayer : canvas = canvas{}
    var UIPerPlayerTimer : canvas = canvas{}

    TextureImagePHolder : texture = TexturesUI.Pic1
    
    Init(
        Image1 : texture,
        Image2 : texture,
        Image3 : texture,
        HUDText : string,
        DefaultTime : int
    ):void=

        #BOX_1_VOTES.SetText(TextToMessage("0"))
        #BOX_2_VOTES.SetText(TextToMessage("0"))
        #BOX_3_VOTES.SetText(TextToMessage("0"))

        BUTTON_VOTE_1.SetText(VoteTextLocalized)
        BUTTON_VOTE_2.SetText(VoteTextLocalized)
        BUTTON_VOTE_3.SetText(VoteTextLocalized)
        BUTTON_CLOSE.SetText(CloseTextLocalized)
        #BUTTON_CLOSE.SetEnabled(false)

        

        IMAGE_1.SetImage(Image1)
        IMAGE_2.SetImage(Image2)
        IMAGE_3.SetImage(Image3)
        if(DefaultTime > 60){
            TIME.SetText(TextToMessage("{DefaultTime}s"))
            
        }
        VoteFor.SetText(TextToMessage("{HUDText}"))
        

        Print("Initialized Class")

    BOX_1_VOTES<public> : text_block = text_block{DefaultTextColor := NamedColors.White}
    BOX_2_VOTES<public> : text_block = text_block{DefaultTextColor := NamedColors.White}
    BOX_3_VOTES<public> : text_block = text_block{DefaultTextColor := NamedColors.White}

    TIME<public> : text_block = text_block{DefaultTextColor := NamedColors.White}
    VoteFor<public> : text_block = text_block{DefaultTextColor := NamedColors.White}

    BUTTON_VOTE_1<public> : button_loud = button_loud{}
    BUTTON_VOTE_2<public> : button_loud = button_loud{}
    BUTTON_VOTE_3<public> : button_loud = button_loud{}

    BUTTON_CLOSE<public> : button_regular = button_regular{}

    IMAGE_1<public> : texture_block = texture_block{DefaultImage:=TexturesUI.Pic1, DefaultDesiredSize:=vector2{X:=500.0, Y:= 281.0}}
    IMAGE_2<public> : texture_block = texture_block{DefaultImage:=TexturesUI.Pic1, DefaultDesiredSize:=vector2{X:=500.0, Y:= 281.0}}
    IMAGE_3<public> : texture_block = texture_block{DefaultImage:=TexturesUI.Pic1, DefaultDesiredSize:=vector2{X:=500.0, Y:= 281.0}}

    CreateTimer() : canvas = 
        UICanvas : canvas = canvas{
            Slots := array{
                #time
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -400.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.4, DefaultDesiredSize:=vector2{X:=500.0, Y:=100.0}}
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -420.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := VoteFor
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -390.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := TIME
                }
            }
        }
        return UICanvas

    CreateUIPlayer() : canvas =
        

        
        UICanvas : canvas = canvas{
            Slots := array{
                

                #canvas_slot{
                    #Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    #Offsets := margin{Top := 300.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    #Alignment := vector2{X := 0.5, Y := 0.5}

                    #Widget := BUTTON_CLOSE
                #}
                #first
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 0.0, Left := -550.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.4, DefaultDesiredSize:=vector2{X:=500.0, Y:=500.0}}
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -50.0, Left := -550.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := IMAGE_1
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 125.0, Left := -550.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := BOX_1_VOTES
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 200.0, Left := -550.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.4, DefaultDesiredSize:=vector2{X:=500.0, Y:=100.0}}
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 200.0, Left := -550.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := BUTTON_VOTE_1
                }
                #Second
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.4, DefaultDesiredSize:=vector2{X:=500.0, Y:=500.0}}
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -50.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := IMAGE_2
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 125.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := BOX_2_VOTES
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 200.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.4, DefaultDesiredSize:=vector2{X:=500.0, Y:=100.0}}
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 200.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := BUTTON_VOTE_2
                }
                #third
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 0.0, Left := 550.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.4, DefaultDesiredSize:=vector2{X:=500.0, Y:=500.0}}
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -50.0, Left := 550.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := IMAGE_3
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 125.0, Left := 550.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := BOX_3_VOTES
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 200.0, Left := 550.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.4, DefaultDesiredSize:=vector2{X:=500.0, Y:=100.0}}
                }
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 200.0, Left := 550.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}

                    Widget := BUTTON_VOTE_3
                }


                
                
            }
        }

        return UICanvas

    ShowUIForPlayer(PlayerAgemt : player):void=
        if (PlayerUI := GetPlayerUI[PlayerAgemt]):
            set UIPerPlayer = CreateUIPlayer()
            set UIPerPlayerTimer = CreateTimer()

            PlayerUI.AddWidget(UIPerPlayer, player_ui_slot{InputMode := ui_input_mode.All})
            PlayerUI.AddWidget(UIPerPlayerTimer)
            

    HideUIForPlayer(PlayerAgemt : player):void=
        if (PlayerUI := GetPlayerUI[PlayerAgemt]):
            PlayerUI.RemoveWidget(UIPerPlayer)

    HideUIAllForPlayer(PlayerAgemt : player):void=
        if (PlayerUI := GetPlayerUI[PlayerAgemt]):
            PlayerUI.RemoveWidget(UIPerPlayer)
            PlayerUI.RemoveWidget(UIPerPlayerTimer)

    
            
ChoiceStructure := struct<concrete>:
    @editable Name : string = "Name"
    @editable Trigger : trigger_device = trigger_device{}

DataStructureChoice := struct
{
    Name:string
    Trigger: trigger_device
    Image : texture
}

voting_system := class(creative_device):
    @editable TriggerVoting : trigger_device = trigger_device{}
    @editable TimeToWait : int = 30
    var TimeCurrent : int = 0
    @editable PromptText : string = "Cast Your Vote For Minigame"
    TextToMessage<localizes>(InText : string) : message = "{InText}"
    var PlayerHudClasses : [player]ui_voting_class = map{}

    var Images : []texture = array{
        TexturesUI.Pic1,
        TexturesUI.Pic2,
        TexturesUI.Pic3,
        TexturesUI.Pic5,
        TexturesUI.Pic6,
        TexturesUI.Pic7
    }
    var ChoicesImagesCompiled : []DataStructureChoice = array{}

    @editable Choices : []ChoiceStructure = array{}
    

    var votes_option_1 : int = 0
    var votes_option_2 : int = 0
    var votes_option_3 : int = 0

    OnBegin<override>()<suspends>:void=
        for (IndexC := 0..Choices.Length-1){
            if(Category := Choices[IndexC]){
                Print(ToString(IndexC))
                Print("{Category.Name}")
                if(set ChoicesImagesCompiled += array{DataStructureChoice{Name:=Category.Name, Trigger:=Category.Trigger, Image:=Images[IndexC]}}){}
            }
            
        }
        TriggerVoting.TriggeredEvent.Subscribe(StartSequence)

    StartSequence(Agent : ?agent): void = 
        spawn{StartSequenceSuspended()}

    StartSequenceSuspended()<suspends>: void = 
        set PlayerHudClasses = map{}
        set TimeCurrent = 0
        set votes_option_1 = 0
        set votes_option_2 = 0
        set votes_option_3 = 0 

        set TimeCurrent = TimeToWait
        Print("Hello, world!")
        Print("2 + 2 = {2 + 2}")
        
        ShuffledList := Shuffle(ChoicesImagesCompiled)

        if(ShuffledFirst := ShuffledList[0], ShuffledSecond := ShuffledList[1], ShuffledThird := ShuffledList[2]){
            AllPlayers := GetPlayspace().GetPlayers()

            for(Player: AllPlayers){
    
                UIHudPlayer := ui_voting_class{Player:=Player}
                UIHudPlayer.Init(
                    Image1 := ShuffledFirst.Image,
                    Image2 := ShuffledSecond.Image,
                    Image3 := ShuffledThird.Image,
                    HUDText := PromptText,
                    DefaultTime := TimeToWait
                )
                Print(ShuffledFirst.Name)
                Print(ShuffledSecond.Name)
                Print(ShuffledThird.Name)
    
                if(set PlayerHudClasses[Player] = UIHudPlayer){

                    UIHudPlayer.ShowUIForPlayer(Player)
                    Print("test")

                    UIHudPlayer.BUTTON_VOTE_1.OnClick().Subscribe(AddVote1)
                    UIHudPlayer.BUTTON_VOTE_2.OnClick().Subscribe(AddVote2)
                    UIHudPlayer.BUTTON_VOTE_3.OnClick().Subscribe(AddVote3)
                    UIHudPlayer.BUTTON_CLOSE.OnClick().Subscribe(RemoveUI)
                    
                }
            }
            loop{
                set TimeCurrent -= 1
                if(TimeCurrent <= 0){
                    var LargestNumber : int = 0
                    Numbers : []int = array{
                        votes_option_1,
                        votes_option_2,
                        votes_option_3
                    }
                    Options : []DataStructureChoice = array{
                        ShuffledFirst,
                        ShuffledSecond,
                        ShuffledThird
                    }
                    for(Number : Numbers){
                        if (Number > LargestNumber){
                            set LargestNumber = Number
        
                        }
                    }
                    for(I := 0..2){
                        if(Numbers[I] = LargestNumber){
                            
                            if(Trigger := Options[I].Trigger, Name := Options[I].Name){
                                Print(Name)
                                Trigger.Trigger()
                                for(Player : AllPlayers){
                                    if(UIClass := PlayerHudClasses[Player]){
                                        UIClass.HideUIAllForPlayer(Player)
                                    }
                                }
                                
                                return
                            }
        
                        }
                    }
                }
                for(Player: AllPlayers){
                    if(UIClass := PlayerHudClasses[Player]){
                        UIClass.TIME.SetText(TextToMessage("{TimeCurrent}s"))
                    }
                }
                
                Sleep(1.0)
            }
        }

        
    RemoveUI(WM: widget_message):void =
        if(UIClass := PlayerHudClasses[WM.Player]){
            UIClass.HideUIForPlayer(WM.Player)
        }

    var PlayerChoices : [player]int = map{}


    #Function to add and remove vote, Requires the player parameter and the new choice parameter (ChoiceNew will be the index)
    AddAndRemoveVote(Player : player, ChoiceNew : int): void = 

        #Checks if Player is inside the PlayerChoices map, if true then PlayersChoiceOld will be the value of it
        if(PlayersChoiceOld := PlayerChoices[Player]){
            #If the choice isnt the same, then... (remove from the original vote)
            if (PlayersChoiceOld <> ChoiceNew){
                case(PlayersChoiceOld){
                    0 => set votes_option_1 -= 1 # Removes the vote from the previos Choice, if its either 0,1,2 they all do different things by setting the variable to subtract 1
                    1 => set votes_option_2 -= 1
                    2 => set votes_option_3 -= 1
                    _ => Print("Couldn't Find Option")
                }
                
            }
            #if the choice is the same then...
            else{
                #basically ends the function
                return
            }
        }
        #checks if ChoiceNew matches, 0,1,2 (our indexes) 
        case(ChoiceNew){
            0 => set votes_option_1 += 1 #if index 0, +1 to option 1
            1 => set votes_option_2 += 1 #if index 2, +1 to option 2
            2 => set votes_option_3 += 1 #if index 3, +1 to option 3
            _ => Print("Couldn't Find Option") #This shouldnt be triggered ever, but in the event that it exceeds 0,1,2 and gives 3 for example. It will give us this message
        }

        if(ChoiceNew = 0){ #if the new choice is the first option
            if(set PlayerChoices[Player] = 0){}
            #sets the players vote to be in choice 1
        }
        if(ChoiceNew = 1){ #if the new choice is the second option
            if(set PlayerChoices[Player] = 1){}
            #sets the players vote to be in choice 2
        }
        if(ChoiceNew = 2){ #if the new choice is the third option
            if(set PlayerChoices[Player] = 2){}
            #sets the players vote to be in choice 3
        }
    VoteTextLocalized<localizes>(Amount : int) : message = "{Amount}"
    #function to update everyones ui
    UpdateUIForAllPlayers(): void = 
        #Get all players
        AllPlayers := GetPlayspace().GetPlayers()
        #for player inside allplayers
        for(Player: AllPlayers){
            #get the individual classes
            if(UIClass := PlayerHudClasses[Player]){
                #update the buttons text to match
                UIClass.BUTTON_VOTE_1.SetText(VoteTextLocalized(votes_option_1))
                UIClass.BUTTON_VOTE_2.SetText(VoteTextLocalized(votes_option_2))
                UIClass.BUTTON_VOTE_3.SetText(VoteTextLocalized(votes_option_3))
            }
        }

    #Triggered when clicked on the first button
    AddVote1(WM : widget_message):void =
        AddAndRemoveVote(WM.Player, 0)
        #Adds a vote from player to the first option (index 0)
        UpdateUIForAllPlayers()
        #Update everyones ui
    #Triggered when clicked on the second button
    AddVote2(WM : widget_message):void =
        AddAndRemoveVote(WM.Player, 1)
        #Adds a vote from player to the second option (index 1)
        UpdateUIForAllPlayers()
        #Update everyones ui

    #Triggered when clicked on the third button
    AddVote3(WM : widget_message):void =
        AddAndRemoveVote(WM.Player, 2)
        #Adds a vote from player to the third option (index 2)
        UpdateUIForAllPlayers()
        #Update everyones ui
        