using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }

#===============================================================================
# SNOW SIMULATOR - Architecture Manager + Array
#===============================================================================
# 1 Manager avec des tableaux configurables - ajoutez des elements avec "+"

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
# ICONS MODULE - Textures pour l'UI (importez vos propres textures)
#===============================================================================

Icons<public> := module:
    # Importez vos textures depuis le Content Browser
    # Exemple: SnowIcon : texture = import("/Game/UI/Icons/Snow.Snow")
    SnowIcon<public> : texture = texture{}
    LevelIcon<public> : texture = texture{}
    XPIcon<public> : texture = texture{}
    RebirthIcon<public> : texture = texture{}

#===============================================================================
# PLAYER UI DATA - Stockage des widgets par joueur
#===============================================================================

player_ui_data := class:
    var SnowText : text_block = text_block{}
    var LevelText : text_block = text_block{}
    var XPText : text_block = text_block{}
    var RebirthText : text_block = text_block{}
    var Canvas : canvas = canvas{}

var PlayerUIMap : weak_map(player, player_ui_data) = map{}

#===============================================================================
# MANAGER CLASS - Gestion principale avec UI Canvas
#===============================================================================

snow_simulator_manager := class(creative_device):

    @editable
    StartingSnow : float = 0.0

    @editable
    HUDUpdateInterval : float = 0.2

    @editable
    Enemies : []snow_enemy_config = array{}

    @editable
    EggStations : []snow_egg_config = array{}

    @editable
    ZoneGates : []snow_zone_config = array{}

    @editable
    RebirthShrines : []snow_rebirth_config = array{}

    @editable
    UpgradeStations : []snow_upgrade_config = array{}

    # Messages localisables pour l'UI
    SnowMsg<localizes>(Amount : string) : message = "{Amount}"
    LevelMsg<localizes>(Lvl : int) : message = "Lvl {Lvl}"
    XPMsg<localizes>(XP : string, XPMax : string) : message = "{XP}/{XPMax}"
    RebirthMsg<localizes>(Count : int) : message = "x{Count}"

    OnBegin<override>()<suspends> : void =
        Print("Snow Simulator Manager - Starting...")

        # Initialize all entities
        InitializeEnemies()
        InitializeEggStations()
        InitializeZoneGates()
        InitializeRebirthShrines()
        InitializeUpgradeStations()

        # Setup player events
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

        for (InPlayer : GetPlayspace().GetPlayers()):
            InitializeNewPlayer(InPlayer)

        spawn{HUDUpdateLoop()}

        Print("Snow Simulator Manager - Ready!")

    InitializeEnemies() : void =
        for (Enemy : Enemies):
            Enemy.Setup()

    InitializeEggStations() : void =
        for (Station : EggStations):
            Station.Setup()

    InitializeZoneGates() : void =
        for (Gate : ZoneGates):
            Gate.Setup()

    InitializeRebirthShrines() : void =
        for (Shrine : RebirthShrines):
            Shrine.Setup()

    InitializeUpgradeStations() : void =
        for (Station : UpgradeStations):
            Station.Setup()

    OnPlayerJoined(InPlayer : player) : void =
        InitializeNewPlayer(InPlayer)

    OnPlayerLeft(InPlayer : player) : void =
        RemoveSimulatorPlayer(InPlayer)
        RemovePlayerUI(InPlayer)

    InitializeNewPlayer(InPlayer : player) : void =
        InitializeSimulatorPlayer(InPlayer)
        TotalEarned := GetTotalSnowEarned(InPlayer)
        if (TotalEarned = 0.0):
            if (StartingSnow > 0.0):
                AddSnow(InPlayer, StartingSnow)
        # Check zones for this player
        for (Gate : ZoneGates):
            Gate.CheckPlayerUnlock(InPlayer)
        # Initialize UI for this player
        InitiateUI(InPlayer)

    RemovePlayerUI(InPlayer : player) : void =
        # UI is automatically cleaned up when player leaves
        return

    # Cree le canvas UI pour un joueur
    CreatePlayerUI(InPlayer : player) : player_ui_data =
        # Creer les text_blocks avec style
        NewSnowText := text_block:
            DefaultTextColor := White
            DefaultShadowOffset := option{vector2{X := 1.0, Y := 1.0}}
            DefaultShadowColor := Black

        NewLevelText := text_block:
            DefaultTextColor := White
            DefaultShadowOffset := option{vector2{X := 1.0, Y := 1.0}}
            DefaultShadowColor := Black

        NewXPText := text_block:
            DefaultTextColor := White
            DefaultShadowOffset := option{vector2{X := 1.0, Y := 1.0}}
            DefaultShadowColor := Black

        NewRebirthText := text_block:
            DefaultTextColor := White
            DefaultShadowOffset := option{vector2{X := 1.0, Y := 1.0}}
            DefaultShadowColor := Black

        # Creer les texture_blocks pour les icones
        SnowIconWidget := texture_block:
            DefaultImage := Icons.SnowIcon

        LevelIconWidget := texture_block:
            DefaultImage := Icons.LevelIcon

        XPIconWidget := texture_block:
            DefaultImage := Icons.XPIcon

        RebirthIconWidget := texture_block:
            DefaultImage := Icons.RebirthIcon

        # Creer le canvas avec tous les slots
        NewCanvas := canvas:
            Slots := array:
                # Snow Icon
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 20.0, Top := 0.0, Right := 40.0, Bottom := 40.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    Widget := SnowIconWidget
                # Snow Text
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 70.0, Top := 0.0, Right := 150.0, Bottom := 40.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    Widget := NewSnowText
                # Level Icon
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 20.0, Top := 50.0, Right := 40.0, Bottom := 40.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    Widget := LevelIconWidget
                # Level Text
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 70.0, Top := 50.0, Right := 100.0, Bottom := 40.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    Widget := NewLevelText
                # XP Icon
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 20.0, Top := 100.0, Right := 40.0, Bottom := 40.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    Widget := XPIconWidget
                # XP Text
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 70.0, Top := 100.0, Right := 150.0, Bottom := 40.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    Widget := NewXPText
                # Rebirth Icon
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 20.0, Top := 150.0, Right := 40.0, Bottom := 40.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    Widget := RebirthIconWidget
                # Rebirth Text
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 70.0, Top := 150.0, Right := 100.0, Bottom := 40.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    Widget := NewRebirthText

        # Retourner les donnees UI
        player_ui_data:
            SnowText := NewSnowText
            LevelText := NewLevelText
            XPText := NewXPText
            RebirthText := NewRebirthText
            Canvas := NewCanvas

    # Initialise l'UI pour un joueur
    InitiateUI(InPlayer : player) : void =
        if (PlayerUI := GetPlayerUI[InPlayer]):
            UIData := CreatePlayerUI(InPlayer)
            PlayerUI.AddWidget(UIData.Canvas)
            UIData.SnowText.SetShadowOpacity(1.0)
            UIData.LevelText.SetShadowOpacity(1.0)
            UIData.XPText.SetShadowOpacity(1.0)
            UIData.RebirthText.SetShadowOpacity(1.0)
            if (set PlayerUIMap[InPlayer] = UIData) {}
            UpdateUIForPlayer(InPlayer)

    HUDUpdateLoop()<suspends> : void =
        loop:
            Sleep(HUDUpdateInterval)
            for (InPlayer : GetPlayspace().GetPlayers()):
                UpdateUIForPlayer(InPlayer)

    UpdateUIForPlayer(InPlayer : player) : void =
        if (UIData := PlayerUIMap[InPlayer]):
            CurrentSnow := GetSnow(InPlayer)
            CurrentLevel := GetLevel(InPlayer)
            CurrentXP := GetCurrentXP(InPlayer)
            CurrentRebirths := GetRebirthCount(InPlayer)
            XPRequired := GetXPForLevel(CurrentLevel)

            SnowFormatted := FormatNumber(CurrentSnow)
            XPStr := FormatNumber(CurrentXP)
            XPMaxStr := FormatNumber(XPRequired)

            UIData.SnowText.SetText(SnowMsg(SnowFormatted))
            UIData.LevelText.SetText(LevelMsg(CurrentLevel))
            UIData.XPText.SetText(XPMsg(XPStr, XPMaxStr))
            UIData.RebirthText.SetText(RebirthMsg(CurrentRebirths))

#===============================================================================
# SNOW ENEMY CONFIG - Classe concrete pour les ennemis
#===============================================================================
# Ajoutez des ennemis avec "+" dans le tableau Enemies du Manager

snow_enemy_config<public> := class<concrete>:

    @editable
    PropManipulator : prop_manipulator_device = prop_manipulator_device{}

    @editable
    HealthBillboard : billboard_device = billboard_device{}

    @editable
    DestroyVFX : vfx_spawner_device = vfx_spawner_device{}

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

    var CurrentHealth : float = 0.0
    var IsDestroyed : logic = false

    HealthMsg<localizes>(HP : int, MaxHP : int) : message = "{HP}/{MaxHP}"

    Setup() : void =
        set CurrentHealth = Health
        PropManipulator.DamagedEvent.Subscribe(OnDamaged)
        UpdateDisplay()

    OnDamaged(Agent : agent) : void =
        if (not IsDestroyed?):
            if (InPlayer := player[Agent]):
                BaseDamage := CalculateDamageForPlayer(InPlayer)
                var EffectiveDamage : float = BaseDamage * (1.0 - Defense / 100.0)
                if (EffectiveDamage < 1.0):
                    set EffectiveDamage = 1.0
                set CurrentHealth = CurrentHealth - EffectiveDamage
                UpdateDisplay()
                if (CurrentHealth <= 0.0):
                    DestroyEnemy(InPlayer)

    DestroyEnemy(InPlayer : player) : void =
        set IsDestroyed = true
        GainSnowForPlayer(InPlayer, SnowReward)
        GainXPForPlayer(InPlayer, XPReward)
        DestroyVFX.Restart()
        PropManipulator.HideProps()
        spawn{RespawnEnemy()}

    RespawnEnemy()<suspends> : void =
        Sleep(RespawnDelay)
        set CurrentHealth = Health
        set IsDestroyed = false
        PropManipulator.ShowProps()
        UpdateDisplay()

    UpdateDisplay() : void =
        if (HP := Int[CurrentHealth]):
            if (MaxHP := Int[Health]):
                HealthBillboard.SetText(HealthMsg(HP, MaxHP))

#===============================================================================
# SNOW EGG CONFIG - Classe concrete pour les stations d'oeufs
#===============================================================================
# Ajoutez des stations avec "+" dans le tableau EggStations du Manager

snow_egg_config<public> := class<concrete>:

    @editable
    PurchaseButton : button_device = button_device{}

    @editable
    CostBillboard : billboard_device = billboard_device{}

    @editable
    HatchVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    ResultHUD : hud_message_device = hud_message_device{}

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

    var IsHatching : logic = false

    CostMsg<localizes>(Amount : float) : message = "Cost: {Amount} Snow"
    HatchingMsg<localizes> : message = "Hatching..."
    ResultMsg<localizes>(RarityStr : string) : message = "You got a {RarityStr} pet!"

    Setup() : void =
        CostBillboard.SetText(CostMsg(Cost))
        PurchaseButton.InteractedWithEvent.Subscribe(OnPurchase)

    OnPurchase(Agent : agent) : void =
        if (not IsHatching?):
            if (InPlayer := player[Agent]):
                if (TryRemoveSnow[InPlayer, Cost]):
                    spawn{PerformHatch(InPlayer)}

    PerformHatch(InPlayer : player)<suspends> : void =
        set IsHatching = true
        CostBillboard.SetText(HatchingMsg)
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
        ResultHUD.SetText(ResultMsg(RarityStr))
        ResultHUD.Show(InPlayer)

        set IsHatching = false
        CostBillboard.SetText(CostMsg(Cost))

#===============================================================================
# SNOW ZONE CONFIG - Classe concrete pour les portes de zone
#===============================================================================
# Ajoutez des portes avec "+" dans le tableau ZoneGates du Manager

snow_zone_config<public> := class<concrete>:

    @editable
    UnlockButton : button_device = button_device{}

    @editable
    GateProp : creative_prop = creative_prop{}

    @editable
    InfoBillboard : billboard_device = billboard_device{}

    @editable
    UnlockVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    TeleportOnUnlock : teleporter_device = teleporter_device{}

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

    Setup() : void =
        set OriginalPosition = GateProp.GetTransform().Translation
        InfoBillboard.SetText(CostInfoMsg(UnlockCost, RequiredLevel))
        UnlockButton.InteractedWithEvent.Subscribe(OnUnlockAttempt)

    OnUnlockAttempt(Agent : agent) : void =
        if (not IsUnlocked?):
            if (InPlayer := player[Agent]):
                PlayerLevel := GetLevel(InPlayer)
                if (PlayerLevel >= RequiredLevel):
                    if (TryRemoveSnow[InPlayer, UnlockCost]):
                        AddUnlockedZone(InPlayer, ZoneID)
                        UnlockGate(InPlayer)
                else:
                    InfoBillboard.SetText(LockedInfoMsg)
                    spawn{ResetInfoDisplay()}

    CheckPlayerUnlock<public>(InPlayer : player) : void =
        if (IsZoneUnlocked[InPlayer, ZoneID]):
            OpenGate()

    UnlockGate(InPlayer : player) : void =
        set IsUnlocked = true
        UnlockVFX.Restart()
        OpenGate()
        TeleportOnUnlock.Teleport(InPlayer)

    OpenGate() : void =
        HidePos := OriginalPosition - vector3{Z := 10000.0}
        if (GateProp.TeleportTo[HidePos, GateProp.GetTransform().Rotation]) {}
        InfoBillboard.SetText(UnlockedInfoMsg)

    ResetInfoDisplay()<suspends> : void =
        Sleep(2.0)
        InfoBillboard.SetText(CostInfoMsg(UnlockCost, RequiredLevel))

#===============================================================================
# SNOW REBIRTH CONFIG - Classe concrete pour les shrines de prestige
#===============================================================================
# Ajoutez des shrines avec "+" dans le tableau RebirthShrines du Manager

snow_rebirth_config<public> := class<concrete>:

    @editable
    InteractButton : button_device = button_device{}

    @editable
    CostBillboard : billboard_device = billboard_device{}

    @editable
    BonusBillboard : billboard_device = billboard_device{}

    @editable
    RebirthVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    SuccessHUD : hud_message_device = hud_message_device{}

    @editable
    TeleportAfter : teleporter_device = teleporter_device{}

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

    Setup() : void =
        CostBillboard.SetText(RebirthCostMsg(RequiredSnow, RequiredPlayerLevel))
        BonusBillboard.SetText(RebirthBonusMsg(DamageBonus, SpeedBonus, CurrencyBonus))
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
                        SuccessHUD.SetText(RebirthSuccessMsg(RebirthLevel))
                        SuccessHUD.Show(InPlayer)
                        TeleportAfter.Teleport(InPlayer)
                    else:
                        ShowFailMessage()
                else:
                    ShowFailMessage()
            else:
                ShowFailMessage()

    ShowFailMessage() : void =
        CostBillboard.SetText(RebirthFailMsg)
        spawn{ResetDisplay()}

    ResetDisplay()<suspends> : void =
        Sleep(2.0)
        CostBillboard.SetText(RebirthCostMsg(RequiredSnow, RequiredPlayerLevel))

#===============================================================================
# SNOW UPGRADE CONFIG - Classe concrete pour les stations d'upgrade
#===============================================================================
# Ajoutez des stations avec "+" dans le tableau UpgradeStations du Manager

snow_upgrade_config<public> := class<concrete>:

    @editable
    PurchaseButton : button_device = button_device{}

    @editable
    NameBillboard : billboard_device = billboard_device{}

    @editable
    LevelBillboard : billboard_device = billboard_device{}

    @editable
    CostBillboard : billboard_device = billboard_device{}

    @editable
    UpgradeVFX : vfx_spawner_device = vfx_spawner_device{}

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

    Setup() : void =
        NameBillboard.SetText(UpgradeNameMsg(UpgradeName))
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
                    CostBillboard.SetText(UpgradeFailMsg)
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
        LevelBillboard.SetText(UpgradeLevelMsg(CurrentLevel))
        if (CurrentLevel >= MaxLevel):
            CostBillboard.SetText(UpgradeMaxedMsg)
        else:
            TheCost := CalculateCost()
            CostBillboard.SetText(UpgradeCostMsg(TheCost))

    ResetCostDisplay()<suspends> : void =
        Sleep(1.5)
        UpdateDisplay()
