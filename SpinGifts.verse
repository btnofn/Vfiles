using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
SpinGifts := class(creative_device):

    @editable PropsToSpin : []creative_prop = array{}
 

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(P : PropsToSpin):
            spawn: 
                MakePropSpin(P)

    MakePropSpin(Prop : creative_prop)<suspends>:void=
            PropPos := Prop.GetTransform().Translation
            PropRot := Prop.GetTransform().Rotation
            
            loop:
                Z := PropPos.Z
                Print("{Z}")
                Prop.MoveTo(vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=PropPos.Z + 25.0}, PropRot, 1.0)
                Prop.MoveTo(vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=PropPos.Z}, PropRot, 1.0)



