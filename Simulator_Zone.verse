using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }

# SIMULATOR ZONE - Système de zones

# Gate de zone
zone_gate_device<public> := class(creative_device):
    @editable
    ZoneID : int = 0

    @editable
    ZoneName : string = "Zone"

    @editable
    UnlockCost : float = 1000.0

    @editable
    RequiredLevel : int = 5

    @editable
    RequiredRebirths : int = 0

    @editable
    GateProp : creative_prop = creative_prop{}

    @editable
    UnlockButton : button_device = button_device{}

    @editable
    CostBillboard : billboard_device = billboard_device{}

    @editable
    UnlockVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    TeleportOnUnlock : teleporter_device = teleporter_device{}

    var IsUnlocked : logic = false
    var OriginalPosition : vector3 = vector3{}

    CostMsg<localizes>(Cost : float) : message = "Cost: {Cost} Snow"
    LevelReqMsg<localizes>(Level : int) : message = "Level {Level} Required"
    UnlockedMsg<localizes> : message = "UNLOCKED"
    LockedMsg<localizes> : message = "LOCKED"

    OnBegin<override>()<suspends> : void =
        set OriginalPosition = GateProp.GetTransform().Translation
        CostBillboard.SetText(CostMsg(UnlockCost))
        UnlockButton.InteractedWithEvent.Subscribe(OnUnlockAttempt)

        for (InPlayer : GetPlayspace().GetPlayers()):
            CheckPlayerUnlock(InPlayer)
        GetPlayspace().PlayerAddedEvent().Subscribe(CheckPlayerUnlock)

    CheckPlayerUnlock(InPlayer : player) : void =
        if (IsZoneUnlocked(InPlayer, ZoneID)):
            OpenGate()

    OnUnlockAttempt(Agent : agent) : void =
        if (IsUnlocked?):
            return
        if (InPlayer := player[Agent]):
            Level := GetLevel(InPlayer)
            Rebirths := GetRebirthCount(InPlayer)
            if (Level >= RequiredLevel):
                if (Rebirths >= RequiredRebirths):
                    if (RemoveSnow(InPlayer, UnlockCost)):
                        UnlockZone(InPlayer, ZoneID)
                        UnlockGate(InPlayer)
                    else:
                        CostBillboard.SetText(LockedMsg)
                else:
                    CostBillboard.SetText(LockedMsg)
            else:
                CostBillboard.SetText(LevelReqMsg(RequiredLevel))

    UnlockGate(InPlayer : player) : void =
        set IsUnlocked = true
        UnlockVFX.Restart()
        OpenGate()
        TeleportOnUnlock.Teleport(InPlayer)

    OpenGate() : void =
        HidePos := OriginalPosition - vector3{Z := 10000.0}
        if (GateProp.TeleportTo[HidePos, GateProp.GetTransform().Rotation]) {}
        CostBillboard.SetText(UnlockedMsg)
