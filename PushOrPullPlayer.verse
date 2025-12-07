
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
PushOrPullPlayer := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable PushOrPullClassNumber : int = 100
    @editable PushPullDevice : movement_modulator_device = movement_modulator_device{}
    @editable PushPullSound : audio_player_device = audio_player_device{}
    @editable PushPullOption : int = 0
    #if 1 : Push
    #if 2 : pull


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(PushOrPull)
            FortCharacter.DamagedShieldEvent().Subscribe(PushOrPull)

    PushOrPull( Result : damage_result) : void =
        if (Instigator := Result.Instigator?, Agent := Instigator.GetInstigatorAgent[], FortCharacter := Agent.GetFortCharacter[]):
            if(Target:= fort_character[Result.Target],TargetAgent := Target.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = PushOrPullClassNumber):
                    if(Target = FortCharacter):   
                        block:
                    else:
                        FCRotation := FortCharacter.GetTransform().Rotation
                        DeviceLocation := PushPullDevice.GetTransform().Translation
                        if(PushPullOption = 1):
                            if(PushPullDevice.TeleportTo[DeviceLocation,FCRotation]){}
                                PushPullSound.Play(TargetAgent)
                                PushPullDevice.Activate(TargetAgent)
                        else if(PushPullOption = 2):
                            NEWRotation := FCRotation.ApplyYaw(3.14)
                            if(PushPullDevice.TeleportTo[DeviceLocation,NEWRotation]){}
                                PushPullSound.Play(TargetAgent)
                                PushPullDevice.Activate(TargetAgent)

            

       