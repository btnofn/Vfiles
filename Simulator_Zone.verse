using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#══════════════════════════════════════════════════════════════════════════════
# SIMULATOR ZONE - Système de zones avec déblocage progressif
#══════════════════════════════════════════════════════════════════════════════

#──────────────────────────────────────────────────────────────────────────────
# GATE (Porte bloquant l'accès à une zone)
#──────────────────────────────────────────────────────────────────────────────
zone_gate := class(creative_device):
    @editable
    ZoneID : int = 0

    @editable
    GateProp : creative_prop = creative_prop{}

    @editable
    GateBarrier : barrier_device = barrier_device{}

    @editable
    UnlockButton : button_device = button_device{}

    @editable
    CostBillboard : billboard_device = billboard_device{}

    @editable
    RequirementsBillboard : billboard_device = billboard_device{}

    @editable
    UnlockVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    UnlockAudio : audio_player_device = audio_player_device{}

    @editable
    TeleportOnUnlock : teleporter_device = teleporter_device{}

    var IsUnlocked : logic = false

    # Messages localisés
    CostMsg<localizes>(Cost : float) : message = "Cost: {Cost} Snow"
    LevelReqMsg<localizes>(Level : int) : message = "Level {Level} Required"
    RebirthReqMsg<localizes>(Rebirths : int) : message = "{Rebirths} Rebirth(s) Required"
    UnlockedMsg<localizes> : message = "UNLOCKED"
    LockedMsg<localizes> : message = "LOCKED"

    OnBegin<override>()<suspends> : void =
        UnlockButton.InteractedWithEvent.Subscribe(OnUnlockAttempt)

        # Vérifie l'état initial pour chaque joueur
        for (Player : GetPlayspace().GetPlayers()):
            CheckAndUpdateGateState(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)

        # Met à jour l'affichage
        UpdateDisplay()

    OnPlayerJoined(Player : player) : void =
        CheckAndUpdateGateState(Player)

    CheckAndUpdateGateState(Player : player) : void =
        if (IsZoneUnlocked(Player, ZoneID)):
            OpenGate()

    OnUnlockAttempt(Agent : agent) : void =
        if (IsUnlocked?):
            return

        if (Player := player[Agent]):
            if (SimPlayer := GetSimulatorPlayer(Player)):
                # Obtient la config de zone
                if (ZoneConfig := GetZoneConfig(ZoneID)):
                    # Vérifie les conditions
                    if (CanUnlockZone(Player, ZoneConfig)):
                        # Tente le déblocage
                        if (SimPlayer.TryUnlockZone(ZoneConfig)):
                            UnlockGate(Player)
                        else:
                            # Pas assez de ressources
                            ShowInsufficientFunds()
                    else:
                        # Conditions non remplies
                        ShowRequirementsNotMet()

    CanUnlockZone(Player : player, Config : zone_config) : logic =
        if (Data := GetFullData(Player)):
            LevelOK := Data.Level >= Config.RequiredLevel
            RebirthOK := Data.RebirthCount >= Config.RequiredRebirths
            NotAlreadyUnlocked := not IsZoneUnlocked(Player, Config.ZoneID)
            LevelOK and RebirthOK and NotAlreadyUnlocked
        else:
            false

    UnlockGate(Player : player) : void =
        set IsUnlocked = true

        # Effets
        UnlockVFX.Restart()
        UnlockAudio.Play()

        # Ouvre la gate
        OpenGate()

        # Téléporte le joueur dans la zone
        TeleportOnUnlock.Teleport(Player)

    OpenGate() : void =
        # Cache le prop de gate
        CurrentPos := GateProp.GetTransform().Translation
        HidePos := CurrentPos - vector3{Z := 10000.0}
        if (GateProp.TeleportTo[HidePos, GateProp.GetTransform().Rotation]) {}

        # Désactive la barrière
        GateBarrier.Disable()

        # Met à jour l'affichage
        CostBillboard.SetText(UnlockedMsg)
        RequirementsBillboard.SetText(UnlockedMsg)

    CloseGate() : void =
        # Remet le prop
        CurrentPos := GateProp.GetTransform().Translation
        ShowPos := CurrentPos + vector3{Z := 10000.0}
        if (GateProp.TeleportTo[ShowPos, GateProp.GetTransform().Rotation]) {}

        # Active la barrière
        GateBarrier.Enable()

        set IsUnlocked = false
        UpdateDisplay()

    UpdateDisplay() : void =
        if (ZoneConfig := GetZoneConfig(ZoneID)):
            CostBillboard.SetText(CostMsg(ZoneConfig.UnlockCost))

            if (ZoneConfig.RequiredRebirths > 0):
                RequirementsBillboard.SetText(RebirthReqMsg(ZoneConfig.RequiredRebirths))
            else:
                RequirementsBillboard.SetText(LevelReqMsg(ZoneConfig.RequiredLevel))

    ShowInsufficientFunds() : void =
        # Flash le billboard en rouge ou autre feedback
        pass

    ShowRequirementsNotMet() : void =
        # Affiche les requirements manquants
        pass

#──────────────────────────────────────────────────────────────────────────────
# ZONE AREA (Définit une zone de jeu)
#──────────────────────────────────────────────────────────────────────────────
zone_area := class(creative_device):
    @editable
    ZoneID : int = 0

    @editable
    ZoneName : string = "Zone"

    @editable
    EntryZone : mutator_zone_device = mutator_zone_device{}

    @editable
    ZoneNameBillboard : billboard_device = billboard_device{}

    @editable
    SpawnPoint : player_spawner_device = player_spawner_device{}

    @editable
    AmbientAudio : audio_player_device = audio_player_device{}

    @editable
    ZoneVFX : vfx_spawner_device = vfx_spawner_device{}

    # Événements
    var OnPlayerEntered : event(player) = event(player){}
    var OnPlayerExited : event(player) = event(player){}

    ZoneNameMsg<localizes>(Name : string) : message = "{Name}"

    OnBegin<override>()<suspends> : void =
        # Affiche le nom de la zone
        if (ZoneConfig := GetZoneConfig(ZoneID)):
            ZoneNameBillboard.SetText(ZoneNameMsg(ZoneConfig.ZoneName))
        else:
            ZoneNameBillboard.SetText(ZoneNameMsg(ZoneName))

        # Subscribe aux événements d'entrée/sortie
        EntryZone.AgentEntersEvent.Subscribe(OnAgentEntered)
        EntryZone.AgentExitsEvent.Subscribe(OnAgentExited)

        # Démarre l'ambiance
        AmbientAudio.Play()
        ZoneVFX.Restart()

    OnAgentEntered(Agent : agent) : void =
        if (Player := player[Agent]):
            # Vérifie si le joueur a accès
            if (IsZoneUnlocked(Player, ZoneID)):
                # Met à jour la zone actuelle du joueur
                SetCurrentZone(Player, ZoneID)
                OnPlayerEntered.Signal(Player)

    OnAgentExited(Agent : agent) : void =
        if (Player := player[Agent]):
            OnPlayerExited.Signal(Player)

#══════════════════════════════════════════════════════════════════════════════
# ZONE MANAGER - Gère toutes les zones
#══════════════════════════════════════════════════════════════════════════════
simulator_zone_manager := class(creative_device):

    @editable
    Gates : []zone_gate = array{}

    @editable
    Areas : []zone_area = array{}

    @editable
    GlobalZoneChangedHUD : hud_message_device = hud_message_device{}

    # État des zones par joueur
    var PlayerCurrentZone : [player]int = map{}

    # Événements globaux
    var OnZoneUnlocked : event(player, int) = event(player, int){}
    var OnZoneChanged : event(player, int, int) = event(player, int, int){}  # player, oldZone, newZone

    ZoneChangedMsg<localizes>(ZoneName : string) : message = "Entering: {ZoneName}"

    OnBegin<override>()<suspends> : void =
        # Subscribe aux événements des gates
        for (Gate : Gates):
            # Les gates gèrent leur propre logique

        # Subscribe aux événements des zones
        for (Area : Areas):
            Area.OnPlayerEntered.Subscribe(HandlePlayerEnteredZone(Area))

        # Initialise les joueurs existants
        for (Player : GetPlayspace().GetPlayers()):
            InitializePlayerZone(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(InitializePlayerZone)
        GetPlayspace().PlayerRemovedEvent().Subscribe(CleanupPlayerZone)

    HandlePlayerEnteredZone(Area : zone_area)(Player : player) : void =
        OldZone := GetPlayerCurrentZone(Player)
        NewZone := Area.ZoneID

        if (OldZone <> NewZone):
            if (set PlayerCurrentZone[Player] = NewZone) {}
            OnZoneChanged.Signal(Player, OldZone, NewZone)

            # Affiche le message HUD
            if (ZoneConfig := GetZoneConfig(NewZone)):
                GlobalZoneChangedHUD.SetText(ZoneChangedMsg(ZoneConfig.ZoneName))
                GlobalZoneChangedHUD.Show(Player)

    InitializePlayerZone(Player : player) : void =
        # Charge la zone actuelle depuis la persistence
        if (Data := GetFullData(Player)):
            if (set PlayerCurrentZone[Player] = Data.CurrentZoneID) {}
        else:
            if (set PlayerCurrentZone[Player] = 0) {}

        # Met à jour l'état des gates
        for (Gate : Gates):
            if (IsZoneUnlocked(Player, Gate.ZoneID)):
                Gate.OpenGate()

    CleanupPlayerZone(Player : player) : void =
        var NewMap : [player]int = map{}
        for (Key -> Value : PlayerCurrentZone):
            if (Key <> Player):
                if (set NewMap[Key] = Value) {}
        set PlayerCurrentZone = NewMap

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR LA ZONE ACTUELLE D'UN JOUEUR
    #──────────────────────────────────────────────────────────────────────────
    GetPlayerCurrentZone(Player : player) : int =
        if (ZoneID := PlayerCurrentZone[Player]):
            ZoneID
        else:
            0

    #──────────────────────────────────────────────────────────────────────────
    # TÉLÉPORTER UN JOUEUR VERS UNE ZONE
    #──────────────────────────────────────────────────────────────────────────
    TeleportPlayerToZone(Player : player, ZoneID : int) : logic =
        # Vérifie que la zone est débloquée
        if (not IsZoneUnlocked(Player, ZoneID)):
            return false

        # Trouve la zone
        for (Area : Areas):
            if (Area.ZoneID = ZoneID):
                Area.SpawnPoint.SpawnPlayer(Player)
                SetCurrentZone(Player, ZoneID)
                if (set PlayerCurrentZone[Player] = ZoneID) {}
                return true

        false

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR LES ZONES DÉBLOQUÉES
    #──────────────────────────────────────────────────────────────────────────
    GetUnlockedZones(Player : player) : []int =
        if (Data := GetFullData(Player)):
            Data.UnlockedZones
        else:
            array{0}

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR LA PROCHAINE ZONE À DÉBLOQUER
    #──────────────────────────────────────────────────────────────────────────
    GetNextZoneToUnlock(Player : player) : ?zone_config =
        UnlockedZones := GetUnlockedZones(Player)
        HighestUnlocked := 0

        for (ZoneID : UnlockedZones):
            if (ZoneID > HighestUnlocked):
                set HighestUnlocked = ZoneID

        NextZoneID := HighestUnlocked + 1
        GetZoneConfig(NextZoneID)

    #──────────────────────────────────────────────────────────────────────────
    # RÉINITIALISER LES ZONES (pour Rebirth)
    #──────────────────────────────────────────────────────────────────────────
    ResetZonesForPlayer(Player : player) : void =
        # Ferme toutes les gates sauf la première
        for (Gate : Gates):
            if (Gate.ZoneID > 0):
                Gate.CloseGate()

        # Remet le joueur à la zone 0
        TeleportPlayerToZone(Player, 0)

#══════════════════════════════════════════════════════════════════════════════
# ZONE TELEPORTER (Pour voyager entre zones débloquées)
#══════════════════════════════════════════════════════════════════════════════
zone_teleporter := class(creative_device):
    @editable
    TeleportButton : button_device = button_device{}

    @editable
    TargetZoneID : int = 0

    @editable
    ZoneManager : simulator_zone_manager = simulator_zone_manager{}

    @editable
    InfoBillboard : billboard_device = billboard_device{}

    @editable
    TeleportVFX : vfx_spawner_device = vfx_spawner_device{}

    TeleportMsg<localizes>(ZoneName : string) : message = "Teleport to {ZoneName}"
    LockedMsg<localizes> : message = "LOCKED"

    OnBegin<override>()<suspends> : void =
        TeleportButton.InteractedWithEvent.Subscribe(OnTeleportRequest)
        UpdateDisplay()

    UpdateDisplay() : void =
        if (ZoneConfig := GetZoneConfig(TargetZoneID)):
            InfoBillboard.SetText(TeleportMsg(ZoneConfig.ZoneName))

    OnTeleportRequest(Agent : agent) : void =
        if (Player := player[Agent]):
            if (IsZoneUnlocked(Player, TargetZoneID)):
                TeleportVFX.Restart()
                ZoneManager.TeleportPlayerToZone(Player, TargetZoneID)
            else:
                # Affiche message locked
                InfoBillboard.SetText(LockedMsg)
                spawn{ResetDisplayAfterDelay()}

    ResetDisplayAfterDelay()<suspends> : void =
        Sleep(2.0)
        UpdateDisplay()

#══════════════════════════════════════════════════════════════════════════════
# ZONE PROGRESS DISPLAY (Affiche la progression dans les zones)
#══════════════════════════════════════════════════════════════════════════════
zone_progress_display := class(creative_device):
    @editable
    ProgressBillboard : billboard_device = billboard_device{}

    @editable
    UpdateInterval : float = 1.0

    ProgressMsg<localizes>(Current : int, Total : int) : message = "Zones: {Current}/{Total}"

    OnBegin<override>()<suspends> : void =
        loop:
            Sleep(UpdateInterval)
            UpdateAllPlayers()

    UpdateAllPlayers() : void =
        for (Player : GetPlayspace().GetPlayers()):
            UpdateForPlayer(Player)

    UpdateForPlayer(Player : player) : void =
        UnlockedCount := 0
        if (Data := GetFullData(Player)):
            set UnlockedCount = Data.UnlockedZones.Length

        TotalZones := DefaultZoneConfigs.Length
        ProgressBillboard.SetText(ProgressMsg(UnlockedCount, TotalZones))
