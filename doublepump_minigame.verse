using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

doublepump_minigame := class(creative_device):

    @editable PM:player_marker_device = player_marker_device{}
    @editable IR:item_remover_device = item_remover_device{}
    @editable IG:item_granter_device = item_granter_device{}

    StartMinigame():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            PM.Attach(Player)
            IG.GrantItem(Player)

        PM.FirstItemValueChangedEvent.Subscribe(OnItemChanged)

    OnItemChanged(Agent:agent):void=
        IR.Remove(Agent)
        IG.GrantItem(Agent)

    ResetMinigame():void=
        PM.DetachFromAll()