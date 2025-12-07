using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

team1_device := class(creative_device):

    @editable
    CarnavalWheel:creative_prop=creative_prop{}
    @editable
    WheelButton:conditional_button_device=conditional_button_device{}
  
    @editable
    GrantBoogie : item_granter_device = item_granter_device {}
    @editable
    GrantCow : item_granter_device = item_granter_device {}
    @editable
    GrantGrappler : item_granter_device = item_granter_device {}
    @editable
    GrantShockwave : item_granter_device = item_granter_device {}

    var IsRotating:logic=false
    var playercoins :int =0
    var playerPoints : int = 50000
    # Runs when the device is started in a running game

    OnBegin<override>()<suspends>:void=
        WheelButton.ActivatedEvent.Subscribe(OnSpinButtonClick)

    OnSpinButtonClick(Agent:agent):void=
        if(IsRotating = false):
       
                    spawn:
                        RotatWheel(Agent)

        #This is a condition they need to have before they can spin the wheel                    

    RotatWheel(Agent:agent)<suspends>:void=
        var RotateDegrees:float = 150.0
        set IsRotating = true
        loop:
            CarnavalWheel.MoveTo(CarnavalWheel.GetTransform().Translation,CarnavalWheel.GetTransform().Rotation.ApplyRoll(DegreesToRadians(RotateDegrees)),1.0)
            var RandomInt:int=GetRandomInt(5,25)
            RandomFloat:float=RandomInt*1.0

            set RotateDegrees -= RandomFloat
            if(RotateDegrees< 0.0):
            
                set IsRotating = false
                WheelRotation:[]float=CarnavalWheel.GetTransform().Rotation.GetYawPitchRollDegrees()
                if(Roll:float = WheelRotation[2]):
                    if(Roll>=0.0 and Roll <=44.9):
                        GrantGrappler.GrantItem(Agent)

                    else if(Roll>=45.0 and Roll <=89.9):
                        GrantShockwave.GrantItem(Agent)

                    else if(Roll>=90.0 and Roll <=134.9):
                        GrantBoogie.GrantItem(Agent)

                    else if(Roll>=135.0 and Roll <=180.0):
                        GrantCow.GrantItem(Agent)

                    else if(Roll>=180.0 and Roll <=225.0):
                        GrantGrappler.GrantItem(Agent)

                    else if(Roll>=225.0 and Roll <=270.0):
                        GrantShockwave.GrantItem(Agent)

                    else if(Roll>=270.0 and Roll <=315.0):
                        GrantBoogie.GrantItem(Agent)

                    else if(Roll>=315.0 and Roll <=360.0):
                        GrantCow.GrantItem(Agent)
                break

