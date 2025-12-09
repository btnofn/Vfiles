using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#══════════════════════════════════════════════════════════════════════════════
# SIMULATOR MAIN - Manager principal du système Snow Simulator
#══════════════════════════════════════════════════════════════════════════════
#
# Ce fichier est le point d'entrée principal du système Simulator.
# Il orchestre tous les sous-systèmes et gère le cycle de vie des joueurs.
#
# ARCHITECTURE:
# ┌─────────────────────────────────────────────────────────────────────────┐
# │                    SIMULATOR MAIN (ce fichier)                         │
# ├─────────────────────────────────────────────────────────────────────────┤
# │  Manages: Players, Events, Lifecycle                                   │
# │                                                                         │
# │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐     │
# │  │Breakables│ │   Pets   │ │   Eggs   │ │  Zones   │ │ Rebirth  │     │
# │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘     │
# │                                                                         │
# │  ┌──────────┐ ┌──────────┐ ┌──────────┐                               │
# │  │   Shop   │ │    UI    │ │Persistence│                               │
# │  └──────────┘ └──────────┘ └──────────┘                               │
# └─────────────────────────────────────────────────────────────────────────┘
#
#══════════════════════════════════════════════════════════════════════════════

simulator_main := class(creative_device):

    #──────────────────────────────────────────────────────────────────────────
    # RÉFÉRENCES AUX SOUS-SYSTÈMES (à connecter dans l'éditeur)
    #──────────────────────────────────────────────────────────────────────────
    @editable
    BreakableManager : simulator_breakable_manager = simulator_breakable_manager{}

    @editable
    PetManager : simulator_pet_manager = simulator_pet_manager{}

    @editable
    EggManager : simulator_egg_manager = simulator_egg_manager{}

    @editable
    ZoneManager : simulator_zone_manager = simulator_zone_manager{}

    @editable
    RebirthManager : simulator_rebirth_manager = simulator_rebirth_manager{}

    @editable
    ShopManager : simulator_shop_manager = simulator_shop_manager{}

    @editable
    MainHUD : simulator_hud = simulator_hud{}

    @editable
    LevelUpCelebration : level_up_celebration = level_up_celebration{}

    @editable
    PetObtainedDisplay : pet_obtained_display = pet_obtained_display{}

    @editable
    RebirthCelebration : rebirth_celebration = rebirth_celebration{}

    @editable
    SnowGainDisplay : snow_gain_display = snow_gain_display{}

    #──────────────────────────────────────────────────────────────────────────
    # CONFIGURATION GLOBALE
    #──────────────────────────────────────────────────────────────────────────
    @editable
    StartingSnow : float = 0.0

    @editable
    PlaytimeTrackingInterval : float = 1.0

    @editable
    DebugMode : logic = false

    @editable
    WelcomeMessage : hud_message_device = hud_message_device{}

    @editable
    StartSpawner : player_spawner_device = player_spawner_device{}

    #──────────────────────────────────────────────────────────────────────────
    # ÉVÉNEMENTS GLOBAUX
    #──────────────────────────────────────────────────────────────────────────
    var OnPlayerInitialized : event(player) = event(player){}
    var OnPlayerRemoved : event(player) = event(player){}
    var OnGlobalLevelUp : event(player, int) = event(player, int){}
    var OnGlobalRebirth : event(player, int) = event(player, int){}

    # Messages
    WelcomeMsg<localizes>(Name : string) : message = "Welcome to Snow Simulator, {Name}!"
    DebugMsg<localizes>(Info : string) : message = "[DEBUG] {Info}"

    #══════════════════════════════════════════════════════════════════════════
    # INITIALISATION
    #══════════════════════════════════════════════════════════════════════════
    OnBegin<override>()<suspends> : void =
        Log("Snow Simulator - Initializing...")

        # Subscribe aux événements de joueurs
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

        # Initialise les joueurs déjà présents
        for (Player : GetPlayspace().GetPlayers()):
            InitializePlayer(Player)

        # Connecte les événements entre sous-systèmes
        ConnectSubsystemEvents()

        # Démarre la boucle de tracking du temps de jeu
        spawn{PlaytimeTrackingLoop()}

        # Démarre la boucle de sauvegarde automatique
        spawn{AutoSaveLoop()}

        Log("Snow Simulator - Ready!")

    #══════════════════════════════════════════════════════════════════════════
    # GESTION DES JOUEURS
    #══════════════════════════════════════════════════════════════════════════
    OnPlayerJoined(Player : player) : void =
        InitializePlayer(Player)

    OnPlayerLeft(Player : player) : void =
        CleanupPlayer(Player)

    InitializePlayer(Player : player) : void =
        Log("Initializing player...")

        # Crée le simulator_player
        SimPlayer := GetOrCreateSimulatorPlayer(Player)
        SimPlayer.Initialize()

        # Donne la neige de départ si nouveau joueur
        if (Data := GetFullData(Player)):
            if (Data.TotalSnowEarned = 0.0 and StartingSnow > 0.0):
                AddSnow(Player, StartingSnow)

        # Met à jour le fort character
        SimPlayer.UpdateFortCharacter()

        # Subscribe aux événements du joueur
        SimPlayer.OnLevelUp.Subscribe(HandlePlayerLevelUp(Player))
        SimPlayer.OnSnowGained.Subscribe(HandlePlayerSnowGained(Player))
        SimPlayer.OnRebirthCompleted.Subscribe(HandlePlayerRebirth(Player))

        # Affiche le message de bienvenue
        WelcomeMessage.SetText(WelcomeMsg("Player"))
        WelcomeMessage.Show(Player)

        # Signal l'événement
        OnPlayerInitialized.Signal(Player)

        Log("Player initialized successfully")

    CleanupPlayer(Player : player) : void =
        Log("Cleaning up player...")

        # Despawn les pets
        PetManager.DespawnAllPetsForPlayer(Player)

        # Supprime le simulator_player
        RemoveSimulatorPlayer(Player)

        # Signal l'événement
        OnPlayerRemoved.Signal(Player)

        Log("Player cleaned up")

    #══════════════════════════════════════════════════════════════════════════
    # HANDLERS D'ÉVÉNEMENTS JOUEUR
    #══════════════════════════════════════════════════════════════════════════
    HandlePlayerLevelUp(Player : player)(NewLevel : int) : void =
        # Déclenche la célébration
        LevelUpCelebration.TriggerCelebration(Player, NewLevel)

        # Signal l'événement global
        OnGlobalLevelUp.Signal(Player, NewLevel)

        if (DebugMode?):
            Log("Player leveled up to {NewLevel}")

    HandlePlayerSnowGained(Player : player)(Amount : float) : void =
        # Affiche le gain
        SnowGainDisplay.ShowGain(Player, Amount)

    HandlePlayerRebirth(Player : player)(RebirthLevel : int) : void =
        # Obtient les bonus
        if (Config := GetRebirthConfig(RebirthLevel)):
            # Déclenche la célébration
            RebirthCelebration.TriggerCelebration(Player, RebirthLevel, Config.DamageBonus, Config.SpeedBonus, Config.CurrencyBonus)

        # Signal l'événement global
        OnGlobalRebirth.Signal(Player, RebirthLevel)

        if (DebugMode?):
            Log("Player completed rebirth {RebirthLevel}")

    #══════════════════════════════════════════════════════════════════════════
    # CONNEXION DES SOUS-SYSTÈMES
    #══════════════════════════════════════════════════════════════════════════
    ConnectSubsystemEvents() : void =
        # Breakables -> Snow & XP
        BreakableManager.OnAnyBreakableDestroyed.Subscribe(HandleBreakableDestroyed)

        # Eggs -> Pet Display
        EggManager.OnEggHatched.Subscribe(HandleEggHatched)

        # Zones -> Diverses notifications
        ZoneManager.OnZoneUnlocked.Subscribe(HandleZoneUnlocked)

    HandleBreakableDestroyed(Agent : agent, Breakable : simulator_breakable, Reward : float) : void =
        # Le snow est déjà ajouté dans le breakable
        # Ici on peut ajouter des effets supplémentaires
        if (DebugMode?):
            if (Player := player[Agent]):
                Log("Breakable destroyed, reward: {Reward}")

    HandleEggHatched(Player : player, Result : hatch_result) : void =
        if (Result.Success?):
            # Obtient le nom du pet
            if (PetConfig := PetManager.GetPetTypeByID(Result.PetID)):
                PetObtainedDisplay.ShowPetObtained(Player, PetConfig.Name, Result.Rarity)

    HandleZoneUnlocked(Player : player, ZoneID : int) : void =
        if (DebugMode?):
            Log("Zone {ZoneID} unlocked")

    #══════════════════════════════════════════════════════════════════════════
    # BOUCLES DE FOND
    #══════════════════════════════════════════════════════════════════════════
    PlaytimeTrackingLoop()<suspends> : void =
        loop:
            Sleep(PlaytimeTrackingInterval)
            for (Player : GetPlayspace().GetPlayers()):
                UpdatePlaytime(Player, PlaytimeTrackingInterval)

    AutoSaveLoop()<suspends> : void =
        # Les données sont sauvegardées automatiquement via la persistence
        # Cette boucle est un placeholder pour des sauvegardes supplémentaires
        loop:
            Sleep(60.0)  # Toutes les minutes
            if (DebugMode?):
                Log("Auto-save check...")

    #══════════════════════════════════════════════════════════════════════════
    # FONCTIONS UTILITAIRES
    #══════════════════════════════════════════════════════════════════════════
    Log(Message : string) : void =
        Print("❄ Snow Simulator: {Message}")

    #══════════════════════════════════════════════════════════════════════════
    # API PUBLIQUE (pour intégration avec d'autres systèmes)
    #══════════════════════════════════════════════════════════════════════════

    # Obtient un joueur simulator
    GetPlayer(Player : player) : ?simulator_player =
        GetSimulatorPlayer(Player)

    # Donne de la neige à un joueur
    GiveSnow(Player : player, Amount : float) : void =
        AddSnow(Player, Amount)

    # Donne de l'XP à un joueur
    GiveXP(Player : player, Amount : float) : void =
        if (SimPlayer := GetSimulatorPlayer(Player)):
            SimPlayer.GainXP(Amount)

    # Donne un pet à un joueur
    GivePet(Player : player, PetID : int) : void =
        AddPet(Player, PetID)

    # Téléporte un joueur à une zone
    TeleportToZone(Player : player, ZoneID : int) : logic =
        ZoneManager.TeleportPlayerToZone(Player, ZoneID)

    # Obtient les stats d'un joueur
    GetPlayerStats(Player : player) : ?tuple(Snow : float, Level : int, Rebirths : int, Damage : float) =
        if (Data := GetFullData(Player)):
            if (SimPlayer := GetSimulatorPlayer(Player)):
                return option{(Snow := Data.Snow, Level := Data.Level, Rebirths := Data.RebirthCount, Damage := SimPlayer.TotalDamage)}
        false

#══════════════════════════════════════════════════════════════════════════════
# DEVICE SIMPLIFIÉ (Version légère pour tests rapides)
#══════════════════════════════════════════════════════════════════════════════
simulator_simple := class(creative_device):
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
    RespawnTime : float = 3.0

    var CurrentHP : float = 0.0
    var OriginalPosition : vector3 = vector3{}

    SnowMsg<localizes>(Amount : float) : message = "Snow: {Amount}"
    LevelMsg<localizes>(Level : int) : message = "Level: {Level}"
    HPMsg<localizes>(HP : int, Max : int) : message = "{HP}/{Max}"

    OnBegin<override>()<suspends> : void =
        set CurrentHP = BreakableHP
        set OriginalPosition = BreakableProp.GetTransform().Translation

        # Initialise les joueurs
        for (Player : GetPlayspace().GetPlayers()):
            LoadOrCreatePlayerData(Player)
            GetOrCreateSimulatorPlayer(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        DamageTrigger.TriggeredEvent.Subscribe(OnDamage)

        # Boucle de mise à jour HUD
        spawn{UpdateHUDLoop()}

    OnPlayerJoined(Player : player) : void =
        LoadOrCreatePlayerData(Player)
        GetOrCreateSimulatorPlayer(Player)

    OnDamage(MaybeAgent : ?agent) : void =
        if (Agent := MaybeAgent?):
            if (Player := player[Agent]):
                if (SimPlayer := GetSimulatorPlayer(Player)):
                    # Applique les dégâts
                    DmgResult := SimPlayer.CalculateDamage()
                    set CurrentHP -= DmgResult.Damage

                    if (CurrentHP <= 0.0):
                        # Récompense
                        SimPlayer.GainSnow(BreakableReward)
                        SimPlayer.GainXP(1.0)

                        # Reset
                        HidePos := OriginalPosition - vector3{Z := 10000.0}
                        if (BreakableProp.TeleportTo[HidePos, BreakableProp.GetTransform().Rotation]) {}

                        spawn{RespawnBreakable()}

    RespawnBreakable()<suspends> : void =
        Sleep(RespawnTime)
        set CurrentHP = BreakableHP
        if (BreakableProp.TeleportTo[OriginalPosition, BreakableProp.GetTransform().Rotation]) {}

    UpdateHUDLoop()<suspends> : void =
        loop:
            Sleep(0.1)
            for (Player : GetPlayspace().GetPlayers()):
                if (Data := GetFullData(Player)):
                    SnowHUD.SetText(SnowMsg(Data.Snow))
                    SnowHUD.Show(Player)
                    LevelHUD.SetText(LevelMsg(Data.Level))
                    LevelHUD.Show(Player)

#══════════════════════════════════════════════════════════════════════════════
# GUIDE D'UTILISATION
#══════════════════════════════════════════════════════════════════════════════
#
# 1. MISE EN PLACE DE BASE:
#    - Place un simulator_main dans ta map
#    - Connecte tous les managers dans l'éditeur
#    - Place des breakables avec simulator_breakable_trigger
#    - Place des egg_station pour les oeufs
#    - Place des zone_gate pour les gates
#    - Place des rebirth_shrine pour les rebirths
#    - Place des upgrade_station pour le shop
#
# 2. CONFIGURATION:
#    - Modifie DefaultZoneConfigs dans Simulator_Types.verse
#    - Modifie DefaultRebirthConfigs pour les bonus de rebirth
#    - Modifie DefaultUpgradeConfigs pour les upgrades
#    - Modifie DefaultRarityConfigs pour les chances de pets
#
# 3. AJOUT DE PETS:
#    - Crée des pet_type_config dans le PetManager
#    - Configure les rarités et bonus
#    - Associe les props visuels
#
# 4. AJOUT D'OEUFS:
#    - Crée des egg_type_config dans le EggManager
#    - Configure les probabilités par rareté
#    - Liste les PetIDs possibles par rareté
#
# 5. TEST RAPIDE:
#    - Utilise simulator_simple pour tester le core loop
#    - Active DebugMode dans simulator_main pour les logs
#
#══════════════════════════════════════════════════════════════════════════════
