
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
BeginTextss := class(creative_device):
    @editable
    BillBoard : billboard_device = billboard_device {}
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        Self.GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
        ShowBillboard()

      

    ShowBillboard()<suspends>:void=
        BillBoard.ShowText()
        Sleep(20.0)
        BillBoard.HideText()

    OnPlayerAdded(Player:player):void=
        spawn:
            ShowBillboard()
