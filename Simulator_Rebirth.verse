using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }

# SIMULATOR REBIRTH - Système de prestige

# Shrine de rebirth
rebirth_shrine_device<public> := class(creative_device):
    @editable
    RebirthLevel : int = 1

    @editable
    RequiredSnow : float = 50000.0

    @editable
    RequiredLevel : int = 25

    @editable
    DamageBonus : float = 25.0

    @editable
    SpeedBonus : float = 10.0

    @editable
    CurrencyBonus : float = 15.0

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

    CostMsg<localizes>(Snow : float) : message = "Cost: {Snow} Snow"
    BonusMsg<localizes>(DMG : float, SPD : float, CURR : float) : message = "+{DMG}% DMG | +{SPD}% Speed | +{CURR}% Snow"
    LevelReqMsg<localizes>(Level : int) : message = "Requires Level {Level}"
    SuccessMsg<localizes>(Level : int) : message = "REBIRTH {Level} Complete!"
    AlreadyMsg<localizes> : message = "Already Rebirthed!"
    NotEnoughMsg<localizes> : message = "Requirements not met!"

    OnBegin<override>()<suspends> : void =
        CostBillboard.SetText(CostMsg(RequiredSnow))
        BonusBillboard.SetText(BonusMsg(DamageBonus, SpeedBonus, CurrencyBonus))
        InteractButton.InteractedWithEvent.Subscribe(OnRebirthAttempt)

    OnRebirthAttempt(Agent : agent) : void =
        if (InPlayer := player[Agent]):
            CurrentRebirths := GetRebirthCount(InPlayer)
            CurrentLevel := GetLevel(InPlayer)
            CurrentSnow := GetSnow(InPlayer)

            # Vérifie si déjà fait
            if (CurrentRebirths >= RebirthLevel):
                CostBillboard.SetText(AlreadyMsg)
                spawn{ResetDisplay()}
                return

            # Vérifie le niveau séquentiel
            if (CurrentRebirths <> RebirthLevel - 1):
                CostBillboard.SetText(NotEnoughMsg)
                spawn{ResetDisplay()}
                return

            # Vérifie le niveau
            if (CurrentLevel < RequiredLevel):
                CostBillboard.SetText(LevelReqMsg(RequiredLevel))
                spawn{ResetDisplay()}
                return

            # Vérifie la neige
            if (CurrentSnow < RequiredSnow):
                CostBillboard.SetText(NotEnoughMsg)
                spawn{ResetDisplay()}
                return

            # Effectue le rebirth
            PerformRebirth(InPlayer, DamageBonus, SpeedBonus, CurrencyBonus)
            RebirthVFX.Restart()
            SuccessHUD.SetText(SuccessMsg(RebirthLevel))
            SuccessHUD.Show(InPlayer)
            TeleportAfter.Teleport(InPlayer)

    ResetDisplay()<suspends> : void =
        Sleep(2.0)
        CostBillboard.SetText(CostMsg(RequiredSnow))
