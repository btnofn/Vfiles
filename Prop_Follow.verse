
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
Prop_Follow := class(creative_device):
    PlayerNameToMessage<localizes>(Agent:agent):message="Guard Eliminated by {Agent} Team 8 "
    @editable
    g1 : creative_prop= creative_prop {}
    @editable
    g2 : creative_prop= creative_prop {}
    @editable
    g3 : creative_prop= creative_prop {}
    @editable
    Guards:[]guard_spawner_device=array{}
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(GuardSpawner:Guards):
            GuardSpawner.SpawnedEvent.Subscribe(OnGuardSpawned)
        #propfollow()
        # TODO: Replace this with your code
    OnGuardSpawned(Agent:agent):void=
        if(GuardObj:=agent[Agent]):
            if(FortCharacter:fort_character=Agent.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Subscribe(CheckElimiator)
    CheckElimiator(Result:elimination_result):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        Eliminator:=Result.EliminatingCharacter
        if(FortCharacter:=Eliminator?,ElimiatorAgent:=FortCharacter.GetAgent[]):
            if (AgentsTeam := TeamCollection.GetTeam[ElimiatorAgent]):
                for (TeamNumber->Team : TeamArray):
                    if (AgentsTeam = Team,TeamNumber = 7):
                        
    propfollow()<suspends> : void=

        loop :    
            Sleep(0.1)     
            if (PlayerList := GetPlayspace().GetPlayers() , FortniteCharacter := PlayerList[0].GetFortCharacter[]):
                    playerposition : vector3 = FortniteCharacter.GetTransform().Translation   
                    g1.MoveTo(playerposition, rotation{}, 0.2)
                    g2.MoveTo(playerposition, rotation{}, 0.2)
                    g3.MoveTo(playerposition, rotation{}, 0.2)