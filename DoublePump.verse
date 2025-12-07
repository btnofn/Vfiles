
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

DoublePump := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable DoublePumpClassNumber : int = 100


    @editable DoublePumpConditional : conditional_button_device = conditional_button_device{}
    @editable DoublePumpPlayerMarker:player_marker_device = player_marker_device{}                  
    @editable DoublePumpItemGranter:item_granter_device = item_granter_device{}                     
    @editable DoublePumpItemRemover:item_remover_device = item_remover_device{}                    

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        DoublePumpPlayerMarker.DetachFromAll()
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = DoublePumpClassNumber):
                    Print("Correct Class Number")
                    spawn:
                        DoublePumpPlayer(Agent)
    DoublePumpPlayer(Agent:agent)<suspends> : void =
        DoublePumpPlayerMarker.Attach(Agent) 
        DoublePumpItemGranter.GrantItem(Agent)  
        DoublePumpPlayerMarker.FirstItemValueChangedEvent.Subscribe(OnItemChanged)  
            
    OnItemChanged(Agent : agent):void=
        # if(DoublePumpConditional.IsHoldingItem[Agent]):
            RemoveAndGive(Agent)
    RemoveAndGive(Agent:agent) : void=
        # DoublePumpPlayerMarker.Attach(Agent)
        DoublePumpItemRemover.Remove(Agent)                                               
        DoublePumpItemGranter.GrantItem(Agent)                                            
    