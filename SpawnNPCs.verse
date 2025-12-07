
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {/Fortnite.com/Teams}

SpawnNPCs := class(creative_device):
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable SpawnNPCTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    

    @editable SpawnNPCSpawner : npc_spawner_device = npc_spawner_device{}
    @editable SpawnNPCSound : audio_player_device = audio_player_device{}
    


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        SpawnNPCTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        SpawnNPCTimer.SuccessEvent.Subscribe(ResetCooldown)
        

    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false

    SpawnNPCsAbility(Agent:agent)<suspends> :void=
        if(MaybeCooldown = false):
            SpawnNPCTimer.Start(Agent)
            set MaybeCooldown=true
            if(Player := player[Agent],FC:=Player.GetFortCharacter[]):
                PlayerPos := FC.GetTransform().Translation
                if(SpawnNPCSpawner.TeleportTo[PlayerPos,IdentityRotation()]){}
                SpawnNPCSpawner.Enable()
                SpawnNPCSpawner.Spawn()
                SpawnNPCSound.Play(Agent)
   
                
            


        else:
            CooldownMSG.Show(Agent)