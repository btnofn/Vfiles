
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }

SeparateArenaGUN := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable SeparateArenaGunClassNumber : int = 100
    @editable ClassRequirement : int = 0
    #0 : no class requirement
    #1 : class requirement








    @editable SeparateGUNConditional: conditional_button_device = conditional_button_device{}
    @editable SeparateGUNSound : audio_player_device = audio_player_device{}

    @editable SeparateGUNItemRemover : item_remover_device = item_remover_device{}
    @editable SeparateGUNItemGranter : item_granter_device = item_granter_device{}
    @editable SeparateGUNCooldownTime : float = 0.0


    @editable SeparateGUNTempProp : creative_prop = creative_prop{}
    @editable SeparateGUNTempProp2 : creative_prop = creative_prop{}
    @editable SeparateGUNStormCircle : basic_storm_controller_device = basic_storm_controller_device{}
    @editable SeparateGUNTargetBackTP : teleporter_device = teleporter_device{}
    @editable SeparateGUNActivatorBackTP : teleporter_device = teleporter_device{}
    @editable SeparateGUNTargetTP : teleporter_device = teleporter_device{}
    @editable SeparateGUNActivatorTP : teleporter_device = teleporter_device{}
    @editable SeparateGUNCin : cinematic_sequence_device = cinematic_sequence_device{}
    @editable SeparateGUNCin2 : cinematic_sequence_device = cinematic_sequence_device{}
    @editable FreezePlayersLength : float = 0.0 #Make sure this is equal to the length of the cinematic
    @editable TimeInArena : float = 0.0
    @editable SeparateGUNCinSound : audio_player_device = audio_player_device{}
    @editable ArenaSetting : int = 0
    var EndTime : logic = false
    var Playerhasdied: logic = false 
    #1 = Teleports 1 Player
    #2 = Teleports 2 Players
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)
            FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamaged)
        spawn:
            LateStorm()
    OnPlayerDamaged(DamageResult: damage_result): void = 
        if: 
            Instigator := DamageResult.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            SeparateGUNConditional.IsHoldingItem[Agent]
            Target:= fort_character[DamageResult.Target]
        then:
            if(ClassRequirement = 0):
                spawn:
                    SepearateArenaGUNPlayer(Target,Agent)
            else if(ClassRequirement = 1):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = SeparateArenaGunClassNumber):
                    spawn:
                        SepearateArenaGUNPlayer(Target,Agent)
                else:
    SepearateArenaGUNPlayer(Target : fort_character,Agent:agent)<suspends> : void=
        if(Player := player[Agent], FC:= Player.GetFortCharacter[],TargetAgent := Target.GetAgent[]):
            if(Target = FC):
                block:
            else:
                spawn:
                    RemoveandGive(Agent)
                if(ArenaSetting = 1):
                    SeparateGUNSound.Play(Agent)
                    TargetLocation := Target.GetTransform().Translation
                    SeparateGUNTargetTP.Teleport(TargetAgent)
                    if(SeparateGUNTempProp.TeleportTo[TargetLocation, Target.GetTransform().Rotation]){}
                    Target.PutInStasis(stasis_args{})
                    SeparateGUNCinSound.Play()             
                    SeparateGUNCin.Play(TargetAgent)
                    Sleep(FreezePlayersLength)           
                    SeparateGUNCin.Stop(TargetAgent)
                    Target.ReleaseFromStasis()
                    set EndTime = false
                    set Playerhasdied = false
                    spawn:
                        Time()
                    Target.EliminatedEvent().Subscribe(EndTimeFunc)
                    loop:
                        Sleep(0.1)
                                if(EndTime = true):
                                    if(SeparateGUNTempProp.TeleportTo[vector3{X:=10000.0, Y:=10000.0, Z:=10000.0},IdentityRotation()]){}
                                    if(SeparateGUNTargetBackTP.TeleportTo[TargetLocation,IdentityRotation()]){}
                                    SeparateGUNTargetBackTP.Teleport(TargetAgent)
                                    if(SeparateGUNTargetBackTP.TeleportTo[vector3{X:=10000.0, Y:=10000.0, Z:=10000.0},IdentityRotation()]){}
                                    break

                else if(ArenaSetting = 2):
                    var ActivatorLocation : vector3 = FC.GetTransform().Translation
                    var TargetLocation : vector3 = Target.GetTransform().Translation
                    SeparateGUNActivatorTP.Teleport(Agent)
                    SeparateGUNTargetTP.Teleport(TargetAgent)
                    if(SeparateGUNTempProp.TeleportTo[TargetLocation, Target.GetTransform().Rotation]){}
                    if(SeparateGUNTempProp2.TeleportTo[ActivatorLocation, FC.GetTransform().Rotation]){}
                    Target.PutInStasis(stasis_args{})
                    Sleep(0.1)
                    FC.PutInStasis(stasis_args{})
                    SeparateGUNCinSound.Play()
                    SeparateGUNCin.Play(Agent)
                    SeparateGUNCin2.Play(TargetAgent)
                    Sleep(FreezePlayersLength)
                    SeparateGUNCin.Stop(Agent)
                    SeparateGUNCin2.Stop(TargetAgent)
                    FC.ReleaseFromStasis()
                    Target.ReleaseFromStasis()
                    set EndTime = false
                    set Playerhasdied = false
                    spawn:
                        Time()
                    Target.EliminatedEvent().Subscribe(EndTimeFunc)
                    FC.EliminatedEvent().Subscribe(EndTimeFunc)
                    loop:
                        Sleep(0.1)
                        if(EndTime = true):
                            if(SeparateGUNTempProp.TeleportTo[vector3{X:=10000.0, Y:=10000.0, Z:=10000.0},IdentityRotation()]){}
                            if(SeparateGUNActivatorBackTP.TeleportTo[ActivatorLocation,IdentityRotation()]){}
                            SeparateGUNActivatorBackTP.Teleport(Agent)
                            if(SeparateGUNActivatorBackTP.TeleportTo[vector3{X:=10000.0, Y:=10000.0, Z:=10000.0},IdentityRotation()]){}

                            if(SeparateGUNTempProp2.TeleportTo[vector3{X:=10000.0, Y:=10000.0, Z:=10000.0},IdentityRotation()]){}
                            if(SeparateGUNTargetBackTP.TeleportTo[TargetLocation,IdentityRotation()]){}
                            SeparateGUNTargetBackTP.Teleport(TargetAgent)
                            if(SeparateGUNTargetBackTP.TeleportTo[vector3{X:=10000.0, Y:=10000.0, Z:=10000.0},IdentityRotation()]){}
                            break





                else:


    EndTimeFunc(Result : elimination_result) : void=
        set EndTime = true
        set Playerhasdied = true
    Time()<suspends> : void=
        Sleep(TimeInArena)
        if (Playerhasdied = false):
            set EndTime = true

                


    RemoveandGive(Agent : agent)<suspends> : void=
        SeparateGUNItemRemover.Remove(Agent)
        Sleep(SeparateGUNCooldownTime)
        SeparateGUNItemGranter.GrantItem(Agent)


    LateStorm()<suspends> : void=
        Sleep(3.0)
        SeparateGUNStormCircle.GenerateStorm()