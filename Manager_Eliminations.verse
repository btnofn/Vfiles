<#
====================================================================================================
Copyright (c) 2024 MapAcademy. All rights reserved.

 

This software and its associated documentation files (the "Software") are the

proprietary property of MapAcademy and are protected by copyright law.

 

The Software is provided to you under the terms of the MapAcademy End User

License Agreement (the "License"). You may use, copy, distribute, and modify

the Software solely in accordance with the terms of the License.

 

BY USING THE SOFTWARE, YOU AGREE TO BE BOUND BY THE TERMS OF THE LICENSE.

IF YOU DO NOT AGREE TO THE TERMS OF THE LICENSE, DO NOT USE THE SOFTWARE.

 

The Software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND,

either express or implied, including without limitation any warranties of

MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, or NON-INFRINGEMENT.

For more details, please refer to the MapAcademy End User License Agreement.
====================================================================================================
#>
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }

#THIS DEVICE HANDLES SFX AND VFX FOR ELIMINATIONS

#Different eliminate types used for each effect
EliminationType := enum:
    OnElimination
    OnEliminated

#Different elimination effects and settings for each
EliminationEffect := class<concrete>():
    @editable EliminateSFX : audio_player_device = audio_player_device{}
    @editable EliminateVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable PlaySFXOn : EliminationType = EliminationType.OnElimination
    @editable PlayVFXOn : EliminationType = EliminationType.OnEliminated
        
#Main creative device class
Manager_Eliminations := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}

    #Tracks eliminations for all players
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()){TrackElimination(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(TrackElimination)

    #Handles eliminations
    TrackElimination(Agent:agent) : void = if(FC := Agent.GetFortCharacter[]){FC.EliminatedEvent().Subscribe(OnElimination)}
    OnElimination(Result : elimination_result): void=
        if:
            EliminatingFC := Result.EliminatingCharacter?
            EliminatingAgent := EliminatingFC.GetAgent[]
            EliminatingCP := AbilityManager.PlayersMap[EliminatingAgent]
            EliminatingEffects := EliminatingCP.EquippedPower.PowerEliminationEffects

            EliminatedFC := Result.EliminatedCharacter
            EliminatedAgent := EliminatedFC.GetAgent[]
            EliminatedCP := AbilityManager.PlayersMap[EliminatedAgent]
            EliminatedEffects := EliminatedCP.EquippedPower.PowerEliminationEffects
        then:
            #Eliminating Effects
            if(EliminatingEffects.PlaySFXOn = EliminationType.OnElimination):
                EliminatingEffects.EliminateSFX.Play(EliminatingAgent)
            if(EliminatingEffects.PlayVFXOn = EliminationType.OnElimination):
                spawn{PlayVFX(EliminatedFC.GetTransform().Translation,EliminatingEffects.EliminateVFX)}

            #Eliminated Effects
            if(EliminatedEffects.PlaySFXOn = EliminationType.OnEliminated):
                EliminatedEffects.EliminateSFX.Play(EliminatedAgent)
            if(EliminatedEffects.PlayVFXOn = EliminationType.OnEliminated):
                spawn{PlayVFX(EliminatedFC.GetTransform().Translation,EliminatedEffects.EliminateVFX)}
    
