using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# SIMULATOR PLAYER - Classe joueur

simulator_player<public> := class:
    Player<public> : player

    var TotalDamage<public> : float = 1.0
    var TotalCurrencyMultiplier<public> : float = 1.0
    var CritChance<public> : float = 0.0
    var CritDamage<public> : float = 2.0
    var MaxEquippedPets<public> : int = 3

    Initialize<public>()<transacts> : void =
        LoadOrCreatePlayerData(Player)
        RecalculateStats()

    RecalculateStats<public>() : void =
        Bonuses := GetRebirthBonuses(Player)
        set TotalDamage = SimulatorConstants.BaseDamage * (1.0 + Bonuses.Damage / 100.0)
        set TotalCurrencyMultiplier = 1.0 * (1.0 + Bonuses.Currency / 100.0)

    CalculateDamage<public>() : tuple(Damage : float, IsCrit : logic) =
        RandomValue := GetRandomFloat(0.0, 100.0)
        if (RandomValue <= CritChance):
            (Damage := TotalDamage * CritDamage, IsCrit := true)
        else:
            (Damage := TotalDamage, IsCrit := false)

    GainSnow<public>(BaseAmount : float)<transacts> : float =
        FinalAmount := BaseAmount * TotalCurrencyMultiplier
        AddSnow(Player, FinalAmount)
        FinalAmount

    GainXP<public>(Amount : float)<transacts> : void =
        AddXP(Player, Amount)

    GetCurrentSnow<public>() : float =
        GetSnow(Player)

    GetCurrentLevel<public>() : int =
        GetLevel(Player)

    GetCurrentRebirths<public>() : int =
        GetRebirthCount(Player)

var SimulatorPlayers<public> : [player]simulator_player = map{}

GetOrCreateSimulatorPlayer<public>(InPlayer : player) : simulator_player =
    if (ExistingPlayer := SimulatorPlayers[InPlayer]):
        ExistingPlayer
    else:
        NewSimPlayer := simulator_player{Player := InPlayer}
        NewSimPlayer.Initialize()
        if (set SimulatorPlayers[InPlayer] = NewSimPlayer) {}
        NewSimPlayer

GetSimulatorPlayer<public>(InPlayer : player) : ?simulator_player =
    if (SimPlayer := SimulatorPlayers[InPlayer]):
        option{SimPlayer}
    else:
        false

RemoveSimulatorPlayer<public>(InPlayer : player) : void =
    var NewMap : [player]simulator_player = map{}
    for (Key -> Value : SimulatorPlayers):
        if (Key <> InPlayer):
            if (set NewMap[Key] = Value) {}
    set SimulatorPlayers = NewMap
