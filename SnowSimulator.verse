using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#===============================================================================
# SNOW SIMULATOR - Architecture Manager + Array Configurable
#===============================================================================
# Chaque manager gere un array d'elements configurables individuellement

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
# ENEMY CONFIG - Configuration d'un ennemi (struct editable)
#===============================================================================

enemy_config<public> := class<concrete>:
    @editable
    Health : float = 100.0

    @editable
    Defense : float = 0.0

    @editable
    SnowReward : float = 10.0

    @editable
    XPReward : float = 5.0

    @editable
    RespawnDelay : float = 5.0

    @editable
    PropManipulator : prop_manipulator_device = prop_manipulator_device{}

    @editable
    HealthBillboard : ?billboard_device = false

    @editable
    DestroyVFX : ?vfx_spawner_device = false

# Runtime state pour chaque ennemi
enemy_state := class:
    Config : enemy_config
    var CurrentHealth : float = 0.0
    var IsDestroyed : logic = false

#===============================================================================
# SIMULATOR MANAGER - Gestionnaire principal avec array d'ennemis
#===============================================================================

simulator_manager<public> := class(creative_device):

    @editable
    Enemies : []enemy_config = array{}

    @editable
    IncreaseDamageTrigger : ?trigger_device = false

    var EnemyStates : []enemy_state = array{}

    HealthMsg<localizes>(HP : int, MaxHP : int) : message = "{HP}/{MaxHP}"

    OnBegin<override>()<suspends> : void =
        Print("Simulator Manager - Initializing {Enemies.Length} enemies...")

        # Initialiser chaque ennemi
        for (Config : Enemies):
            State := enemy_state:
                Config := Config
            set State.CurrentHealth = Config.Health
            set EnemyStates = EnemyStates + array{State}
            Config.PropManipulator.DamagedEvent.Subscribe(MakeOnDamaged(State))
            UpdateEnemyDisplay(State)

        # Trigger pour augmenter les degats (optionnel)
        if (Trigger := IncreaseDamageTrigger?):
            Trigger.TriggeredEvent.Subscribe(OnIncreaseDamage)

        Print("Simulator Manager - Ready!")

    MakeOnDamaged(State : enemy_state) : tuple(agent) -> void =
        return (Agent : agent) => OnEnemyDamaged(State, Agent)

    OnEnemyDamaged(State : enemy_state, Agent : agent) : void =
        if (not State.IsDestroyed?):
            if (InPlayer := player[Agent]):
                BaseDamage := CalculateDamageForPlayer(InPlayer)
                # Appliquer defense
                EffectiveDamage := BaseDamage * (1.0 - State.Config.Defense / 100.0)
                if (EffectiveDamage < 1.0):
                    set EffectiveDamage = 1.0
                set State.CurrentHealth = State.CurrentHealth - EffectiveDamage
                UpdateEnemyDisplay(State)
                if (State.CurrentHealth <= 0.0):
                    DestroyEnemy(State, InPlayer)

    DestroyEnemy(State : enemy_state, InPlayer : player) : void =
        set State.IsDestroyed = true
        GainSnowForPlayer(InPlayer, State.Config.SnowReward)
        GainXPForPlayer(InPlayer, State.Config.XPReward)
        if (VFX := State.Config.DestroyVFX?):
            VFX.Restart()
        State.Config.PropManipulator.HideProps()
        spawn{RespawnEnemy(State)}

    RespawnEnemy(State : enemy_state)<suspends> : void =
        Sleep(State.Config.RespawnDelay)
        set State.CurrentHealth = State.Config.Health
        set State.IsDestroyed = false
        State.Config.PropManipulator.ShowProps()
        UpdateEnemyDisplay(State)

    UpdateEnemyDisplay(State : enemy_state) : void =
        if (HP := Int[State.CurrentHealth]):
            if (MaxHP := Int[State.Config.Health]):
                if (BB := State.Config.HealthBillboard?):
                    BB.SetText(HealthMsg(HP, MaxHP))

    OnIncreaseDamage(MaybeAgent : ?agent) : void =
        Print("Damage increased!")

#===============================================================================
# EGG CONFIG - Configuration d'une station d'oeufs
#===============================================================================

egg_config<public> := class<concrete>:
    @editable
    Cost : float = 100.0

    @editable
    HatchDuration : float = 2.0

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
    PurchaseButton : button_device = button_device{}

    @editable
    CostBillboard : ?billboard_device = false

    @editable
    HatchVFX : ?vfx_spawner_device = false

egg_state := class:
    Config : egg_config
    var IsHatching : logic = false

#===============================================================================
# EGG MANAGER - Gestionnaire des stations d'oeufs
#===============================================================================

egg_manager<public> := class(creative_device):

    @editable
    EggStations : []egg_config = array{}

    @editable
    ResultHUD : ?hud_message_device = false

    var StationStates : []egg_state = array{}

    CostMsg<localizes>(Amount : float) : message = "Cost: {Amount} Snow"
    HatchingMsg<localizes> : message = "Hatching..."
    ResultMsg<localizes>(RarityStr : string) : message = "You got a {RarityStr} pet!"

    OnBegin<override>()<suspends> : void =
        for (Config : EggStations):
            State := egg_state:
                Config := Config
            set StationStates = StationStates + array{State}
            if (BB := Config.CostBillboard?):
                BB.SetText(CostMsg(Config.Cost))
            Config.PurchaseButton.InteractedWithEvent.Subscribe(MakeOnPurchase(State))

    MakeOnPurchase(State : egg_state) : tuple(agent) -> void =
        return (Agent : agent) => OnEggPurchase(State, Agent)

    OnEggPurchase(State : egg_state, Agent : agent) : void =
        if (not State.IsHatching?):
            if (InPlayer := player[Agent]):
                if (TryRemoveSnow[InPlayer, State.Config.Cost]):
                    spawn{PerformHatch(State, InPlayer)}

    PerformHatch(State : egg_state, InPlayer : player)<suspends> : void =
        set State.IsHatching = true
        if (BB := State.Config.CostBillboard?):
            BB.SetText(HatchingMsg)
        if (VFX := State.Config.HatchVFX?):
            VFX.Restart()
        Sleep(State.Config.HatchDuration)

        Roll := GetRandomFloat(0.0, 1.0)
        var SelectedRarity : pet_rarity = pet_rarity.Common
        var Cumulative : float = State.Config.MythicChance

        if (Roll <= Cumulative):
            set SelectedRarity = pet_rarity.Mythic
        else:
            set Cumulative = Cumulative + State.Config.LegendaryChance
            if (Roll <= Cumulative):
                set SelectedRarity = pet_rarity.Legendary
            else:
                set Cumulative = Cumulative + State.Config.EpicChance
                if (Roll <= Cumulative):
                    set SelectedRarity = pet_rarity.Epic
                else:
                    set Cumulative = Cumulative + State.Config.RareChance
                    if (Roll <= Cumulative):
                        set SelectedRarity = pet_rarity.Rare

        PetID := GetRandomInt(1, 100)
        AddPet(InPlayer, PetID)

        RarityStr := GetRarityName(SelectedRarity)
        if (HUD := ResultHUD?):
            HUD.SetText(ResultMsg(RarityStr))
            HUD.Show(InPlayer)

        set State.IsHatching = false
        if (BB := State.Config.CostBillboard?):
            BB.SetText(CostMsg(State.Config.Cost))

#===============================================================================
# ZONE CONFIG - Configuration d'une porte de zone
#===============================================================================

zone_config<public> := class<concrete>:
    @editable
    ZoneID : int = 1

    @editable
    UnlockCost : float = 1000.0

    @editable
    RequiredLevel : int = 5

    @editable
    UnlockButton : button_device = button_device{}

    @editable
    GateProp : creative_prop = creative_prop{}

    @editable
    InfoBillboard : ?billboard_device = false

    @editable
    UnlockVFX : ?vfx_spawner_device = false

    @editable
    TeleportOnUnlock : ?teleporter_device = false

zone_state := class:
    Config : zone_config
    var IsUnlocked : logic = false
    var OriginalPosition : vector3 = vector3{}

#===============================================================================
# ZONE MANAGER - Gestionnaire des portes de zone
#===============================================================================

zone_manager<public> := class(creative_device):

    @editable
    ZoneGates : []zone_config = array{}

    var GateStates : []zone_state = array{}

    CostInfoMsg<localizes>(SnowCost : float, LvlReq : int) : message = "Cost: {SnowCost} | Level {LvlReq}"
    UnlockedInfoMsg<localizes> : message = "UNLOCKED"
    LockedInfoMsg<localizes> : message = "Requirements not met!"

    OnBegin<override>()<suspends> : void =
        for (Config : ZoneGates):
            State := zone_state:
                Config := Config
            set State.OriginalPosition = Config.GateProp.GetTransform().Translation
            set GateStates = GateStates + array{State}
            if (BB := Config.InfoBillboard?):
                BB.SetText(CostInfoMsg(Config.UnlockCost, Config.RequiredLevel))
            Config.UnlockButton.InteractedWithEvent.Subscribe(MakeOnUnlock(State))

        for (InPlayer : GetPlayspace().GetPlayers()):
            CheckPlayerUnlocks(InPlayer)
        GetPlayspace().PlayerAddedEvent().Subscribe(CheckPlayerUnlocks)

    MakeOnUnlock(State : zone_state) : tuple(agent) -> void =
        return (Agent : agent) => OnUnlockAttempt(State, Agent)

    OnUnlockAttempt(State : zone_state, Agent : agent) : void =
        if (not State.IsUnlocked?):
            if (InPlayer := player[Agent]):
                PlayerLevel := GetLevel(InPlayer)
                if (PlayerLevel >= State.Config.RequiredLevel):
                    if (TryRemoveSnow[InPlayer, State.Config.UnlockCost]):
                        AddUnlockedZone(InPlayer, State.Config.ZoneID)
                        UnlockGate(State, InPlayer)
                else:
                    if (BB := State.Config.InfoBillboard?):
                        BB.SetText(LockedInfoMsg)
                    spawn{ResetInfoDisplay(State)}

    CheckPlayerUnlocks(InPlayer : player) : void =
        for (State : GateStates):
            if (IsZoneUnlocked[InPlayer, State.Config.ZoneID]):
                OpenGate(State)

    UnlockGate(State : zone_state, InPlayer : player) : void =
        set State.IsUnlocked = true
        if (VFX := State.Config.UnlockVFX?):
            VFX.Restart()
        OpenGate(State)
        if (TP := State.Config.TeleportOnUnlock?):
            TP.Teleport(InPlayer)

    OpenGate(State : zone_state) : void =
        HidePos := State.OriginalPosition - vector3{Z := 10000.0}
        if (State.Config.GateProp.TeleportTo[HidePos, State.Config.GateProp.GetTransform().Rotation]) {}
        if (BB := State.Config.InfoBillboard?):
            BB.SetText(UnlockedInfoMsg)

    ResetInfoDisplay(State : zone_state)<suspends> : void =
        Sleep(2.0)
        if (BB := State.Config.InfoBillboard?):
            BB.SetText(CostInfoMsg(State.Config.UnlockCost, State.Config.RequiredLevel))

#===============================================================================
# REBIRTH CONFIG - Configuration d'un shrine de prestige
#===============================================================================

rebirth_config<public> := class<concrete>:
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

    @editable
    InteractButton : button_device = button_device{}

    @editable
    CostBillboard : ?billboard_device = false

    @editable
    BonusBillboard : ?billboard_device = false

    @editable
    RebirthVFX : ?vfx_spawner_device = false

#===============================================================================
# REBIRTH MANAGER - Gestionnaire des shrines de prestige
#===============================================================================

rebirth_manager<public> := class(creative_device):

    @editable
    RebirthShrines : []rebirth_config = array{}

    @editable
    SuccessHUD : ?hud_message_device = false

    @editable
    TeleportAfter : ?teleporter_device = false

    RebirthCostMsg<localizes>(SnowCost : float, LvlReq : int) : message = "Cost: {SnowCost} | Level {LvlReq}"
    RebirthBonusMsg<localizes>(DMG : float, SPD : float, CURR : float) : message = "+{DMG}% DMG | +{SPD}% Speed | +{CURR}% Snow"
    RebirthSuccessMsg<localizes>(Lvl : int) : message = "REBIRTH {Lvl} Complete!"
    RebirthFailMsg<localizes> : message = "Requirements not met!"

    OnBegin<override>()<suspends> : void =
        for (Config : RebirthShrines):
            if (CostBB := Config.CostBillboard?):
                CostBB.SetText(RebirthCostMsg(Config.RequiredSnow, Config.RequiredPlayerLevel))
            if (BonusBB := Config.BonusBillboard?):
                BonusBB.SetText(RebirthBonusMsg(Config.DamageBonus, Config.SpeedBonus, Config.CurrencyBonus))
            Config.InteractButton.InteractedWithEvent.Subscribe(MakeOnRebirth(Config))

    MakeOnRebirth(Config : rebirth_config) : tuple(agent) -> void =
        return (Agent : agent) => OnRebirthAttempt(Config, Agent)

    OnRebirthAttempt(Config : rebirth_config, Agent : agent) : void =
        if (InPlayer := player[Agent]):
            CurrentRebirths := GetRebirthCount(InPlayer)
            CurrentLevel := GetLevel(InPlayer)
            CurrentSnow := GetSnow(InPlayer)

            ExpectedRebirths := Config.RebirthLevel - 1
            if (CurrentRebirths = ExpectedRebirths):
                if (CurrentLevel >= Config.RequiredPlayerLevel):
                    if (CurrentSnow >= Config.RequiredSnow):
                        DoRebirth(InPlayer, Config.DamageBonus, Config.SpeedBonus, Config.CurrencyBonus)
                        if (VFX := Config.RebirthVFX?):
                            VFX.Restart()
                        if (HUD := SuccessHUD?):
                            HUD.SetText(RebirthSuccessMsg(Config.RebirthLevel))
                            HUD.Show(InPlayer)
                        if (TP := TeleportAfter?):
                            TP.Teleport(InPlayer)
                    else:
                        ShowFailMessage(Config)
                else:
                    ShowFailMessage(Config)
            else:
                ShowFailMessage(Config)

    ShowFailMessage(Config : rebirth_config) : void =
        if (CostBB := Config.CostBillboard?):
            CostBB.SetText(RebirthFailMsg)
        spawn{ResetDisplay(Config)}

    ResetDisplay(Config : rebirth_config)<suspends> : void =
        Sleep(2.0)
        if (CostBB := Config.CostBillboard?):
            CostBB.SetText(RebirthCostMsg(Config.RequiredSnow, Config.RequiredPlayerLevel))

#===============================================================================
# UPGRADE CONFIG - Configuration d'une station d'upgrade
#===============================================================================

upgrade_config<public> := class<concrete>:
    @editable
    UpgradeName : string = "Damage"

    @editable
    BaseCost : float = 50.0

    @editable
    CostMultiplier : float = 1.15

    @editable
    MaxLevel : int = 100

    @editable
    PurchaseButton : button_device = button_device{}

    @editable
    NameBillboard : ?billboard_device = false

    @editable
    LevelBillboard : ?billboard_device = false

    @editable
    CostBillboard : ?billboard_device = false

    @editable
    UpgradeVFX : ?vfx_spawner_device = false

upgrade_state := class:
    Config : upgrade_config
    var CurrentLevel : int = 0

#===============================================================================
# UPGRADE MANAGER - Gestionnaire des stations d'upgrade
#===============================================================================

upgrade_manager<public> := class(creative_device):

    @editable
    UpgradeStations : []upgrade_config = array{}

    var UpgradeStates : []upgrade_state = array{}

    UpgradeNameMsg<localizes>(TheName : string) : message = "{TheName}"
    UpgradeLevelMsg<localizes>(Lvl : int) : message = "Level: {Lvl}"
    UpgradeCostMsg<localizes>(TheCost : float) : message = "Cost: {TheCost} Snow"
    UpgradeMaxedMsg<localizes> : message = "MAXED!"
    UpgradeFailMsg<localizes> : message = "Not enough Snow!"

    OnBegin<override>()<suspends> : void =
        for (Config : UpgradeStations):
            State := upgrade_state:
                Config := Config
            set UpgradeStates = UpgradeStates + array{State}
            if (NameBB := Config.NameBillboard?):
                NameBB.SetText(UpgradeNameMsg(Config.UpgradeName))
            UpdateDisplay(State)
            Config.PurchaseButton.InteractedWithEvent.Subscribe(MakeOnPurchase(State))

    MakeOnPurchase(State : upgrade_state) : tuple(agent) -> void =
        return (Agent : agent) => OnUpgradePurchase(State, Agent)

    OnUpgradePurchase(State : upgrade_state, Agent : agent) : void =
        if (State.CurrentLevel < State.Config.MaxLevel):
            if (InPlayer := player[Agent]):
                TheCost := CalculateCost(State)
                if (TryRemoveSnow[InPlayer, TheCost]):
                    set State.CurrentLevel = State.CurrentLevel + 1
                    if (VFX := State.Config.UpgradeVFX?):
                        VFX.Restart()
                    UpdateDisplay(State)
                else:
                    if (CostBB := State.Config.CostBillboard?):
                        CostBB.SetText(UpgradeFailMsg)
                    spawn{ResetCostDisplay(State)}

    CalculateCost(State : upgrade_state) : float =
        var Result : float = State.Config.BaseCost
        var I : int = 0
        loop:
            if (I >= State.CurrentLevel):
                break
            set Result = Result * State.Config.CostMultiplier
            set I = I + 1
        Result

    UpdateDisplay(State : upgrade_state) : void =
        if (LevelBB := State.Config.LevelBillboard?):
            LevelBB.SetText(UpgradeLevelMsg(State.CurrentLevel))
        if (CostBB := State.Config.CostBillboard?):
            if (State.CurrentLevel >= State.Config.MaxLevel):
                CostBB.SetText(UpgradeMaxedMsg)
            else:
                TheCost := CalculateCost(State)
                CostBB.SetText(UpgradeCostMsg(TheCost))

    ResetCostDisplay(State : upgrade_state)<suspends> : void =
        Sleep(1.5)
        UpdateDisplay(State)

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
