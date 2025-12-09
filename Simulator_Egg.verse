using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#══════════════════════════════════════════════════════════════════════════════
# SIMULATOR EGG - Système d'oeufs et hatching avec gacha
#══════════════════════════════════════════════════════════════════════════════

#──────────────────────────────────────────────────────────────────────────────
# CONFIGURATION D'UN TYPE D'OEUF
#──────────────────────────────────────────────────────────────────────────────
egg_type_config := class<concrete>:
    @editable
    EggID : int = 0

    @editable
    Name : string = "Basic Egg"

    @editable
    Cost : float = 100.0

    @editable
    RequiredZone : int = 0  # Zone minimum pour acheter cet oeuf

    @editable
    RequiredRebirths : int = 0  # Rebirths minimum

    # Probabilités par rareté (doivent totaliser 1.0)
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

    # IDs des pets possibles par rareté
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

#──────────────────────────────────────────────────────────────────────────────
# RÉSULTAT D'UN HATCHING
#──────────────────────────────────────────────────────────────────────────────
hatch_result := struct:
    Success : logic
    PetID : int
    Rarity : pet_rarity
    IsNew : logic  # Premier exemplaire de ce pet

#──────────────────────────────────────────────────────────────────────────────
# STATION D'OEUFS (Device placé dans le monde)
#──────────────────────────────────────────────────────────────────────────────
egg_station := class(creative_device):
    @editable
    EggConfig : egg_type_config = egg_type_config{}

    @editable
    PurchaseButton : button_device = button_device{}

    @editable
    CostBillboard : billboard_device = billboard_device{}

    @editable
    EggProp : creative_prop = creative_prop{}

    @editable
    HatchVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    HatchAudio : audio_player_device = audio_player_device{}

    @editable
    SuccessPopup : popup_dialog_device = popup_dialog_device{}

    @editable
    HatchAnimationDuration : float = 2.0

    var IsHatching : logic = false

    # Messages localisés
    CostMsg<localizes>(Amount : float) : message = "Cost: {Amount} Snow"
    HatchingMsg<localizes> : message = "Hatching..."
    LockedMsg<localizes> : message = "LOCKED"

    OnBegin<override>()<suspends> : void =
        UpdateCostDisplay()
        PurchaseButton.InteractedWithEvent.Subscribe(OnPurchaseAttempt)

    UpdateCostDisplay() : void =
        CostBillboard.SetText(CostMsg(EggConfig.Cost))

    OnPurchaseAttempt(Agent : agent) : void =
        if (IsHatching?):
            return

        if (Player := player[Agent]):
            if (SimPlayer := GetSimulatorPlayer(Player)):
                # Vérifie les conditions
                if (CanPurchaseEgg(Player)):
                    # Tente d'acheter
                    if (RemoveSnow(Player, EggConfig.Cost)):
                        spawn{PerformHatch(Player, SimPlayer)}
                    else:
                        # Pas assez de neige - feedback
                        pass
                else:
                    # Conditions non remplies - feedback
                    pass

    CanPurchaseEgg(Player : player) : logic =
        if (Data := GetFullData(Player)):
            # Vérifie la zone
            ZoneUnlocked := IsZoneUnlocked(Player, EggConfig.RequiredZone)
            # Vérifie les rebirths
            EnoughRebirths := Data.RebirthCount >= EggConfig.RequiredRebirths
            ZoneUnlocked and EnoughRebirths
        else:
            false

    PerformHatch(Player : player, SimPlayer : simulator_player)<suspends> : void =
        set IsHatching = true
        CostBillboard.SetText(HatchingMsg)

        # Animation de l'oeuf (shake, glow, etc.)
        HatchVFX.Restart()
        HatchAudio.Play()

        # Anime l'oeuf (mouvement de secousse)
        spawn{AnimateEggShake()}

        # Attend la durée de l'animation
        Sleep(HatchAnimationDuration)

        # Détermine le résultat
        Result := RollForPet(Player)

        if (Result.Success?):
            # Ajoute le pet à la collection
            AddPet(Player, Result.PetID)

            # Recalcule les stats
            SimPlayer.RecalculateStats()

            # Affiche le résultat
            ShowHatchResult(Result)

        # Reset
        set IsHatching = false
        UpdateCostDisplay()

    AnimateEggShake()<suspends> : void =
        OriginalPos := EggProp.GetTransform().Translation
        OriginalRot := EggProp.GetTransform().Rotation
        ShakeIntensity := 5.0
        ShakeCount := 10

        for (I := 0..ShakeCount - 1):
            # Shake gauche
            OffsetX := GetRandomFloat(-ShakeIntensity, ShakeIntensity)
            OffsetY := GetRandomFloat(-ShakeIntensity, ShakeIntensity)
            ShakePos := OriginalPos + vector3{X := OffsetX, Y := OffsetY}
            if (EggProp.TeleportTo[ShakePos, OriginalRot]) {}
            Sleep(HatchAnimationDuration / (ShakeCount * 2.0))

            # Retour centre
            if (EggProp.TeleportTo[OriginalPos, OriginalRot]) {}
            Sleep(HatchAnimationDuration / (ShakeCount * 2.0))

    RollForPet(Player : player) : hatch_result =
        # Tire un nombre aléatoire
        Roll := GetRandomFloat(0.0, 1.0)

        # Détermine la rareté
        var SelectedRarity : pet_rarity = pet_rarity.Common
        var PetPool : []int = EggConfig.CommonPetIDs
        var CumulativeChance : float = 0.0

        # Mythic
        set CumulativeChance += EggConfig.MythicChance
        if (Roll <= CumulativeChance):
            set SelectedRarity = pet_rarity.Mythic
            set PetPool = EggConfig.MythicPetIDs
        else:
            # Legendary
            set CumulativeChance += EggConfig.LegendaryChance
            if (Roll <= CumulativeChance):
                set SelectedRarity = pet_rarity.Legendary
                set PetPool = EggConfig.LegendaryPetIDs
            else:
                # Epic
                set CumulativeChance += EggConfig.EpicChance
                if (Roll <= CumulativeChance):
                    set SelectedRarity = pet_rarity.Epic
                    set PetPool = EggConfig.EpicPetIDs
                else:
                    # Rare
                    set CumulativeChance += EggConfig.RareChance
                    if (Roll <= CumulativeChance):
                        set SelectedRarity = pet_rarity.Rare
                        set PetPool = EggConfig.RarePetIDs
                    # Sinon Common (par défaut)

        # Sélectionne un pet aléatoire dans le pool
        if (PetPool.Length > 0):
            RandomIndex := GetRandomInt(0, PetPool.Length - 1)
            if (PetID := PetPool[RandomIndex]):
                # Vérifie si c'est un nouveau pet
                IsNew := not PlayerOwnsPet(Player, PetID)
                return hatch_result:
                    Success := true
                    PetID := PetID
                    Rarity := SelectedRarity
                    IsNew := IsNew

        # Fallback - aucun pet dans le pool
        hatch_result:
            Success := false
            PetID := 0
            Rarity := pet_rarity.Common
            IsNew := false

    PlayerOwnsPet(Player : player, PetID : int) : logic =
        OwnedPets := GetOwnedPets(Player)
        for (ID : OwnedPets):
            if (ID = PetID):
                return true
        false

    ShowHatchResult(Result : hatch_result) : void =
        # Affiche le popup avec le résultat
        # Note: Le popup device affichera le nom et la rareté du pet
        SuccessPopup.Show()

#══════════════════════════════════════════════════════════════════════════════
# MANAGER DES OEUFS
#══════════════════════════════════════════════════════════════════════════════
simulator_egg_manager := class(creative_device):

    @editable
    EggTypes : []egg_type_config = array{}

    @editable
    EggStations : []egg_station = array{}

    # Événements
    var OnEggHatched : event(player, hatch_result) = event(player, hatch_result){}

    OnBegin<override>()<suspends> : void =
        # Initialise les stations
        for (Station : EggStations):
            # Les stations s'initialisent elles-mêmes

    #──────────────────────────────────────────────────────────────────────────
    # ACHETER ET OUVRIR UN OEUF (version programmation)
    #──────────────────────────────────────────────────────────────────────────
    TryPurchaseEgg(Player : player, EggID : int)<transacts><decides> : hatch_result =
        # Trouve la config de l'oeuf
        EggConfig := GetEggConfigByID(EggID)?

        # Vérifie les conditions
        Data := GetFullData(Player)?
        IsZoneUnlocked(Player, EggConfig.RequiredZone)?
        Data.RebirthCount >= EggConfig.RequiredRebirths

        # Retire le coût
        RemoveSnow(Player, EggConfig.Cost)?

        # Effectue le roll
        Result := RollEgg(Player, EggConfig)

        if (Result.Success?):
            AddPet(Player, Result.PetID)

        OnEggHatched.Signal(Player, Result)
        Result

    #──────────────────────────────────────────────────────────────────────────
    # ROLL UN OEUF
    #──────────────────────────────────────────────────────────────────────────
    RollEgg(Player : player, Config : egg_type_config) : hatch_result =
        Roll := GetRandomFloat(0.0, 1.0)

        var SelectedRarity : pet_rarity = pet_rarity.Common
        var PetPool : []int = Config.CommonPetIDs
        var CumulativeChance : float = 0.0

        # Check chaque rareté du plus rare au moins rare
        set CumulativeChance = Config.MythicChance
        if (Roll <= CumulativeChance):
            set SelectedRarity = pet_rarity.Mythic
            set PetPool = Config.MythicPetIDs
        else:
            set CumulativeChance += Config.LegendaryChance
            if (Roll <= CumulativeChance):
                set SelectedRarity = pet_rarity.Legendary
                set PetPool = Config.LegendaryPetIDs
            else:
                set CumulativeChance += Config.EpicChance
                if (Roll <= CumulativeChance):
                    set SelectedRarity = pet_rarity.Epic
                    set PetPool = Config.EpicPetIDs
                else:
                    set CumulativeChance += Config.RareChance
                    if (Roll <= CumulativeChance):
                        set SelectedRarity = pet_rarity.Rare
                        set PetPool = Config.RarePetIDs

        # Sélectionne un pet
        if (PetPool.Length > 0):
            RandomIndex := GetRandomInt(0, PetPool.Length - 1)
            if (PetID := PetPool[RandomIndex]):
                OwnedPets := GetOwnedPets(Player)
                var IsNew : logic = true
                for (ID : OwnedPets):
                    if (ID = PetID):
                        set IsNew = false
                        break
                return hatch_result:
                    Success := true
                    PetID := PetID
                    Rarity := SelectedRarity
                    IsNew := IsNew

        hatch_result{Success := false, PetID := 0, Rarity := pet_rarity.Common, IsNew := false}

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR UNE CONFIG D'OEUF PAR ID
    #──────────────────────────────────────────────────────────────────────────
    GetEggConfigByID(EggID : int) : ?egg_type_config =
        for (Config : EggTypes):
            if (Config.EggID = EggID):
                return option{Config}
        false

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR LES OEUFS DISPONIBLES POUR UN JOUEUR
    #──────────────────────────────────────────────────────────────────────────
    GetAvailableEggs(Player : player) : []egg_type_config =
        var Available : []egg_type_config = array{}
        if (Data := GetFullData(Player)):
            for (Config : EggTypes):
                if (IsZoneUnlocked(Player, Config.RequiredZone)):
                    if (Data.RebirthCount >= Config.RequiredRebirths):
                        set Available += array{Config}
        Available

    #──────────────────────────────────────────────────────────────────────────
    # CALCULER LES CHANCES POUR UN OEUF (pour UI)
    #──────────────────────────────────────────────────────────────────────────
    GetEggChances(EggID : int) : ?[]tuple(Rarity : pet_rarity, Chance : float) =
        if (Config := GetEggConfigByID(EggID)):
            return option{array:
                (Rarity := pet_rarity.Common, Chance := Config.CommonChance)
                (Rarity := pet_rarity.Rare, Chance := Config.RareChance)
                (Rarity := pet_rarity.Epic, Chance := Config.EpicChance)
                (Rarity := pet_rarity.Legendary, Chance := Config.LegendaryChance)
                (Rarity := pet_rarity.Mythic, Chance := Config.MythicChance)
            }
        false

#══════════════════════════════════════════════════════════════════════════════
# TRIPLE HATCH (Acheter 3 oeufs d'un coup)
#══════════════════════════════════════════════════════════════════════════════
egg_station_triple := class(creative_device):
    @editable
    EggConfig : egg_type_config = egg_type_config{}

    @editable
    PurchaseButton : button_device = button_device{}

    @editable
    CostBillboard : billboard_device = billboard_device{}

    @editable
    EggProps : []creative_prop = array{}  # 3 props d'oeufs

    @editable
    HatchVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    DiscountPercent : float = 10.0  # 10% de réduction pour triple

    var IsHatching : logic = false

    TripleCostMsg<localizes>(Amount : float) : message = "3x Cost: {Amount} Snow (-{DiscountPercent}%)"

    OnBegin<override>()<suspends> : void =
        TripleCost := GetTripleCost()
        CostBillboard.SetText(TripleCostMsg(TripleCost))
        PurchaseButton.InteractedWithEvent.Subscribe(OnTriplePurchase)

    GetTripleCost() : float =
        BaseCost := EggConfig.Cost * 3.0
        Discount := BaseCost * (DiscountPercent / 100.0)
        BaseCost - Discount

    OnTriplePurchase(Agent : agent) : void =
        if (IsHatching?):
            return

        if (Player := player[Agent]):
            if (SimPlayer := GetSimulatorPlayer(Player)):
                TripleCost := GetTripleCost()
                if (RemoveSnow(Player, TripleCost)):
                    spawn{PerformTripleHatch(Player, SimPlayer)}

    PerformTripleHatch(Player : player, SimPlayer : simulator_player)<suspends> : void =
        set IsHatching = true

        # Hatch les 3 oeufs
        for (I := 0..2):
            HatchVFX.Restart()
            Sleep(0.5)

            # Roll pour ce pet
            Result := RollSinglePet(Player)
            if (Result.Success?):
                AddPet(Player, Result.PetID)

            Sleep(1.0)

        SimPlayer.RecalculateStats()
        set IsHatching = false

    RollSinglePet(Player : player) : hatch_result =
        Roll := GetRandomFloat(0.0, 1.0)
        var SelectedRarity : pet_rarity = pet_rarity.Common
        var PetPool : []int = EggConfig.CommonPetIDs
        var Cumulative : float = 0.0

        set Cumulative = EggConfig.MythicChance
        if (Roll <= Cumulative):
            set SelectedRarity = pet_rarity.Mythic
            set PetPool = EggConfig.MythicPetIDs
        else:
            set Cumulative += EggConfig.LegendaryChance
            if (Roll <= Cumulative):
                set SelectedRarity = pet_rarity.Legendary
                set PetPool = EggConfig.LegendaryPetIDs
            else:
                set Cumulative += EggConfig.EpicChance
                if (Roll <= Cumulative):
                    set SelectedRarity = pet_rarity.Epic
                    set PetPool = EggConfig.EpicPetIDs
                else:
                    set Cumulative += EggConfig.RareChance
                    if (Roll <= Cumulative):
                        set SelectedRarity = pet_rarity.Rare
                        set PetPool = EggConfig.RarePetIDs

        if (PetPool.Length > 0):
            Idx := GetRandomInt(0, PetPool.Length - 1)
            if (ID := PetPool[Idx]):
                return hatch_result{Success := true, PetID := ID, Rarity := SelectedRarity, IsNew := false}

        hatch_result{Success := false, PetID := 0, Rarity := pet_rarity.Common, IsNew := false}

#══════════════════════════════════════════════════════════════════════════════
# AUTO-HATCH (Hatch automatique avec toggle)
#══════════════════════════════════════════════════════════════════════════════
auto_hatch_controller := class(creative_device):
    @editable
    ToggleButton : button_device = button_device{}

    @editable
    StatusBillboard : billboard_device = billboard_device{}

    @editable
    EggManager : simulator_egg_manager = simulator_egg_manager{}

    @editable
    TargetEggID : int = 0

    @editable
    HatchIntervalSeconds : float = 1.0

    var IsAutoHatching : logic = false
    var AutoHatchPlayer : ?player = false

    EnabledMsg<localizes> : message = "Auto-Hatch: ON"
    DisabledMsg<localizes> : message = "Auto-Hatch: OFF"

    OnBegin<override>()<suspends> : void =
        StatusBillboard.SetText(DisabledMsg)
        ToggleButton.InteractedWithEvent.Subscribe(OnToggle)
        spawn{AutoHatchLoop()}

    OnToggle(Agent : agent) : void =
        if (Player := player[Agent]):
            if (IsAutoHatching?):
                set IsAutoHatching = false
                set AutoHatchPlayer = false
                StatusBillboard.SetText(DisabledMsg)
            else:
                set IsAutoHatching = true
                set AutoHatchPlayer = option{Player}
                StatusBillboard.SetText(EnabledMsg)

    AutoHatchLoop()<suspends> : void =
        loop:
            Sleep(HatchIntervalSeconds)
            if (IsAutoHatching?):
                if (Player := AutoHatchPlayer?):
                    if (EggManager.TryPurchaseEgg(Player, TargetEggID)) {}
