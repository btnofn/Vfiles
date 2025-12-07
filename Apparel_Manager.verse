using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

#THIS DEVICE IS USED TO PURCHASE AND EQUIP CUSTOM APPAREL/VFX

Apparel := class<concrete><unique>():

    var GameManager : Game_Manager = Game_Manager{}                                     #Game manager to track players

    var PurchaseFailMSG : hud_message_device = hud_message_device{}                     #Failure message that appears if player does not have enough resources to purchase

    var SuccessMSG : hud_message_device = hud_message_device{}                          #Success message that appears if player successfuly purchases the apparel

    var AlreadyHaveFailHUD : hud_message_device = hud_message_device{}                  #Failure message that appears if player already has purchased the apparel

    var PurchaseXP : accolades_device = accolades_device{}                              #XP granted when a player purchases the apparel

    @editable BodySlot : int = 0                                                        #Which slot on the body the apparel is applied to (Can only be 1-3)

    @editable VFX : visual_effect_powerup_device = visual_effect_powerup_device{}       #Visual effect used to apply the apparel to the player

    @editable CostType : string = ""                                                    #What resource should the apparel cost

    @editable CostAmount : float = 0.0                                                  #How much the apparel costs to purchase

    @editable PurchaseButton : button_device = button_device{}                          #Button used to purchase the apparel

    var UniqueIDX : int = 0                                                             #IDX to keep track of each apparel

    @editable BoostType : string = ""                                                   #What resource is boosted when apparel is worn

    @editable BoostAmount : float = 0.0                                                 #Amount to boost resource by when worn

    #Function that purchases the apparel
    PurchaseApparel(Agent:agent) : void=
        if(CP := GameManager.PlayersMap[Agent]):
            if(not CP.BoughtApparels.Find[UniqueIDX]):
                SpendResult := CP.Spend(CostAmount,CostType)
                if(SpendResult?):
                    set CP.BoughtApparels += array{UniqueIDX}
                    SuccessMSG.Show(Agent)
                    PurchaseXP.Award(Agent)
                else:
                    PurchaseFailMSG.Show(Agent)
            else:
                AlreadyHaveFailHUD.Show(Agent)

                
    #Function that gives the bonuses when an apparel is equipped
    GiveApparelBonuses(Agent:agent): void=
        if(CP := GameManager.PlayersMap[Agent]):
            CP.Boost(BoostAmount,BoostType)

    #Function that removes the bonuses when an apparel is unequipped
    RemoveApparelBonuses(Agent:agent): void=
        if(CP := GameManager.PlayersMap[Agent]):
            CP.RemoveBoost(BoostAmount,BoostType)


Apparel_Manager := class(creative_device):

    @editable GameManager : Game_Manager = Game_Manager{}                                                   #Game Manager to track players stats

    @editable OpenApparelButton : button_device = button_device{}                                           #Button to open apparel closet

    @editable ApparelCam : gameplay_camera_fixed_point_device = gameplay_camera_fixed_point_device{}        #Camera for apparel closet

    @editable ApparelTP : teleporter_device = teleporter_device{}                                           #TP for apparel closet

    @editable AllApparel : []Apparel = array{}                                                              #Array of all apparel

    @editable Position1Trigger : trigger_device = trigger_device{}                                          #Trigger to clear apparel in position 1
    var Position1ButtonL : button_loud = button_loud{}
    var Position1ButtonR : button_loud = button_loud{}

    @editable Position2Trigger : trigger_device = trigger_device{}                                          #Trigger to clear apparel in position 2
    var Position2ButtonL : button_loud = button_loud{}
    var Position2ButtonR : button_loud = button_loud{}

    @editable Position3Trigger : trigger_device = trigger_device{}                                          #Trigger to clear apparel in position 3
    var Position3ButtonL : button_loud = button_loud{}
    var Position3ButtonR : button_loud = button_loud{}


    @editable PurchaseFailMSG : hud_message_device = hud_message_device{}                                   #Failure message when player does not have enough resources to purchase

    @editable AlreadyHaveFailHUD: hud_message_device = hud_message_device{}                                 #Failure message when player has already purchased apparel

    @editable SuccessMSG : hud_message_device = hud_message_device{}                                        #Success message when player purchases an apparel

    @editable PurchaseXP : accolades_device = accolades_device{}                                            #XP granted when player purchases an apparel

    

    var ExitButton : button_loud = button_loud{}                                                            #UI Exit button

    var MaybeMyUIRewPerPlayer : [player]?canvas = map{}                                                     #Map to track player UI


    
    StringToMessage<localizes>(value:string) : message = "{value}"      #Converts string to a message

    OnBegin<override>()<suspends>:void=
        spawn:
            InitializeUI()          #Initialized UI
        
        OpenApparelButton.InteractedWithEvent.Subscribe(OpenApparelClosetR)         #tracks when button is pressed

        #Sets up all apparel
        for(idx -> App : AllApparel):                          
            set App.PurchaseFailMSG = PurchaseFailMSG
            set App.AlreadyHaveFailHUD = AlreadyHaveFailHUD
            set App.SuccessMSG = SuccessMSG
            set App.PurchaseXP = PurchaseXP
            set App.GameManager = GameManager
            set App.UniqueIDX = idx + 1
            App.PurchaseButton.InteractedWithEvent.Subscribe(App.PurchaseApparel)


    #Initializes all of the UI buttons
    InitializeUI()<suspends> : void=
        Position1ButtonL.SetText(StringToMessage("<"))
        Position1ButtonR.SetText(StringToMessage(">"))
        Position2ButtonL.SetText(StringToMessage("<"))
        Position2ButtonR.SetText(StringToMessage(">"))
        Position3ButtonL.SetText(StringToMessage("<"))
        Position3ButtonR.SetText(StringToMessage(">"))

        ExitButton.SetText(StringToMessage("Exit"))
        ExitButton.OnClick().Subscribe(HandleExitButton)

        Position1ButtonL.OnClick().Subscribe(LeftPos1)
        Position1ButtonR.OnClick().Subscribe(RightPos1)
        Position2ButtonL.OnClick().Subscribe(LeftPos2)
        Position2ButtonR.OnClick().Subscribe(RightPos2)
        Position3ButtonL.OnClick().Subscribe(LeftPos3)
        Position3ButtonR.OnClick().Subscribe(RightPos3)


    #Functions to open closet UI for player
    OpenApparelClosetR(Agent:agent) : void=
        spawn:
            OpenApparelCloset(Agent)
    OpenApparelCloset(Agent:agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            ApparelTP.Teleport(Agent)               #Teleports player
            Sleep(0.1)
            FC.PutInStasis(stasis_args{})           #Freezes player
            ApparelCam.AddTo(Agent)                 #Adds camera to player
            AddHUD(Agent)                           #Adds ui to player

    #Adds main UI to player
    AddHUD(Agent : agent ) : void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player],CP := GameManager.PlayersMap[Agent]):
            NewApparelUI := SetupUI()
            CP.MyUI.SetVisibility(widget_visibility.Hidden)
            PlayerUI.AddWidget(NewApparelUI, player_ui_slot{InputMode := ui_input_mode.All})
            if (set MaybeMyUIRewPerPlayer[Player] = option{NewApparelUI}) {}

    #Exits UI when exit button is pressed
    HandleExitButton(Message : widget_message) : void=
        if (PlayerUI := GetPlayerUI[Message.Player], MyUI := MaybeMyUIRewPerPlayer[Message.Player]?,FC:=Message.Player.GetFortCharacter[],CP := GameManager.PlayersMap[Message.Player]):
            PlayerUI.RemoveWidget(MyUI)
            CP.MyUI.SetVisibility(widget_visibility.Visible)
            if (set MaybeMyUIRewPerPlayer[Message.Player] = false) {}
            ApparelCam.RemoveFrom(Message.Player)
            FC.ReleaseFromStasis()


    #Functions to control what to do for each UI button    
    LeftPos1(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,1,true)
    LeftPos2(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,2,true)
    LeftPos3(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,3,true)
    RightPos1(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,1,false)
    RightPos2(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,2,false)
    RightPos3(Message : widget_message) : void =
        if (Player:= Message.Player, CP := GameManager.PlayersMap[Player]):
            ScrollThrough(Player,3,false)
            
    
    #Function to scroll through apparel for different positions
    ScrollThrough(Player : player, Pos : int , IsLeft : logic) : void=
        if (CP := GameManager.PlayersMap[Player]):
            var OwnedSlot1 : []int = array{}
            var OwnedSlot2 : []int = array{}
            var OwnedSlot3 : []int = array{}
            for(idx -> OwnedApp : CP.BoughtApparels):                    #for apparel bought by player
                for(App : AllApparel):                                  #goes through every appael
                    if(OwnedApp = App.UniqueIDX):                       #if apparel is bought by the player
                        if(App.BodySlot = 1):                           #adds the specific apparel to array of specific slots
                            set OwnedSlot1 += array{App.UniqueIDX}
                        if(App.BodySlot = 2):
                            set OwnedSlot2 += array{App.UniqueIDX}
                        if(App.BodySlot = 3):
                            set OwnedSlot3 += array{App.UniqueIDX}

            if(ToEquip1 := OwnedSlot1[CP.EquippedApparels[0] - 1]):
                for(App : AllApparel):
                    if(App.UniqueIDX = ToEquip1):
                        App.RemoveApparelBonuses(Player)
            if(ToEquip2 := OwnedSlot2[CP.EquippedApparels[1] - 1]):
                for(App : AllApparel):
                    if(App.UniqueIDX = ToEquip2):
                        App.RemoveApparelBonuses(Player) 
            if(ToEquip3 := OwnedSlot3[CP.EquippedApparels[2] - 1]):
                for(App : AllApparel):
                    if(App.UniqueIDX = ToEquip3):
                        App.RemoveApparelBonuses(Player) 


            AmountofSlot1 := OwnedSlot1.Length
            AmountofSlot2 := OwnedSlot2.Length
            AmountofSlot3 := OwnedSlot3.Length
            if(IsLeft?):
                if(Pos = 1):
                    if(CP.EquippedApparels[0] - 1 < 0):
                        if(set CP.EquippedApparels[0] = AmountofSlot1){}
                    else:
                        if(set CP.EquippedApparels[0] -= 1){} 
                else if(Pos = 2):
                    if(CP.EquippedApparels[1] - 1 < 0):
                        if(set CP.EquippedApparels[1] = AmountofSlot2){}
                    else:
                        if(set CP.EquippedApparels[1] -= 1){} 
                else if(Pos = 3):
                    if(CP.EquippedApparels[2] - 1 < 0):
                        if(set CP.EquippedApparels[2] = AmountofSlot3){}
                    else:
                        if(set CP.EquippedApparels[2] -= 1){} 
            else:
                if(Pos = 1):
                    if(CP.EquippedApparels[0] + 1 > AmountofSlot1):
                        if(set CP.EquippedApparels[0] =0){}
                    else:
                        if(set CP.EquippedApparels[0] += 1){} 
                else if(Pos = 2):
                    if(CP.EquippedApparels[1] + 1 > AmountofSlot2):
                        if(set CP.EquippedApparels[1] =0){}
                    else:
                        if(set CP.EquippedApparels[1] += 1){} 
                else if(Pos = 3):                    
                    if(CP.EquippedApparels[2] + 1 > AmountofSlot3):
                        if(set CP.EquippedApparels[2] =0){}
                    else:
                        if(set CP.EquippedApparels[2] += 1){} 
    
            ApparelCheck(Player,OwnedSlot1,OwnedSlot2,OwnedSlot3)





    #Function to check which apparel is equipped and equip it 
    ApparelCheck(Player:player, Owned1 : []int ,Owned2 : []int,Owned3 : []int) : void=
        Position1Trigger.Trigger(Player)
        Position2Trigger.Trigger(Player)
        Position3Trigger.Trigger(Player)
        if(CP :=  GameManager.PlayersMap[Player]):
            if(ToEquip1 := Owned1[CP.EquippedApparels[0] - 1]):
                for(App : AllApparel):
                    if(App.UniqueIDX = ToEquip1):
                        App.VFX.Pickup(Player)
                        App.GiveApparelBonuses(Player)
            if(ToEquip2 := Owned2[CP.EquippedApparels[1] - 1]):
                for(App : AllApparel):
                    if(App.UniqueIDX = ToEquip2):
                        App.VFX.Pickup(Player) 
                        App.GiveApparelBonuses(Player)
            if(ToEquip3 := Owned2[CP.EquippedApparels[2] - 1]):
                for(App : AllApparel):
                    if(App.UniqueIDX = ToEquip3):
                        App.VFX.Pickup(Player) 
                        App.GiveApparelBonuses(Player)
            

    #Setups main UI
    SetupUI() : canvas=
        NewUI : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -250.0, Left := 200.0, Right := 100.0, Bottom := 100.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := Position1ButtonR
                       

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -250.0, Left := -300.0, Right := 100.0, Bottom := 100.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := Position1ButtonL


                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -50.0, Left := 200.0, Right := 100.0, Bottom := 100.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := Position2ButtonR
                        

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -50.0, Left := -300.0, Right := 100.0, Bottom := 100.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := Position2ButtonL


                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 150.0, Left := 200.0, Right := 100.0, Bottom := 100.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := Position3ButtonR
                        

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := 150.0, Left := -300.0, Right := 100.0, Bottom := 100.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := Position3ButtonL

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Top := -400.0, Left := 200.0, Right := 200.0, Bottom := 100.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := ExitButton
        return NewUI         