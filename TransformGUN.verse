
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }

TransformGUN := class(creative_device):

    @editable GameStartDevice : GameStart = GameStart{}
    @editable TransformGunClassNumber : int = 100
    @editable ClassRequirement : int = 0
    #0 : no class requirement
    #1 : class requirement







    @editable TransformGUNConditional: conditional_button_device = conditional_button_device{}
    @editable TransformGUNTransformTime : float = 0.0
    @editable TransformGUNCooldownTime : float = 0.0
    @editable TransformGUNProp : creative_prop = creative_prop{}
    @editable TransformGUNItemRemover : item_remover_device = item_remover_device{}
    @editable TransformGUNItemGranter : item_granter_device = item_granter_device{}
    @editable TransformGUNSound : audio_player_device = audio_player_device{}
    @editable TransformGUNMovingAnimation : cinematic_sequence_device = cinematic_sequence_device{}

    var Time : logic = false
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)
            FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamaged)
    OnPlayerDamaged(DamageResult: damage_result): void = 
        if: 
            Instigator := DamageResult.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            TransformGUNConditional.IsHoldingItem[Agent]
            Target:= fort_character[DamageResult.Target]
        then:
            if(ClassRequirement = 0):
                spawn:
                    TransformPlayer(Target,Agent)
            else if(ClassRequirement = 1):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = TransformGunClassNumber):
                    spawn:
                        TransformPlayer(Target,Agent)
                else:
    TransformPlayer(Target : fort_character,Agent:agent)<suspends> : void=
        if(Player := player[Agent], FC:= Player.GetFortCharacter[],TargetAgent := FC.GetAgent[]):
            if(Target = FC):   
                block:
            else:
                set Time = false
                spawn:
                    RemoveandGive(Agent)
                spawn:
                    Timer()
                TransformGUNSound.Play(TargetAgent)
                Target.Hide()
                branch:
                    loop:
                        if(Target.IsActive[]):
                            Sleep(0.0)
    
                            PlayerPos := Target.GetTransform().Translation
                            PlayerRot := Target.GetTransform().Rotation

                            TransformGUNProp.MoveTo(PlayerPos, PlayerRot, 0.1)
                        else:
                            Target.Show()
                            Target.ReleaseFromStasis()
                            if(TransformGUNProp.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=-10000.0},TransformGUNProp.GetTransform().Rotation]){}
                            break
                        if(Time = true):
                            Target.Show()
                            Target.ReleaseFromStasis()
                            if(TransformGUNProp.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=-10000.0},TransformGUNProp.GetTransform().Rotation]){}
                            break
                loop:
                    if (not FC.IsActive[]):
                        break
                    Sleep(0.1)
                    IsSprintingTuple := FC.SprintedEvent().Await()
                    if (IsSprintingTuple(1)?):
                        TransformGUNMovingAnimation.Play()
                    else:
                        TransformGUNMovingAnimation.Stop()














    Timer()<suspends>: void=
        Sleep(TransformGUNTransformTime)
        set Time = true
                

    RemoveandGive(Agent : agent)<suspends> : void=
        TransformGUNItemRemover.Remove(Agent)
        Sleep(TransformGUNCooldownTime)
        TransformGUNItemGranter.GrantItem(Agent)