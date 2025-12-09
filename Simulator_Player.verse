using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#══════════════════════════════════════════════════════════════════════════════
# SIMULATOR PLAYER - Classe représentant un joueur dans le Simulator
#══════════════════════════════════════════════════════════════════════════════

#──────────────────────────────────────────────────────────────────────────────
# CLASSE JOUEUR SIMULATOR
#──────────────────────────────────────────────────────────────────────────────
simulator_player := class:
    # Références
    Player : player
    var FortCharacter : ?fort_character = false

    # Stats calculées (mises à jour dynamiquement)
    var TotalDamage : float = SimulatorConstants.BaseDamage
    var TotalSpeed : float = SimulatorConstants.BaseAttackSpeed
    var TotalCurrencyMultiplier : float = 1.0
    var CritChance : float = 0.0
    var CritDamage : float = SimulatorConstants.CritMultiplierBase
    var MaxEquippedPets : int = SimulatorConstants.DefaultMaxEquippedPets

    # État actuel
    var CurrentZoneID : int = 0
    var IsAttacking : logic = false
    var LastAttackTime : float = 0.0

    # Pets actifs (références aux props spawned)
    var ActivePetProps : []creative_prop = array{}
    var ActivePetDefinitions : []pet_definition = array{}

    # Événements
    var OnLevelUp : event(int) = event(int){}
    var OnSnowGained : event(float) = event(float){}
    var OnPetEquipped : event(pet_definition) = event(pet_definition){}
    var OnRebirthCompleted : event(int) = event(int){}

    #──────────────────────────────────────────────────────────────────────────
    # INITIALISATION
    #──────────────────────────────────────────────────────────────────────────
    Initialize()<transacts> : void =
        # Charge les données persistantes
        LoadOrCreatePlayerData(Player)
        RecalculateStats()

    #──────────────────────────────────────────────────────────────────────────
    # RECALCUL DES STATS
    #──────────────────────────────────────────────────────────────────────────
    RecalculateStats() : void =
        if (Data := GetFullData(Player)):
            # Base stats
            var BaseDamage : float = SimulatorConstants.BaseDamage
            var BaseSpeed : float = SimulatorConstants.BaseAttackSpeed
            var BaseCurrency : float = 1.0
            var BaseCrit : float = 0.0
            var BaseCritDmg : float = SimulatorConstants.CritMultiplierBase
            var BaseMaxPets : int = SimulatorConstants.DefaultMaxEquippedPets

            # Bonus des upgrades
            for (Index := 0..Data.UpgradeLevels.Length - 1):
                if (Level := Data.UpgradeLevels[Index]):
                    if (Level > 0):
                        if (Config := DefaultUpgradeConfigs[Index]):
                            case (Config.Type):
                                upgrade_type.Damage =>
                                    set BaseDamage += Config.BonusPerLevel * Level
                                upgrade_type.Speed =>
                                    set BaseSpeed += (Config.BonusPerLevel * Level) / 100.0
                                upgrade_type.CurrencyGain =>
                                    set BaseCurrency += (Config.BonusPerLevel * Level) / 100.0
                                upgrade_type.MaxPets =>
                                    set BaseMaxPets += Int[Config.BonusPerLevel * Level]
                                upgrade_type.CritChance =>
                                    set BaseCrit += Config.BonusPerLevel * Level
                                upgrade_type.CritDamage =>
                                    set BaseCritDmg += (Config.BonusPerLevel * Level) / 100.0

            # Bonus des pets équipés
            for (PetDef : ActivePetDefinitions):
                set BaseDamage += PetDef.BaseDamage
                set BaseSpeed += PetDef.BaseSpeed / 100.0
                set BaseCurrency += PetDef.BaseCurrencyBonus / 100.0

            # Bonus de rebirth (permanents)
            RebirthBonuses := GetRebirthBonuses(Player)
            DamageMultiplier := 1.0 + (RebirthBonuses.Damage / 100.0)
            SpeedMultiplier := 1.0 + (RebirthBonuses.Speed / 100.0)
            CurrencyMultiplier := 1.0 + (RebirthBonuses.Currency / 100.0)

            # Application finale
            set TotalDamage = BaseDamage * DamageMultiplier
            set TotalSpeed = BaseSpeed * SpeedMultiplier
            set TotalCurrencyMultiplier = BaseCurrency * CurrencyMultiplier
            set CritChance = BaseCrit
            set CritDamage = BaseCritDmg
            set MaxEquippedPets = BaseMaxPets

    #──────────────────────────────────────────────────────────────────────────
    # CALCUL DES DÉGÂTS
    #──────────────────────────────────────────────────────────────────────────
    CalculateDamage() : tuple(Damage : float, IsCrit : logic) =
        # Vérifie le coup critique
        RandomValue := GetRandomFloat(0.0, 100.0)
        if (RandomValue <= CritChance):
            (Damage := TotalDamage * CritDamage, IsCrit := true)
        else:
            (Damage := TotalDamage, IsCrit := false)

    #──────────────────────────────────────────────────────────────────────────
    # CALCUL DE LA RÉCOMPENSE
    #──────────────────────────────────────────────────────────────────────────
    CalculateReward(BaseReward : float) : float =
        BaseReward * TotalCurrencyMultiplier

    #──────────────────────────────────────────────────────────────────────────
    # GAIN DE RESSOURCES
    #──────────────────────────────────────────────────────────────────────────
    GainSnow(BaseAmount : float)<transacts> : float =
        FinalAmount := CalculateReward(BaseAmount)
        AddSnow(Player, FinalAmount)
        OnSnowGained.Signal(FinalAmount)
        FinalAmount

    GainXP(Amount : float)<transacts> : void =
        Result := AddXP(Player, Amount)
        if (Result.LeveledUp?):
            OnLevelUp.Signal(Result.NewLevel)
            RecalculateStats()

    #──────────────────────────────────────────────────────────────────────────
    # GESTION DES PETS
    #──────────────────────────────────────────────────────────────────────────
    EquipPetByDefinition(PetDef : pet_definition)<transacts><decides> : void =
        EquipPet(Player, PetDef.ID, MaxEquippedPets)?
        set ActivePetDefinitions += array{PetDef}
        OnPetEquipped.Signal(PetDef)
        RecalculateStats()

    UnequipPetByID(PetID : int)<transacts> : void =
        UnequipPet(Player, PetID)
        # Retire de la liste active
        var NewDefinitions : []pet_definition = array{}
        for (PetDef : ActivePetDefinitions):
            if (PetDef.ID <> PetID):
                set NewDefinitions += array{PetDef}
        set ActivePetDefinitions = NewDefinitions
        RecalculateStats()

    #──────────────────────────────────────────────────────────────────────────
    # REBIRTH
    #──────────────────────────────────────────────────────────────────────────
    TryRebirth(RebirthConfig : rebirth_config)<transacts><decides> : void =
        Data := GetFullData(Player)?
        # Vérifie les conditions
        Data.Snow >= RebirthConfig.RequiredSnow
        Data.Level >= RebirthConfig.RequiredLevel
        Data.RebirthCount = RebirthConfig.RebirthLevel - 1

        # Effectue le rebirth
        PerformRebirth(Player, RebirthConfig.DamageBonus, RebirthConfig.SpeedBonus, RebirthConfig.CurrencyBonus)

        # Reset les pets actifs visuellement
        set ActivePetProps = array{}
        set ActivePetDefinitions = array{}

        # Recalcule les stats
        RecalculateStats()

        # Signal l'événement
        OnRebirthCompleted.Signal(RebirthConfig.RebirthLevel)

    #──────────────────────────────────────────────────────────────────────────
    # ACHAT D'UPGRADE
    #──────────────────────────────────────────────────────────────────────────
    TryBuyUpgrade(UpgradeIndex : int)<transacts><decides> : int =
        Config := DefaultUpgradeConfigs[UpgradeIndex]?
        CurrentLevel := GetUpgradeLevel(Player, UpgradeIndex)

        # Vérifie le niveau max
        if (Config.MaxLevel >= 0):
            CurrentLevel < Config.MaxLevel

        # Calcule et vérifie le coût
        Cost := GetUpgradeCost(Config, CurrentLevel)
        RemoveSnow(Player, Cost)?

        # Applique l'upgrade
        NewLevel := UpgradeLevel(Player, UpgradeIndex)?
        RecalculateStats()
        NewLevel

    #──────────────────────────────────────────────────────────────────────────
    # DÉBLOQUAGE DE ZONE
    #──────────────────────────────────────────────────────────────────────────
    TryUnlockZone(ZoneConfig : zone_config)<transacts><decides> : void =
        Data := GetFullData(Player)?

        # Vérifie les conditions
        Data.Level >= ZoneConfig.RequiredLevel
        Data.RebirthCount >= ZoneConfig.RequiredRebirths
        not IsZoneUnlocked(Player, ZoneConfig.ZoneID)

        # Vérifie et retire le coût
        if (ZoneConfig.UnlockCost > 0.0):
            RemoveSnow(Player, ZoneConfig.UnlockCost)?

        # Débloque la zone
        UnlockZone(Player, ZoneConfig.ZoneID)

    #──────────────────────────────────────────────────────────────────────────
    # GETTERS RAPIDES
    #──────────────────────────────────────────────────────────────────────────
    GetCurrentSnow() : float =
        GetSnow(Player)

    GetCurrentLevel() : int =
        GetLevel(Player)

    GetCurrentRebirths() : int =
        GetRebirthCount(Player)

    GetPosition() : vector3 =
        if (FC := FortCharacter?):
            FC.GetTransform().Translation
        else:
            vector3{}

    #──────────────────────────────────────────────────────────────────────────
    # MISE À JOUR DU FORT CHARACTER
    #──────────────────────────────────────────────────────────────────────────
    UpdateFortCharacter() : void =
        if (FC := Player.GetFortCharacter[]):
            set FortCharacter = option{FC}

#══════════════════════════════════════════════════════════════════════════════
# MAP GLOBALE DES JOUEURS SIMULATOR
#══════════════════════════════════════════════════════════════════════════════
var SimulatorPlayers : [player]simulator_player = map{}

# Crée ou obtient un simulator_player
GetOrCreateSimulatorPlayer(Player : player) : simulator_player =
    if (ExistingPlayer := SimulatorPlayers[Player]):
        ExistingPlayer
    else:
        NewSimPlayer := simulator_player{Player := Player}
        NewSimPlayer.Initialize()
        if (set SimulatorPlayers[Player] = NewSimPlayer) {}
        NewSimPlayer

# Supprime un simulator_player
RemoveSimulatorPlayer(Player : player) : void =
    if (SimPlayer := SimulatorPlayers[Player]):
        # Nettoie les pets visuels si nécessaire
        var NewMap : [player]simulator_player = map{}
        for (Key -> Value : SimulatorPlayers):
            if (Key <> Player):
                if (set NewMap[Key] = Value) {}
        set SimulatorPlayers = NewMap

# Obtient un simulator_player existant
GetSimulatorPlayer(Player : player) : ?simulator_player =
    if (SimPlayer := SimulatorPlayers[Player]):
        option{SimPlayer}
    else:
        false
