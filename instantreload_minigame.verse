using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

instantreload_minigame := class(creative_device):

    @editable ReloadClass:class_and_team_selector_device = class_and_team_selector_device{}

    StartMinigame():void=
        if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
            UtilsSystem.GrantStandardItems()

        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            ReloadClass.ChangeClass(Player)

    ResetMinigame():void=
        block: