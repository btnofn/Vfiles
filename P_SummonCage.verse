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

#THIS DEVICE SUMMONS A CAGE AROUND A PLAYER

#Class for each preset cage
CageCollection := class<concrete>():
    TT_CageProp<localizes>:message = "Creative Prop Used To Summon Cage\n*Required Settings*\nCollision Presets: No Collision\nAll 'CageExplosive' & 'CageTP' Should be Attached to this Prop"
    TT_CageExplosive<localizes>:message = "Explosive Device That Explodes To Clear Builds around Target\n*Required Settings*\nCan Be Damaged: False\nStructure Damage: 5000\nVisible During Game: False\nCollision During Games: Off\nShow Health Bar: False\nTime Until Reset Allowed: 0.1"
    TT_CageTP<localizes>:message = "Teleporter Device to Teleport Target into Cage and Avoid Clipping\n*Required Settings*\nTeleporter Group: None\nTeleporter Target Group: None"
    @editable{ToolTip := TT_CageProp} CageProp : creative_prop = creative_prop{}
    @editable{ToolTip := TT_CageExplosive} CageExplosive : explosive_device = explosive_device{}
    @editable{ToolTip := TT_CageTP} CageTP : teleporter_device = teleporter_device{}
    var IsAvailable : logic = true

#Main creative device class
P_SummonCage := class(creative_device):
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}
    @editable{ToolTip := TT_ActivateTrigger} ActivateTrigger : trigger_device = trigger_device{}
    @editable{ToolTip := TT_Cooldown} Cooldown : float = 0.0

    TT_Cages<localizes>:message = "Collection of Cages\n*Required Settings*\nCreate One Projectile for Each Potential User of this Ability"
    TT_SummonCageDuration<localizes>:message = "Duration the Cage Remains on Target"
    TT_SummonCageTargetEffect<localizes>:message = "Effects Applied to Target on Activation"
    TT_WhoDoesItEffect<localizes>:message = "Controls How Target is Chosen"
    TT_CageZOffset<localizes>:message = "Z axis Offset added to cage when teleported to Target"
    @editable{ToolTip := TT_Cages} Cages : []CageCollection = array{}
    @editable{ToolTip := TT_SummonCageDuration} SummonCageDuration : float = 0.0
    @editable{ToolTip := TT_ActivateSound} SummonCageSound : audio_player_device = audio_player_device{}
    @editable{ToolTip := TT_SummonCageTargetEffect} SummonCageTargetEffect : ?DurationEffect = false
    @editable{ToolTip := TT_WhoDoesItEffect} WhoDoesItEffect : OptionsEffectedNotAll = OptionsEffectedNotAll.ClosestPlayer
    @editable{ToolTip := TT_CageZOffset} CageZOffset : float = 0.0

    #Initializes all events
    OnBegin<override>()<suspends>:void=
        ActivateTrigger.TriggeredEvent.Subscribe(PreActivateAbility)

    #Activates the ability for the player
    PreActivateAbility(MAgent : ?agent) : void = if(Agent := MAgent?){spawn{ActivateAbility(Agent)}}
    ActivateAbility(Agent:agent)<suspends> : void=
        if(CP := AbilityManager.PlayersMap[Agent],FC:=Agent.GetFortCharacter[]):
            NotOnCooldown := CP.HandleCooldown(Cooldown)
            if(NotOnCooldown?):
                var Targets : []fort_character = array{}
                for(Player : AbilityManager.GetPlayers() , EveryFC := Player.GetFortCharacter[] , not FC = EveryFC){set Targets += array{EveryFC}}

                if(WhoDoesItEffect = OptionsEffectedNotAll.ClosestPlayer):
                    if(Target := FindNearestTarget[FC , Targets] , TargetAgent := Target.GetAgent[]){spawn{ActivateSummonCage(Agent,TargetAgent)}}

                else if(WhoDoesItEffect = OptionsEffectedNotAll.RandomPlayer):
                    if(RandomTarget := Targets[GetRandomInt(0,Targets.Length-1)], TargetAgent := RandomTarget.GetAgent[]){spawn{ActivateSummonCage(Agent,TargetAgent)}}

    #Summons a cage at the targets location and handles devices
    ActivateSummonCage(Instigator : agent , Target : agent)<suspends> : void=
        if:
            TargetFC := Target.GetFortCharacter[]
            InstigatorFC := Instigator.GetFortCharacter[]
        then:
            TargetPos := TargetFC.GetTransform().Translation
            SpawnPos := TargetPos + vector3{Z:=CageZOffset}
            
            var IsFound : logic = false
            var Cage : CageCollection = CageCollection{}
            for(C : Cages, not IsFound?):
                if(C.IsAvailable?):
                    set IsFound = true
                    set Cage = C
                    set C.IsAvailable = false
            if(Cage.CageProp.TeleportTo[SpawnPos,IdentityRotation()]):
                Cage.CageExplosive.Explode(Instigator)
                SummonCageSound.Play(Target)
                if(NewEffect := SummonCageTargetEffect?){spawn{NewEffect.Enable(Target)}}
                Cage.CageTP.Teleport(Target)
                Sleep(SummonCageDuration)
                Cage.CageExplosive.Reset()
                if(Cage.CageProp.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=-10000.0},IdentityRotation()]):
                SummonCageSound.Stop(Target)
                set Cage.IsAvailable = true