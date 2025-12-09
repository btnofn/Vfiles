using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#══════════════════════════════════════════════════════════════════════════════
# SIMULATOR REBIRTH - Système de prestige avec bonus permanents
#══════════════════════════════════════════════════════════════════════════════

#──────────────────────────────────────────────────────────────────────────────
# STATUE DE REBIRTH (Device placé dans le monde)
#──────────────────────────────────────────────────────────────────────────────
rebirth_shrine := class(creative_device):
    @editable
    RebirthLevel : int = 1  # Quel rebirth cette statue débloque

    @editable
    InteractButton : button_device = button_device{}

    @editable
    ShrineProp : creative_prop = creative_prop{}

    @editable
    CostBillboard : billboard_device = billboard_device{}

    @editable
    BonusBillboard : billboard_device = billboard_device{}

    @editable
    RequirementsBillboard : billboard_device = billboard_device{}

    @editable
    RebirthVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    RebirthAudio : audio_player_device = audio_player_device{}

    @editable
    ConfirmationPopup : popup_dialog_device = popup_dialog_device{}

    @editable
    SuccessHUD : hud_message_device = hud_message_device{}

    @editable
    TeleportAfterRebirth : teleporter_device = teleporter_device{}

    @editable
    ZoneManager : ?simulator_zone_manager = false

    @editable
    PetManager : ?simulator_pet_manager = false

    # Messages localisés
    CostMsg<localizes>(Snow : float) : message = "Cost: {Snow} Snow"
    BonusMsg<localizes>(DMG : float, SPD : float, CURR : float) : message = "+{DMG}% DMG | +{SPD}% Speed | +{CURR}% Snow"
    LevelReqMsg<localizes>(Level : int) : message = "Requires Level {Level}"
    AlreadyRebirthMsg<localizes> : message = "Already Rebirthed!"
    NotEnoughMsg<localizes> : message = "Requirements not met!"
    SuccessMsg<localizes>(Level : int, Message : string) : message = "REBIRTH {Level}! {Message}"

    var Config : ?rebirth_config = false

    OnBegin<override>()<suspends> : void =
        # Charge la config
        set Config = GetRebirthConfig(RebirthLevel)
        UpdateDisplay()
        InteractButton.InteractedWithEvent.Subscribe(OnRebirthAttempt)

    UpdateDisplay() : void =
        if (Cfg := Config?):
            CostBillboard.SetText(CostMsg(Cfg.RequiredSnow))
            BonusBillboard.SetText(BonusMsg(Cfg.DamageBonus, Cfg.SpeedBonus, Cfg.CurrencyBonus))
            RequirementsBillboard.SetText(LevelReqMsg(Cfg.RequiredLevel))

    OnRebirthAttempt(Agent : agent) : void =
        if (Player := player[Agent]):
            if (Cfg := Config?):
                if (SimPlayer := GetSimulatorPlayer(Player)):
                    # Vérifie si le joueur peut rebirth
                    Result := CanRebirth(Player, Cfg)

                    case (Result):
                        rebirth_check_result.CanRebirth =>
                            # Effectue le rebirth
                            PerformRebirth(Player, SimPlayer, Cfg)
                        rebirth_check_result.AlreadyDone =>
                            RequirementsBillboard.SetText(AlreadyRebirthMsg)
                        rebirth_check_result.NotEnoughSnow =>
                            RequirementsBillboard.SetText(NotEnoughMsg)
                        rebirth_check_result.LevelTooLow =>
                            RequirementsBillboard.SetText(NotEnoughMsg)
                        _ =>
                            RequirementsBillboard.SetText(NotEnoughMsg)

                    spawn{ResetDisplayAfterDelay()}

    CanRebirth(Player : player, Cfg : rebirth_config) : rebirth_check_result =
        if (Data := GetFullData(Player)):
            # Vérifie si déjà fait ce rebirth
            if (Data.RebirthCount >= Cfg.RebirthLevel):
                return rebirth_check_result.AlreadyDone

            # Vérifie si c'est le bon rebirth (doit être séquentiel)
            if (Data.RebirthCount <> Cfg.RebirthLevel - 1):
                return rebirth_check_result.WrongOrder

            # Vérifie le niveau
            if (Data.Level < Cfg.RequiredLevel):
                return rebirth_check_result.LevelTooLow

            # Vérifie la neige
            if (Data.Snow < Cfg.RequiredSnow):
                return rebirth_check_result.NotEnoughSnow

            rebirth_check_result.CanRebirth
        else:
            rebirth_check_result.NotEnoughSnow

    PerformRebirth(Player : player, SimPlayer : simulator_player, Cfg : rebirth_config) : void =
        # Effectue le rebirth via le SimPlayer
        if (SimPlayer.TryRebirth(Cfg)):
            # Effets visuels et audio
            RebirthVFX.Restart()
            RebirthAudio.Play()

            # Message de succès
            SuccessHUD.SetText(SuccessMsg(Cfg.RebirthLevel, Cfg.UnlockMessage))
            SuccessHUD.Show(Player)

            # Reset les pets visuels
            if (PM := PetManager?):
                PM.DespawnAllPetsForPlayer(Player)

            # Reset les zones
            if (ZM := ZoneManager?):
                ZM.ResetZonesForPlayer(Player)

            # Téléporte au spawn
            TeleportAfterRebirth.Teleport(Player)

    ResetDisplayAfterDelay()<suspends> : void =
        Sleep(3.0)
        UpdateDisplay()

#──────────────────────────────────────────────────────────────────────────────
# ENUM RÉSULTAT DE VÉRIFICATION
#──────────────────────────────────────────────────────────────────────────────
rebirth_check_result := enum:
    CanRebirth
    AlreadyDone
    WrongOrder
    LevelTooLow
    NotEnoughSnow

#══════════════════════════════════════════════════════════════════════════════
# REBIRTH MANAGER - Gère tous les rebirths
#══════════════════════════════════════════════════════════════════════════════
simulator_rebirth_manager := class(creative_device):

    @editable
    RebirthShrines : []rebirth_shrine = array{}

    @editable
    ZoneManager : simulator_zone_manager = simulator_zone_manager{}

    @editable
    PetManager : simulator_pet_manager = simulator_pet_manager{}

    @editable
    GlobalRebirthHUD : hud_message_device = hud_message_device{}

    # Événements
    var OnRebirthCompleted : event(player, int) = event(player, int){}

    RebirthAnnounceMsg<localizes>(PlayerName : string, Level : int) : message = "{PlayerName} achieved Rebirth {Level}!"

    OnBegin<override>()<suspends> : void =
        # Configure les shrines avec les managers
        for (Shrine : RebirthShrines):
            set Shrine.ZoneManager = option{ZoneManager}
            set Shrine.PetManager = option{PetManager}

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR LE PROCHAIN REBIRTH DISPONIBLE
    #──────────────────────────────────────────────────────────────────────────
    GetNextRebirthForPlayer(Player : player) : ?rebirth_config =
        CurrentRebirths := GetRebirthCount(Player)
        NextLevel := CurrentRebirths + 1
        GetRebirthConfig(NextLevel)

    #──────────────────────────────────────────────────────────────────────────
    # VÉRIFIER SI UN JOUEUR PEUT REBIRTH
    #──────────────────────────────────────────────────────────────────────────
    CanPlayerRebirth(Player : player) : logic =
        if (NextRebirth := GetNextRebirthForPlayer(Player)):
            if (Data := GetFullData(Player)):
                LevelOK := Data.Level >= NextRebirth.RequiredLevel
                SnowOK := Data.Snow >= NextRebirth.RequiredSnow
                LevelOK and SnowOK
            else:
                false
        else:
            false  # Pas de rebirth suivant disponible

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR LES BONUS TOTAUX DE REBIRTH
    #──────────────────────────────────────────────────────────────────────────
    GetTotalRebirthBonuses(Player : player) : tuple(Damage : float, Speed : float, Currency : float) =
        GetRebirthBonuses(Player)

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR LE MULTIPLICATEUR DE REBIRTH
    #──────────────────────────────────────────────────────────────────────────
    GetRebirthMultiplier(Player : player, StatType : rebirth_stat_type) : float =
        Bonuses := GetRebirthBonuses(Player)
        case (StatType):
            rebirth_stat_type.Damage => 1.0 + (Bonuses.Damage / 100.0)
            rebirth_stat_type.Speed => 1.0 + (Bonuses.Speed / 100.0)
            rebirth_stat_type.Currency => 1.0 + (Bonuses.Currency / 100.0)

#──────────────────────────────────────────────────────────────────────────────
# TYPE DE STAT REBIRTH
#──────────────────────────────────────────────────────────────────────────────
rebirth_stat_type := enum:
    Damage
    Speed
    Currency

#══════════════════════════════════════════════════════════════════════════════
# REBIRTH INFO DISPLAY - Affiche les infos de rebirth du joueur
#══════════════════════════════════════════════════════════════════════════════
rebirth_info_display := class(creative_device):
    @editable
    RebirthCountBillboard : billboard_device = billboard_device{}

    @editable
    BonusesBillboard : billboard_device = billboard_device{}

    @editable
    NextRebirthBillboard : billboard_device = billboard_device{}

    @editable
    UpdateInterval : float = 0.5

    # Messages
    RebirthCountMsg<localizes>(Count : int) : message = "Rebirths: {Count}"
    BonusesMsg<localizes>(DMG : float, SPD : float, CURR : float) : message = "+{DMG}% DMG | +{SPD}% SPD | +{CURR}% Snow"
    NextRebirthMsg<localizes>(Snow : float, Level : int) : message = "Next: {Snow} Snow, Lv.{Level}"
    MaxRebirthMsg<localizes> : message = "MAX REBIRTH!"

    OnBegin<override>()<suspends> : void =
        loop:
            Sleep(UpdateInterval)
            UpdateAllPlayers()

    UpdateAllPlayers() : void =
        for (Player : GetPlayspace().GetPlayers()):
            UpdateForPlayer(Player)

    UpdateForPlayer(Player : player) : void =
        # Rebirth count
        RebirthCount := GetRebirthCount(Player)
        RebirthCountBillboard.SetText(RebirthCountMsg(RebirthCount))

        # Bonus actuels
        Bonuses := GetRebirthBonuses(Player)
        BonusesBillboard.SetText(BonusesMsg(Bonuses.Damage, Bonuses.Speed, Bonuses.Currency))

        # Prochain rebirth
        NextLevel := RebirthCount + 1
        if (NextConfig := GetRebirthConfig(NextLevel)):
            NextRebirthBillboard.SetText(NextRebirthMsg(NextConfig.RequiredSnow, NextConfig.RequiredLevel))
        else:
            NextRebirthBillboard.SetText(MaxRebirthMsg)

#══════════════════════════════════════════════════════════════════════════════
# REBIRTH LEADERBOARD - Classement des rebirths
#══════════════════════════════════════════════════════════════════════════════
rebirth_leaderboard := class(creative_device):
    @editable
    LeaderboardBillboards : []billboard_device = array{}  # Top 10

    @editable
    UpdateInterval : float = 5.0

    @editable
    TitleBillboard : billboard_device = billboard_device{}

    TitleMsg<localizes> : message = "TOP REBIRTHS"
    EntryMsg<localizes>(Rank : int, Name : string, Rebirths : int) : message = "#{Rank} {Name}: {Rebirths}"
    EmptyMsg<localizes> : message = "---"

    OnBegin<override>()<suspends> : void =
        TitleBillboard.SetText(TitleMsg)
        loop:
            Sleep(UpdateInterval)
            UpdateLeaderboard()

    UpdateLeaderboard() : void =
        # Collecte les données de tous les joueurs
        var PlayerData : []tuple(Player : player, Rebirths : int) = array{}

        for (Player : GetPlayspace().GetPlayers()):
            Rebirths := GetRebirthCount(Player)
            set PlayerData += array{(Player := Player, Rebirths := Rebirths)}

        # Trie par nombre de rebirths (décroissant) - Bubble sort simple
        for (I := 0..PlayerData.Length - 1):
            for (J := 0..PlayerData.Length - I - 2):
                if (DataJ := PlayerData[J]):
                    if (DataJ1 := PlayerData[J + 1]):
                        if (DataJ.Rebirths < DataJ1.Rebirths):
                            # Swap
                            var NewData : []tuple(Player : player, Rebirths : int) = array{}
                            for (K := 0..PlayerData.Length - 1):
                                if (K = J):
                                    set NewData += array{DataJ1}
                                else if (K = J + 1):
                                    set NewData += array{DataJ}
                                else:
                                    if (DataK := PlayerData[K]):
                                        set NewData += array{DataK}
                            set PlayerData = NewData

        # Met à jour les billboards
        for (Index := 0..LeaderboardBillboards.Length - 1):
            if (Billboard := LeaderboardBillboards[Index]):
                if (Data := PlayerData[Index]):
                    # Obtient le nom du joueur (simplifié)
                    PlayerName := "Player {Index + 1}"
                    Billboard.SetText(EntryMsg(Index + 1, PlayerName, Data.Rebirths))
                else:
                    Billboard.SetText(EmptyMsg)

#══════════════════════════════════════════════════════════════════════════════
# REBIRTH MILESTONE REWARDS - Récompenses spéciales par palier
#══════════════════════════════════════════════════════════════════════════════
rebirth_milestone := class(creative_device):
    @editable
    RequiredRebirths : int = 1

    @editable
    ClaimButton : button_device = button_device{}

    @editable
    RewardItemGranter : item_granter_device = item_granter_device{}

    @editable
    InfoBillboard : billboard_device = billboard_device{}

    @editable
    ClaimVFX : vfx_spawner_device = vfx_spawner_device{}

    var ClaimedPlayers : []player = array{}

    RequiredMsg<localizes>(Rebirths : int) : message = "Requires {Rebirths} Rebirth(s)"
    ClaimedMsg<localizes> : message = "CLAIMED!"
    LockedMsg<localizes> : message = "LOCKED"

    OnBegin<override>()<suspends> : void =
        InfoBillboard.SetText(RequiredMsg(RequiredRebirths))
        ClaimButton.InteractedWithEvent.Subscribe(OnClaimAttempt)

    OnClaimAttempt(Agent : agent) : void =
        if (Player := player[Agent]):
            # Vérifie si déjà claim
            for (ClaimedPlayer : ClaimedPlayers):
                if (ClaimedPlayer = Player):
                    return

            # Vérifie les rebirths
            if (GetRebirthCount(Player) >= RequiredRebirths):
                # Claim la récompense
                set ClaimedPlayers += array{Player}
                RewardItemGranter.GrantItem(Player)
                ClaimVFX.Restart()
                InfoBillboard.SetText(ClaimedMsg)
            else:
                InfoBillboard.SetText(LockedMsg)
                spawn{ResetDisplayAfterDelay()}

    ResetDisplayAfterDelay()<suspends> : void =
        Sleep(2.0)
        InfoBillboard.SetText(RequiredMsg(RequiredRebirths))
