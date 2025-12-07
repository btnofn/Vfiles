
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

CustomPlayerModel := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable CustomModelClassNumber : int = 100

    @editable ModelProp : creative_prop = creative_prop{}
    @editable ModelRunningAnimation : cinematic_sequence_device = cinematic_sequence_device{}

    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = CustomModelClassNumber):
                    spawn:
                        CustomModelPlayer(Agent)


    CustomModelPlayer(Agent:agent)<suspends> : void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Hide()
            branch:
                loop:
                    if(FC.IsActive[]):
                        PlayerPos := FC.GetTransform().Translation
                        PlayerRot := FC.GetTransform().Rotation
   
                        ModelProp.MoveTo(PlayerPos- vector3{Z:=60.0}, PlayerRot, 0.1)
                        Sleep(0.0)

                    else:
                        if(ModelProp.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=-10000.0},ModelProp.GetTransform().Rotation]){}
                        FC.Show()
                        break
            loop:
                if (not FC.IsActive[]):
                    break
                Sleep(0.0)
                IsSprintingTuple := FC.SprintedEvent().Await()
                if (IsSprintingTuple(1)?):
                    ModelRunningAnimation.Play()
                else:
                    ModelRunningAnimation.Stop()
