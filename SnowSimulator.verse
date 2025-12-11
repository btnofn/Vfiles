using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#===============================================================================
# SNOW SIMULATOR - Architecture 1 Device = 1 Instance
#===============================================================================
# Chaque device controle UNE seule instance configurable individuellement

#-------------------------------------------------------------------------------
# ENUMS
#-------------------------------------------------------------------------------

pet_rarity<public> := enum:
    Common
    Rare
    Epic
    Legendary
    Mythic

#-------------------------------------------------------------------------------
# CONSTANTES
#-------------------------------------------------------------------------------

SimulatorConstants<public> := module:
    BaseXPPerLevel<public> : float = 100.0
    XPMultiplierPerLevel<public> : float = 1.15
    MaxLevel<public> : int = 100
    BaseDamage<public> : float = 1.0

#-------------------------------------------------------------------------------
# FONCTIONS UTILITAIRES
#-------------------------------------------------------------------------------

GetXPForLevel<public>(Level : int) : float =
    var Result : float = SimulatorConstants.BaseXPPerLevel
    var I : int = 1
    loop:
        if (I >= Level):
            break
        set Result = Result * SimulatorConstants.XPMultiplierPerLevel
        set I = I + 1
    Result

FormatNumber<public>(Value : float) : string =
    if (Value >= 1000000000.0):
        if (Formatted := Floor[Value / 1000000000.0]):
            return "{Formatted}B"
    if (Value >= 1000000.0):
        if (Formatted := Floor[Value / 1000000.0]):
            return "{Formatted}M"
    if (Value >= 1000.0):
        if (Formatted := Floor[Value / 1000.0]):
            return "{Formatted}K"
    if (Formatted := Floor[Value]):
        return "{Formatted}"
    "0"

GetRarityName<public>(Rarity : pet_rarity) : string =
    case (Rarity):
        pet_rarity.Common => "Common"
        pet_rarity.Rare => "Rare"
        pet_rarity.Epic => "Epic"
        pet_rarity.Legendary => "Legendary"
        pet_rarity.Mythic => "Mythic"

#-------------------------------------------------------------------------------
# PERSISTENCE - Donnees sauvegardees
#-------------------------------------------------------------------------------

simulator_save_data<public> := class<final><persistable>:
    Version<public> : int = 1
    Level<public> : int = 1
    CurrentXP<public> : float = 0.0
    Snow<public> : float = 0.0
    TotalSnowEarned<public> : float = 0.0
    RebirthCount<public> : int = 0
    BonusDamage<public> : float = 0.0
    BonusSpeed<public> : float = 0.0
    BonusCurrency<public> : float = 0.0
    UnlockedZones<public> : []int = array{0}
    OwnedPets<public> : []int = array{}
    EquippedPets<public> : []int = array{}

var SimulatorPlayerData<public> : weak_map(player, simulator_save_data) = map{}

InitPlayerData<public>(InPlayer : player) : void =
    if (not SimulatorPlayerData[InPlayer]):
        if (set SimulatorPlayerData[InPlayer] = simulator_save_data{}) {}

GetSnow<public>(InPlayer : player) : float =
    var Result : float = 0.0
    if (Data := SimulatorPlayerData[InPlayer]):
        set Result = Data.Snow
    Result

GetLevel<public>(InPlayer : player) : int =
    var Result : int = 1
    if (Data := SimulatorPlayerData[InPlayer]):
        set Result = Data.Level
    Result

GetCurrentXP<public>(InPlayer : player) : float =
    var Result : float = 0.0
    if (Data := SimulatorPlayerData[InPlayer]):
        set Result = Data.CurrentXP
    Result

GetRebirthCount<public>(InPlayer : player) : int =
    var Result : int = 0
    if (Data := SimulatorPlayerData[InPlayer]):
        set Result = Data.RebirthCount
    Result

GetBonusDamage<public>(InPlayer : player) : float =
    var Result : float = 0.0
    if (Data := SimulatorPlayerData[InPlayer]):
        set Result = Data.BonusDamage
    Result

GetBonusSpeed<public>(InPlayer : player) : float =
    var Result : float = 0.0
    if (Data := SimulatorPlayerData[InPlayer]):
        set Result = Data.BonusSpeed
    Result

GetBonusCurrency<public>(InPlayer : player) : float =
    var Result : float = 0.0
    if (Data := SimulatorPlayerData[InPlayer]):
        set Result = Data.BonusCurrency
    Result

GetTotalSnowEarned<public>(InPlayer : player) : float =
    var Result : float = 0.0
    if (Data := SimulatorPlayerData[InPlayer]):
        set Result = Data.TotalSnowEarned
    Result

SetSnow<public>(InPlayer : player, NewValue : float) : void =
    if (CurrentData := SimulatorPlayerData[InPlayer]):
        NewData := simulator_save_data:
            Version := CurrentData.Version
            Level := CurrentData.Level
            CurrentXP := CurrentData.CurrentXP
            Snow := NewValue
            TotalSnowEarned := CurrentData.TotalSnowEarned
            RebirthCount := CurrentData.RebirthCount
            BonusDamage := CurrentData.BonusDamage
            BonusSpeed := CurrentData.BonusSpeed
            BonusCurrency := CurrentData.BonusCurrency
            UnlockedZones := CurrentData.UnlockedZones
            OwnedPets := CurrentData.OwnedPets
            EquippedPets := CurrentData.EquippedPets
        if (set SimulatorPlayerData[InPlayer] = NewData) {}

AddSnow<public>(InPlayer : player, Amount : float) : void =
    if (CurrentData := SimulatorPlayerData[InPlayer]):
        NewData := simulator_save_data:
            Version := CurrentData.Version
            Level := CurrentData.Level
            CurrentXP := CurrentData.CurrentXP
            Snow := CurrentData.Snow + Amount
            TotalSnowEarned := CurrentData.TotalSnowEarned + Amount
            RebirthCount := CurrentData.RebirthCount
            BonusDamage := CurrentData.BonusDamage
            BonusSpeed := CurrentData.BonusSpeed
            BonusCurrency := CurrentData.BonusCurrency
            UnlockedZones := CurrentData.UnlockedZones
            OwnedPets := CurrentData.OwnedPets
            EquippedPets := CurrentData.EquippedPets
        if (set SimulatorPlayerData[InPlayer] = NewData) {}

TryRemoveSnow<public>(InPlayer : player, Amount : float)<decides><transacts> : void =
    if (CurrentData := SimulatorPlayerData[InPlayer]):
        CurrentData.Snow >= Amount
        NewData := simulator_save_data:
            Version := CurrentData.Version
            Level := CurrentData.Level
            CurrentXP := CurrentData.CurrentXP
            Snow := CurrentData.Snow - Amount
            TotalSnowEarned := CurrentData.TotalSnowEarned
            RebirthCount := CurrentData.RebirthCount
            BonusDamage := CurrentData.BonusDamage
            BonusSpeed := CurrentData.BonusSpeed
            BonusCurrency := CurrentData.BonusCurrency
            UnlockedZones := CurrentData.UnlockedZones
            OwnedPets := CurrentData.OwnedPets
            EquippedPets := CurrentData.EquippedPets
        set SimulatorPlayerData[InPlayer] = NewData

AddXP<public>(InPlayer : player, Amount : float) : void =
    if (CurrentData := SimulatorPlayerData[InPlayer]):
        var NewXP : float = CurrentData.CurrentXP + Amount
        var NewLevel : int = CurrentData.Level
        XPRequired := GetXPForLevel(NewLevel)
        if (NewXP >= XPRequired):
            set NewXP = NewXP - XPRequired
            set NewLevel = NewLevel + 1
        NewData := simulator_save_data:
            Version := CurrentData.Version
            Level := NewLevel
            CurrentXP := NewXP
            Snow := CurrentData.Snow
            TotalSnowEarned := CurrentData.TotalSnowEarned
            RebirthCount := CurrentData.RebirthCount
            BonusDamage := CurrentData.BonusDamage
            BonusSpeed := CurrentData.BonusSpeed
            BonusCurrency := CurrentData.BonusCurrency
            UnlockedZones := CurrentData.UnlockedZones
            OwnedPets := CurrentData.OwnedPets
            EquippedPets := CurrentData.EquippedPets
        if (set SimulatorPlayerData[InPlayer] = NewData) {}

AddPet<public>(InPlayer : player, PetID : int) : void =
    if (CurrentData := SimulatorPlayerData[InPlayer]):
        NewData := simulator_save_data:
            Version := CurrentData.Version
            Level := CurrentData.Level
            CurrentXP := CurrentData.CurrentXP
            Snow := CurrentData.Snow
            TotalSnowEarned := CurrentData.TotalSnowEarned
            RebirthCount := CurrentData.RebirthCount
            BonusDamage := CurrentData.BonusDamage
            BonusSpeed := CurrentData.BonusSpeed
            BonusCurrency := CurrentData.BonusCurrency
            UnlockedZones := CurrentData.UnlockedZones
            OwnedPets := CurrentData.OwnedPets + array{PetID}
            EquippedPets := CurrentData.EquippedPets
        if (set SimulatorPlayerData[InPlayer] = NewData) {}

DoRebirth<public>(InPlayer : player, AddDmg : float, AddSpd : float, AddCurr : float) : void =
    if (CurrentData := SimulatorPlayerData[InPlayer]):
        NewData := simulator_save_data:
            Version := CurrentData.Version
            Level := 1
            CurrentXP := 0.0
            Snow := 0.0
            TotalSnowEarned := CurrentData.TotalSnowEarned
            RebirthCount := CurrentData.RebirthCount + 1
            BonusDamage := CurrentData.BonusDamage + AddDmg
            BonusSpeed := CurrentData.BonusSpeed + AddSpd
            BonusCurrency := CurrentData.BonusCurrency + AddCurr
            UnlockedZones := array{0}
            OwnedPets := CurrentData.OwnedPets
            EquippedPets := CurrentData.EquippedPets
        if (set SimulatorPlayerData[InPlayer] = NewData) {}

AddUnlockedZone<public>(InPlayer : player, ZoneID : int) : void =
    if (CurrentData := SimulatorPlayerData[InPlayer]):
        NewData := simulator_save_data:
            Version := CurrentData.Version
            Level := CurrentData.Level
            CurrentXP := CurrentData.CurrentXP
            Snow := CurrentData.Snow
            TotalSnowEarned := CurrentData.TotalSnowEarned
            RebirthCount := CurrentData.RebirthCount
            BonusDamage := CurrentData.BonusDamage
            BonusSpeed := CurrentData.BonusSpeed
            BonusCurrency := CurrentData.BonusCurrency
            UnlockedZones := CurrentData.UnlockedZones + array{ZoneID}
            OwnedPets := CurrentData.OwnedPets
            EquippedPets := CurrentData.EquippedPets
        if (set SimulatorPlayerData[InPlayer] = NewData) {}

IsZoneUnlocked<public>(InPlayer : player, ZoneID : int)<decides><transacts> : void =
    Data := SimulatorPlayerData[InPlayer]
    var Found : logic = false
    for (UnlockedID : Data.UnlockedZones):
        if (UnlockedID = ZoneID):
            set Found = true
    Found?

#-------------------------------------------------------------------------------
# FONCTIONS JOUEUR - Calculs runtime
#-------------------------------------------------------------------------------

GetTotalDamage<public>(InPlayer : player) : float =
    DmgBonus := GetBonusDamage(InPlayer)
    SimulatorConstants.BaseDamage * (1.0 + DmgBonus / 100.0)

GetTotalCurrencyMult<public>(InPlayer : player) : float =
    CurrBonus := GetBonusCurrency(InPlayer)
    1.0 * (1.0 + CurrBonus / 100.0)

CalculateDamageForPlayer<public>(InPlayer : player) : float =
    GetTotalDamage(InPlayer)

GainSnowForPlayer<public>(InPlayer : player, BaseAmount : float) : float =
    CurrMult := GetTotalCurrencyMult(InPlayer)
    FinalAmount := BaseAmount * CurrMult
    AddSnow(InPlayer, FinalAmount)
    FinalAmount

GainXPForPlayer<public>(InPlayer : player, Amount : float) : void =
    AddXP(InPlayer, Amount)

InitializeSimulatorPlayer<public>(InPlayer : player) : void =
    InitPlayerData(InPlayer)

RemoveSimulatorPlayer<public>(InPlayer : player) : void =
    return

#===============================================================================
# SNOW BREAKABLE - 1 Device = 1 Prop cassable
#===============================================================================
# Utilise prop_manipulator_device pour detecter les coups
# Optionnel: material_parameter_controller pour affichage PV via materiau

snow_breakable<public> := class(creative_device):

    @editable
    PropManipulator : prop_manipulator_device = prop_manipulator_device{}

    @editable
    DestroyVFX : vfx_spawner_device = vfx_spawner_device{}

    # Affichage PV - Choisir billboard OU material controller
    @editable
    HealthBillboard : ?billboard_device = false

    @editable
    HealthMaterialController : ?material_parameter_controller_device = false

    # Stats configurables par instance
    @editable
    MaxHealth : float = 100.0

    @editable
    SnowReward : float = 10.0

    @editable
    XPReward : float = 5.0

    @editable
    RespawnTime : float = 5.0

    var CurrentHealth : float = 0.0
    var IsDestroyed : logic = false

    HealthMsg<localizes>(HP : int, MaxHP : int) : message = "{HP}/{MaxHP}"

    OnBegin<override>()<suspends> : void =
        set CurrentHealth = MaxHealth
        PropManipulator.DamagedEvent.Subscribe(OnDamaged)
        UpdateHealthDisplay()

    OnDamaged(Agent : agent) : void =
        if (not IsDestroyed?):
            if (InPlayer := player[Agent]):
                DamageAmount := CalculateDamageForPlayer(InPlayer)
                set CurrentHealth = CurrentHealth - DamageAmount
                UpdateHealthDisplay()
                if (CurrentHealth <= 0.0):
                    DestroyBreakable(InPlayer)

    DestroyBreakable(InPlayer : player) : void =
        set IsDestroyed = true
        GainSnowForPlayer(InPlayer, SnowReward)
        GainXPForPlayer(InPlayer, XPReward)
        DestroyVFX.Restart()
        PropManipulator.HideProps()
        spawn{RespawnBreakable()}

    RespawnBreakable()<suspends> : void =
        Sleep(RespawnTime)
        set CurrentHealth = MaxHealth
        set IsDestroyed = false
        PropManipulator.ShowProps()
        UpdateHealthDisplay()

    UpdateHealthDisplay() : void =
        if (HP := Int[CurrentHealth]):
            if (MaxHP := Int[MaxHealth]):
                # Option 1: Billboard
                if (BB := HealthBillboard?):
                    BB.SetText(HealthMsg(HP, MaxHP))
                # Option 2: Material controller (valeur 0.0 a 1.0)
                if (MC := HealthMaterialController?):
                    HealthPercent := CurrentHealth / MaxHealth
                    MC.SetScalarParameterValue(HealthPercent)

#===============================================================================
# SNOW EGG STATION - 1 Device = 1 Station d'oeufs
#===============================================================================

snow_egg_station<public> := class(creative_device):

    @editable
    PurchaseButton : button_device = button_device{}

    @editable
    HatchVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    CostBillboard : ?billboard_device = false

    @editable
    ResultHUD : ?hud_message_device = false

    # Stats configurables
    @editable
    EggCost : float = 100.0

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
    HatchDuration : float = 2.0

    var IsHatching : logic = false

    CostMsg<localizes>(Amount : float) : message = "Cost: {Amount} Snow"
    HatchingMsg<localizes> : message = "Hatching..."
    ResultMsg<localizes>(RarityStr : string) : message = "You got a {RarityStr} pet!"

    OnBegin<override>()<suspends> : void =
        if (BB := CostBillboard?):
            BB.SetText(CostMsg(EggCost))
        PurchaseButton.InteractedWithEvent.Subscribe(OnPurchase)

    OnPurchase(Agent : agent) : void =
        if (not IsHatching?):
            if (InPlayer := player[Agent]):
                if (TryRemoveSnow[InPlayer, EggCost]):
                    spawn{PerformHatch(InPlayer)}

    PerformHatch(InPlayer : player)<suspends> : void =
        set IsHatching = true
        if (BB := CostBillboard?):
            BB.SetText(HatchingMsg)
        HatchVFX.Restart()
        Sleep(HatchDuration)

        Roll := GetRandomFloat(0.0, 1.0)
        var SelectedRarity : pet_rarity = pet_rarity.Common
        var Cumulative : float = MythicChance

        if (Roll <= Cumulative):
            set SelectedRarity = pet_rarity.Mythic
        else:
            set Cumulative = Cumulative + LegendaryChance
            if (Roll <= Cumulative):
                set SelectedRarity = pet_rarity.Legendary
            else:
                set Cumulative = Cumulative + EpicChance
                if (Roll <= Cumulative):
                    set SelectedRarity = pet_rarity.Epic
                else:
                    set Cumulative = Cumulative + RareChance
                    if (Roll <= Cumulative):
                        set SelectedRarity = pet_rarity.Rare

        PetID := GetRandomInt(1, 100)
        AddPet(InPlayer, PetID)

        RarityStr := GetRarityName(SelectedRarity)
        if (HUD := ResultHUD?):
            HUD.SetText(ResultMsg(RarityStr))
            HUD.Show(InPlayer)

        set IsHatching = false
        if (BB := CostBillboard?):
            BB.SetText(CostMsg(EggCost))

#===============================================================================
# SNOW ZONE GATE - 1 Device = 1 Porte de zone
#===============================================================================

snow_zone_gate<public> := class(creative_device):

    @editable
    UnlockButton : button_device = button_device{}

    @editable
    GateProp : creative_prop = creative_prop{}

    @editable
    UnlockVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    InfoBillboard : ?billboard_device = false

    @editable
    TeleportOnUnlock : ?teleporter_device = false

    # Stats configurables
    @editable
    ZoneID : int = 1

    @editable
    UnlockCost : float = 1000.0

    @editable
    RequiredLevel : int = 5

    var IsUnlocked : logic = false
    var OriginalPosition : vector3 = vector3{}

    CostInfoMsg<localizes>(SnowCost : float, LvlReq : int) : message = "Cost: {SnowCost} | Level {LvlReq}"
    UnlockedInfoMsg<localizes> : message = "UNLOCKED"
    LockedInfoMsg<localizes> : message = "Requirements not met!"

    OnBegin<override>()<suspends> : void =
        set OriginalPosition = GateProp.GetTransform().Translation
        if (BB := InfoBillboard?):
            BB.SetText(CostInfoMsg(UnlockCost, RequiredLevel))
        UnlockButton.InteractedWithEvent.Subscribe(OnUnlockAttempt)

        for (InPlayer : GetPlayspace().GetPlayers()):
            CheckPlayerUnlock(InPlayer)
        GetPlayspace().PlayerAddedEvent().Subscribe(CheckPlayerUnlock)

    OnUnlockAttempt(Agent : agent) : void =
        if (not IsUnlocked?):
            if (InPlayer := player[Agent]):
                PlayerLevel := GetLevel(InPlayer)
                if (PlayerLevel >= RequiredLevel):
                    if (TryRemoveSnow[InPlayer, UnlockCost]):
                        AddUnlockedZone(InPlayer, ZoneID)
                        UnlockGate(InPlayer)
                else:
                    if (BB := InfoBillboard?):
                        BB.SetText(LockedInfoMsg)
                    spawn{ResetInfoDisplay()}

    CheckPlayerUnlock(InPlayer : player) : void =
        if (IsZoneUnlocked[InPlayer, ZoneID]):
            OpenGate()

    UnlockGate(InPlayer : player) : void =
        set IsUnlocked = true
        UnlockVFX.Restart()
        OpenGate()
        if (TP := TeleportOnUnlock?):
            TP.Teleport(InPlayer)

    OpenGate() : void =
        HidePos := OriginalPosition - vector3{Z := 10000.0}
        if (GateProp.TeleportTo[HidePos, GateProp.GetTransform().Rotation]) {}
        if (BB := InfoBillboard?):
            BB.SetText(UnlockedInfoMsg)

    ResetInfoDisplay()<suspends> : void =
        Sleep(2.0)
        if (BB := InfoBillboard?):
            BB.SetText(CostInfoMsg(UnlockCost, RequiredLevel))

#===============================================================================
# SNOW REBIRTH SHRINE - 1 Device = 1 Shrine de prestige
#===============================================================================

snow_rebirth_shrine<public> := class(creative_device):

    @editable
    InteractButton : button_device = button_device{}

    @editable
    RebirthVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    CostBillboard : ?billboard_device = false

    @editable
    BonusBillboard : ?billboard_device = false

    @editable
    SuccessHUD : ?hud_message_device = false

    @editable
    TeleportAfter : ?teleporter_device = false

    # Stats configurables
    @editable
    RebirthLevel : int = 1

    @editable
    RequiredSnow : float = 50000.0

    @editable
    RequiredPlayerLevel : int = 25

    @editable
    DamageBonus : float = 25.0

    @editable
    SpeedBonus : float = 10.0

    @editable
    CurrencyBonus : float = 15.0

    RebirthCostMsg<localizes>(SnowCost : float, LvlReq : int) : message = "Cost: {SnowCost} | Level {LvlReq}"
    RebirthBonusMsg<localizes>(DMG : float, SPD : float, CURR : float) : message = "+{DMG}% DMG | +{SPD}% Speed | +{CURR}% Snow"
    RebirthSuccessMsg<localizes>(Lvl : int) : message = "REBIRTH {Lvl} Complete!"
    RebirthFailMsg<localizes> : message = "Requirements not met!"

    OnBegin<override>()<suspends> : void =
        if (CostBB := CostBillboard?):
            CostBB.SetText(RebirthCostMsg(RequiredSnow, RequiredPlayerLevel))
        if (BonusBB := BonusBillboard?):
            BonusBB.SetText(RebirthBonusMsg(DamageBonus, SpeedBonus, CurrencyBonus))
        InteractButton.InteractedWithEvent.Subscribe(OnRebirthAttempt)

    OnRebirthAttempt(Agent : agent) : void =
        if (InPlayer := player[Agent]):
            CurrentRebirths := GetRebirthCount(InPlayer)
            CurrentLevel := GetLevel(InPlayer)
            CurrentSnow := GetSnow(InPlayer)

            ExpectedRebirths := RebirthLevel - 1
            if (CurrentRebirths = ExpectedRebirths):
                if (CurrentLevel >= RequiredPlayerLevel):
                    if (CurrentSnow >= RequiredSnow):
                        DoRebirth(InPlayer, DamageBonus, SpeedBonus, CurrencyBonus)
                        RebirthVFX.Restart()
                        if (HUD := SuccessHUD?):
                            HUD.SetText(RebirthSuccessMsg(RebirthLevel))
                            HUD.Show(InPlayer)
                        if (TP := TeleportAfter?):
                            TP.Teleport(InPlayer)
                    else:
                        ShowFailMessage()
                else:
                    ShowFailMessage()
            else:
                ShowFailMessage()

    ShowFailMessage() : void =
        if (CostBB := CostBillboard?):
            CostBB.SetText(RebirthFailMsg)
        spawn{ResetDisplay()}

    ResetDisplay()<suspends> : void =
        Sleep(2.0)
        if (CostBB := CostBillboard?):
            CostBB.SetText(RebirthCostMsg(RequiredSnow, RequiredPlayerLevel))

#===============================================================================
# SNOW UPGRADE STATION - 1 Device = 1 Station d'upgrade
#===============================================================================

snow_upgrade_station<public> := class(creative_device):

    @editable
    PurchaseButton : button_device = button_device{}

    @editable
    UpgradeVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    NameBillboard : ?billboard_device = false

    @editable
    LevelBillboard : ?billboard_device = false

    @editable
    CostBillboard : ?billboard_device = false

    # Stats configurables
    @editable
    UpgradeName : string = "Damage"

    @editable
    BaseCost : float = 50.0

    @editable
    CostMultiplier : float = 1.15

    @editable
    MaxLevel : int = 100

    var CurrentLevel : int = 0

    UpgradeNameMsg<localizes>(TheName : string) : message = "{TheName}"
    UpgradeLevelMsg<localizes>(Lvl : int) : message = "Level: {Lvl}"
    UpgradeCostMsg<localizes>(TheCost : float) : message = "Cost: {TheCost} Snow"
    UpgradeMaxedMsg<localizes> : message = "MAXED!"
    UpgradeFailMsg<localizes> : message = "Not enough Snow!"

    OnBegin<override>()<suspends> : void =
        if (NameBB := NameBillboard?):
            NameBB.SetText(UpgradeNameMsg(UpgradeName))
        UpdateDisplay()
        PurchaseButton.InteractedWithEvent.Subscribe(OnPurchase)

    OnPurchase(Agent : agent) : void =
        if (CurrentLevel < MaxLevel):
            if (InPlayer := player[Agent]):
                TheCost := CalculateCost()
                if (TryRemoveSnow[InPlayer, TheCost]):
                    set CurrentLevel = CurrentLevel + 1
                    UpgradeVFX.Restart()
                    UpdateDisplay()
                else:
                    if (CostBB := CostBillboard?):
                        CostBB.SetText(UpgradeFailMsg)
                    spawn{ResetCostDisplay()}

    CalculateCost() : float =
        var Result : float = BaseCost
        var I : int = 0
        loop:
            if (I >= CurrentLevel):
                break
            set Result = Result * CostMultiplier
            set I = I + 1
        Result

    UpdateDisplay() : void =
        if (LevelBB := LevelBillboard?):
            LevelBB.SetText(UpgradeLevelMsg(CurrentLevel))
        if (CostBB := CostBillboard?):
            if (CurrentLevel >= MaxLevel):
                CostBB.SetText(UpgradeMaxedMsg)
            else:
                TheCost := CalculateCost()
                CostBB.SetText(UpgradeCostMsg(TheCost))

    ResetCostDisplay()<suspends> : void =
        Sleep(1.5)
        UpdateDisplay()

#===============================================================================
# SNOW SIMULATOR MAIN - Device principal (initialisation joueurs)
#===============================================================================

snow_simulator_main<public> := class(creative_device):

    @editable
    SnowHUD : ?hud_message_device = false

    @editable
    LevelHUD : ?hud_message_device = false

    @editable
    RebirthHUD : ?hud_message_device = false

    @editable
    StartingSnow : float = 0.0

    @editable
    HUDUpdateInterval : float = 0.2

    MainSnowMsg<localizes>(Amount : string) : message = "Snow: {Amount}"
    MainLevelMsg<localizes>(Lvl : int, XP : string, XPMax : string) : message = "Level {Lvl} | XP: {XP}/{XPMax}"
    MainRebirthMsg<localizes>(Count : int) : message = "Rebirth: {Count}"

    OnBegin<override>()<suspends> : void =
        Print("Snow Simulator - Starting...")

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

        for (InPlayer : GetPlayspace().GetPlayers()):
            InitializeNewPlayer(InPlayer)

        spawn{HUDUpdateLoop()}

        Print("Snow Simulator - Ready!")

    OnPlayerJoined(InPlayer : player) : void =
        InitializeNewPlayer(InPlayer)

    OnPlayerLeft(InPlayer : player) : void =
        RemoveSimulatorPlayer(InPlayer)

    InitializeNewPlayer(InPlayer : player) : void =
        InitializeSimulatorPlayer(InPlayer)

        TotalEarned := GetTotalSnowEarned(InPlayer)
        if (TotalEarned = 0.0):
            if (StartingSnow > 0.0):
                AddSnow(InPlayer, StartingSnow)

    HUDUpdateLoop()<suspends> : void =
        loop:
            Sleep(HUDUpdateInterval)
            for (InPlayer : GetPlayspace().GetPlayers()):
                UpdateHUDForPlayer(InPlayer)

    UpdateHUDForPlayer(InPlayer : player) : void =
        CurrentSnow := GetSnow(InPlayer)
        CurrentLevel := GetLevel(InPlayer)
        CurrentXP := GetCurrentXP(InPlayer)
        CurrentRebirths := GetRebirthCount(InPlayer)

        SnowFormatted := FormatNumber(CurrentSnow)
        if (SH := SnowHUD?):
            SH.SetText(MainSnowMsg(SnowFormatted))
            SH.Show(InPlayer)

        XPRequired := GetXPForLevel(CurrentLevel)
        XPStr := FormatNumber(CurrentXP)
        XPMaxStr := FormatNumber(XPRequired)
        if (LH := LevelHUD?):
            LH.SetText(MainLevelMsg(CurrentLevel, XPStr, XPMaxStr))
            LH.Show(InPlayer)

        if (RH := RebirthHUD?):
            RH.SetText(MainRebirthMsg(CurrentRebirths))
            RH.Show(InPlayer)
