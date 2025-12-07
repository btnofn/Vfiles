using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS SCRIPT WILL GIVE PLAYERS A MONEY BOOST WHEN DANCING IN A MUTATOR ZONE

Dance_Manager := class(creative_device):
    @editable GameManager : Game_Manager = Game_Manager{}      #Main game manager

    @editable DanceCam : gameplay_camera_fixed_point_device = gameplay_camera_fixed_point_device{}  #Camera that applies to player when they enter the zone

    @editable DanceBoostMutator : mutator_zone_device = mutator_zone_device{}   #Mutator for when a player enters the zone

    @editable DanceBoostHUD : hud_message_device = hud_message_device{}     #Hud msg to display when a player enters the zone

    @editable var BoostBy : float = 0.0   #Amount to boost the player by when they are dancing

    @editable ResourceToBoost : string = ""  #Resource to Boost

    var IsDancing : logic = false   #Used to better manager when player is dancing to avoid glitches

    OnBegin<override>()<suspends>:void=
        DanceBoostMutator.AgentEntersEvent.Subscribe(OnEntered)     #Activates when a player enters zone
        DanceBoostMutator.AgentExitsEvent.Subscribe(OnExit)     #Activates When a player leaves zone
        DanceBoostMutator.AgentBeginsEmotingEvent.Subscribe(StartBoost)     #Activates when a player starts emoting in zone
        DanceBoostMutator.AgentEndsEmotingEvent.Subscribe(StopBoost)        #Activates when a player stops emoting in zone


    
    OnEntered(Agent:agent) : void=      #When someone enters the zone
        DanceCam.AddTo(Agent)       #Adds the camera to player
        DanceBoostHUD.Show(Agent)       #Shows msg to player

    OnExit(Agent:agent) : void=     #When someone leaves the zone
        DanceCam.RemoveFrom(Agent)      #Removes the camera from player
        DanceBoostHUD.Hide()            #Hides the msg from player

        if(IsDancing = true):                   #Removes boost
            if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player]):
                set IsDancing = false
                CustomPlayer.RemoveBoost(BoostBy, ResourceToBoost)

    StartBoost(Agent:agent) : void=     #When player starts dancing
        if(IsDancing = false):          #Adds Boost
            if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player]):
                set IsDancing = true
                CustomPlayer.Boost(BoostBy, ResourceToBoost)
                
    StopBoost(Agent:agent) : void=      #When player stops dancing
        if(IsDancing = true):           #Removes boost
            if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player]):
                set IsDancing = false
                CustomPlayer.RemoveBoost(BoostBy, ResourceToBoost)

