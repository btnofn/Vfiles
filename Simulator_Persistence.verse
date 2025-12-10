using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }

# SIMULATOR PERSISTENCE - Système de sauvegarde

# Table de données persistante
simulator_save_data<public> := class<final><persistable>:
    Level<public> : int = 1
    CurrentXP<public> : float = 0.0
    Snow<public> : float = 0.0
    TotalSnowEarned<public> : float = 0.0
    RebirthCount<public> : int = 0
    TotalRebirthDamageBonus<public> : float = 0.0
    TotalRebirthSpeedBonus<public> : float = 0.0
    TotalRebirthCurrencyBonus<public> : float = 0.0
    UnlockedZones<public> : []int = array{0}
    CurrentZoneID<public> : int = 0
    OwnedPets<public> : []int = array{}
    EquippedPets<public> : []int = array{}
    UpgradeLevels<public> : []int = array{0, 0, 0, 0, 0, 0}
    TotalBreakablesDestroyed<public> : int = 0
    TotalDamageDealt<public> : float = 0.0
    TotalEggsOpened<public> : int = 0
    PlaytimeSeconds<public> : float = 0.0

# Map globale pour persistence
var SimulatorPlayerData<public> : weak_map(player, simulator_save_data) = map{}

# Charge ou crée les données d'un joueur
LoadOrCreatePlayerData<public>(Player : player)<transacts> : simulator_save_data =
    if (ExistingData := SimulatorPlayerData[Player]):
        ExistingData
    else:
        NewData := simulator_save_data{}
        if (set SimulatorPlayerData[Player] = NewData) {}
        NewData

# Ajoute de la neige
AddSnow<public>(Player : player, Amount : float)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        NewData := simulator_save_data:
            Level := CurrentData.Level
            CurrentXP := CurrentData.CurrentXP
            Snow := CurrentData.Snow + Amount
            TotalSnowEarned := CurrentData.TotalSnowEarned + Amount
            RebirthCount := CurrentData.RebirthCount
            TotalRebirthDamageBonus := CurrentData.TotalRebirthDamageBonus
            TotalRebirthSpeedBonus := CurrentData.TotalRebirthSpeedBonus
            TotalRebirthCurrencyBonus := CurrentData.TotalRebirthCurrencyBonus
            UnlockedZones := CurrentData.UnlockedZones
            CurrentZoneID := CurrentData.CurrentZoneID
            OwnedPets := CurrentData.OwnedPets
            EquippedPets := CurrentData.EquippedPets
            UpgradeLevels := CurrentData.UpgradeLevels
            TotalBreakablesDestroyed := CurrentData.TotalBreakablesDestroyed
            TotalDamageDealt := CurrentData.TotalDamageDealt
            TotalEggsOpened := CurrentData.TotalEggsOpened
            PlaytimeSeconds := CurrentData.PlaytimeSeconds
        if (set SimulatorPlayerData[Player] = NewData) {}

# Retire de la neige
RemoveSnow<public>(Player : player, Amount : float)<transacts><decides> : void =
    CurrentData := SimulatorPlayerData[Player]
    CurrentData.Snow >= Amount
    NewData := simulator_save_data:
        Level := CurrentData.Level
        CurrentXP := CurrentData.CurrentXP
        Snow := CurrentData.Snow - Amount
        TotalSnowEarned := CurrentData.TotalSnowEarned
        RebirthCount := CurrentData.RebirthCount
        TotalRebirthDamageBonus := CurrentData.TotalRebirthDamageBonus
        TotalRebirthSpeedBonus := CurrentData.TotalRebirthSpeedBonus
        TotalRebirthCurrencyBonus := CurrentData.TotalRebirthCurrencyBonus
        UnlockedZones := CurrentData.UnlockedZones
        CurrentZoneID := CurrentData.CurrentZoneID
        OwnedPets := CurrentData.OwnedPets
        EquippedPets := CurrentData.EquippedPets
        UpgradeLevels := CurrentData.UpgradeLevels
        TotalBreakablesDestroyed := CurrentData.TotalBreakablesDestroyed
        TotalDamageDealt := CurrentData.TotalDamageDealt
        TotalEggsOpened := CurrentData.TotalEggsOpened
        PlaytimeSeconds := CurrentData.PlaytimeSeconds
    if (set SimulatorPlayerData[Player] = NewData) {}

# Ajoute un pet
AddPet<public>(Player : player, PetID : int)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        NewData := simulator_save_data:
            Level := CurrentData.Level
            CurrentXP := CurrentData.CurrentXP
            Snow := CurrentData.Snow
            TotalSnowEarned := CurrentData.TotalSnowEarned
            RebirthCount := CurrentData.RebirthCount
            TotalRebirthDamageBonus := CurrentData.TotalRebirthDamageBonus
            TotalRebirthSpeedBonus := CurrentData.TotalRebirthSpeedBonus
            TotalRebirthCurrencyBonus := CurrentData.TotalRebirthCurrencyBonus
            UnlockedZones := CurrentData.UnlockedZones
            CurrentZoneID := CurrentData.CurrentZoneID
            OwnedPets := CurrentData.OwnedPets + array{PetID}
            EquippedPets := CurrentData.EquippedPets
            UpgradeLevels := CurrentData.UpgradeLevels
            TotalBreakablesDestroyed := CurrentData.TotalBreakablesDestroyed
            TotalDamageDealt := CurrentData.TotalDamageDealt
            TotalEggsOpened := CurrentData.TotalEggsOpened + 1
            PlaytimeSeconds := CurrentData.PlaytimeSeconds
        if (set SimulatorPlayerData[Player] = NewData) {}

# Ajoute de l'XP
AddXP<public>(Player : player, Amount : float)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        var NewXP : float = CurrentData.CurrentXP + Amount
        var NewLevel : int = CurrentData.Level
        XPRequired := GetXPForLevel(NewLevel)
        if (NewXP >= XPRequired):
            set NewXP = NewXP - XPRequired
            set NewLevel = NewLevel + 1
        NewData := simulator_save_data:
            Level := NewLevel
            CurrentXP := NewXP
            Snow := CurrentData.Snow
            TotalSnowEarned := CurrentData.TotalSnowEarned
            RebirthCount := CurrentData.RebirthCount
            TotalRebirthDamageBonus := CurrentData.TotalRebirthDamageBonus
            TotalRebirthSpeedBonus := CurrentData.TotalRebirthSpeedBonus
            TotalRebirthCurrencyBonus := CurrentData.TotalRebirthCurrencyBonus
            UnlockedZones := CurrentData.UnlockedZones
            CurrentZoneID := CurrentData.CurrentZoneID
            OwnedPets := CurrentData.OwnedPets
            EquippedPets := CurrentData.EquippedPets
            UpgradeLevels := CurrentData.UpgradeLevels
            TotalBreakablesDestroyed := CurrentData.TotalBreakablesDestroyed
            TotalDamageDealt := CurrentData.TotalDamageDealt
            TotalEggsOpened := CurrentData.TotalEggsOpened
            PlaytimeSeconds := CurrentData.PlaytimeSeconds
        if (set SimulatorPlayerData[Player] = NewData) {}

# Effectue un rebirth
PerformRebirth<public>(Player : player, DmgBonus : float, SpdBonus : float, CurrBonus : float)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        NewData := simulator_save_data:
            Level := 1
            CurrentXP := 0.0
            Snow := 0.0
            TotalSnowEarned := CurrentData.TotalSnowEarned
            RebirthCount := CurrentData.RebirthCount + 1
            TotalRebirthDamageBonus := CurrentData.TotalRebirthDamageBonus + DmgBonus
            TotalRebirthSpeedBonus := CurrentData.TotalRebirthSpeedBonus + SpdBonus
            TotalRebirthCurrencyBonus := CurrentData.TotalRebirthCurrencyBonus + CurrBonus
            UnlockedZones := array{0}
            CurrentZoneID := 0
            OwnedPets := CurrentData.OwnedPets
            EquippedPets := CurrentData.EquippedPets
            UpgradeLevels := array{0, 0, 0, 0, 0, 0}
            TotalBreakablesDestroyed := CurrentData.TotalBreakablesDestroyed
            TotalDamageDealt := CurrentData.TotalDamageDealt
            TotalEggsOpened := CurrentData.TotalEggsOpened
            PlaytimeSeconds := CurrentData.PlaytimeSeconds
        if (set SimulatorPlayerData[Player] = NewData) {}

# Obtient la neige
GetSnow<public>(Player : player) : float =
    if (Data := SimulatorPlayerData[Player]):
        Data.Snow
    else:
        0.0

# Obtient le niveau
GetLevel<public>(Player : player) : int =
    if (Data := SimulatorPlayerData[Player]):
        Data.Level
    else:
        1

# Obtient le nombre de rebirths
GetRebirthCount<public>(Player : player) : int =
    if (Data := SimulatorPlayerData[Player]):
        Data.RebirthCount
    else:
        0

# Obtient les bonus de rebirth
GetRebirthBonuses<public>(Player : player) : tuple(Damage : float, Speed : float, Currency : float) =
    if (Data := SimulatorPlayerData[Player]):
        (Damage := Data.TotalRebirthDamageBonus, Speed := Data.TotalRebirthSpeedBonus, Currency := Data.TotalRebirthCurrencyBonus)
    else:
        (Damage := 0.0, Speed := 0.0, Currency := 0.0)

# Obtient les pets équipés
GetEquippedPets<public>(Player : player) : []int =
    if (Data := SimulatorPlayerData[Player]):
        Data.EquippedPets
    else:
        array{}

# Obtient les pets possédés
GetOwnedPets<public>(Player : player) : []int =
    if (Data := SimulatorPlayerData[Player]):
        Data.OwnedPets
    else:
        array{}

# Vérifie si une zone est débloquée
IsZoneUnlocked<public>(Player : player, ZoneID : int) : logic =
    if (Data := SimulatorPlayerData[Player]):
        for (UnlockedID : Data.UnlockedZones):
            if (UnlockedID = ZoneID):
                return true
    false

# Débloque une zone
UnlockZone<public>(Player : player, ZoneID : int)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        NewData := simulator_save_data:
            Level := CurrentData.Level
            CurrentXP := CurrentData.CurrentXP
            Snow := CurrentData.Snow
            TotalSnowEarned := CurrentData.TotalSnowEarned
            RebirthCount := CurrentData.RebirthCount
            TotalRebirthDamageBonus := CurrentData.TotalRebirthDamageBonus
            TotalRebirthSpeedBonus := CurrentData.TotalRebirthSpeedBonus
            TotalRebirthCurrencyBonus := CurrentData.TotalRebirthCurrencyBonus
            UnlockedZones := CurrentData.UnlockedZones + array{ZoneID}
            CurrentZoneID := CurrentData.CurrentZoneID
            OwnedPets := CurrentData.OwnedPets
            EquippedPets := CurrentData.EquippedPets
            UpgradeLevels := CurrentData.UpgradeLevels
            TotalBreakablesDestroyed := CurrentData.TotalBreakablesDestroyed
            TotalDamageDealt := CurrentData.TotalDamageDealt
            TotalEggsOpened := CurrentData.TotalEggsOpened
            PlaytimeSeconds := CurrentData.PlaytimeSeconds
        if (set SimulatorPlayerData[Player] = NewData) {}

# Obtient les données complètes
GetFullData<public>(Player : player) : ?simulator_save_data =
    if (Data := SimulatorPlayerData[Player]):
        option{Data}
    else:
        false
