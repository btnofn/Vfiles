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
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary}

#THIS DEVICE WILL ACT AS A PET MANAGER AND ALLOW PLAYERS TO EQUP / UNEQUIP THE PETS THAT THEY OWN

ManagerPet := class<concrete>():

    var GameMan : Game_Manager = Game_Manager{}         #Main game manager device

    var PetNum : int = 0                                #Pet Identfying Number

    var PetButton : button_loud = button_loud{}         #Button for pet

    var PetBaseImage : texture_block = texture_block:   #Button base image
        DefaultImage := Icons.money_ui
        DefaultDesiredSize := vector2{X:=235.0,Y:=340.0}    #Desired size for image

    
    var PetBoughtImage : texture = Icons.money_ui

    var PetCanvas : canvas = canvas{}       #Canvas for each pet that combines button + image

    var PetBought : logic = false           #Has the pet been bought

    var PetEquipped : logic = false         #Has the pet been equipped

    var EquipPetTracker : tracker_device = tracker_device{}         #Tracker to increment when a player equips a pet


    @editable BaseClass : class_and_team_selector_device = class_and_team_selector_device{}     #Base Class selector to switch player back to when special pet is unequipped

    @editable PetClass : class_and_team_selector_device = class_and_team_selector_device{}      #Class selector to switch player to specific class if pet has powers

    @editable PetProp : creative_prop_asset = DefaultCreativePropAsset                          #Prop that the pet will be

    @editable PetBoostAmount : float = 0.0      #Amount for the pet to boost when equipped
    
    @editable PetBoostType : string = ""        #Resource type for the pet to boost when equipped
    
    DistanceAllowedNearPlayer : float = 200.0       #Distance the pet will be from player

    var Despawn : logic = false         #When enabled, pet despawns


    StringToMessage<localizes>(value:string) : message = "{value}"  #String to message

    EquipPet(Message : widget_message) : void=          #Equips the pet
        if(Player := Message.Player,PetBut := text_button_base[Message.Source],CustomPlayer := GameMan.PlayersMap[Player]):
            for(Num : CustomPlayer.BoughtPets):
                if(Num = PetNum):
                    if(PetEquipped = false and CustomPlayer.EquippedPet = 999):
                        set CustomPlayer.EquippedPet = PetNum
                        set PetEquipped = true
                        CheckPets(Player)
                        SpawnPet(Player)
                        EquipPetAbilities(Player)
                        EquipPetTracker.Increment(Player)
                    else if(PetEquipped = true):
                        set CustomPlayer.EquippedPet = 999
                        set PetEquipped = false
                        CheckPets(Player)
                        DespawnPetAbilities(Player)
                        set Despawn = true


    CheckPets(Agent : agent): void=     #changes pet button and image based on if the player has owned/equipped the pet
        PetButton.SetText(StringToMessage("???"))
            if(CustomPlayer := GameMan.PlayersMap[Agent]):
                for(Num : CustomPlayer.BoughtPets):
                    if(Num = PetNum):
                        PetButton.SetText(StringToMessage("Equip"))
                        PetBaseImage.SetImage(PetBoughtImage)
                        if(PetNum = CustomPlayer.EquippedPet):
                            PetButton.SetText(StringToMessage("UnEquip"))

    SpawnPet(Agent:agent):void=     #spawns the pet in when equipped
        if(FC:=Agent.GetFortCharacter[]):
            PlayerPos := FC.GetTransform().Translation
            PlayerForward := FC.GetViewRotation().GetLocalForward() * 300.0
            PetSpawnPos := PlayerPos + PlayerForward
            Result := SpawnProp(PetProp,PetSpawnPos,rotation{})
            if (SpawnedProp := Result(0)?):
                set Despawn = false
                spawn:
                    PetFollowsPlayer(FC,SpawnedProp)


    PetFollowsPlayer( FortniteCharacter : fort_character, CreativeProp : creative_prop)<suspends> : void =      #Makes the pet follow the player
        loop:
            Sleep(0.0)
            #Credit to PiEqualsThree for this pet better pet follow system
            PlayerPos := FortniteCharacter.GetTransform().Translation
            PetPos := CreativeProp.GetTransform().Translation
            DistanceFromPlayer := Distance(PlayerPos, PetPos)
            PlayerRight := FortniteCharacter.GetTransform().Rotation.GetLocalRight()
            DirectionPetToPlayer := PlayerPos - PetPos
            Angle := ArcTan(DirectionPetToPlayer.X, DirectionPetToPlayer.Y) - 3.14 / 2.0
            NewRotation := MakeRotation( vector3{ X := 0.0, Y := 0.0, Z := -1.0} , Angle) 
            NoJumpPlayerPos := vector3{ X := PlayerPos.X + PlayerRight.X * DistanceAllowedNearPlayer * 0.65, Y := PlayerPos.Y + PlayerRight.Y * DistanceAllowedNearPlayer * 0.65, Z := PlayerPos.Z + 30.0}
            if (DistanceFromPlayer > DistanceAllowedNearPlayer):
                Time := DistanceFromPlayer / 450.0
                CreativeProp.MoveTo(NoJumpPlayerPos, NewRotation, Time)

            if(Despawn = true):
                CreativeProp.Dispose()
                break

    
    EquipPetAbilities(Agent:agent) : void=           #Manages pet boosts when a pet is equipped

        if(FC:=Agent.GetFortCharacter[],CustomPlayer := GameMan.PlayersMap[Agent]):
            CustomPlayer.Boost(PetBoostAmount,PetBoostType)
        
        #If you want to add special boosts add them here(Ex:if(PetNum = 22){PetClass.ChangeClass(Agent)})
         

    DespawnPetAbilities(Agent:agent) : void=     #Manages pet boosts when a pet is unequipped

        if(FC:=Agent.GetFortCharacter[],CustomPlayer := GameMan.PlayersMap[Agent]):
            CustomPlayer.RemoveBoost(PetBoostAmount,PetBoostType)

        #If you want to remove special boosts add them here(Ex:if(PetNum = 22){BaseClass.ChangeClass(Agent)})
            



Pet_Manager := class(creative_device):

    @editable PetMerchant : Pet_Merchant = Pet_Merchant{}       #Pet merchant device

    @editable GameManager : Game_Manager = Game_Manager{}       #Main game manager

    @editable PetManagerButton : button_device = button_device{}    #Button to open manager

    @editable var AllPets : []ManagerPet = array{}                  #Array of all pets

    @editable EnableManagerHUD : hud_message_device = hud_message_device{}      #Hud message to show when manager is enabled
    
    var MaybeMyUIPerPlayer : [player]?overlay = map{}           #Player map to keep track of manager UI

    @editable ActivatePetManagerTrigger : trigger_device = trigger_device{}


    #A list of all pet images that show before the pet is bought (THE ORDER MATTERS!, THE FIRST IMAGE WILL HAVE PETNUM 0, SECOND PETNUM 1, ECT.)
    var PetTextures : []texture = array{Icons.money_ui}

    #A list of all pet images that show after the pet is bought (THE ORDER MATTERS!, THE FIRST IMAGE WILL HAVE PETNUM 0, SECOND PETNUM 1, ECT.)
    var PetBoughtTextures : []texture = array{Icons.money_ui}


    var ExitButton : button_loud = button_loud{}        #Exit button to close UI

    var ManagerUI : overlay = overlay{}         #Main manager UI

    #Buttons to sort through different pet rarities
    var UncommonButton : button_loud = button_loud{}
    var RareButton : button_loud = button_loud{}
    var EpicButton : button_loud = button_loud{}
    var LegendaryButton : button_loud = button_loud{}
    var SpecialButton : button_loud = button_loud{}

    #A canvas for every pet
    var Pet1 : canvas = canvas{}
    var Pet2 : canvas = canvas{}
    var Pet3 : canvas = canvas{}
    var Pet4 : canvas = canvas{}
    var Pet5 : canvas = canvas{}
    var Pet6 : canvas = canvas{}
    var Pet7 : canvas = canvas{}
    var Pet8 : canvas = canvas{}
    var Pet9 : canvas = canvas{}
    var Pet10 : canvas = canvas{}
    #To add more just copy from above and change number


    #All pets that are currently on the UI
    var PetUI1 : canvas = canvas{}
    var PetUI2 : canvas = canvas{}
    var PetUI3 : canvas = canvas{}
    var PetUI4 : canvas = canvas{}
    var PetUI5 : canvas = canvas{}
    var PetUI6 : canvas = canvas{}
    
    

    @editable EquipPetTracker : tracker_device = tracker_device{}   #tracker device the increments when a pet is equipped

    var Blank : canvas = canvas{}  #An empty canvas to fill up slots when there isnt enough pets


    StringToMessage<localizes>(value:string) : message = "{value}"  #string to message

    EnableManager(MAgent:?agent) : void=  #Function to enable pet manager
        if(Agent := MAgent?):
            EnableManagerHUD.Show(Agent)        #Shows HUD to let player know the manager is enabled
            PetManagerButton.Enable()           #Enables the manager button

    OnBegin<override>()<suspends>:void=
        spawn:
            InitialSetup()  #Initializes everything

        #Handle all buttons 
        ExitButton.OnClick().Subscribe(HandleExitButton)
        UncommonButton.OnClick().Subscribe(HandleUncommonButton)
        RareButton.OnClick().Subscribe(HandleRareButton)
        EpicButton.OnClick().Subscribe(HandleEpicButton)
        LegendaryButton.OnClick().Subscribe(HandleLegendaryButton)
        SpecialButton.OnClick().Subscribe(HandleSpecialButton)
        
        ActivatePetManagerTrigger.TriggeredEvent.Subscribe(EnableManager)    #Enables manager when trigger is triggered

        PetManagerButton.InteractedWithEvent.Subscribe(UIOpen)       #activates when pet manager button is pressed


    UIOpen(Agent:agent) : void=       #Opens the Manager
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player],CP := GameManager.PlayersMap[Agent]):
            CP.MyUI.SetVisibility(widget_visibility.Hidden)
            for(P : AllPets):
                P.CheckPets(Agent)      #Changes button texts
            PlayerUI.AddWidget(ManagerUI, player_ui_slot{InputMode := ui_input_mode.All})
            if (set MaybeMyUIPerPlayer[Player] = option{ManagerUI}) {}


    InitialSetup()<suspends> : void=      
        PetSetup()                              #set ups pets
        set ManagerUI = ConstructMainUI()       #Constructs UI

    

    ConstructMainUI() : overlay =       #constructs main ui
        ManUI : overlay = overlay:
            Slots := array:
                overlay_slot:       #Background image for pet manager
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=0.0,Right:=0.0,Bottom:=0.0}
                    Widget := texture_block:
                        DefaultImage := Icons.money_ui
                        DefaultDesiredSize := vector2{X:=1750.0,Y:=900.0}

                overlay_slot:       #Pet slot 1 on UI
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=0.0,Right:=310.0,Bottom:=100.0}
                    Widget := PetUI1
                overlay_slot:       #Pet slot 2 on UI
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=0.0,Right:=60.0,Bottom:=100.0}
                    Widget := PetUI2
                overlay_slot:       #Pet slot 3 on UI
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=190.0,Top:=0.0,Right:=0.0,Bottom:=100.0}
                    Widget := PetUI3
                overlay_slot:       #Pet slot 4 on UI
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=440.0,Top:=0.0,Right:=0.0,Bottom:=100.0}
                    Widget := PetUI4
                overlay_slot:       #Pet slot 5 on UI
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=690.0,Top:=0.0,Right:=0.0,Bottom:=100.0}
                    Widget := PetUI5
                overlay_slot:       #Pet slot 6 on UI
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=245.0,Right:=310.0,Bottom:=0.0}
                    Widget := PetUI6


                overlay_slot:       #Exit button
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin{Left:=50.0,Top:=80.0,Right:=0.0,Bottom:=0.0}
                    Widget := ExitButton  

                overlay_slot:       #uncommon rarity button
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=165.0,Top:=0.0,Right:=0.0,Bottom:=220.0}
                    Widget := UncommonButton  

                overlay_slot:       #rare rarity button
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=230.0,Top:=0.0,Right:=0.0,Bottom:=75.0}
                    Widget := RareButton  

                overlay_slot:       #epic rarity button
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=230.0,Top:=70.0,Right:=0.0,Bottom:=0.0}
                    Widget := EpicButton  

                overlay_slot:       #legendary rarity button
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=165.0,Top:=210.0,Right:=0.0,Bottom:=0.0}
                    Widget := LegendaryButton  

                overlay_slot:       #special rarity button
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=200.0,Top:=360.0,Right:=0.0,Bottom:=0.0}
                    Widget := SpecialButton  
        return ManUI




    PetSetup() : void=      #Sets up all pets
        #Sets button texts
        ExitButton.SetText(StringToMessage("Exit"))
        UncommonButton.SetText(StringToMessage("Uncommon"))
        RareButton.SetText(StringToMessage("Rare"))
        EpicButton.SetText(StringToMessage("Epic"))
        LegendaryButton.SetText(StringToMessage("Legendary"))
        SpecialButton.SetText(StringToMessage("Special"))

        for(IDX -> SinglePet : AllPets):
            set SinglePet.GameMan = GameManager
            set SinglePet.PetNum = IDX
            set SinglePet.EquipPetTracker = EquipPetTracker
            if(ImageToSet := PetTextures[IDX]):
                if(SecondImageToSet := PetBoughtTextures[IDX]):
                    set SinglePet.PetBoughtImage = SecondImageToSet
                    SinglePet.PetBaseImage.SetImage(ImageToSet)
                    set SinglePet.PetCanvas = ConstructPets(SinglePet.PetButton, SinglePet.PetBaseImage)
                SinglePet.PetButton.OnClick().Subscribe(SinglePet.EquipPet)     #Trys to equip pet when button is pressed
        if:
            p1 := AllPets[0].PetCanvas
            p2 := AllPets[1].PetCanvas
            p3 := AllPets[2].PetCanvas
            p4 := AllPets[3].PetCanvas
            p5 := AllPets[4].PetCanvas
            p6 := AllPets[5].PetCanvas
            p7 := AllPets[6].PetCanvas
            p8 := AllPets[7].PetCanvas
            p9 := AllPets[8].PetCanvas
            p10 := AllPets[9].PetCanvas
            #To add more pets just copy from above and change numbers 

        then:
            set Pet1 = p1
            set Pet2 = p2
            set Pet3 = p3
            set Pet4 = p4
            set Pet5 = p5
            set Pet6 = p6
            set Pet7 = p7
            set Pet8 = p8
            set Pet9 = p9
            set Pet10 = p10
            #To add more pets just copy from above and change numbers 


        

        
        

    ConstructPets(Button : button_loud,Image : texture_block) : canvas=     #constructs each pet canvas (Image + Button)
        PetCan : canvas = canvas:
            Slots := array:
                canvas_slot:        #image slot
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 850.0, Bottom := 425.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Image
                canvas_slot:        #button slot
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 1.0}, Maximum := vector2{X := 0.5, Y := 1.0}}
                    Offsets := margin{Top := -35.0, Left := 0.0, Right := 210.0, Bottom := 50.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := Button
        return PetCan



        
    HandleExitButton(Message : widget_message) : void=      #Closes UI when exit button is pressed
        if (PlayerUI := GetPlayerUI[Message.Player], MyUI := MaybeMyUIPerPlayer[Message.Player]?,CP := GameManager.PlayersMap[Message.Player]):
            PlayerUI.RemoveWidget(MyUI)
            if (set MaybeMyUIPerPlayer[Message.Player] = false) {}
            CP.MyUI.SetVisibility(widget_visibility.Visible)


            
    #All rarity buttons
    HandleUncommonButton(Message : widget_message) : void=
        #TO CONFIGURE IF FOR EXAMPLE: PETS 1,4,5,and 10 ARE ALL UNCOMMON IT WOULD LOOK LIKE THIS:
        <#
        set PetUI1 = Pet1
        set PetUI2 = Pet4
        set PetUI3 = Pet5
        set PetUI4 = Pet10
        set PetUI5 = Blank
        set PetUI6 = Blank
        #>
        set PetUI1 = Blank
        set PetUI2 = Blank
        set PetUI3 = Blank
        set PetUI4 = Blank
        set PetUI5 = Blank
        set PetUI6 = Blank
        set ManagerUI = ConstructMainUI()
        Player := Message.Player
        UpdateUI(Player)
    HandleRareButton(Message : widget_message) : void=
        set PetUI1 = Blank
        set PetUI2 = Blank
        set PetUI3 = Blank
        set PetUI4 = Blank
        set PetUI5 = Blank
        set PetUI6 = Blank
        set ManagerUI = ConstructMainUI()
        Player := Message.Player
        UpdateUI(Player)
    HandleEpicButton(Message : widget_message) : void=
        set PetUI1 = Blank
        set PetUI2 = Blank
        set PetUI3 = Blank
        set PetUI4 = Blank
        set PetUI5 = Blank
        set PetUI6 = Blank
        set ManagerUI = ConstructMainUI()
        Player := Message.Player
        UpdateUI(Player)
    HandleLegendaryButton(Message : widget_message) : void=
        set PetUI1 = Blank
        set PetUI2 = Blank
        set PetUI3 = Blank
        set PetUI4 = Blank
        set PetUI5 = Blank
        set PetUI6 = Blank
        set ManagerUI = ConstructMainUI()
        Player := Message.Player
        UpdateUI(Player)
    HandleSpecialButton(Message : widget_message) : void=
        set PetUI1 = Blank
        set PetUI2 = Blank
        set PetUI3 = Blank
        set PetUI4 = Blank
        set PetUI5 = Blank
        set PetUI6 = Blank
        set ManagerUI = ConstructMainUI()
        Player := Message.Player
        UpdateUI(Player)


    UpdateUI(Player : player): void=        #Updates the ui
        if (PlayerUI := GetPlayerUI[Player], MyUI := MaybeMyUIPerPlayer[Player]?):
            PlayerUI.RemoveWidget(MyUI)
            PlayerUI.AddWidget(ManagerUI, player_ui_slot{InputMode := ui_input_mode.All})
            if (set MaybeMyUIPerPlayer[Player] = option{ManagerUI}) {}

