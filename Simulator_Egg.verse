using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }

# SIMULATOR EGG - Système d'oeufs

# Configuration d'un oeuf
egg_config<public> := class<concrete>:
    @editable
    EggID : int = 0

    @editable
    Name : string = "Basic Egg"

    @editable
    Cost : float = 100.0

    @editable
    CommonChance : float = 0.60

    @editable
    RareChance : float = 0.25

    @editable
    EpicChance : float = 0.10

    @editable
    LegendaryChance : float = 0.04

    @editable
    MythicChance : float = 0.01

    @editable
    CommonPetIDs : []int = array{}

    @editable
    RarePetIDs : []int = array{}

    @editable
    EpicPetIDs : []int = array{}

    @editable
    LegendaryPetIDs : []int = array{}

    @editable
    MythicPetIDs : []int = array{}

# Station d'oeufs
egg_station_device<public> := class(creative_device):
    @editable
    EggConfig : egg_config = egg_config{}

    @editable
    PurchaseButton : button_device = button_device{}

    @editable
    CostBillboard : billboard_device = billboard_device{}

    @editable
    HatchVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    ResultHUD : hud_message_device = hud_message_device{}

    var IsHatching : logic = false

    CostMsg<localizes>(Amount : float) : message = "Cost: {Amount} Snow"
    HatchingMsg<localizes> : message = "Hatching..."
    ResultMsg<localizes>(Rarity : string) : message = "You got a {Rarity} pet!"

    OnBegin<override>()<suspends> : void =
        CostBillboard.SetText(CostMsg(EggConfig.Cost))
        PurchaseButton.InteractedWithEvent.Subscribe(OnPurchase)

    OnPurchase(Agent : agent) : void =
        if (IsHatching?):
            return
        if (InPlayer := player[Agent]):
            if (RemoveSnow(InPlayer, EggConfig.Cost)):
                spawn{PerformHatch(InPlayer)}

    PerformHatch(InPlayer : player)<suspends> : void =
        set IsHatching = true
        CostBillboard.SetText(HatchingMsg)
        HatchVFX.Restart()
        Sleep(2.0)

        # Roll la rareté
        Roll := GetRandomFloat(0.0, 1.0)
        var SelectedRarity : pet_rarity = pet_rarity.Common
        var PetPool : []int = EggConfig.CommonPetIDs
        var Cumulative : float = 0.0

        set Cumulative = EggConfig.MythicChance
        if (Roll <= Cumulative):
            set SelectedRarity = pet_rarity.Mythic
            set PetPool = EggConfig.MythicPetIDs
        else:
            set Cumulative = Cumulative + EggConfig.LegendaryChance
            if (Roll <= Cumulative):
                set SelectedRarity = pet_rarity.Legendary
                set PetPool = EggConfig.LegendaryPetIDs
            else:
                set Cumulative = Cumulative + EggConfig.EpicChance
                if (Roll <= Cumulative):
                    set SelectedRarity = pet_rarity.Epic
                    set PetPool = EggConfig.EpicPetIDs
                else:
                    set Cumulative = Cumulative + EggConfig.RareChance
                    if (Roll <= Cumulative):
                        set SelectedRarity = pet_rarity.Rare
                        set PetPool = EggConfig.RarePetIDs

        # Sélectionne un pet
        if (PetPool.Length > 0):
            RandomIndex := GetRandomInt(0, PetPool.Length - 1)
            if (PetID := PetPool[RandomIndex]):
                AddPet(InPlayer, PetID)

        RarityName := GetRarityName(SelectedRarity)
        ResultHUD.SetText(ResultMsg(RarityName))
        ResultHUD.Show(InPlayer)

        set IsHatching = false
        CostBillboard.SetText(CostMsg(EggConfig.Cost))
