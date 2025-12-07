using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

oneshot_minigame := class(creative_device):

    @editable OneShotWeapons:item_granter_device = item_granter_device{}
    @editable OneShotConsumables:item_granter_device = item_granter_device{}
    @editable OneShotClass:class_and_team_selector_device = class_and_team_selector_device{}

    StartMinigame():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            OneShotClass.ChangeClass(Player)
            OneShotWeapons.CycleToRandomItem(Player)
            OneShotWeapons.CycleToRandomItem(Player)
            OneShotWeapons.CycleToRandomItem(Player)
            OneShotWeapons.CycleToRandomItem(Player)
            OneShotConsumables.GrantItem(Player)

    ResetMinigame():void=
        block: