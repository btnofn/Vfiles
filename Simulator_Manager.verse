
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


Custom_Enemy := class<concrete>():
    @editable Health : float = 0.0
    @editable Defense : float = 0.0
    @editable HealthBillboard : billboard_device = billboard_device{}
    @editable Prop : creative_prop = creative_prop{}
    @editable PropManipulator : prop_manipulator_device = prop_manipulator_device{}
    @editable RewardTrigger : trigger_device = trigger_device{}
    var SimulatorManager : Simulator_Manager = Simulator_Manager{}
    @editable RespawnDelay : float = 0.0

    var CurrentHealth : float = 0.0

    StringToMessage<localizes>(String : string) : message = "{String}"
    

    Setup() : void=
        set CurrentHealth = Health
        PropManipulator.DamagedEvent.Subscribe(OnDamaged)

        if(NewHealth := Int[CurrentHealth]):
            HealthBillboard.SetText(StringToMessage("{NewHealth}"))

    OnDamaged(Agent:agent) : void=
        if(CP := SimulatorManager.PlayerMap[Agent]):
            var NewDamage : float = CP.PlayersDamage - Defense
            if(NewDamage < 0.0):
                set NewDamage = 0.0
            set CurrentHealth -= NewDamage

            if(NewHealth := Int[CurrentHealth]):
                HealthBillboard.SetText(StringToMessage("{NewHealth}"))

            if(CurrentHealth <= 0.0):
                EliminateEnemy(Agent)

    EliminateEnemy(Agent:agent) : void=
        HealthBillboard.SetText(StringToMessage(""))
        if(Prop.TeleportTo[Prop.GetTransform().Translation - vector3{Z:= 10000.0}, Prop.GetTransform().Rotation]){}
        RewardTrigger.Trigger(Agent)
        spawn{RespawnEnemy()}

    RespawnEnemy()<suspends> : void=
        Sleep(RespawnDelay)
        set CurrentHealth = Health
        if(NewHealth := Int[CurrentHealth]):
            HealthBillboard.SetText(StringToMessage("{NewHealth}"))

        if(Prop.TeleportTo[Prop.GetTransform().Translation + vector3{Z:= 10000.0}, Prop.GetTransform().Rotation]){}
        

Simulator_Custom_Player := class():
    Player : player
    var PlayersDamage : float = 0.0



Simulator_Manager := class(creative_device):

    var PlayerMap : [player]Simulator_Custom_Player = map{}

    @editable Enemies : []Custom_Enemy = array{}
    @editable IncreaseDamageTrigger : trigger_device = trigger_device{}


    OnBegin<override>()<suspends>:void=

        for(Player : GetPlayspace().GetPlayers()):
            Initialize(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(Initialize)

        InitializeEnemies()

        IncreaseDamageTrigger.TriggeredEvent.Subscribe(IncDMG)


    IncDMG(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            if(CP := PlayerMap[Agent]):
                set CP.PlayersDamage += 1.0

    InitializeEnemies() : void=
        for(Enemy : Enemies):
            Enemy.Setup()
            set Enemy.SimulatorManager = Self


    Initialize(Agent:agent) : void=
        if(Player := player[Agent]):
            if(PlayerExists := PlayerMap[Player]):

            else:
                if(set PlayerMap[Player] = Simulator_Custom_Player{Player := Player}){}
