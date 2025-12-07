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

#THIS ABILITY ALLOWS A SPECIFIC WEAPON TO FREEZE ON CONTACT WITH OTHER PLAYERS

#Main creative device class
P_FreezeWeapon := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_EquipTrigger} EquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_UnEquipTrigger} UnEquippedTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_GunSettings} GunAbilitySettings : GunAbility = GunAbility{}

    TT_FreezeGUNProp<localizes>:message = "Creative Prop Asset That is Spawned On Targets Location\n*Required Settings*\nCollision Preset: No Collision"
    TT_FreezeGUNSound<localizes>:message = "Plays Sound For Target When Frozen\n*Required Settings*\nPlay Location: Instigating Player"
    TT_FreezeGUNFrozenHUD<localizes>:message = "Hud Message Device that displays a message to Frozen Player\n*Required Settings*\nMessage Recipient: Triggering Player"
    TT_PropZOffset<localizes>:message = "Offset on Z axis of the spawned prop"
    TT_FreezeGUNFreezeTime<localizes>:message = "Time Player is Frozen For"
    @editable{ToolTip := TT_FreezeGUNProp} FreezeGUNProp : ?creative_prop_asset = false
    @editable{ToolTip := TT_FreezeGUNSound} FreezeGUNSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_FreezeGUNFrozenHUD} FreezeGUNFrozenHUD : hud_message_device = hud_message_device{}
    @editable{ToolTip := TT_PropZOffset} PropZOffset : float = 0.0
    @editable{ToolTip := TT_FreezeGUNFreezeTime} FreezeGUNFreezeTime : float = 0.0

    #Initializes damage events for all players and sets up weapon equip/unequip events
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()){InitializeDamage(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitializeDamage)
        GunAbilitySettings.Setup(EquippedTrigger , UnEquippedTrigger, AbilityManager)
          
    #Initializes damage events for a player
    InitializeDamage(Agent:agent) : void =
        if(FC := Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnPlayerDamaged)
            FC.DamagedShieldEvent().Subscribe(OnPlayerDamaged)

    #Checks to see if the ability should activate
    OnPlayerDamaged(DamageResult: damage_result): void = 
        if: 
            Instigator := DamageResult.Instigator?
            InstigatorAgent := Instigator.GetInstigatorAgent[]
            Target := fort_character[DamageResult.Target]
            TargetAgent := Target.GetAgent[]
            not TargetAgent = InstigatorAgent
        then:
            ShouldActivate := GunAbilitySettings.Check(InstigatorAgent)
            if(ShouldActivate?):
                spawn{ActivateGunAbility(InstigatorAgent, TargetAgent)}

    #Activates the ability
    ActivateGunAbility(InstigatorAgent : agent , TargetAgent : agent)<suspends> : void=
        if:
            TargetFC := TargetAgent.GetFortCharacter[]
            InstigatorFC := InstigatorAgent.GetFortCharacter[]
        then:
            sync:
                block:
                    FreezeGUNSound.Play(TargetAgent)
                    FreezeGUNFrozenHUD.Show(TargetAgent)
                    TargetFC.PutInStasis(stasis_args{})
                    Sleep(FreezeGUNFreezeTime)
                    TargetFC.ReleaseFromStasis()
                block:
                    if(NewAsset := FreezeGUNProp? , NewProp := SpawnProp(NewAsset,TargetFC.GetTransform().Translation + vector3{Z:=PropZOffset}, TargetFC.GetTransform().Rotation)(0)?):
                        Sleep(FreezeGUNFreezeTime)
                        NewProp.Dispose()