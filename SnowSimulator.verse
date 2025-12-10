using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#===============================================================================
# SNOW SIMULATOR - Systeme complet corrige
#===============================================================================
# IMPORTANT: Ce fichier doit etre dans Content/[NomProjet]/

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
    BreakableRespawnTime<public> : float = 5.0

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
    BaseDamage := GetTotalDamage(InPlayer)
    BaseDamage

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

#-------------------------------------------------------------------------------
# BREAKABLE MANAGER - Gere PLUSIEURS props cassables
#-------------------------------------------------------------------------------

breakable_data := class:
    var CurrentHealth : float = 0.0
    var IsDestroyed : logic = false
    var OriginalPosition : vector3 = vector3{}
    var OriginalRotation : rotation = rotation{}

snow_breakables_manager<public> := class(creative_device):
    @editable
    Props : []creative_prop = array{}

    @editable
    DamageTriggers : []trigger_device = array{}

    @editable
    HealthBillboards : []billboard_device = array{}

    @editable
    DestroyVFXs : []vfx_spawner_device = array{}

    @editable
    BaseHealth : float = 100.0

    @editable
    BaseReward : float = 10.0

    @editable
    XPReward : float = 5.0

    @editable
    RespawnTime : float = 5.0

    var BreakableStates : []breakable_data = array{}

    HealthMsg<localizes>(HP : int, MaxHP : int) : message = "{HP}/{MaxHP}"

    OnBegin<override>()<suspends> : void =
        InitializeAllBreakables()

    InitializeAllBreakables() : void =
        var Index : int = 0
        for (Prop : Props):
            NewState := breakable_data{}
            set NewState.CurrentHealth = BaseHealth
            set NewState.OriginalPosition = Prop.GetTransform().Translation
            set NewState.OriginalRotation = Prop.GetTransform().Rotation
            set BreakableStates = BreakableStates + array{NewState}

            if (Trigger := DamageTriggers[Index]):
                CapturedIndex := Index
                Trigger.TriggeredEvent.Subscribe(MakeDamageHandler(CapturedIndex))

            UpdateHealthDisplayAt(Index)
            set Index = Index + 1

    MakeDamageHandler(Index : int) : tuple(MaybeAgent : ?agent) -> void =
        return (MaybeAgent : ?agent) -> void:
            HandleDamageAt(Index, MaybeAgent)

    HandleDamageAt(Index : int, MaybeAgent : ?agent) : void =
        if (State := BreakableStates[Index]):
            if (State.IsDestroyed?):
                return
            if (Agent := MaybeAgent?):
                if (InPlayer := player[Agent]):
                    DamageAmount := CalculateDamageForPlayer(InPlayer)
                    set State.CurrentHealth = State.CurrentHealth - DamageAmount
                    UpdateHealthDisplayAt(Index)
                    if (State.CurrentHealth <= 0.0):
                        DestroyBreakableAt(Index, InPlayer)

    DestroyBreakableAt(Index : int, InPlayer : player) : void =
        if (State := BreakableStates[Index]):
            set State.IsDestroyed = true
            GainSnowForPlayer(InPlayer, BaseReward)
            GainXPForPlayer(InPlayer, XPReward)

            if (VFX := DestroyVFXs[Index]):
                VFX.Restart()

            if (Prop := Props[Index]):
                HidePosition := State.OriginalPosition - vector3{Z := 10000.0}
                if (Prop.TeleportTo[HidePosition, State.OriginalRotation]) {}

            spawn{RespawnBreakableAt(Index)}

    RespawnBreakableAt(Index : int)<suspends> : void =
        Sleep(RespawnTime)
        if (State := BreakableStates[Index]):
            set State.CurrentHealth = BaseHealth
            set State.IsDestroyed = false
            if (Prop := Props[Index]):
                if (Prop.TeleportTo[State.OriginalPosition, State.OriginalRotation]) {}
            UpdateHealthDisplayAt(Index)

    UpdateHealthDisplayAt(Index : int) : void =
        if (State := BreakableStates[Index]):
            if (Billboard := HealthBillboards[Index]):
                if (HP := Int[State.CurrentHealth]):
                    if (MaxHP := Int[BaseHealth]):
                        Billboard.SetText(HealthMsg(HP, MaxHP))

#-------------------------------------------------------------------------------
# EGG STATIONS MANAGER - Gere PLUSIEURS stations d oeufs
#-------------------------------------------------------------------------------

egg_station_data := class:
    var IsHatching : logic = false

snow_egg_stations_manager<public> := class(creative_device):
    @editable
    PurchaseButtons : []button_device = array{}

    @editable
    CostBillboards : []billboard_device = array{}

    @editable
    HatchVFXs : []vfx_spawner_device = array{}

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
    ResultHUD : hud_message_device = hud_message_device{}

    var StationStates : []egg_station_data = array{}

    CostMsg<localizes>(Amount : float) : message = "Cost: {Amount} Snow"
    HatchingMsg<localizes> : message = "Hatching..."
    ResultMsg<localizes>(RarityStr : string) : message = "You got a {RarityStr} pet!"

    OnBegin<override>()<suspends> : void =
        var Index : int = 0
        for (Button : PurchaseButtons):
            NewState := egg_station_data{}
            set StationStates = StationStates + array{NewState}

            if (Billboard := CostBillboards[Index]):
                Billboard.SetText(CostMsg(EggCost))

            CapturedIndex := Index
            Button.InteractedWithEvent.Subscribe(MakePurchaseHandler(CapturedIndex))
            set Index = Index + 1

    MakePurchaseHandler(Index : int) : tuple(Agent : agent) -> void =
        return (Agent : agent) -> void:
            HandlePurchaseAt(Index, Agent)

    HandlePurchaseAt(Index : int, Agent : agent) : void =
        if (State := StationStates[Index]):
            if (State.IsHatching?):
                return
            if (InPlayer := player[Agent]):
                if (TryRemoveSnow[InPlayer, EggCost]):
                    spawn{PerformHatchAt(Index, InPlayer)}

    PerformHatchAt(Index : int, InPlayer : player)<suspends> : void =
        if (State := StationStates[Index]):
            set State.IsHatching = true

            if (Billboard := CostBillboards[Index]):
                Billboard.SetText(HatchingMsg)
            if (VFX := HatchVFXs[Index]):
                VFX.Restart()

            Sleep(2.0)

            Roll := GetRandomFloat(0.0, 1.0)
            var SelectedRarity : pet_rarity = pet_rarity.Common
            var Cumulative : float = 0.0

            set Cumulative = MythicChance
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
            ResultHUD.SetText(ResultMsg(RarityStr))
            ResultHUD.Show(InPlayer)

            set State.IsHatching = false
            if (Billboard := CostBillboards[Index]):
                Billboard.SetText(CostMsg(EggCost))

#-------------------------------------------------------------------------------
# ZONE GATES MANAGER - Gere PLUSIEURS portes de zone
#-------------------------------------------------------------------------------

zone_gate_data := class:
    var IsUnlocked : logic = false
    var OriginalPosition : vector3 = vector3{}
    ZoneID : int
    UnlockCost : float
    RequiredLevel : int

snow_zone_gates_manager<public> := class(creative_device):
    @editable
    ZoneIDs : []int = array{}

    @editable
    UnlockCosts : []float = array{}

    @editable
    RequiredLevels : []int = array{}

    @editable
    GateProps : []creative_prop = array{}

    @editable
    UnlockButtons : []button_device = array{}

    @editable
    InfoBillboards : []billboard_device = array{}

    @editable
    UnlockVFXs : []vfx_spawner_device = array{}

    @editable
    TeleportOnUnlocks : []teleporter_device = array{}

    var GateStates : []zone_gate_data = array{}

    CostInfoMsg<localizes>(SnowCost : float, LvlReq : int) : message = "Cost: {SnowCost} | Level {LvlReq}"
    UnlockedInfoMsg<localizes> : message = "UNLOCKED"
    LockedInfoMsg<localizes> : message = "Requirements not met!"

    OnBegin<override>()<suspends> : void =
        var Index : int = 0
        for (Button : UnlockButtons):
            var TheZoneID : int = Index
            var TheCost : float = 1000.0
            var TheReqLevel : int = 5

            if (Z := ZoneIDs[Index]):
                set TheZoneID = Z
            if (C := UnlockCosts[Index]):
                set TheCost = C
            if (L := RequiredLevels[Index]):
                set TheReqLevel = L

            NewState := zone_gate_data:
                ZoneID := TheZoneID
                UnlockCost := TheCost
                RequiredLevel := TheReqLevel

            if (Prop := GateProps[Index]):
                set NewState.OriginalPosition = Prop.GetTransform().Translation

            set GateStates = GateStates + array{NewState}

            if (Billboard := InfoBillboards[Index]):
                Billboard.SetText(CostInfoMsg(TheCost, TheReqLevel))

            CapturedIndex := Index
            Button.InteractedWithEvent.Subscribe(MakeUnlockHandler(CapturedIndex))
            set Index = Index + 1

        for (InPlayer : GetPlayspace().GetPlayers()):
            CheckAllPlayerUnlocks(InPlayer)
        GetPlayspace().PlayerAddedEvent().Subscribe(CheckAllPlayerUnlocks)

    MakeUnlockHandler(Index : int) : tuple(Agent : agent) -> void =
        return (Agent : agent) -> void:
            HandleUnlockAttemptAt(Index, Agent)

    CheckAllPlayerUnlocks(InPlayer : player) : void =
        var Index : int = 0
        for (State : GateStates):
            if (IsZoneUnlocked[InPlayer, State.ZoneID]):
                OpenGateAt(Index)
            set Index = Index + 1

    HandleUnlockAttemptAt(Index : int, Agent : agent) : void =
        if (State := GateStates[Index]):
            if (State.IsUnlocked?):
                return
            if (InPlayer := player[Agent]):
                PlayerLevel := GetLevel(InPlayer)
                if (PlayerLevel >= State.RequiredLevel):
                    if (TryRemoveSnow[InPlayer, State.UnlockCost]):
                        AddUnlockedZone(InPlayer, State.ZoneID)
                        UnlockGateForAt(Index, InPlayer)
                    else:
                        if (Billboard := InfoBillboards[Index]):
                            Billboard.SetText(LockedInfoMsg)
                        spawn{ResetInfoDisplayAt(Index)}
                else:
                    if (Billboard := InfoBillboards[Index]):
                        Billboard.SetText(LockedInfoMsg)
                    spawn{ResetInfoDisplayAt(Index)}

    UnlockGateForAt(Index : int, InPlayer : player) : void =
        if (State := GateStates[Index]):
            set State.IsUnlocked = true
            if (VFX := UnlockVFXs[Index]):
                VFX.Restart()
            OpenGateAt(Index)
            if (Teleporter := TeleportOnUnlocks[Index]):
                Teleporter.Teleport(InPlayer)

    OpenGateAt(Index : int) : void =
        if (State := GateStates[Index]):
            if (Prop := GateProps[Index]):
                HidePos := State.OriginalPosition - vector3{Z := 10000.0}
                if (Prop.TeleportTo[HidePos, Prop.GetTransform().Rotation]) {}
            if (Billboard := InfoBillboards[Index]):
                Billboard.SetText(UnlockedInfoMsg)

    ResetInfoDisplayAt(Index : int)<suspends> : void =
        Sleep(2.0)
        if (State := GateStates[Index]):
            if (Billboard := InfoBillboards[Index]):
                Billboard.SetText(CostInfoMsg(State.UnlockCost, State.RequiredLevel))

#-------------------------------------------------------------------------------
# REBIRTH SHRINES MANAGER - Gere PLUSIEURS shrines de prestige
#-------------------------------------------------------------------------------

rebirth_shrine_data := class:
    RebirthLevel : int
    RequiredSnow : float
    RequiredPlayerLevel : int
    DamageBonus : float
    SpeedBonus : float
    CurrencyBonus : float

snow_rebirth_shrines_manager<public> := class(creative_device):
    @editable
    RebirthLevels : []int = array{}

    @editable
    RequiredSnows : []float = array{}

    @editable
    RequiredPlayerLevels : []int = array{}

    @editable
    DamageBonuses : []float = array{}

    @editable
    SpeedBonuses : []float = array{}

    @editable
    CurrencyBonuses : []float = array{}

    @editable
    InteractButtons : []button_device = array{}

    @editable
    CostDisplayBillboards : []billboard_device = array{}

    @editable
    BonusDisplayBillboards : []billboard_device = array{}

    @editable
    RebirthVFXs : []vfx_spawner_device = array{}

    @editable
    SuccessHUD : hud_message_device = hud_message_device{}

    @editable
    TeleportAfter : teleporter_device = teleporter_device{}

    var ShrineStates : []rebirth_shrine_data = array{}

    RebirthCostMsg<localizes>(SnowCost : float, LvlReq : int) : message = "Cost: {SnowCost} | Level {LvlReq}"
    RebirthBonusMsg<localizes>(DMG : float, SPD : float, CURR : float) : message = "+{DMG}% DMG | +{SPD}% Speed | +{CURR}% Snow"
    RebirthSuccessMsg<localizes>(Lvl : int) : message = "REBIRTH {Lvl} Complete!"
    RebirthFailMsg<localizes> : message = "Requirements not met!"

    OnBegin<override>()<suspends> : void =
        var Index : int = 0
        for (Button : InteractButtons):
            var TheLevel : int = Index + 1
            var TheReqSnow : float = 50000.0
            var TheReqLevel : int = 25
            var TheDmgBonus : float = 25.0
            var TheSpdBonus : float = 10.0
            var TheCurrBonus : float = 15.0

            if (L := RebirthLevels[Index]):
                set TheLevel = L
            if (S := RequiredSnows[Index]):
                set TheReqSnow = S
            if (RL := RequiredPlayerLevels[Index]):
                set TheReqLevel = RL
            if (D := DamageBonuses[Index]):
                set TheDmgBonus = D
            if (SP := SpeedBonuses[Index]):
                set TheSpdBonus = SP
            if (C := CurrencyBonuses[Index]):
                set TheCurrBonus = C

            NewState := rebirth_shrine_data:
                RebirthLevel := TheLevel
                RequiredSnow := TheReqSnow
                RequiredPlayerLevel := TheReqLevel
                DamageBonus := TheDmgBonus
                SpeedBonus := TheSpdBonus
                CurrencyBonus := TheCurrBonus
            set ShrineStates = ShrineStates + array{NewState}

            if (CostBB := CostDisplayBillboards[Index]):
                CostBB.SetText(RebirthCostMsg(TheReqSnow, TheReqLevel))
            if (BonusBB := BonusDisplayBillboards[Index]):
                BonusBB.SetText(RebirthBonusMsg(TheDmgBonus, TheSpdBonus, TheCurrBonus))

            CapturedIndex := Index
            Button.InteractedWithEvent.Subscribe(MakeRebirthHandler(CapturedIndex))
            set Index = Index + 1

    MakeRebirthHandler(Index : int) : tuple(Agent : agent) -> void =
        return (Agent : agent) -> void:
            HandleRebirthAttemptAt(Index, Agent)

    HandleRebirthAttemptAt(Index : int, Agent : agent) : void =
        if (State := ShrineStates[Index]):
            if (InPlayer := player[Agent]):
                CurrentRebirths := GetRebirthCount(InPlayer)
                CurrentLevel := GetLevel(InPlayer)
                CurrentSnow := GetSnow(InPlayer)

                if (CurrentRebirths >= State.RebirthLevel):
                    return

                ExpectedRebirths := State.RebirthLevel - 1
                if (CurrentRebirths <> ExpectedRebirths):
                    if (CostBB := CostDisplayBillboards[Index]):
                        CostBB.SetText(RebirthFailMsg)
                    spawn{ResetRebirthDisplayAt(Index)}
                    return

                if (CurrentLevel < State.RequiredPlayerLevel):
                    if (CostBB := CostDisplayBillboards[Index]):
                        CostBB.SetText(RebirthFailMsg)
                    spawn{ResetRebirthDisplayAt(Index)}
                    return

                if (CurrentSnow < State.RequiredSnow):
                    if (CostBB := CostDisplayBillboards[Index]):
                        CostBB.SetText(RebirthFailMsg)
                    spawn{ResetRebirthDisplayAt(Index)}
                    return

                DoRebirth(InPlayer, State.DamageBonus, State.SpeedBonus, State.CurrencyBonus)

                if (VFX := RebirthVFXs[Index]):
                    VFX.Restart()
                SuccessHUD.SetText(RebirthSuccessMsg(State.RebirthLevel))
                SuccessHUD.Show(InPlayer)
                TeleportAfter.Teleport(InPlayer)

    ResetRebirthDisplayAt(Index : int)<suspends> : void =
        Sleep(2.0)
        if (State := ShrineStates[Index]):
            if (CostBB := CostDisplayBillboards[Index]):
                CostBB.SetText(RebirthCostMsg(State.RequiredSnow, State.RequiredPlayerLevel))

#-------------------------------------------------------------------------------
# UPGRADE STATIONS MANAGER - Gere PLUSIEURS stations d upgrade
#-------------------------------------------------------------------------------

upgrade_station_data := class:
    var CurrentLevel : int = 0
    Name : string
    BaseCost : float
    CostMult : float
    MaxLevel : int

snow_upgrade_stations_manager<public> := class(creative_device):
    @editable
    UpgradeNames : []string = array{}

    @editable
    BaseCosts : []float = array{}

    @editable
    CostMultipliers : []float = array{}

    @editable
    MaxLevels : []int = array{}

    @editable
    PurchaseButtons : []button_device = array{}

    @editable
    NameBillboards : []billboard_device = array{}

    @editable
    LevelBillboards : []billboard_device = array{}

    @editable
    CostBillboards : []billboard_device = array{}

    @editable
    UpgradeVFXs : []vfx_spawner_device = array{}

    var UpgradeStates : []upgrade_station_data = array{}

    UpgradeNameMsg<localizes>(Name : string) : message = "{Name}"
    UpgradeLevelMsg<localizes>(Lvl : int) : message = "Level: {Lvl}"
    UpgradeCostMsg<localizes>(TheCost : float) : message = "Cost: {TheCost} Snow"
    UpgradeMaxedMsg<localizes> : message = "MAXED!"
    UpgradeFailMsg<localizes> : message = "Not enough Snow!"

    OnBegin<override>()<suspends> : void =
        var Index : int = 0
        for (Button : PurchaseButtons):
            var TheName : string = "Upgrade"
            var TheBaseCost : float = 50.0
            var TheCostMult : float = 1.15
            var TheMaxLevel : int = 100

            if (N := UpgradeNames[Index]):
                set TheName = N
            if (C := BaseCosts[Index]):
                set TheBaseCost = C
            if (M := CostMultipliers[Index]):
                set TheCostMult = M
            if (L := MaxLevels[Index]):
                set TheMaxLevel = L

            NewState := upgrade_station_data:
                Name := TheName
                BaseCost := TheBaseCost
                CostMult := TheCostMult
                MaxLevel := TheMaxLevel
            set UpgradeStates = UpgradeStates + array{NewState}

            if (NameBB := NameBillboards[Index]):
                NameBB.SetText(UpgradeNameMsg(TheName))

            UpdateUpgradeDisplayAt(Index)

            CapturedIndex := Index
            Button.InteractedWithEvent.Subscribe(MakeUpgradeHandler(CapturedIndex))
            set Index = Index + 1

    MakeUpgradeHandler(Index : int) : tuple(Agent : agent) -> void =
        return (Agent : agent) -> void:
            HandleUpgradePurchaseAt(Index, Agent)

    CalculateCostAt(Index : int) : float =
        var Result : float = 50.0
        if (State := UpgradeStates[Index]):
            set Result = State.BaseCost
            var I : int = 0
            loop:
                if (I >= State.CurrentLevel):
                    break
                set Result = Result * State.CostMult
                set I = I + 1
        Result

    UpdateUpgradeDisplayAt(Index : int) : void =
        if (State := UpgradeStates[Index]):
            if (LevelBB := LevelBillboards[Index]):
                LevelBB.SetText(UpgradeLevelMsg(State.CurrentLevel))
            if (CostBB := CostBillboards[Index]):
                if (State.CurrentLevel >= State.MaxLevel):
                    CostBB.SetText(UpgradeMaxedMsg)
                else:
                    TheCost := CalculateCostAt(Index)
                    CostBB.SetText(UpgradeCostMsg(TheCost))

    HandleUpgradePurchaseAt(Index : int, Agent : agent) : void =
        if (State := UpgradeStates[Index]):
            if (State.CurrentLevel >= State.MaxLevel):
                return
            if (InPlayer := player[Agent]):
                TheCost := CalculateCostAt(Index)
                if (TryRemoveSnow[InPlayer, TheCost]):
                    set State.CurrentLevel = State.CurrentLevel + 1
                    if (VFX := UpgradeVFXs[Index]):
                        VFX.Restart()
                    UpdateUpgradeDisplayAt(Index)
                else:
                    if (CostBB := CostBillboards[Index]):
                        CostBB.SetText(UpgradeFailMsg)
                    spawn{ResetUpgradeCostDisplayAt(Index)}

    ResetUpgradeCostDisplayAt(Index : int)<suspends> : void =
        Sleep(1.5)
        UpdateUpgradeDisplayAt(Index)

#-------------------------------------------------------------------------------
# MAIN MANAGER - Device principal
#-------------------------------------------------------------------------------

snow_simulator_main<public> := class(creative_device):

    @editable
    SnowHUD : hud_message_device = hud_message_device{}

    @editable
    LevelHUD : hud_message_device = hud_message_device{}

    @editable
    RebirthHUD : hud_message_device = hud_message_device{}

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
        SnowHUD.SetText(MainSnowMsg(SnowFormatted))
        SnowHUD.Show(InPlayer)

        XPRequired := GetXPForLevel(CurrentLevel)
        XPStr := FormatNumber(CurrentXP)
        XPMaxStr := FormatNumber(XPRequired)
        LevelHUD.SetText(MainLevelMsg(CurrentLevel, XPStr, XPMaxStr))
        LevelHUD.Show(InPlayer)

        RebirthHUD.SetText(MainRebirthMsg(CurrentRebirths))
        RebirthHUD.Show(InPlayer)
