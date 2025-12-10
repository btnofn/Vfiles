using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# SIMULATOR MAIN - Manager principal du système Snow Simulator

# Device principal
simulator_main<public> := class(creative_device):

    @editable
    WelcomeHUD : hud_message_device = hud_message_device{}

    @editable
    SnowHUD : hud_message_device = hud_message_device{}

    @editable
    LevelHUD : hud_message_device = hud_message_device{}

    @editable
    RebirthHUD : hud_message_device = hud_message_device{}

    @editable
    StartingSnow : float = 0.0

    @editable
    HUDUpdateInterval : float = 0.1

    @editable
    DebugMode : logic = false

    WelcomeMsg<localizes> : message = "Welcome to Snow Simulator!"
    SnowMsg<localizes>(Amount : string) : message = "Snow: {Amount}"
    LevelMsg<localizes>(Level : int, XP : int, XPMax : int) : message = "Level {Level} - XP: {XP}/{XPMax}"
    RebirthMsg<localizes>(Count : int) : message = "Rebirth: {Count}"

    OnBegin<override>()<suspends> : void =
        Print("Snow Simulator - Starting...")

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

        for (Player : GetPlayspace().GetPlayers()):
            InitializePlayer(Player)

        spawn{HUDUpdateLoop()}

        Print("Snow Simulator - Ready!")

    OnPlayerJoined(Player : player) : void =
        InitializePlayer(Player)

    OnPlayerLeft(Player : player) : void =
        RemoveSimulatorPlayer(Player)
        Print("Player left")

    InitializePlayer(Player : player) : void =
        Print("Initializing player...")

        SimPlayer := GetOrCreateSimulatorPlayer(Player)

        if (Data := GetFullData(Player)):
            if (Data.TotalSnowEarned = 0.0):
                if (StartingSnow > 0.0):
                    AddSnow(Player, StartingSnow)

        WelcomeHUD.Show(Player)

        Print("Player initialized")

    HUDUpdateLoop()<suspends> : void =
        loop:
            Sleep(HUDUpdateInterval)
            for (Player : GetPlayspace().GetPlayers()):
                UpdatePlayerHUD(Player)

    UpdatePlayerHUD(Player : player) : void =
        if (Data := GetFullData(Player)):
            SnowFormatted := FormatNumber(Data.Snow)
            SnowHUD.SetText(SnowMsg(SnowFormatted))
            SnowHUD.Show(Player)

            XPRequired := GetXPForLevel(Data.Level)
            if (XPInt := Int[Data.CurrentXP]):
                if (XPReqInt := Int[XPRequired]):
                    LevelHUD.SetText(LevelMsg(Data.Level, XPInt, XPReqInt))
                    LevelHUD.Show(Player)

            RebirthHUD.SetText(RebirthMsg(Data.RebirthCount))
            RebirthHUD.Show(Player)

# Version simplifiée tout-en-un pour tests rapides
simulator_simple<public> := class(creative_device):
    @editable
    DamageTrigger : trigger_device = trigger_device{}

    @editable
    SnowHUD : hud_message_device = hud_message_device{}

    @editable
    LevelHUD : hud_message_device = hud_message_device{}

    @editable
    BreakableProp : creative_prop = creative_prop{}

    @editable
    BreakableHP : float = 10.0

    @editable
    BreakableReward : float = 1.0

    @editable
    XPReward : float = 1.0

    @editable
    RespawnTime : float = 3.0

    var CurrentHP : float = 0.0
    var IsDestroyed : logic = false
    var OriginalPosition : vector3 = vector3{}
    var OriginalRotation : rotation = rotation{}

    SnowMsg<localizes>(Amount : string) : message = "Snow: {Amount}"
    LevelMsg<localizes>(Level : int) : message = "Level: {Level}"

    OnBegin<override>()<suspends> : void =
        set CurrentHP = BreakableHP
        set OriginalPosition = BreakableProp.GetTransform().Translation
        set OriginalRotation = BreakableProp.GetTransform().Rotation

        for (Player : GetPlayspace().GetPlayers()):
            LoadOrCreatePlayerData(Player)
            GetOrCreateSimulatorPlayer(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        DamageTrigger.TriggeredEvent.Subscribe(OnDamage)

        spawn{UpdateHUDLoop()}

    OnPlayerJoined(Player : player) : void =
        LoadOrCreatePlayerData(Player)
        GetOrCreateSimulatorPlayer(Player)

    OnDamage(MaybeAgent : ?agent) : void =
        if (IsDestroyed?):
            return
        if (Agent := MaybeAgent?):
            if (Player := player[Agent]):
                if (SimPlayer := GetSimulatorPlayer(Player)):
                    DmgResult := SimPlayer.CalculateDamage()
                    set CurrentHP = CurrentHP - DmgResult.Damage

                    if (CurrentHP <= 0.0):
                        set IsDestroyed = true
                        SimPlayer.GainSnow(BreakableReward)
                        SimPlayer.GainXP(XPReward)

                        HidePos := OriginalPosition - vector3{Z := 10000.0}
                        if (BreakableProp.TeleportTo[HidePos, OriginalRotation]) {}

                        spawn{RespawnBreakable()}

    RespawnBreakable()<suspends> : void =
        Sleep(RespawnTime)
        set CurrentHP = BreakableHP
        set IsDestroyed = false
        if (BreakableProp.TeleportTo[OriginalPosition, OriginalRotation]) {}

    UpdateHUDLoop()<suspends> : void =
        loop:
            Sleep(0.1)
            for (Player : GetPlayspace().GetPlayers()):
                if (Data := GetFullData(Player)):
                    SnowFormatted := FormatNumber(Data.Snow)
                    SnowHUD.SetText(SnowMsg(SnowFormatted))
                    SnowHUD.Show(Player)
                    LevelHUD.SetText(LevelMsg(Data.Level))
                    LevelHUD.Show(Player)
