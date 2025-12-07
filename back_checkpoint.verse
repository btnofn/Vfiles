
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
remote_elim_manager := class(creative_device):

    # Your Remote Device
    
    @editable

    RemoteDevice : signal_remote_manager_device = signal_remote_manager_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        RemoteDevice.PrimarySignalEvent.Subscribe(OnRemoteButtonPressed)

    OnRemoteButtonPressed(Agent : agent):void=
        if(FC := Agent.GetFortCharacter[]):
            FC.Damage(1000.0)
