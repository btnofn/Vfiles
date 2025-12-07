using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Random }

#THIS DEVICE ACTS AS A PET MERCHANT WHERE IT RANDOMLY CHOOSES THREE PETS BASED ON PREDERTMINED PROBABILITY AND REFRESHES ON A TIMER

Pet := class<concrete>():       #Custom class for each pet

    var GameMan : Game_Manager = Game_Manager{}                     #Main game manager

    var PlayerStatManager : player_stats_manager = player_stats_manager{}       #Persistence Manager

    var PetNum : int = 0                                            #Pet identifying number

    var BuyPetXP : accolades_device = accolades_device{}            #XP granted for buying a pet

    var PetButton : button_loud = button_loud{}                     #Button to buy pet

    var PetImage : texture_block = texture_block:                  
        DefaultImage := Icons.money_ui
        DefaultDesiredSize := vector2{X:=300.0,Y:=400.0}        #Desired size for the image

    var PetCanvas : canvas = canvas{}   #Combination of pet image and button


    @editable var Probability: type{_X : float where _X >= 0.0, _X <= 1.0} = 0.0    #Pets probability of being selected !ALL PROBABILITYS MUST ADD UP TO 1.0!

    @editable Price : float = 0.0   #Price of the pet
    @editable ResourceType : string = ""   #Type of resource the pet costs

    StringToMessage<localizes>(value:string) : message = "{value}"      #Converts string to message

    BuyPet(Message : widget_message) : void=    #Method to buy a pet
        if(Player := Message.Player,PetBut := text_button_base[Message.Source],CustomPlayer := GameMan.PlayersMap[Player]):
            if(not CustomPlayer.BoughtPets.Find[PetNum]):              #Check if pet is already owned
                SpendResult := CustomPlayer.Spend(Price,ResourceType)   #Trys to buy pet
                if(SpendResult?):
                    set CustomPlayer.BoughtPets += array{PetNum}        #Adds pet to player
                    BuyPetXP.Award(Player)                              #Gives xp
                    PlayerStatManager.RecordPlayerArrStat(Player, StatType.Pets, ?Score := PetNum)      #records pet for persistence
                    CheckPets(Player)       #Changes pet image/button text if bought

                    
    CheckPets(Agent : agent): void=         #Checks all pets to see which are bought
        PetButton.SetText(StringToMessage("Buy"))
        if(CustomPlayer := GameMan.PlayersMap[Agent]):
            for(Num : CustomPlayer.BoughtPets):         #for every pet that has been bought by the player, change the button image to Owned
                if(Num = PetNum):
                    PetButton.SetText(StringToMessage("Owned"))
                        




Pet_Merchant := class(creative_device):

    @editable GameMan : Game_Manager = Game_Manager{}                       #Main Game Manager

    var PlayerStatManager : player_stats_manager = player_stats_manager{}   #Persistence Manager

    @editable PetButton : button_device = button_device{}                   #Button device to open pet merchant

    @editable BuyPetXP : accolades_device = accolades_device{}              #XP to grant to player when pet is bought

    var MaybeMyUIPerPlayer : [player]?overlay = map{}                       #Map to keep track of merchant UI

    #Amount of time for the merchant to refresh its pets
    @editable var InitialHours : int = 0 
    @editable var InitialMinutes : int = 5           
    @editable var InitialSeconds : int = 0               

    #A list of all pet images  (THE ORDER MATTERS!, THE FIRST IMAGE WILL HAVE PETNUM 0, SECOND PETNUM 1, ECT.)
    var PetTextures : []texture = array{}#Put pet images here}
    
    @editable var AllPets : []Pet = array{}         #An array of all pets, each index is equal to the image in the pet textures


    var ShopUI : overlay = overlay{}                #Main shop UI

    #All three pets visible at a time
    var ShopButton1 : canvas = canvas{}
    var ShopButton2 : canvas = canvas{}
    var ShopButton3 : canvas = canvas{}

    var ExitButton : button_loud = button_loud{}    #Exit button

    var TimerTextBlock : text_block = text_block{DefaultTextColor := White}     #Reset timer


    StringToMessage<localizes>(value:string) : message = "{value}"      #String to message

    OnBegin<override>()<suspends>:void=
        spawn:
            InitialSetup() #Initializes everything

        ExitButton.OnClick().Subscribe(HandleExitButton)    #Exits the UI
        PetButton.InteractedWithEvent.Subscribe(ShopOpen)   #Activates when button is pressed and opens shop UI


    ShopOpen(Agent:agent) : void=       #Opens shop ui
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player],CP := GameMan.PlayersMap[Agent]):
            #hides the main UI
            CP.MyUI.SetVisibility(widget_visibility.Hidden)     

            for(P : AllPets):
                P.CheckPets(Agent)          #Changes buttons text for the player

            #Adds the ui
            PlayerUI.AddWidget(ShopUI, player_ui_slot{InputMode := ui_input_mode.All})      
            if (set MaybeMyUIPerPlayer[Player] = option{ShopUI}) {}


    InitialSetup()<suspends> : void=
        PetSetup()  #sets up all pets
        ExitButton.SetText(StringToMessage("Exit")) 
        set ShopUI = ConstructMainUI()  #Initalizes the UI

        spawn:
            ShopChangeTimer()       #Starts the timer for the shop change event

        #Randomizes shop at game start(Required multiple times because of glitch)
        spawn:
            ChangeShop()
        spawn:
            ChangeShopIn()

    ChangeShopIn()<suspends> : void=    #required bc of glitch
        Sleep(10.0)
        spawn:
            ChangeShop()


    ShopChangeTimer()<suspends>:void=   #Changes shop time
        var Hours : int = InitialHours
        var Minutes : int = InitialMinutes
        var Seconds : int = InitialSeconds

        loop:
            Sleep(1.0)
            var BonusZeroHours : string = ""
            var BonusZeroMinutes : string = ""
            var BonusZeroSeconds : string = ""
            if(Hours < 10){set BonusZeroHours = "0"}
            if(Minutes < 10){set BonusZeroMinutes = "0"}
            if(Seconds < 10){set BonusZeroSeconds = "0"}
            TimerTextBlock.SetText(StringToMessage("{BonusZeroHours}{Hours}:{BonusZeroMinutes}{Minutes}:{BonusZeroSeconds}{Seconds}"))
            set Seconds -= 1
            if(Seconds <= 0):
                if(not Minutes <= 0):
                    set Minutes -= 1
                    set Seconds = 59
                else if(not Hours <= 0):
                    set Hours -= 1
                    set Minutes = 59
                    set Seconds = 59
                else:
                    set Hours = InitialHours
                    set Minutes = InitialMinutes
                    set Seconds = InitialSeconds
                    spawn:
                        ChangeShop()        #Activated when time is 0


    ChangeShop()<suspends> : void=      #Changes pets in shop
        spawn:
            RandomizeButtons()
        set ShopUI = ConstructMainUI()
        for(Player : GetPlayspace().GetPlayers()):
            if(PlayerUI := GetPlayerUI[Player]):
                if (MyUI := MaybeMyUIPerPlayer[Player]?):
                    PlayerUI.RemoveWidget(MyUI)
                    PlayerUI.AddWidget(ShopUI, player_ui_slot{InputMode := ui_input_mode.All})
                    if (set MaybeMyUIPerPlayer[Player] = option{ShopUI}) {}


    PetSetup() : void=      #Sets up all pets
        for(IDX -> SinglePet : AllPets):    
            set SinglePet.GameMan = GameMan
            set SinglePet.PlayerStatManager = player_stats_manager{}
            set SinglePet.PetNum = IDX
            set SinglePet.BuyPetXP = BuyPetXP
            if(ImageToSet := PetTextures[IDX]):
                SinglePet.PetImage.SetImage(ImageToSet)
                set SinglePet.PetCanvas = ConstructPets(SinglePet.PetButton, SinglePet.PetImage)   #sends pet image and button to be constructed
            SinglePet.PetButton.OnClick().Subscribe(SinglePet.BuyPet)   #when button is pressed, tries to buy pet
        
        

    ConstructPets(Button : button_loud,Image : texture_block) : canvas=     #Construct a canvas for each pet including both the Image and Button
        PetCan : canvas = canvas:
            Slots := array:
                canvas_slot:        #Pet image
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 30.0, Left := 0.0, Right := 385.0, Bottom := 565.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := Image
                canvas_slot:        #Pet Button
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 1.0}, Maximum := vector2{X := 0.5, Y := 1.0}}
                    Offsets := margin{Top := 80.0, Left := 0.0, Right := 300.0, Bottom := 60.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := Button
        return PetCan
       



                    
    ConstructMainUI() : overlay =       #Constructs the main ui
        NewShopUI : overlay = overlay:
            Slots := array:
                overlay_slot:       #main background image
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=0.0,Right:=0.0,Bottom:=0.0}
                    Widget := texture_block:
                        DefaultImage := Icons.money_ui
                        DefaultDesiredSize := vector2{X:=1600.0,Y:=900.0}

                overlay_slot:       #Merchant Pet 1
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=0.0,Right:=450.0,Bottom:=0.0}
                    Widget := ShopButton1
                overlay_slot:       #Merchant Pet 2
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=0.0,Right:=0.0,Bottom:=0.0}
                    Widget := ShopButton2
                overlay_slot:       #Merchant Pet 3
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=450.0,Top:=0.0,Right:=0.0,Bottom:=0.0}
                    Widget := ShopButton3

                overlay_slot:       #Merchant Timer
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=180.0,Top:=0.0,Right:=0.0,Bottom:=286.0}
                    Widget := TimerTextBlock

                overlay_slot:       #Merchant Exit Button
                    HorizontalAlignment := horizontal_alignment.Right
                    VerticalAlignment := vertical_alignment.Bottom
                    Padding := margin{Left:=0.0,Top:=0.0,Right:=100.0,Bottom:=70.0}
                    Widget := ExitButton
        return NewShopUI

   
   
   
    RandomizeButtons()<suspends> : void =       #Picks out three pets based on probability
        var ReturnPets : []canvas = array{}
        var TempPets : []Pet = AllPets
        loop:
            Sleep(0.0)
            if(ReturnPets.Length < 3):
                RandomFloat:= GetRandomFloat(0.0, 1.0)
                var TotalProb : float = 0.0
                for(idx -> CurrentPet : TempPets):
                    set TotalProb += CurrentPet.Probability
                    if(RandomFloat <= TotalProb, RandomFloat > TotalProb - CurrentPet.Probability):
                        set ReturnPets += array{CurrentPet.PetCanvas}
                        if(NEWTempArray := TempPets.RemoveElement[idx]):
                            set TempPets = NEWTempArray
            else:
                if(B1 := ReturnPets[0]):
                    set ShopButton1 = B1
                if(B2 := ReturnPets[1]):
                    set ShopButton2 = B2
                if(B3 := ReturnPets[2]):
                    set ShopButton3 = B3
                break

    HandleExitButton(Message : widget_message) : void=  #Closes out the Merchant UI
        if (PlayerUI := GetPlayerUI[Message.Player], MyUI := MaybeMyUIPerPlayer[Message.Player]?, SelectedButton := text_button_base[Message.Source],CP := GameMan.PlayersMap[Message.Player]):
            PlayerUI.RemoveWidget(MyUI)
            if (set MaybeMyUIPerPlayer[Message.Player] = false) {}
            CP.MyUI.SetVisibility(widget_visibility.Visible)

        
   