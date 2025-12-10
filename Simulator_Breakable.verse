using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# SIMULATOR BREAKABLE - Props cassables

# Device breakable simple
simulator_breakable_device<public> := class(creative_device):
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

    var CurrentHealth : float = 0.0
    var MaxHealth : float = 0.0
    var IsDestroyed : logic = false
    var OriginalPosition : vector3 = vector3{}
    var OriginalRotation : rotation = rotation{}

    HealthMsg<localizes>(HP : int, MaxHP : int) : message = "{HP}/{MaxHP}"

    OnBegin<override>()<suspends> : void =
        set MaxHealth = BaseHealth
        set CurrentHealth = MaxHealth
        set OriginalPosition = Prop.GetTransform().Translation
        set OriginalRotation = Prop.GetTransform().Rotation
        UpdateDisplay()
        DamageTrigger.TriggeredEvent.Subscribe(OnDamage)

    OnDamage(MaybeAgent : ?agent) : void =
        if (IsDestroyed?):
            return
        if (Agent := MaybeAgent?):
            if (InPlayer := player[Agent]):
                if (SimPlayer := GetSimulatorPlayer(InPlayer)):
                    DamageResult := SimPlayer.CalculateDamage()
                    set CurrentHealth = CurrentHealth - DamageResult.Damage
                    UpdateDisplay()
                    if (CurrentHealth <= 0.0):
                        DestroyBreakable(Agent, SimPlayer)

    DestroyBreakable(Agent : agent, SimPlayer : simulator_player) : void =
        set IsDestroyed = true
        SimPlayer.GainSnow(BaseReward)
        SimPlayer.GainXP(XPReward)
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
