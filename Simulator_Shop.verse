using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }

#══════════════════════════════════════════════════════════════════════════════
# SIMULATOR SHOP - Système d'upgrades et magasin
#══════════════════════════════════════════════════════════════════════════════

#──────────────────────────────────────────────────────────────────────────────
# UPGRADE STATION (Un upgrade spécifique)
#──────────────────────────────────────────────────────────────────────────────
upgrade_station := class(creative_device):
    @editable
    UpgradeIndex : int = 0  # Index dans DefaultUpgradeConfigs

    @editable
    PurchaseButton : button_device = button_device{}

    @editable
    NameBillboard : billboard_device = billboard_device{}

    @editable
    LevelBillboard : billboard_device = billboard_device{}

    @editable
    CostBillboard : billboard_device = billboard_device{}

    @editable
    DescriptionBillboard : billboard_device = billboard_device{}

    @editable
    UpgradeVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    UpgradeAudio : audio_player_device = audio_player_device{}

    @editable
    MaxLevelIndicator : billboard_device = billboard_device{}

    var Config : ?upgrade_config = false

    # Messages localisés
    NameMsg<localizes>(Name : string) : message = "{Name}"
    LevelMsg<localizes>(Level : int) : message = "Level: {Level}"
    LevelMaxMsg<localizes>(Level : int, Max : int) : message = "Level: {Level}/{Max}"
    CostMsg<localizes>(Cost : float) : message = "Cost: {Cost} Snow"
    MaxedMsg<localizes> : message = "MAXED!"
    DescMsg<localizes>(Desc : string) : message = "{Desc}"
    NotEnoughMsg<localizes> : message = "Not enough Snow!"

    OnBegin<override>()<suspends> : void =
        # Charge la config
        if (UpgradeIndex >= 0 and UpgradeIndex < DefaultUpgradeConfigs.Length):
            if (Cfg := DefaultUpgradeConfigs[UpgradeIndex]):
                set Config = option{Cfg}

        PurchaseButton.InteractedWithEvent.Subscribe(OnPurchaseAttempt)

        # Met à jour l'affichage initial
        UpdateDisplay()

        # Boucle de mise à jour pour tous les joueurs
        spawn{UpdateLoop()}

    UpdateLoop()<suspends> : void =
        loop:
            Sleep(0.5)
            UpdateDisplay()

    UpdateDisplay() : void =
        if (Cfg := Config?):
            # Nom et description
            NameBillboard.SetText(NameMsg(Cfg.Name))
            DescriptionBillboard.SetText(DescMsg(Cfg.Description))

            # Niveau et coût (basé sur le premier joueur pour l'affichage global)
            # Note: Dans un vrai système, on afficherait par joueur
            Players := GetPlayspace().GetPlayers()
            if (FirstPlayer := Players[0]):
                CurrentLevel := GetUpgradeLevel(FirstPlayer, UpgradeIndex)
                Cost := GetUpgradeCost(Cfg, CurrentLevel)

                # Vérifie si maxé
                if (Cfg.MaxLevel >= 0 and CurrentLevel >= Cfg.MaxLevel):
                    LevelBillboard.SetText(LevelMaxMsg(CurrentLevel, Cfg.MaxLevel))
                    CostBillboard.SetText(MaxedMsg)
                    MaxLevelIndicator.SetText(MaxedMsg)
                else:
                    if (Cfg.MaxLevel >= 0):
                        LevelBillboard.SetText(LevelMaxMsg(CurrentLevel, Cfg.MaxLevel))
                    else:
                        LevelBillboard.SetText(LevelMsg(CurrentLevel))
                    CostBillboard.SetText(CostMsg(Cost))
                    MaxLevelIndicator.SetText(NameMsg(""))

    OnPurchaseAttempt(Agent : agent) : void =
        if (Cfg := Config?):
            if (Player := player[Agent]):
                if (SimPlayer := GetSimulatorPlayer(Player)):
                    # Tente l'achat
                    if (NewLevel := SimPlayer.TryBuyUpgrade(UpgradeIndex)):
                        # Succès
                        UpgradeVFX.Restart()
                        UpgradeAudio.Play()
                        UpdateDisplay()
                    else:
                        # Échec - pas assez de ressources ou maxé
                        CostBillboard.SetText(NotEnoughMsg)
                        spawn{ResetCostDisplayAfterDelay()}

    ResetCostDisplayAfterDelay()<suspends> : void =
        Sleep(1.5)
        UpdateDisplay()

#══════════════════════════════════════════════════════════════════════════════
# SHOP MANAGER - Gère toutes les stations d'upgrade
#══════════════════════════════════════════════════════════════════════════════
simulator_shop_manager := class(creative_device):

    @editable
    UpgradeStations : []upgrade_station = array{}

    @editable
    ShopTitleBillboard : billboard_device = billboard_device{}

    @editable
    TotalSpentBillboard : billboard_device = billboard_device{}

    # Événements
    var OnUpgradePurchased : event(player, int, int) = event(player, int, int){}  # player, upgradeIndex, newLevel

    TitleMsg<localizes> : message = "UPGRADE SHOP"
    TotalSpentMsg<localizes>(Amount : float) : message = "Total Invested: {Amount} Snow"

    OnBegin<override>()<suspends> : void =
        ShopTitleBillboard.SetText(TitleMsg)

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR LE COÛT TOTAL DES UPGRADES D'UN JOUEUR
    #──────────────────────────────────────────────────────────────────────────
    GetTotalUpgradeCost(Player : player) : float =
        var Total : float = 0.0
        for (Index := 0..DefaultUpgradeConfigs.Length - 1):
            if (Cfg := DefaultUpgradeConfigs[Index]):
                CurrentLevel := GetUpgradeLevel(Player, Index)
                # Calcule le coût total pour atteindre ce niveau
                for (Lvl := 0..CurrentLevel - 1):
                    set Total += GetUpgradeCost(Cfg, Lvl)
        Total

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR TOUS LES NIVEAUX D'UPGRADE
    #──────────────────────────────────────────────────────────────────────────
    GetAllUpgradeLevels(Player : player) : []int =
        var Levels : []int = array{}
        for (Index := 0..DefaultUpgradeConfigs.Length - 1):
            Level := GetUpgradeLevel(Player, Index)
            set Levels += array{Level}
        Levels

    #──────────────────────────────────────────────────────────────────────────
    # ACHETER PLUSIEURS NIVEAUX D'UN COUP
    #──────────────────────────────────────────────────────────────────────────
    BuyMultipleUpgrades(Player : player, UpgradeIndex : int, Count : int)<transacts><decides> : int =
        var Purchased : int = 0
        if (SimPlayer := GetSimulatorPlayer(Player)):
            for (I := 0..Count - 1):
                if (SimPlayer.TryBuyUpgrade(UpgradeIndex)):
                    set Purchased += 1
                else:
                    break
        Purchased > 0
        Purchased

#══════════════════════════════════════════════════════════════════════════════
# BULK UPGRADE STATION (Acheter plusieurs niveaux d'un coup)
#══════════════════════════════════════════════════════════════════════════════
bulk_upgrade_station := class(creative_device):
    @editable
    UpgradeIndex : int = 0

    @editable
    Buy1Button : button_device = button_device{}

    @editable
    Buy10Button : button_device = button_device{}

    @editable
    BuyMaxButton : button_device = button_device{}

    @editable
    InfoBillboard : billboard_device = billboard_device{}

    @editable
    UpgradeVFX : vfx_spawner_device = vfx_spawner_device{}

    var Config : ?upgrade_config = false

    InfoMsg<localizes>(Name : string, Level : int) : message = "{Name} - Lv.{Level}"
    BoughtMsg<localizes>(Count : int) : message = "+{Count} Levels!"

    OnBegin<override>()<suspends> : void =
        if (UpgradeIndex >= 0 and UpgradeIndex < DefaultUpgradeConfigs.Length):
            if (Cfg := DefaultUpgradeConfigs[UpgradeIndex]):
                set Config = option{Cfg}

        Buy1Button.InteractedWithEvent.Subscribe(OnBuy1)
        Buy10Button.InteractedWithEvent.Subscribe(OnBuy10)
        BuyMaxButton.InteractedWithEvent.Subscribe(OnBuyMax)

        spawn{UpdateLoop()}

    UpdateLoop()<suspends> : void =
        loop:
            Sleep(0.5)
            UpdateDisplay()

    UpdateDisplay() : void =
        if (Cfg := Config?):
            Players := GetPlayspace().GetPlayers()
            if (P := Players[0]):
                Level := GetUpgradeLevel(P, UpgradeIndex)
                InfoBillboard.SetText(InfoMsg(Cfg.Name, Level))

    OnBuy1(Agent : agent) : void =
        BuyUpgrades(Agent, 1)

    OnBuy10(Agent : agent) : void =
        BuyUpgrades(Agent, 10)

    OnBuyMax(Agent : agent) : void =
        BuyUpgrades(Agent, 1000)  # Essaie d'acheter jusqu'à 1000

    BuyUpgrades(Agent : agent, Count : int) : void =
        if (Player := player[Agent]):
            if (SimPlayer := GetSimulatorPlayer(Player)):
                var Purchased : int = 0
                for (I := 0..Count - 1):
                    if (SimPlayer.TryBuyUpgrade(UpgradeIndex)):
                        set Purchased += 1
                    else:
                        break

                if (Purchased > 0):
                    UpgradeVFX.Restart()
                    InfoBillboard.SetText(BoughtMsg(Purchased))
                    spawn{ResetDisplayAfterDelay()}

    ResetDisplayAfterDelay()<suspends> : void =
        Sleep(1.5)
        UpdateDisplay()

#══════════════════════════════════════════════════════════════════════════════
# STATS DISPLAY (Affiche les stats du joueur depuis les upgrades)
#══════════════════════════════════════════════════════════════════════════════
player_stats_display := class(creative_device):
    @editable
    DamageBillboard : billboard_device = billboard_device{}

    @editable
    SpeedBillboard : billboard_device = billboard_device{}

    @editable
    CurrencyBillboard : billboard_device = billboard_device{}

    @editable
    CritChanceBillboard : billboard_device = billboard_device{}

    @editable
    CritDamageBillboard : billboard_device = billboard_device{}

    @editable
    MaxPetsBillboard : billboard_device = billboard_device{}

    @editable
    UpdateInterval : float = 0.25

    # Messages
    DamageMsg<localizes>(Value : float) : message = "Damage: {Value}"
    SpeedMsg<localizes>(Value : float) : message = "Speed: {Value}x"
    CurrencyMsg<localizes>(Value : float) : message = "Snow Bonus: {Value}x"
    CritChanceMsg<localizes>(Value : float) : message = "Crit Chance: {Value}%"
    CritDamageMsg<localizes>(Value : float) : message = "Crit Damage: {Value}x"
    MaxPetsMsg<localizes>(Value : int) : message = "Max Pets: {Value}"

    OnBegin<override>()<suspends> : void =
        loop:
            Sleep(UpdateInterval)
            UpdateAllPlayers()

    UpdateAllPlayers() : void =
        # Note: Pour un vrai système multi-joueur, il faudrait des billboards par joueur
        # Ici on affiche les stats du premier joueur comme exemple
        Players := GetPlayspace().GetPlayers()
        if (Player := Players[0]):
            if (SimPlayer := GetSimulatorPlayer(Player)):
                DamageBillboard.SetText(DamageMsg(SimPlayer.TotalDamage))
                SpeedBillboard.SetText(SpeedMsg(SimPlayer.TotalSpeed))
                CurrencyBillboard.SetText(CurrencyMsg(SimPlayer.TotalCurrencyMultiplier))
                CritChanceBillboard.SetText(CritChanceMsg(SimPlayer.CritChance))
                CritDamageBillboard.SetText(CritDamageMsg(SimPlayer.CritDamage))
                MaxPetsBillboard.SetText(MaxPetsMsg(SimPlayer.MaxEquippedPets))

#══════════════════════════════════════════════════════════════════════════════
# PET SHOP (Pour équiper/déséquiper les pets)
#══════════════════════════════════════════════════════════════════════════════
pet_equip_station := class(creative_device):
    @editable
    PetID : int = 0

    @editable
    EquipButton : button_device = button_device{}

    @editable
    InfoBillboard : billboard_device = billboard_device{}

    @editable
    StatusBillboard : billboard_device = billboard_device{}

    @editable
    PetManager : simulator_pet_manager = simulator_pet_manager{}

    EquippedMsg<localizes> : message = "EQUIPPED"
    UnequippedMsg<localizes> : message = "Click to Equip"
    NotOwnedMsg<localizes> : message = "NOT OWNED"
    MaxPetsMsg<localizes> : message = "Max Pets Reached!"

    OnBegin<override>()<suspends> : void =
        EquipButton.InteractedWithEvent.Subscribe(OnEquipToggle)
        spawn{UpdateLoop()}

    UpdateLoop()<suspends> : void =
        loop:
            Sleep(0.5)
            UpdateDisplay()

    UpdateDisplay() : void =
        Players := GetPlayspace().GetPlayers()
        if (Player := Players[0]):
            # Vérifie si possédé
            OwnedPets := GetOwnedPets(Player)
            var Owned : logic = false
            for (ID : OwnedPets):
                if (ID = PetID):
                    set Owned = true
                    break

            if (Owned?):
                # Vérifie si équipé
                EquippedPets := GetEquippedPets(Player)
                var Equipped : logic = false
                for (ID : EquippedPets):
                    if (ID = PetID):
                        set Equipped = true
                        break

                if (Equipped?):
                    StatusBillboard.SetText(EquippedMsg)
                else:
                    StatusBillboard.SetText(UnequippedMsg)
            else:
                StatusBillboard.SetText(NotOwnedMsg)

    OnEquipToggle(Agent : agent) : void =
        if (Player := player[Agent]):
            if (SimPlayer := GetSimulatorPlayer(Player)):
                # Vérifie si déjà équipé
                EquippedPets := GetEquippedPets(Player)
                var IsEquipped : logic = false
                for (ID : EquippedPets):
                    if (ID = PetID):
                        set IsEquipped = true
                        break

                if (IsEquipped?):
                    # Déséquipe
                    SimPlayer.UnequipPetByID(PetID)
                    PetManager.DespawnPetForPlayer(Player, PetID)
                    StatusBillboard.SetText(UnequippedMsg)
                else:
                    # Vérifie si possédé
                    OwnedPets := GetOwnedPets(Player)
                    var Owned : logic = false
                    for (ID : OwnedPets):
                        if (ID = PetID):
                            set Owned = true
                            break

                    if (Owned?):
                        # Essaie d'équiper
                        if (PetConfig := PetManager.GetPetTypeByID(PetID)):
                            PetDef := pet_definition:
                                ID := PetConfig.ID
                                Name := PetConfig.Name
                                Rarity := PetConfig.Rarity
                                BaseDamage := PetConfig.BaseDamage
                                BaseSpeed := PetConfig.BaseSpeed
                                BaseCurrencyBonus := PetConfig.BaseCurrencyBonus
                                PropAsset := PetConfig.PropAsset

                            if (SimPlayer.EquipPetByDefinition(PetDef)):
                                PetManager.SpawnPetForPlayer(Player, PetID)
                                StatusBillboard.SetText(EquippedMsg)
                            else:
                                StatusBillboard.SetText(MaxPetsMsg)
                                spawn{ResetDisplayAfterDelay()}

    ResetDisplayAfterDelay()<suspends> : void =
        Sleep(1.5)
        UpdateDisplay()

#══════════════════════════════════════════════════════════════════════════════
# SELL ALL PETS (Vendre tous les pets d'une rareté)
#══════════════════════════════════════════════════════════════════════════════
sell_pets_station := class(creative_device):
    @editable
    TargetRarity : pet_rarity = pet_rarity.Common

    @editable
    SellButton : button_device = button_device{}

    @editable
    InfoBillboard : billboard_device = billboard_device{}

    @editable
    SellVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    SnowPerPet : float = 10.0  # Neige gagnée par pet vendu

    SellMsg<localizes>(Count : int, Total : float) : message = "Sold {Count} pets for {Total} Snow!"
    NoSellMsg<localizes> : message = "No pets to sell!"
    InfoMsg<localizes>(Rarity : string, Price : float) : message = "Sell {Rarity} pets ({Price} Snow each)"

    OnBegin<override>()<suspends> : void =
        RarityName := GetRarityName(TargetRarity)
        InfoBillboard.SetText(InfoMsg(RarityName, SnowPerPet))
        SellButton.InteractedWithEvent.Subscribe(OnSellAll)

    OnSellAll(Agent : agent) : void =
        if (Player := player[Agent]):
            # Note: Cette fonctionnalité nécessiterait d'ajouter une logique de vente
            # dans la persistence. Pour l'instant, c'est un placeholder.
            SellVFX.Restart()
            InfoBillboard.SetText(NoSellMsg)
            spawn{ResetDisplayAfterDelay()}

    ResetDisplayAfterDelay()<suspends> : void =
        Sleep(2.0)
        RarityName := GetRarityName(TargetRarity)
        InfoBillboard.SetText(InfoMsg(RarityName, SnowPerPet))
