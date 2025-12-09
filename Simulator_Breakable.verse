using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#══════════════════════════════════════════════════════════════════════════════
# SIMULATOR BREAKABLE - Props cassables avec HP, respawn et rewards
#══════════════════════════════════════════════════════════════════════════════

#──────────────────────────────────────────────────────────────────────────────
# CONFIGURATION D'UN BREAKABLE (éditeur)
#──────────────────────────────────────────────────────────────────────────────
simulator_breakable_config := class<concrete>:
    @editable
    Prop : creative_prop = creative_prop{}

    @editable
    PropManipulator : prop_manipulator_device = prop_manipulator_device{}

    @editable
    HealthBillboard : billboard_device = billboard_device{}

    @editable
    DamageVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    DestroyVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    BaseHealth : float = 100.0

    @editable
    BaseReward : float = 10.0

    @editable
    XPReward : float = 5.0

    @editable
    RespawnTime : float = 5.0

    @editable
    ZoneID : int = 0

#──────────────────────────────────────────────────────────────────────────────
# CLASSE BREAKABLE ACTIVE
#──────────────────────────────────────────────────────────────────────────────
simulator_breakable := class:
    Config : simulator_breakable_config
    var Manager : ?simulator_breakable_manager = false

    # État
    var CurrentHealth : float = 0.0
    var MaxHealth : float = 0.0
    var IsDestroyed : logic = false
    var OriginalPosition : vector3 = vector3{}
    var OriginalRotation : rotation = rotation{}

    # Événements
    var OnDamaged : event(agent, float, logic) = event(agent, float, logic){}  # agent, damage, isCrit
    var OnDestroyed : event(agent, float) = event(agent, float){}              # agent, totalReward

    # Message localisé pour HP
    HealthMessage<localizes>(HP : int, MaxHP : int) : message = "{HP}/{MaxHP}"
    CritMessage<localizes> : message = "CRIT!"

    #──────────────────────────────────────────────────────────────────────────
    # INITIALISATION
    #──────────────────────────────────────────────────────────────────────────
    Initialize(ZoneConfig : ?zone_config) : void =
        # Calcule la santé en fonction de la zone
        if (ZConfig := ZoneConfig?):
            set MaxHealth = ZConfig.BreakableHP
        else:
            set MaxHealth = Config.BaseHealth

        set CurrentHealth = MaxHealth
        set IsDestroyed = false

        # Sauvegarde la position originale
        set OriginalPosition = Config.Prop.GetTransform().Translation
        set OriginalRotation = Config.Prop.GetTransform().Rotation

        # Met à jour l'affichage
        UpdateHealthDisplay()

        # Subscribe aux événements de dégâts
        Config.PropManipulator.DamagedEvent.Subscribe(HandleDamage)

    #──────────────────────────────────────────────────────────────────────────
    # GESTION DES DÉGÂTS
    #──────────────────────────────────────────────────────────────────────────
    HandleDamage(Agent : agent) : void =
        if (IsDestroyed?):
            return

        # Récupère le joueur simulator
        if (Player := player[Agent]):
            if (SimPlayer := GetSimulatorPlayer(Player)):
                # Calcule les dégâts
                DamageResult := SimPlayer.CalculateDamage()

                # Applique les dégâts
                set CurrentHealth -= DamageResult.Damage

                # VFX de dégâts
                Config.DamageVFX.Restart()

                # Signal l'événement
                OnDamaged.Signal(Agent, DamageResult.Damage, DamageResult.IsCrit)

                # Met à jour l'affichage
                UpdateHealthDisplay()

                # Vérifie la destruction
                if (CurrentHealth <= 0.0):
                    Destroy(Agent, SimPlayer)

    #──────────────────────────────────────────────────────────────────────────
    # DESTRUCTION
    #──────────────────────────────────────────────────────────────────────────
    Destroy(Agent : agent, SimPlayer : simulator_player) : void =
        set IsDestroyed = true

        # Calcule la récompense
        BaseReward := Config.BaseReward
        if (ZoneConfig := GetZoneConfig(Config.ZoneID)):
            set BaseReward = ZoneConfig.BreakableReward

        FinalReward := SimPlayer.GainSnow(BaseReward)
        SimPlayer.GainXP(Config.XPReward)

        # Stats
        if (Player := player[Agent]):
            IncrementCombatStats(Player, MaxHealth)

        # VFX de destruction
        Config.DestroyVFX.Restart()

        # Cache le prop
        HideProp()

        # Signal l'événement
        OnDestroyed.Signal(Agent, FinalReward)

        # Lance le respawn
        spawn{RespawnAfterDelay()}

    #──────────────────────────────────────────────────────────────────────────
    # RESPAWN
    #──────────────────────────────────────────────────────────────────────────
    RespawnAfterDelay()<suspends> : void =
        Sleep(Config.RespawnTime)
        Respawn()

    Respawn() : void =
        # Restaure la santé
        set CurrentHealth = MaxHealth
        set IsDestroyed = false

        # Remet le prop à sa position
        ShowProp()

        # Met à jour l'affichage
        UpdateHealthDisplay()

    #──────────────────────────────────────────────────────────────────────────
    # AFFICHAGE
    #──────────────────────────────────────────────────────────────────────────
    UpdateHealthDisplay() : void =
        if (HP := Int[CurrentHealth]):
            if (MaxHP := Int[MaxHealth]):
                Config.HealthBillboard.SetText(HealthMessage(HP, MaxHP))

    HideProp() : void =
        # Téléporte sous la map
        HidePosition := OriginalPosition - vector3{Z := 10000.0}
        if (Config.Prop.TeleportTo[HidePosition, OriginalRotation]) {}
        Config.HealthBillboard.SetText(HealthMessage(0, 0))

    ShowProp() : void =
        if (Config.Prop.TeleportTo[OriginalPosition, OriginalRotation]) {}

#══════════════════════════════════════════════════════════════════════════════
# MANAGER DES BREAKABLES
#══════════════════════════════════════════════════════════════════════════════
simulator_breakable_manager := class(creative_device):

    @editable
    BreakableConfigs : []simulator_breakable_config = array{}

    @editable
    GlobalRespawnTime : float = 5.0

    @editable
    DamageNumbersEnabled : logic = true

    # Liste des breakables actifs
    var ActiveBreakables : []simulator_breakable = array{}

    # Événements globaux
    var OnAnyBreakableDestroyed : event(agent, simulator_breakable, float) = event(agent, simulator_breakable, float){}

    #──────────────────────────────────────────────────────────────────────────
    # INITIALISATION
    #──────────────────────────────────────────────────────────────────────────
    OnBegin<override>()<suspends> : void =
        InitializeAllBreakables()

    InitializeAllBreakables() : void =
        for (Config : BreakableConfigs):
            Breakable := simulator_breakable{Config := Config}

            # Obtient la config de zone
            ZoneConfig := GetZoneConfig(Config.ZoneID)
            Breakable.Initialize(ZoneConfig)

            # Set le manager reference
            set Breakable.Manager = option{Self}

            # Subscribe aux événements
            Breakable.OnDestroyed.Subscribe(HandleBreakableDestroyed(Breakable))
            Breakable.OnDamaged.Subscribe(HandleBreakableDamaged(Breakable))

            set ActiveBreakables += array{Breakable}

    #──────────────────────────────────────────────────────────────────────────
    # HANDLERS D'ÉVÉNEMENTS
    #──────────────────────────────────────────────────────────────────────────
    HandleBreakableDestroyed(Breakable : simulator_breakable)(Agent : agent, Reward : float) : void =
        OnAnyBreakableDestroyed.Signal(Agent, Breakable, Reward)

    HandleBreakableDamaged(Breakable : simulator_breakable)(Agent : agent, Damage : float, IsCrit : logic) : void =
        if (DamageNumbersEnabled?):
            # Affiche les dégâts (le billboard peut être utilisé temporairement)
            # Note: Dans un système complet, on utiliserait un système de floating text
            pass

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR LES BREAKABLES PAR ZONE
    #──────────────────────────────────────────────────────────────────────────
    GetBreakablesInZone(ZoneID : int) : []simulator_breakable =
        var Result : []simulator_breakable = array{}
        for (Breakable : ActiveBreakables):
            if (Breakable.Config.ZoneID = ZoneID):
                set Result += array{Breakable}
        Result

    #──────────────────────────────────────────────────────────────────────────
    # RESET TOUS LES BREAKABLES D'UNE ZONE
    #──────────────────────────────────────────────────────────────────────────
    ResetZoneBreakables(ZoneID : int) : void =
        for (Breakable : ActiveBreakables):
            if (Breakable.Config.ZoneID = ZoneID):
                Breakable.Respawn()

    #──────────────────────────────────────────────────────────────────────────
    # RESET TOUS LES BREAKABLES
    #──────────────────────────────────────────────────────────────────────────
    ResetAllBreakables() : void =
        for (Breakable : ActiveBreakables):
            Breakable.Respawn()

#══════════════════════════════════════════════════════════════════════════════
# BREAKABLE SIMPLE (VERSION LÉGÈRE)
# Utilise un trigger au lieu de prop_manipulator pour plus de flexibilité
#══════════════════════════════════════════════════════════════════════════════
simulator_breakable_trigger := class(creative_device):

    @editable
    Prop : creative_prop = creative_prop{}

    @editable
    DamageTrigger : trigger_device = trigger_device{}

    @editable
    HealthBillboard : billboard_device = billboard_device{}

    @editable
    DestroyVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    BaseHealth : float = 100.0

    @editable
    BaseReward : float = 10.0

    @editable
    XPReward : float = 5.0

    @editable
    RespawnTime : float = 5.0

    @editable
    ZoneID : int = 0

    # État
    var CurrentHealth : float = 0.0
    var MaxHealth : float = 0.0
    var IsDestroyed : logic = false
    var OriginalPosition : vector3 = vector3{}
    var OriginalRotation : rotation = rotation{}

    HealthMsg<localizes>(HP : int, MaxHP : int) : message = "{HP}/{MaxHP}"

    OnBegin<override>()<suspends> : void =
        # Calcule la santé en fonction de la zone
        if (ZoneConfig := GetZoneConfig(ZoneID)):
            set MaxHealth = ZoneConfig.BreakableHP
        else:
            set MaxHealth = BaseHealth

        set CurrentHealth = MaxHealth
        set OriginalPosition = Prop.GetTransform().Translation
        set OriginalRotation = Prop.GetTransform().Rotation

        UpdateDisplay()
        DamageTrigger.TriggeredEvent.Subscribe(OnTriggerHit)

    OnTriggerHit(MaybeAgent : ?agent) : void =
        if (IsDestroyed?):
            return

        if (Agent := MaybeAgent?):
            if (Player := player[Agent]):
                if (SimPlayer := GetSimulatorPlayer(Player)):
                    # Calcule les dégâts
                    DamageResult := SimPlayer.CalculateDamage()
                    set CurrentHealth -= DamageResult.Damage
                    UpdateDisplay()

                    if (CurrentHealth <= 0.0):
                        DestroyBreakable(Agent, SimPlayer)

    DestroyBreakable(Agent : agent, SimPlayer : simulator_player) : void =
        set IsDestroyed = true

        # Récompenses
        if (ZoneConfig := GetZoneConfig(ZoneID)):
            SimPlayer.GainSnow(ZoneConfig.BreakableReward)
        else:
            SimPlayer.GainSnow(BaseReward)

        SimPlayer.GainXP(XPReward)

        # Stats
        if (Player := player[Agent]):
            IncrementCombatStats(Player, MaxHealth)

        # VFX et hide
        DestroyVFX.Restart()
        HidePosition := OriginalPosition - vector3{Z := 10000.0}
        if (Prop.TeleportTo[HidePosition, OriginalRotation]) {}

        spawn{RespawnDelay()}

    RespawnDelay()<suspends> : void =
        Sleep(RespawnTime)
        set CurrentHealth = MaxHealth
        set IsDestroyed = false
        if (Prop.TeleportTo[OriginalPosition, OriginalRotation]) {}
        UpdateDisplay()

    UpdateDisplay() : void =
        if (HP := Int[CurrentHealth]):
            if (MaxHP := Int[MaxHealth]):
                HealthBillboard.SetText(HealthMsg(HP, MaxHP))
