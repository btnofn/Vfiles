using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

#══════════════════════════════════════════════════════════════════════════════
# SIMULATOR UI - Interface utilisateur et HUD
#══════════════════════════════════════════════════════════════════════════════

#──────────────────────────────────────────────────────────────────────────────
# HUD PRINCIPAL (Affichage permanent)
#──────────────────────────────────────────────────────────────────────────────
simulator_hud := class(creative_device):
    @editable
    SnowHUD : hud_message_device = hud_message_device{}

    @editable
    LevelHUD : hud_message_device = hud_message_device{}

    @editable
    XPBarHUD : hud_message_device = hud_message_device{}

    @editable
    RebirthHUD : hud_message_device = hud_message_device{}

    @editable
    ZoneHUD : hud_message_device = hud_message_device{}

    @editable
    DamageHUD : hud_message_device = hud_message_device{}

    @editable
    UpdateInterval : float = 0.1

    # Messages localisés
    SnowMsg<localizes>(Amount : string) : message = "❄ {Amount}"
    LevelMsg<localizes>(Level : int) : message = "Lv. {Level}"
    XPMsg<localizes>(Current : float, Required : float, Percent : int) : message = "XP: {Percent}%"
    RebirthMsg<localizes>(Count : int) : message = "⭐ Rebirth: {Count}"
    ZoneMsg<localizes>(ZoneName : string) : message = "📍 {ZoneName}"
    DamageMsg<localizes>(Damage : string) : message = "⚔ {Damage} DMG"

    OnBegin<override>()<suspends> : void =
        # Démarre la boucle de mise à jour
        loop:
            Sleep(UpdateInterval)
            UpdateHUD()

    UpdateHUD() : void =
        for (Player : GetPlayspace().GetPlayers()):
            UpdatePlayerHUD(Player)

    UpdatePlayerHUD(Player : player) : void =
        if (Data := GetFullData(Player)):
            # Neige
            SnowFormatted := FormatNumber(Data.Snow)
            SnowHUD.SetText(SnowMsg(SnowFormatted))
            SnowHUD.Show(Player)

            # Niveau
            LevelHUD.SetText(LevelMsg(Data.Level))
            LevelHUD.Show(Player)

            # XP
            XPRequired := GetXPForLevel(Data.Level)
            XPPercent := (Data.CurrentXP / XPRequired) * 100.0
            if (Percent := Int[XPPercent]):
                XPBarHUD.SetText(XPMsg(Data.CurrentXP, XPRequired, Percent))
                XPBarHUD.Show(Player)

            # Rebirth
            RebirthHUD.SetText(RebirthMsg(Data.RebirthCount))
            RebirthHUD.Show(Player)

            # Zone
            if (ZoneConfig := GetZoneConfig(Data.CurrentZoneID)):
                ZoneHUD.SetText(ZoneMsg(ZoneConfig.ZoneName))
                ZoneHUD.Show(Player)

            # Dégâts
            if (SimPlayer := GetSimulatorPlayer(Player)):
                DamageFormatted := FormatNumber(SimPlayer.TotalDamage)
                DamageHUD.SetText(DamageMsg(DamageFormatted))
                DamageHUD.Show(Player)

#══════════════════════════════════════════════════════════════════════════════
# FLOATING DAMAGE NUMBERS - Nombres de dégâts flottants
#══════════════════════════════════════════════════════════════════════════════
damage_number_spawner := class(creative_device):
    @editable
    DamageBillboards : []billboard_device = array{}  # Pool de billboards

    @editable
    CritDamageBillboards : []billboard_device = array{}  # Pour les crits

    @editable
    FloatDistance : float = 200.0

    @editable
    FloatDuration : float = 1.0

    var NextBillboardIndex : int = 0
    var NextCritIndex : int = 0

    DamageMsg<localizes>(Damage : int) : message = "{Damage}"
    CritMsg<localizes>(Damage : int) : message = "CRIT! {Damage}"

    #──────────────────────────────────────────────────────────────────────────
    # SPAWN UN NOMBRE DE DÉGÂTS
    #──────────────────────────────────────────────────────────────────────────
    SpawnDamageNumber(Position : vector3, Damage : float, IsCrit : logic) : void =
        if (DamageInt := Int[Damage]):
            if (IsCrit?):
                if (CritDamageBillboards.Length > 0):
                    Index := NextCritIndex mod CritDamageBillboards.Length
                    set NextCritIndex += 1
                    if (Billboard := CritDamageBillboards[Index]):
                        Billboard.SetText(CritMsg(DamageInt))
                        spawn{AnimateDamageNumber(Billboard, Position)}
            else:
                if (DamageBillboards.Length > 0):
                    Index := NextBillboardIndex mod DamageBillboards.Length
                    set NextBillboardIndex += 1
                    if (Billboard := DamageBillboards[Index]):
                        Billboard.SetText(DamageMsg(DamageInt))
                        spawn{AnimateDamageNumber(Billboard, Position)}

    AnimateDamageNumber(Billboard : billboard_device, StartPosition : vector3)<suspends> : void =
        # Note: Les billboards UEFN ne supportent pas le déplacement direct
        # Cette fonction est un placeholder pour l'animation
        # Dans un vrai projet, on utiliserait des props ou un système custom

        # Affiche pendant la durée
        Sleep(FloatDuration)

        # Cache le billboard
        HideMsg : message = ""
        Billboard.SetText(HideMsg)

#══════════════════════════════════════════════════════════════════════════════
# SNOW GAIN POPUP - Popup de gain de neige
#══════════════════════════════════════════════════════════════════════════════
snow_gain_display := class(creative_device):
    @editable
    GainHUD : hud_message_device = hud_message_device{}

    @editable
    DisplayDuration : float = 1.5

    var IsShowing : logic = false
    var PendingGains : float = 0.0

    GainMsg<localizes>(Amount : string) : message = "+{Amount} ❄"

    #──────────────────────────────────────────────────────────────────────────
    # AFFICHE UN GAIN DE NEIGE
    #──────────────────────────────────────────────────────────────────────────
    ShowGain(Player : player, Amount : float) : void =
        set PendingGains += Amount
        if (not IsShowing?):
            spawn{DisplayGainRoutine(Player)}

    DisplayGainRoutine(Player : player)<suspends> : void =
        set IsShowing = true

        # Affiche les gains accumulés
        FormattedAmount := FormatNumber(PendingGains)
        GainHUD.SetText(GainMsg(FormattedAmount))
        GainHUD.Show(Player)

        # Reset les gains accumulés
        set PendingGains = 0.0

        # Attend la durée d'affichage
        Sleep(DisplayDuration)

        # Cache
        GainHUD.Hide(Player)
        set IsShowing = false

#══════════════════════════════════════════════════════════════════════════════
# LEVEL UP CELEBRATION - Animation de level up
#══════════════════════════════════════════════════════════════════════════════
level_up_celebration := class(creative_device):
    @editable
    LevelUpHUD : hud_message_device = hud_message_device{}

    @editable
    LevelUpVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    LevelUpAudio : audio_player_device = audio_player_device{}

    @editable
    DisplayDuration : float = 3.0

    LevelUpMsg<localizes>(Level : int) : message = "🎉 LEVEL UP! 🎉 Level {Level}"

    #──────────────────────────────────────────────────────────────────────────
    # DÉCLENCHE LA CÉLÉBRATION
    #──────────────────────────────────────────────────────────────────────────
    TriggerCelebration(Player : player, NewLevel : int) : void =
        LevelUpHUD.SetText(LevelUpMsg(NewLevel))
        LevelUpHUD.Show(Player)
        LevelUpVFX.Restart()
        LevelUpAudio.Play()

        spawn{HideAfterDelay(Player)}

    HideAfterDelay(Player : player)<suspends> : void =
        Sleep(DisplayDuration)
        LevelUpHUD.Hide(Player)

#══════════════════════════════════════════════════════════════════════════════
# PET OBTAINED POPUP - Popup d'obtention de pet
#══════════════════════════════════════════════════════════════════════════════
pet_obtained_display := class(creative_device):
    @editable
    ObtainedHUD : hud_message_device = hud_message_device{}

    @editable
    RarityHUD : hud_message_device = hud_message_device{}

    @editable
    CommonVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    RareVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    EpicVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    LegendaryVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    MythicVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    DisplayDuration : float = 3.0

    ObtainedMsg<localizes>(PetName : string) : message = "NEW PET: {PetName}"
    RarityMsg<localizes>(Rarity : string) : message = "[ {Rarity} ]"

    #──────────────────────────────────────────────────────────────────────────
    # AFFICHE L'OBTENTION D'UN PET
    #──────────────────────────────────────────────────────────────────────────
    ShowPetObtained(Player : player, PetName : string, Rarity : pet_rarity) : void =
        ObtainedHUD.SetText(ObtainedMsg(PetName))
        ObtainedHUD.Show(Player)

        RarityName := GetRarityName(Rarity)
        RarityHUD.SetText(RarityMsg(RarityName))
        RarityHUD.Show(Player)

        # VFX selon la rareté
        case (Rarity):
            pet_rarity.Common => CommonVFX.Restart()
            pet_rarity.Rare => RareVFX.Restart()
            pet_rarity.Epic => EpicVFX.Restart()
            pet_rarity.Legendary => LegendaryVFX.Restart()
            pet_rarity.Mythic => MythicVFX.Restart()

        spawn{HideAfterDelay(Player)}

    HideAfterDelay(Player : player)<suspends> : void =
        Sleep(DisplayDuration)
        ObtainedHUD.Hide(Player)
        RarityHUD.Hide(Player)

#══════════════════════════════════════════════════════════════════════════════
# REBIRTH CELEBRATION - Célébration de rebirth
#══════════════════════════════════════════════════════════════════════════════
rebirth_celebration := class(creative_device):
    @editable
    RebirthHUD : hud_message_device = hud_message_device{}

    @editable
    BonusHUD : hud_message_device = hud_message_device{}

    @editable
    RebirthVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    RebirthAudio : audio_player_device = audio_player_device{}

    @editable
    ScreenFlash : cinematic_sequence_device = cinematic_sequence_device{}

    @editable
    DisplayDuration : float = 5.0

    RebirthTitleMsg<localizes>(Level : int) : message = "⭐ REBIRTH {Level} ⭐"
    BonusesMsg<localizes>(DMG : float, SPD : float, CURR : float) : message = "+{DMG}% DMG | +{SPD}% Speed | +{CURR}% Snow"

    #──────────────────────────────────────────────────────────────────────────
    # DÉCLENCHE LA CÉLÉBRATION DE REBIRTH
    #──────────────────────────────────────────────────────────────────────────
    TriggerCelebration(Player : player, RebirthLevel : int, DmgBonus : float, SpdBonus : float, CurrBonus : float) : void =
        RebirthHUD.SetText(RebirthTitleMsg(RebirthLevel))
        RebirthHUD.Show(Player)

        BonusHUD.SetText(BonusesMsg(DmgBonus, SpdBonus, CurrBonus))
        BonusHUD.Show(Player)

        RebirthVFX.Restart()
        RebirthAudio.Play()
        ScreenFlash.Play()

        spawn{HideAfterDelay(Player)}

    HideAfterDelay(Player : player)<suspends> : void =
        Sleep(DisplayDuration)
        RebirthHUD.Hide(Player)
        BonusHUD.Hide(Player)

#══════════════════════════════════════════════════════════════════════════════
# XP BAR VISUAL (Barre de progression XP)
#══════════════════════════════════════════════════════════════════════════════
xp_bar_visual := class(creative_device):
    @editable
    BarSegments : []creative_prop = array{}  # 10 segments de barre

    @editable
    UpdateInterval : float = 0.25

    OnBegin<override>()<suspends> : void =
        loop:
            Sleep(UpdateInterval)
            UpdateBars()

    UpdateBars() : void =
        for (Player : GetPlayspace().GetPlayers()):
            if (Data := GetFullData(Player)):
                XPRequired := GetXPForLevel(Data.Level)
                XPPercent := Data.CurrentXP / XPRequired

                # Active les segments proportionnellement
                TotalSegments := BarSegments.Length
                ActiveSegments := Int[XPPercent * TotalSegments]

                for (Index := 0..TotalSegments - 1):
                    if (Segment := BarSegments[Index]):
                        if (ActiveSegmentCount := ActiveSegments):
                            if (Index < ActiveSegmentCount):
                                # Segment actif - visible
                                ShowSegment(Segment)
                            else:
                                # Segment inactif - caché ou transparent
                                HideSegment(Segment)

    ShowSegment(Prop : creative_prop) : void =
        # Dans un vrai système, on changerait la couleur/visibilité
        pass

    HideSegment(Prop : creative_prop) : void =
        # Dans un vrai système, on changerait la couleur/visibilité
        pass

#══════════════════════════════════════════════════════════════════════════════
# COMBO DISPLAY - Affichage du combo (hits successifs)
#══════════════════════════════════════════════════════════════════════════════
combo_display := class(creative_device):
    @editable
    ComboHUD : hud_message_device = hud_message_device{}

    @editable
    ComboVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    ComboTimeout : float = 2.0  # Temps avant reset du combo

    var PlayerCombos : [player]int = map{}
    var LastHitTime : [player]float = map{}

    ComboMsg<localizes>(Count : int) : message = "COMBO x{Count}"

    OnBegin<override>()<suspends> : void =
        # Le combo serait incrémenté par le système de breakables
        loop:
            Sleep(0.1)
            CheckComboTimeouts()

    IncrementCombo(Player : player) : void =
        CurrentCombo := 0
        if (Combo := PlayerCombos[Player]):
            set CurrentCombo = Combo

        set CurrentCombo += 1
        if (set PlayerCombos[Player] = CurrentCombo) {}

        # Affiche le combo
        if (CurrentCombo > 1):
            ComboHUD.SetText(ComboMsg(CurrentCombo))
            ComboHUD.Show(Player)

            if (CurrentCombo mod 10 = 0):  # VFX tous les 10 combos
                ComboVFX.Restart()

    ResetCombo(Player : player) : void =
        if (set PlayerCombos[Player] = 0) {}
        ComboHUD.Hide(Player)

    CheckComboTimeouts() : void =
        # Dans un vrai système, on comparerait avec le temps actuel
        pass

#══════════════════════════════════════════════════════════════════════════════
# NOTIFICATION SYSTEM - Système de notifications
#══════════════════════════════════════════════════════════════════════════════
notification_system := class(creative_device):
    @editable
    NotificationHUD : hud_message_device = hud_message_device{}

    @editable
    DefaultDuration : float = 3.0

    var NotificationQueue : []tuple(Player : player, Message : message, Duration : float) = array{}
    var IsShowingNotification : logic = false

    OnBegin<override>()<suspends> : void =
        loop:
            Sleep(0.1)
            ProcessQueue()

    #──────────────────────────────────────────────────────────────────────────
    # AJOUTE UNE NOTIFICATION À LA QUEUE
    #──────────────────────────────────────────────────────────────────────────
    QueueNotification(Player : player, Msg : message, Duration : float) : void =
        set NotificationQueue += array{(Player := Player, Message := Msg, Duration := Duration)}

    ProcessQueue() : void =
        if (not IsShowingNotification?):
            if (NotificationQueue.Length > 0):
                if (Notification := NotificationQueue[0]):
                    spawn{ShowNotification(Notification.Player, Notification.Message, Notification.Duration)}
                    # Retire de la queue
                    var NewQueue : []tuple(Player : player, Message : message, Duration : float) = array{}
                    for (Index := 1..NotificationQueue.Length - 1):
                        if (N := NotificationQueue[Index]):
                            set NewQueue += array{N}
                    set NotificationQueue = NewQueue

    ShowNotification(Player : player, Msg : message, Duration : float)<suspends> : void =
        set IsShowingNotification = true
        NotificationHUD.SetText(Msg)
        NotificationHUD.Show(Player)
        Sleep(Duration)
        NotificationHUD.Hide(Player)
        set IsShowingNotification = false
