
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
Start_Game_Device := class(creative_device):

    @editable StartGameDelay : float = 0.0

    @editable PropsToHide : []creative_prop = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Sleep(StartGameDelay)
        for(P : PropsToHide):
            PropPos := P.GetTransform().Translation
            PropRot := P.GetTransform().Rotation
            if(P.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=PropPos.Z - 10000.0},PropRot]):