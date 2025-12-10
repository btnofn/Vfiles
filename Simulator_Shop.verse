using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }

# SIMULATOR SHOP - Système d'upgrades

# Station d'upgrade
upgrade_station_device<public> := class(creative_device):
    @editable
    UpgradeName : string = "Damage"

    @editable
    UpgradeDescription : string = "+1 Damage"

    @editable
    BaseCost : float = 50.0

    @editable
    CostMultiplier : float = 1.15

    @editable
    BonusPerLevel : float = 1.0

    @editable
    MaxLevel : int = -1

    @editable
    UpgradeIndex : int = 0

    @editable
    PurchaseButton : button_device = button_device{}

    @editable
    NameBillboard : billboard_device = billboard_device{}

    @editable
    LevelBillboard : billboard_device = billboard_device{}

    @editable
    CostBillboard : billboard_device = billboard_device{}

    @editable
    UpgradeVFX : vfx_spawner_device = vfx_spawner_device{}

    var CurrentPlayerLevel : int = 0

    NameMsg<localizes>(Name : string) : message = "{Name}"
    LevelMsg<localizes>(Level : int) : message = "Level: {Level}"
    CostMsg<localizes>(Cost : float) : message = "Cost: {Cost} Snow"
    MaxedMsg<localizes> : message = "MAXED!"
    NotEnoughMsg<localizes> : message = "Not enough Snow!"

    OnBegin<override>()<suspends> : void =
        NameBillboard.SetText(NameMsg(UpgradeName))
        PurchaseButton.InteractedWithEvent.Subscribe(OnPurchase)
        spawn{UpdateLoop()}

    UpdateLoop()<suspends> : void =
        loop:
            Sleep(0.5)
            UpdateDisplay()

    UpdateDisplay() : void =
        Players := GetPlayspace().GetPlayers()
        if (FirstPlayer := Players[0]):
            # Simule le niveau d'upgrade (dans un vrai système, utilise la persistence)
            Cost := CalculateCost(CurrentPlayerLevel)
            LevelBillboard.SetText(LevelMsg(CurrentPlayerLevel))
            if (MaxLevel >= 0):
                if (CurrentPlayerLevel >= MaxLevel):
                    CostBillboard.SetText(MaxedMsg)
                else:
                    CostBillboard.SetText(CostMsg(Cost))
            else:
                CostBillboard.SetText(CostMsg(Cost))

    CalculateCost(Level : int) : float =
        var Result : float = BaseCost
        var I : int = 0
        loop:
            if (I >= Level):
                break
            set Result = Result * CostMultiplier
            set I = I + 1
        Result

    OnPurchase(Agent : agent) : void =
        if (InPlayer := player[Agent]):
            # Vérifie le max level
            if (MaxLevel >= 0):
                if (CurrentPlayerLevel >= MaxLevel):
                    return

            Cost := CalculateCost(CurrentPlayerLevel)
            if (RemoveSnow(InPlayer, Cost)):
                set CurrentPlayerLevel = CurrentPlayerLevel + 1
                UpgradeVFX.Restart()
                UpdateDisplay()

                # Met à jour les stats du joueur
                if (SimPlayer := GetSimulatorPlayer(InPlayer)):
                    SimPlayer.RecalculateStats()
            else:
                CostBillboard.SetText(NotEnoughMsg)
                spawn{ResetCostDisplay()}

    ResetCostDisplay()<suspends> : void =
        Sleep(1.5)
        UpdateDisplay()
