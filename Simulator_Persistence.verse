using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }

#══════════════════════════════════════════════════════════════════════════════
# SIMULATOR PERSISTENCE - Système de sauvegarde des données joueur
#══════════════════════════════════════════════════════════════════════════════

#──────────────────────────────────────────────────────────────────────────────
# TABLE DE DONNÉES PERSISTANTE
#──────────────────────────────────────────────────────────────────────────────
simulator_save_data := class<final><persistable>:
    # Progression
    Level : int = 1
    CurrentXP : float = 0.0

    # Monnaie
    Snow : float = 0.0
    TotalSnowEarned : float = 0.0

    # Rebirth
    RebirthCount : int = 0
    TotalRebirthDamageBonus : float = 0.0
    TotalRebirthSpeedBonus : float = 0.0
    TotalRebirthCurrencyBonus : float = 0.0

    # Zones débloquées (stocke les IDs)
    UnlockedZones : []int = array{0}
    CurrentZoneID : int = 0

    # Pets possédés (IDs des pets)
    OwnedPets : []int = array{}
    EquippedPets : []int = array{}

    # Upgrades (index = type d'upgrade, valeur = niveau)
    UpgradeLevels : []int = array{0, 0, 0, 0, 0, 0}

    # Statistiques
    TotalBreakablesDestroyed : int = 0
    TotalDamageDealt : float = 0.0
    TotalEggsOpened : int = 0
    PlaytimeSeconds : float = 0.0

#──────────────────────────────────────────────────────────────────────────────
# CONSTRUCTEUR POUR MISE À JOUR
#──────────────────────────────────────────────────────────────────────────────
MakeSimulatorSaveData<constructor>(OldData : simulator_save_data)<transacts> := simulator_save_data:
    Level := OldData.Level
    CurrentXP := OldData.CurrentXP
    Snow := OldData.Snow
    TotalSnowEarned := OldData.TotalSnowEarned
    RebirthCount := OldData.RebirthCount
    TotalRebirthDamageBonus := OldData.TotalRebirthDamageBonus
    TotalRebirthSpeedBonus := OldData.TotalRebirthSpeedBonus
    TotalRebirthCurrencyBonus := OldData.TotalRebirthCurrencyBonus
    UnlockedZones := OldData.UnlockedZones
    CurrentZoneID := OldData.CurrentZoneID
    OwnedPets := OldData.OwnedPets
    EquippedPets := OldData.EquippedPets
    UpgradeLevels := OldData.UpgradeLevels
    TotalBreakablesDestroyed := OldData.TotalBreakablesDestroyed
    TotalDamageDealt := OldData.TotalDamageDealt
    TotalEggsOpened := OldData.TotalEggsOpened
    PlaytimeSeconds := OldData.PlaytimeSeconds

#──────────────────────────────────────────────────────────────────────────────
# MAP GLOBALE POUR PERSISTENCE
#──────────────────────────────────────────────────────────────────────────────
var SimulatorPlayerData : weak_map(player, simulator_save_data) = map{}

#──────────────────────────────────────────────────────────────────────────────
# FONCTIONS DE GESTION DES DONNÉES
#──────────────────────────────────────────────────────────────────────────────

# Charge ou crée les données d'un joueur
LoadOrCreatePlayerData(Player : player)<transacts> : simulator_save_data =
    if (ExistingData := SimulatorPlayerData[Player]):
        ExistingData
    else:
        NewData := simulator_save_data{}
        if (set SimulatorPlayerData[Player] = NewData) {}
        NewData

# Sauvegarde les données modifiées
SavePlayerData(Player : player, NewData : simulator_save_data)<transacts> : void =
    if (set SimulatorPlayerData[Player] = NewData) {}

#══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE MODIFICATION SPÉCIFIQUES
#══════════════════════════════════════════════════════════════════════════════

# Ajoute de la neige
AddSnow(Player : player, Amount : float)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        NewData := simulator_save_data:
            MakeSimulatorSaveData(CurrentData)
            Snow := CurrentData.Snow + Amount
            TotalSnowEarned := CurrentData.TotalSnowEarned + Amount
        SavePlayerData(Player, NewData)

# Retire de la neige (retourne true si succès)
RemoveSnow(Player : player, Amount : float)<transacts><decides> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        CurrentData.Snow >= Amount
        NewData := simulator_save_data:
            MakeSimulatorSaveData(CurrentData)
            Snow := CurrentData.Snow - Amount
        SavePlayerData(Player, NewData)

# Ajoute de l'XP et gère le level up
AddXP(Player : player, Amount : float)<transacts> : tuple(NewLevel : int, LeveledUp : logic) =
    if (CurrentData := SimulatorPlayerData[Player]):
        var NewXP : float = CurrentData.CurrentXP + Amount
        var NewLevel : int = CurrentData.Level
        var LeveledUp : logic = false

        # Vérifie les level ups successifs
        loop:
            XPRequired := GetXPForLevel(NewLevel)
            if (NewXP >= XPRequired):
                set NewXP -= XPRequired
                set NewLevel += 1
                set LeveledUp = true
            else:
                break

        NewData := simulator_save_data:
            MakeSimulatorSaveData(CurrentData)
            Level := NewLevel
            CurrentXP := NewXP
        SavePlayerData(Player, NewData)

        (NewLevel := NewLevel, LeveledUp := LeveledUp)
    else:
        (NewLevel := 1, LeveledUp := false)

# Ajoute un pet à la collection
AddPet(Player : player, PetID : int)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        NewOwnedPets := CurrentData.OwnedPets + array{PetID}
        NewData := simulator_save_data:
            MakeSimulatorSaveData(CurrentData)
            OwnedPets := NewOwnedPets
            TotalEggsOpened := CurrentData.TotalEggsOpened + 1
        SavePlayerData(Player, NewData)

# Équipe un pet
EquipPet(Player : player, PetID : int, MaxPets : int)<transacts><decides> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        # Vérifie que le pet est possédé
        var PetOwned : logic = false
        for (OwnedID : CurrentData.OwnedPets):
            if (OwnedID = PetID):
                set PetOwned = true
                break
        PetOwned?

        # Vérifie qu'il n'est pas déjà équipé
        for (EquippedID : CurrentData.EquippedPets):
            if (EquippedID = PetID):
                return  # Déjà équipé

        # Vérifie le nombre max
        CurrentData.EquippedPets.Length < MaxPets

        NewEquippedPets := CurrentData.EquippedPets + array{PetID}
        NewData := simulator_save_data:
            MakeSimulatorSaveData(CurrentData)
            EquippedPets := NewEquippedPets
        SavePlayerData(Player, NewData)

# Déséquipe un pet
UnequipPet(Player : player, PetID : int)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        var NewEquippedPets : []int = array{}
        for (EquippedID : CurrentData.EquippedPets):
            if (EquippedID <> PetID):
                set NewEquippedPets += array{EquippedID}

        NewData := simulator_save_data:
            MakeSimulatorSaveData(CurrentData)
            EquippedPets := NewEquippedPets
        SavePlayerData(Player, NewData)

# Débloque une zone
UnlockZone(Player : player, ZoneID : int)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        # Vérifie que la zone n'est pas déjà débloquée
        for (UnlockedID : CurrentData.UnlockedZones):
            if (UnlockedID = ZoneID):
                return  # Déjà débloquée

        NewUnlockedZones := CurrentData.UnlockedZones + array{ZoneID}
        NewData := simulator_save_data:
            MakeSimulatorSaveData(CurrentData)
            UnlockedZones := NewUnlockedZones
        SavePlayerData(Player, NewData)

# Change la zone actuelle
SetCurrentZone(Player : player, ZoneID : int)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        NewData := simulator_save_data:
            MakeSimulatorSaveData(CurrentData)
            CurrentZoneID := ZoneID
        SavePlayerData(Player, NewData)

# Améliore un upgrade
UpgradeLevel(Player : player, UpgradeIndex : int)<transacts><decides> : int =
    if (CurrentData := SimulatorPlayerData[Player]):
        if (CurrentLevel := CurrentData.UpgradeLevels[UpgradeIndex]):
            var NewUpgradeLevels : []int = array{}
            var Index : int = 0
            for (Level : CurrentData.UpgradeLevels):
                if (Index = UpgradeIndex):
                    set NewUpgradeLevels += array{Level + 1}
                else:
                    set NewUpgradeLevels += array{Level}
                set Index += 1

            NewData := simulator_save_data:
                MakeSimulatorSaveData(CurrentData)
                UpgradeLevels := NewUpgradeLevels
            SavePlayerData(Player, NewData)
            CurrentLevel + 1
        else:
            0
    else:
        0

# Effectue un rebirth
PerformRebirth(Player : player, DamageBonus : float, SpeedBonus : float, CurrencyBonus : float)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        NewData := simulator_save_data:
            MakeSimulatorSaveData(CurrentData)
            # Reset progression
            Level := 1
            CurrentXP := 0.0
            Snow := 0.0
            UnlockedZones := array{0}
            CurrentZoneID := 0
            # Garde les pets et ajoute les bonus permanents
            RebirthCount := CurrentData.RebirthCount + 1
            TotalRebirthDamageBonus := CurrentData.TotalRebirthDamageBonus + DamageBonus
            TotalRebirthSpeedBonus := CurrentData.TotalRebirthSpeedBonus + SpeedBonus
            TotalRebirthCurrencyBonus := CurrentData.TotalRebirthCurrencyBonus + CurrencyBonus
            # Reset les upgrades
            UpgradeLevels := array{0, 0, 0, 0, 0, 0}
        SavePlayerData(Player, NewData)

# Incrémente les stats de combat
IncrementCombatStats(Player : player, DamageDealt : float)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        NewData := simulator_save_data:
            MakeSimulatorSaveData(CurrentData)
            TotalBreakablesDestroyed := CurrentData.TotalBreakablesDestroyed + 1
            TotalDamageDealt := CurrentData.TotalDamageDealt + DamageDealt
        SavePlayerData(Player, NewData)

# Met à jour le temps de jeu
UpdatePlaytime(Player : player, DeltaTime : float)<transacts> : void =
    if (CurrentData := SimulatorPlayerData[Player]):
        NewData := simulator_save_data:
            MakeSimulatorSaveData(CurrentData)
            PlaytimeSeconds := CurrentData.PlaytimeSeconds + DeltaTime
        SavePlayerData(Player, NewData)

#══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE LECTURE
#══════════════════════════════════════════════════════════════════════════════

# Obtient la neige actuelle
GetSnow(Player : player) : float =
    if (Data := SimulatorPlayerData[Player]):
        Data.Snow
    else:
        0.0

# Obtient le niveau actuel
GetLevel(Player : player) : int =
    if (Data := SimulatorPlayerData[Player]):
        Data.Level
    else:
        1

# Obtient le nombre de rebirths
GetRebirthCount(Player : player) : int =
    if (Data := SimulatorPlayerData[Player]):
        Data.RebirthCount
    else:
        0

# Vérifie si une zone est débloquée
IsZoneUnlocked(Player : player, ZoneID : int) : logic =
    if (Data := SimulatorPlayerData[Player]):
        for (UnlockedID : Data.UnlockedZones):
            if (UnlockedID = ZoneID):
                return true
    false

# Obtient le niveau d'un upgrade
GetUpgradeLevel(Player : player, UpgradeIndex : int) : int =
    if (Data := SimulatorPlayerData[Player]):
        if (Level := Data.UpgradeLevels[UpgradeIndex]):
            Level
        else:
            0
    else:
        0

# Obtient les bonus de rebirth
GetRebirthBonuses(Player : player) : tuple(Damage : float, Speed : float, Currency : float) =
    if (Data := SimulatorPlayerData[Player]):
        (Damage := Data.TotalRebirthDamageBonus, Speed := Data.TotalRebirthSpeedBonus, Currency := Data.TotalRebirthCurrencyBonus)
    else:
        (Damage := 0.0, Speed := 0.0, Currency := 0.0)

# Obtient les pets équipés
GetEquippedPets(Player : player) : []int =
    if (Data := SimulatorPlayerData[Player]):
        Data.EquippedPets
    else:
        array{}

# Obtient tous les pets possédés
GetOwnedPets(Player : player) : []int =
    if (Data := SimulatorPlayerData[Player]):
        Data.OwnedPets
    else:
        array{}

# Obtient les données complètes (lecture seule)
GetFullData(Player : player) : ?simulator_save_data =
    if (Data := SimulatorPlayerData[Player]):
        option{Data}
    else:
        false
