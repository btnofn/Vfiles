using { /Fortnite.com/Devices }
using { /Verse.org/Simulation}
using { /UnrealEngine.com/Temporary/Diagnostics}

shotking :=class(creative_device):

    @editable
    PlayerMarker:player_marker_device = player_marker_device{}

    @editable
    ItemRemover:item_remover_device = item_remover_device{}

    @editable
    ItemGranter:item_granter_device = item_granter_device{}
 
    OnBegin<override>()<suspends>:void=
        PlayerMarker.FirstItemValueChangedEvent.Subscribe(OnItemChanged)
    
    OnItemChanged(Agent:agent):void=
        ItemRemover.Remove(Agent)
        ItemGranter.GrantItem(Agent)
    
    WhenActivated (Agent:agent):void=
        PlayerMarker.Attach(Agent)
        ItemGranter.ItemGrantedEvent