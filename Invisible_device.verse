
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

test := class(creative_device):

    @editable conbtn: conditional_button_device = conditional_button_device{}

    OnBegin<override>()<suspends>:void=
        spawn{checkForCard()}

    checkForCard()<suspends>:void=
        loop:
            Sleep(1.0)
            AllPlayers := GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if (IsAgent:agent=agent[Player]):
                    if (conbtn.IsHoldingItem[IsAgent]):
                        HideAgent(IsAgent)
                    else:
                        ShowAgent(IsAgent)
                

    HideAgent(Agent:agent):void=
        if(FC := Agent.GetFortCharacter[]):
            FC.Hide()
    ShowAgent(Agent:agent):void=
        if(FC := Agent.GetFortCharacter[]):
            FC.Show()
            