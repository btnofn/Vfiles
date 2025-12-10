using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }

# SIMULATOR TYPES - Types de base et configurations

# Rareté des pets
pet_rarity := enum:
    Common
    Rare
    Epic
    Legendary
    Mythic

# Configuration d'une zone
zone_config := class<concrete>:
    ZoneID : int = 0
    ZoneName : string = ""
    UnlockCost : float = 0.0
    RequiredLevel : int = 1
    RequiredRebirths : int = 0
    BreakableHP : float = 10.0
    BreakableReward : float = 1.0

# Configuration du rebirth
rebirth_config := class<concrete>:
    RebirthLevel : int = 1
    RequiredSnow : float = 50000.0
    RequiredLevel : int = 25
    DamageBonus : float = 25.0
    SpeedBonus : float = 10.0
    CurrencyBonus : float = 15.0
    UnlockMessage : string = "Rebirth!"

# Type d'upgrade
upgrade_type := enum:
    Damage
    Speed
    CurrencyGain
    MaxPets
    CritChance
    CritDamage

# Configuration d'un upgrade
upgrade_config := class<concrete>:
    Type : upgrade_type = upgrade_type.Damage
    Name : string = "Upgrade"
    Description : string = ""
    BaseCost : float = 50.0
    CostMultiplier : float = 1.15
    BonusPerLevel : float = 1.0
    MaxLevel : int = -1

# Constantes globales
SimulatorConstants<public> := module:
    BaseXPPerLevel<public> : float = 100.0
    XPMultiplierPerLevel<public> : float = 1.15
    MaxLevel<public> : int = 100
    DefaultMaxEquippedPets<public> : int = 3
    PetFollowDistance<public> : float = 150.0
    PetFollowSpeed<public> : float = 5.0
    PetOrbitSpeed<public> : float = 2.0
    BaseDamage<public> : float = 1.0
    BaseAttackSpeed<public> : float = 1.0
    CritMultiplierBase<public> : float = 2.0
    BreakableRespawnTime<public> : float = 5.0
    BaseSnowGain<public> : float = 1.0

# Calcule l'XP requise pour un niveau donné
GetXPForLevel<public>(Level : int) : float =
    var Result : float = SimulatorConstants.BaseXPPerLevel
    var I : int = 1
    loop:
        if (I >= Level):
            break
        set Result = Result * SimulatorConstants.XPMultiplierPerLevel
        set I = I + 1
    Result

# Calcule le coût d'un upgrade
GetUpgradeCost<public>(Config : upgrade_config, CurrentLevel : int) : float =
    var Result : float = Config.BaseCost
    var I : int = 0
    loop:
        if (I >= CurrentLevel):
            break
        set Result = Result * Config.CostMultiplier
        set I = I + 1
    Result

# Formate un nombre avec suffixes
FormatNumber<public>(Value : float) : string =
    if (Value >= 1000000000.0):
        "{Floor[Value / 1000000000.0]}B"
    else if (Value >= 1000000.0):
        "{Floor[Value / 1000000.0]}M"
    else if (Value >= 1000.0):
        "{Floor[Value / 1000.0]}K"
    else:
        "{Floor[Value]}"

# Obtient le nom de la rareté
GetRarityName<public>(Rarity : pet_rarity) : string =
    case(Rarity):
        pet_rarity.Common => "Common"
        pet_rarity.Rare => "Rare"
        pet_rarity.Epic => "Epic"
        pet_rarity.Legendary => "Legendary"
        pet_rarity.Mythic => "Mythic"
