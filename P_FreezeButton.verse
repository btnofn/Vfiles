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
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

#THIS ABILITY FREEZES, PLAYS SFX, SHOWS HUD, AND TELEPORTS PROP TO THE CLOSEST TARGET FROM THE ACTIVATING PLAYER

#Main creative device class
P_FreezeButton := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_FreezeClosestProp<localizes>:message = "Creative Prop Asset That is Spawned On Targets Location\n*Required Settings*\nCollision Preset: No Collision"
    TT_FreezeClosestSound<localizes>:message = "Plays Sound For Target When Frozen\n*Required Settings*\nPlay Location: Instigating Player"
    TT_FreezeClosestHUD<localizes>:message = "Hud Message Device that displays a message to Frozen Player\n*Required Settings*\nMessage Recipient: Triggering Player"
    TT_WhoDoesItEffectSetting<localizes>:message = "Controls What Player Is Effected by This Ability"
    TT_PropZOffset<localizes>:message = "Offset on Z axis of the spawned prop"
    TT_FreezeDuration<localizes>:message = "Time Player is Frozen For"
    @editable{ToolTip := TT_FreezeClosestProp} FreezeClosestProp : ?creative_prop_asset = false
    @editable{ToolTip := TT_FreezeClosestSound} FreezeClosestSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_FreezeClosestHUD} FreezeClosestHUD : hud_message_device = hud_message_device{}
    @editable{ToolTip := TT_WhoDoesItEffectSetting} WhoDoesItEffectSetting : OptionsEffected = OptionsEffected.ClosestPlayer
    @editable{ToolTip := TT_PropZOffset} PropZOffset : float = 0.0
    @editable{ToolTip := TT_FreezeDuration} FreezeDuration : float = 0.0
    
    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)
        FreezeClosestHUD.SetDisplayTime(FreezeDuration)

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
            if(NotOnCooldown?):
                var Targets : []fort_character = array{}
                for(Player : AbilityManager.GetPlayers() , EveryFC := Player.GetFortCharacter[] , not FC = EveryFC){set Targets += array{EveryFC}}

                if(WhoDoesItEffectSetting = OptionsEffected.ClosestPlayer):
                    if(Target := FindNearestTarget[FC , Targets] , TargetAgent := Target.GetAgent[]){spawn{ActivateFreezePlayer(TargetAgent)}}
                        
                else if(WhoDoesItEffectSetting = OptionsEffected.AllPlayers):
                    for(T : Targets , TargetAgent := T.GetAgent[]){spawn{ActivateFreezePlayer(TargetAgent)}}

                else if(WhoDoesItEffectSetting = OptionsEffected.RandomPlayer):
                    if(RandomTarget := Targets[GetRandomInt(0,Targets.Length-1)], TargetAgent := RandomTarget.GetAgent[]){spawn{ActivateFreezePlayer(TargetAgent)}}

    #Freezes a player for a set amount of time
    ActivateFreezePlayer(Agent:agent)<suspends> : void=
        if(FC:=Agent.GetFortCharacter[]):
            sync:
                block:
                    FreezeClosestSound.Play(Agent)
                    FreezeClosestHUD.Show(Agent)
                    FC.PutInStasis(stasis_args{})
                    Sleep(FreezeDuration)
                    FC.ReleaseFromStasis()
                block:
                    if(NewAsset := FreezeClosestProp? , NewProp := SpawnProp(NewAsset,FC.GetTransform().Translation + vector3{Z:=PropZOffset}, FC.GetTransform().Rotation)(0)?):
                        Sleep(FreezeDuration)
                        NewProp.Dispose()