using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }

#══════════════════════════════════════════════════════════════════════════════
# SIMULATOR TYPES - Types de base, configurations et constantes
#══════════════════════════════════════════════════════════════════════════════

#──────────────────────────────────────────────────────────────────────────────
# RARETÉ DES PETS
#──────────────────────────────────────────────────────────────────────────────
pet_rarity := enum:
    Common      # 60% - Bonus faibles
    Rare        # 25% - Bonus moyens
    Epic        # 10% - Bonus élevés
    Legendary   # 4%  - Bonus très élevés
    Mythic      # 1%  - Bonus exceptionnels

#──────────────────────────────────────────────────────────────────────────────
# CONFIGURATION DES RARITÉS (Chances + Multiplicateurs)
#──────────────────────────────────────────────────────────────────────────────
rarity_config := struct:
    Rarity : pet_rarity
    DropChance : float          # Probabilité de drop (0.0 à 1.0)
    DamageMultiplier : float    # Multiplicateur de dégâts
    SpeedBonus : float          # Bonus de vitesse (%)
    CurrencyBonus : float       # Bonus de monnaie (%)
    EggCost : float             # Coût de l'oeuf pour cette rareté
    Color : color               # Couleur associée à la rareté

# Configuration par défaut des rarités
DefaultRarityConfigs : []rarity_config = array:
    rarity_config:
        Rarity := pet_rarity.Common
        DropChance := 0.60
        DamageMultiplier := 1.0
        SpeedBonus := 0.0
        CurrencyBonus := 0.0
        EggCost := 100.0
        Color := color{R := 0.7, G := 0.7, B := 0.7}  # Gris
    rarity_config:
        Rarity := pet_rarity.Rare
        DropChance := 0.25
        DamageMultiplier := 1.5
        SpeedBonus := 5.0
        CurrencyBonus := 10.0
        EggCost := 500.0
        Color := color{R := 0.2, G := 0.6, B := 1.0}  # Bleu
    rarity_config:
        Rarity := pet_rarity.Epic
        DropChance := 0.10
        DamageMultiplier := 2.5
        SpeedBonus := 10.0
        CurrencyBonus := 25.0
        EggCost := 2500.0
        Color := color{R := 0.8, G := 0.2, B := 1.0}  # Violet
    rarity_config:
        Rarity := pet_rarity.Legendary
        DropChance := 0.04
        DamageMultiplier := 5.0
        SpeedBonus := 20.0
        CurrencyBonus := 50.0
        EggCost := 10000.0
        Color := color{R := 1.0, G := 0.8, B := 0.0}  # Or
    rarity_config:
        Rarity := pet_rarity.Mythic
        DropChance := 0.01
        DamageMultiplier := 10.0
        SpeedBonus := 35.0
        CurrencyBonus := 100.0
        EggCost := 50000.0
        Color := color{R := 1.0, G := 0.2, B := 0.4}  # Rouge/Rose

#──────────────────────────────────────────────────────────────────────────────
# DÉFINITION D'UN PET
#──────────────────────────────────────────────────────────────────────────────
pet_definition := struct:
    ID : int
    Name : string
    Rarity : pet_rarity
    BaseDamage : float
    BaseSpeed : float
    BaseCurrencyBonus : float
    PropAsset : creative_prop_asset     # Asset visuel du pet

#──────────────────────────────────────────────────────────────────────────────
# CONFIGURATION D'UNE ZONE
#──────────────────────────────────────────────────────────────────────────────
zone_config := struct:
    ZoneID : int
    ZoneName : string
    UnlockCost : float                  # Coût en neige pour débloquer
    RequiredLevel : int                 # Niveau requis
    RequiredRebirths : int              # Rebirths requis (0 = aucun)
    BreakableHP : float                 # HP des breakables dans cette zone
    BreakableReward : float             # Récompense de base par breakable
    EggTypes : []int                    # IDs des oeufs disponibles dans cette zone

# Configuration des 6 zones progressives (thème neige/hiver)
DefaultZoneConfigs : []zone_config = array:
    zone_config:  # Zone 1 - Départ
        ZoneID := 0
        ZoneName := "Village Enneigé"
        UnlockCost := 0.0
        RequiredLevel := 1
        RequiredRebirths := 0
        BreakableHP := 10.0
        BreakableReward := 1.0
        EggTypes := array{0, 1}
    zone_config:  # Zone 2
        ZoneID := 1
        ZoneName := "Forêt Glaciale"
        UnlockCost := 1000.0
        RequiredLevel := 5
        RequiredRebirths := 0
        BreakableHP := 50.0
        BreakableReward := 5.0
        EggTypes := array{0, 1, 2}
    zone_config:  # Zone 3
        ZoneID := 2
        ZoneName := "Caverne de Cristal"
        UnlockCost := 10000.0
        RequiredLevel := 15
        RequiredRebirths := 0
        BreakableHP := 250.0
        BreakableReward := 25.0
        EggTypes := array{1, 2, 3}
    zone_config:  # Zone 4
        ZoneID := 3
        ZoneName := "Sommet Arctique"
        UnlockCost := 100000.0
        RequiredLevel := 30
        RequiredRebirths := 1
        BreakableHP := 1000.0
        BreakableReward := 100.0
        EggTypes := array{2, 3, 4}
    zone_config:  # Zone 5
        ZoneID := 4
        ZoneName := "Temple du Blizzard"
        UnlockCost := 1000000.0
        RequiredLevel := 50
        RequiredRebirths := 2
        BreakableHP := 5000.0
        BreakableReward := 500.0
        EggTypes := array{3, 4}
    zone_config:  # Zone 6 - Finale
        ZoneID := 5
        ZoneName := "Royaume Éternel"
        UnlockCost := 10000000.0
        RequiredLevel := 100
        RequiredRebirths := 5
        BreakableHP := 25000.0
        BreakableReward := 2500.0
        EggTypes := array{4}

#──────────────────────────────────────────────────────────────────────────────
# CONFIGURATION DU REBIRTH
#──────────────────────────────────────────────────────────────────────────────
rebirth_config := struct:
    RebirthLevel : int              # Numéro du rebirth (1, 2, 3...)
    RequiredSnow : float            # Neige requise pour rebirth
    RequiredLevel : int             # Niveau requis
    DamageBonus : float             # Bonus permanent de dégâts (%)
    SpeedBonus : float              # Bonus permanent de vitesse (%)
    CurrencyBonus : float           # Bonus permanent de monnaie (%)
    UnlockMessage : string          # Message affiché lors du rebirth

# Configuration des rebirths progressifs
DefaultRebirthConfigs : []rebirth_config = array:
    rebirth_config:
        RebirthLevel := 1
        RequiredSnow := 50000.0
        RequiredLevel := 25
        DamageBonus := 25.0
        SpeedBonus := 10.0
        CurrencyBonus := 15.0
        UnlockMessage := "Premier Éveil - Le froid te renforce!"
    rebirth_config:
        RebirthLevel := 2
        RequiredSnow := 500000.0
        RequiredLevel := 25
        DamageBonus := 50.0
        SpeedBonus := 20.0
        CurrencyBonus := 35.0
        UnlockMessage := "Maître du Givre - Ta puissance grandit!"
    rebirth_config:
        RebirthLevel := 3
        RequiredSnow := 5000000.0
        RequiredLevel := 25
        DamageBonus := 100.0
        SpeedBonus := 35.0
        CurrencyBonus := 60.0
        UnlockMessage := "Seigneur des Neiges - Tu domines l'hiver!"
    rebirth_config:
        RebirthLevel := 4
        RequiredSnow := 50000000.0
        RequiredLevel := 25
        DamageBonus := 175.0
        SpeedBonus := 50.0
        CurrencyBonus := 100.0
        UnlockMessage := "Titan Glacial - Les éléments t'obéissent!"
    rebirth_config:
        RebirthLevel := 5
        RequiredSnow := 500000000.0
        RequiredLevel := 25
        DamageBonus := 300.0
        SpeedBonus := 75.0
        CurrencyBonus := 175.0
        UnlockMessage := "Divinité de l'Hiver - Tu es LÉGENDAIRE!"

#──────────────────────────────────────────────────────────────────────────────
# CONFIGURATION DES UPGRADES (Shop)
#──────────────────────────────────────────────────────────────────────────────
upgrade_type := enum:
    Damage          # Augmente les dégâts de base
    Speed           # Augmente la vitesse
    CurrencyGain    # Augmente le gain de monnaie
    MaxPets         # Augmente le nombre max de pets équipés
    CritChance      # Chance de coup critique
    CritDamage      # Dégâts critiques

upgrade_config := struct:
    Type : upgrade_type
    Name : string
    Description : string
    BaseCost : float
    CostMultiplier : float      # Coût = BaseCost * (CostMultiplier ^ Level)
    BonusPerLevel : float       # Bonus gagné par niveau
    MaxLevel : int              # Niveau maximum (-1 = illimité)

DefaultUpgradeConfigs : []upgrade_config = array:
    upgrade_config:
        Type := upgrade_type.Damage
        Name := "Force du Blizzard"
        Description := "+1 Dégâts de base"
        BaseCost := 50.0
        CostMultiplier := 1.15
        BonusPerLevel := 1.0
        MaxLevel := -1
    upgrade_config:
        Type := upgrade_type.Speed
        Name := "Agilité Glaciale"
        Description := "+2% Vitesse"
        BaseCost := 100.0
        CostMultiplier := 1.20
        BonusPerLevel := 2.0
        MaxLevel := 50
    upgrade_config:
        Type := upgrade_type.CurrencyGain
        Name := "Bénédiction des Neiges"
        Description := "+5% Gain de Neige"
        BaseCost := 200.0
        CostMultiplier := 1.25
        BonusPerLevel := 5.0
        MaxLevel := -1
    upgrade_config:
        Type := upgrade_type.MaxPets
        Name := "Meute Étendue"
        Description := "+1 Pet équipable"
        BaseCost := 5000.0
        CostMultiplier := 3.0
        BonusPerLevel := 1.0
        MaxLevel := 10
    upgrade_config:
        Type := upgrade_type.CritChance
        Name := "Instinct du Chasseur"
        Description := "+2% Chance Critique"
        BaseCost := 1000.0
        CostMultiplier := 1.30
        BonusPerLevel := 2.0
        MaxLevel := 25
    upgrade_config:
        Type := upgrade_type.CritDamage
        Name := "Frappe Dévastatrice"
        Description := "+10% Dégâts Critiques"
        BaseCost := 2000.0
        CostMultiplier := 1.25
        BonusPerLevel := 10.0
        MaxLevel := 50

#──────────────────────────────────────────────────────────────────────────────
# CONSTANTES GLOBALES
#──────────────────────────────────────────────────────────────────────────────
SimulatorConstants := module:
    # XP et Niveaux
    BaseXPPerLevel<public> : float = 100.0
    XPMultiplierPerLevel<public> : float = 1.15
    MaxLevel<public> : int = 100

    # Pets
    DefaultMaxEquippedPets<public> : int = 3
    PetFollowDistance<public> : float = 150.0
    PetFollowSpeed<public> : float = 5.0
    PetOrbitSpeed<public> : float = 2.0

    # Combat
    BaseDamage<public> : float = 1.0
    BaseAttackSpeed<public> : float = 1.0
    CritMultiplierBase<public> : float = 2.0

    # Breakables
    BreakableRespawnTime<public> : float = 5.0

    # Économie
    BaseSnowGain<public> : float = 1.0

#──────────────────────────────────────────────────────────────────────────────
# HELPER FUNCTIONS
#──────────────────────────────────────────────────────────────────────────────

# Calcule l'XP requise pour un niveau donné
GetXPForLevel(Level : int) : float =
    SimulatorConstants.BaseXPPerLevel * Pow(SimulatorConstants.XPMultiplierPerLevel, Level - 1)

# Calcule le coût d'un upgrade à un niveau donné
GetUpgradeCost(Config : upgrade_config, CurrentLevel : int) : float =
    Config.BaseCost * Pow(Config.CostMultiplier, CurrentLevel)

# Obtient la config de rareté par enum
GetRarityConfig(Rarity : pet_rarity) : ?rarity_config =
    for (Config : DefaultRarityConfigs):
        if (Config.Rarity = Rarity):
            return option{Config}
    false

# Obtient la config de zone par ID
GetZoneConfig(ZoneID : int) : ?zone_config =
    if (ZoneID >= 0 and ZoneID < DefaultZoneConfigs.Length):
        if (Config := DefaultZoneConfigs[ZoneID]):
            return option{Config}
    false

# Obtient la config de rebirth par niveau
GetRebirthConfig(RebirthLevel : int) : ?rebirth_config =
    for (Config : DefaultRebirthConfigs):
        if (Config.RebirthLevel = RebirthLevel):
            return option{Config}
    false

# Formate un nombre avec suffixes (K, M, B...)
FormatNumber(Value : float) : string =
    if (Value >= 1000000000.0):
        "{Value / 1000000000.0}B"
    else if (Value >= 1000000.0):
        "{Value / 1000000.0}M"
    else if (Value >= 1000.0):
        "{Value / 1000.0}K"
    else:
        "{Value}"

# Obtient le nom de la rareté en string
GetRarityName(Rarity : pet_rarity) : string =
    case (Rarity):
        pet_rarity.Common => "Common"
        pet_rarity.Rare => "Rare"
        pet_rarity.Epic => "Épique"
        pet_rarity.Legendary => "Légendaire"
        pet_rarity.Mythic => "Mythique"
