<#
====================================================================================================
THIS CODE IS MAPACADEMY PROPERTY. RESPECT THE RIGHTS OF THIS CODE.
SHARING THIS CODE COULD COME WITH A LEGAL CONSEQUENCES.                                                                                                 
CONTACT MAPPCO ON DISCORD
====================================================================================================
#>
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


ResetBuildsCode := class(creative_device):
    @editable ResetButton : button_device = button_device{}    #button to reset builds
    @editable ExplosiveDevices : []explosive_device = array{}   #explosive devices to destroy builds

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        ResetButton.InteractedWithEvent.Subscribe(ResetBuilds)

        
    ResetBuilds(Agent:agent):void =     
        spawn:
            ResetBuildsReal(Agent)


    ResetBuildsReal(Agent:agent)<suspends>:void =    #activates when button is pressed
        for (explosive : ExplosiveDevices):    #explodes all explosive devices
            explosive.Explode(Agent)
            explosive.Reset()
 
