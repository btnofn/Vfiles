
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
HoldingCardInvisible := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable HoldingCardClassNumber : int = 100
    @editable HoldingCardConditional : conditional_button_device = conditional_button_device{}
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        spawn:
            InvisibilityPlayer()
    InvisibilityPlayer()<suspends> : void =
        loop:
            for (Player : GetPlayspace().GetPlayers()):
                if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                    if( GameStartDevice.EachPlayerMap[Agent].ClassNum = HoldingCardClassNumber):
                        if(HoldingCardConditional.IsHoldingItem[Agent]):
                            FC.Hide()
                        else:
                            FC.Show()
                        Sleep(0.1)
            Sleep(0.1)


    
            


    