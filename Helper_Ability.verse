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
using { /Fortnite.com/Devices/CreativeAnimation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }

#CONTAINS DIFFERENT HELPER FUNCTIONS USED TO CREATE VARIOUS ABILITIES

#Class for individual vfx instances for each player
PlayerVFX := class<concrete>():
    @editable VFX : vfx_spawner_device = vfx_spawner_device{}
    var IsAvailable : logic = true
    var AssignedPlayer : ?agent = false

#Main creative device class
Helper_Ability := class(creative_device):
    @editable DisableBuildsMutator : mutator_zone_device = mutator_zone_device{}
    @editable WallHackVFXs : []PlayerVFX = array{}
    @editable{ToolTip := TT_AbilityManager} AbilityManager : Manager_Ability = Manager_Ability{}

    #Initiates all players VFXs
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()){InitiateVFX(Player)}
        GetPlayspace().PlayerAddedEvent().Subscribe(InitiateVFX)

    #Enables a player's assigned vfx
    EnableVFXForPlayer(Agent : agent)<suspends> : void=
        for(VFX : WallHackVFXs):
            if(VFXAttachedPlayer := VFX.AssignedPlayer? , VFXAttachedPlayer = Agent):
                VFX.VFX.Enable()

    #Disables a player's assigned vfx
    DisableVFXForPlayer(Agent : agent)<suspends> : void=
        for(VFX : WallHackVFXs):
            if(VFXAttachedPlayer := VFX.AssignedPlayer? , VFXAttachedPlayer = Agent):
                VFX.VFX.Disable()

    #Tracks a player with a vfx
    InitiateVFX(Agent:agent) : void = spawn{VFXTrackPlayer(Agent)}
    VFXTrackPlayer(Agent:agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            var IsFound : logic = false
            var NewVFX : PlayerVFX = PlayerVFX{}
            for(W : WallHackVFXs, not IsFound?):
                if(W.IsAvailable?):
                    set IsFound = true
                    set NewVFX = W
                    set W.IsAvailable = false
                    set W.AssignedPlayer = option{Agent}
                    W.VFX.Enable()
            race:
                block:
                    loop:
                        LeavingPlayer := GetPlayspace().PlayerRemovedEvent().Await()
                        if(Agent = LeavingPlayer):
                            set NewVFX.IsAvailable = true
                            NewVFX.VFX.Disable()
                            break
                loop:
                    Sleep(0.1)
                    if(NewVFX.VFX.TeleportTo[FC.GetTransform().Translation,FC.GetTransform().Rotation]):

    #Disables builds in arena
    DisableBuilds(Duration : float)<suspends> : void=
        DisableBuildsMutator.Enable()
        Sleep(Duration)
        DisableBuildsMutator.Disable()            

#Different options for who an ability should effect
OptionsEffected := enum:
    ClosestPlayer
    AllPlayers
    RandomPlayer

#Different options for who an ability should effect
OptionsEffectedNotAll := enum:
    ClosestPlayer
    RandomPlayer
    
#Applies an effect for a specified duration
DurationEffect := class<concrete>(Effect):
    TT_Invulnerability<localizes>:message = "Should Player Become Invulnerable"
    TT_Invisibility<localizes>:message = "Should Player Become Invisible"
    TT_EffectDuration<localizes>:message = "Duration of Effect"
    @editable{ToolTip := TT_Invulnerability} Invulnerability: logic = false
    @editable{ToolTip := TT_Invisibility} Invisibility : logic = false
    @editable{ToolTip := TT_EffectDuration} Duration : float = 0.0
    Enable(Agent:agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            if(DMG := DMGBoost?):
                DMG.SetDuration(Duration)
                DMG.Pickup(Agent)
            if(Speed := SpeedBoost?){Speed.Activate(Agent)}
            if(VFX := VFXPowerup?):
                VFX.SetDuration(Duration)
                VFX.Pickup(Agent)
            if(Invisibility?){FC.Hide()}
            if(Invulnerability?){FC.SetVulnerability(false)}
            Sleep(Duration)
            if(Invisibility?){FC.Show()}
            if(Invulnerability?){FC.SetVulnerability(true)}

#Applies an effect until manually cleared
AbilityEffect := class<concrete>(Effect):
    @editable ClassSwitch : ?class_and_team_selector_device = false
    Enable(Agent:agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            if(DMG := DMGBoost?){DMG.Pickup(Agent)}
            if(Speed := SpeedBoost?){Speed.Activate(Agent)}
            if(VFX := VFXPowerup?){ VFX.Pickup(Agent)}
            if(Class := ClassSwitch?){Class.ChangeTeamAndClass(Agent)}
               
#Base class used for effects
Effect := class<concrete>():
    @editable DMGBoost : ?damage_amplifier_powerup_device = false
    @editable SpeedBoost : ?movement_modulator_device = false
    @editable VFXPowerup : ?visual_effect_powerup_device = false
 

#Custom UI Timer class
UITimer := class():
    var TimerCanvas : canvas = canvas{}
    var TimerText : text_block = text_block{DefaultJustification := text_justification.Center,DefaultTextColor := White, DefaultShadowColor := Black, DefaultShadowOffset := option{vector2{X:= 1.0, Y:= 1.0}}}
    var Minutes : int = 0
    var Seconds : int = 0
    var TimerMessage : string = ""
    TimerEndEvent : event() = event(){}
    CancelEvent : event() = event(){}
    
    TimerStringToMessage<localizes>(String : string) : message = "{String}"

    HandleTimer(Agent : agent )<suspends> : void=
        TimerText.SetShadowOpacity(1.0)
        if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
            var SecondsZeros : string = ""
            TimerText.SetText(TimerStringToMessage("{TimerMessage}\n{Minutes}:{SecondsZeros}{Seconds}"))
            race:
                block:
                    CancelEvent.Await()
                    TimerEndEvent.Signal()
                    return
                loop:
                    Sleep(1.0)
                    set Seconds -= 1
                    if(Seconds <= 0):
                        if(Minutes <= 0):
                            TimerEndEvent.Signal()
                            break
                        else:
                            set Minutes -= 1
                            set Seconds = 60

                    if(Seconds < 10){set SecondsZeros = "0"}
                    else{set SecondsZeros = ""}

                    TimerText.SetText(TimerStringToMessage("{TimerMessage}{Minutes}:{SecondsZeros}{Seconds}"))

#Class for individual custom models
CustomModel := class<concrete>():
    TT_ModelProp<localizes>:message = "Creative Prop Used to replace the Character\n*Required Settings*\nCollision Presets: No Collision"
    TT_ModelRunningAnimationCin<localizes>:message = "Cinematic Sequence To Play Animations for 'ModelProp' while player is moving\n*Required Settings*\nLoop Playback: True"
    @editable{ToolTip := TT_ModelProp} ModelProp : creative_prop = creative_prop{}
    @editable{ToolTip := TT_ModelRunningAnimationCin} ModelRunningAnimationCin : cinematic_sequence_device = cinematic_sequence_device{}
    var IsUsed : logic = false

#A collection of settings for all weapon abilities
GunAbility := class<concrete>():
    @editable var AbilityManager : Manager_Ability = Manager_Ability{}
    TT_CooldownTime<localizes>:message = "If Enabled, Removes the Weapon Abilities weapon from the player for the specified duration"
    TT_RequireEquipped<localizes>:message = "If Enabled, only players with this ability equipped can use weapon abilities"
    @editable{ToolTip := TT_ItemConditional} Conditional : conditional_button_device = conditional_button_device{}
    @editable{ToolTip := TT_ItemRemover} ItemRemover : item_remover_device = item_remover_device{}
    @editable{ToolTip := TT_ItemGranter} ItemGranter : item_granter_device = item_granter_device{}
    @editable{ToolTip := TT_CooldownTime} CooldownTime : ?float = false
    @editable{ToolTip := TT_RequireEquipped} RequireEquipped : logic = false
    var EquippedPlayers : []agent = array{}

    #Sets up the gun ability
    Setup(EquippedTrigger : trigger_device , UnEquippedTrigger : trigger_device, AbilityMan : Manager_Ability) : void=
        EquippedTrigger.TriggeredEvent.Subscribe(EquipGunAbility)
        UnEquippedTrigger.TriggeredEvent.Subscribe(UnEquipGunAbility)
        set AbilityManager = AbilityMan

    #Equips the gun ability
    EquipGunAbility(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            set EquippedPlayers += array{Agent}

    #Unequips the gun ability
    UnEquipGunAbility(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            if(NewArray := EquippedPlayers.RemoveFirstElement[Agent]){set EquippedPlayers = NewArray}

    #Checks to see if the ability should activate
    Check(Agent : agent) : logic=
        if(Conditional.IsHoldingItem[Agent]):
            if(RequireEquipped?):
                if(EquippedPlayers.Find[Agent]):
                    spawn{HandleDelay(Agent)}
                    return true
                else:
                    return false
            else:
                spawn{HandleDelay(Agent)}
                return true
        else:
            return false

    #Handles delay for the weapon ability
    HandleDelay(Agent : agent)<suspends> : void=
        if(Delay := CooldownTime?, FC := Agent.GetFortCharacter[]):
            ItemRemover.Remove(Agent)
            Sleep(Delay)
            if(AbilityManager.AllowAbilityActivation?):
                ItemGranter.GrantItem(Agent)

    
#Finds the nearest target from a player
FindNearestTarget(FromPlayer : fort_character , AllTargets : []fort_character)<transacts><decides> : fort_character =
    var MaybeTarget : ?fort_character = false
    var NearestLocation : float = 1000000.0
    for (Target : AllTargets):
        if (DistancePlayerToTarget := Distance(Target.GetTransform().Translation, FromPlayer.GetTransform().Translation) < NearestLocation):
            set MaybeTarget = option{Target}
            set NearestLocation = DistancePlayerToTarget
    return MaybeTarget?

#Plays a VFX at a location
PlayVFX(Location : vector3 , VFX : vfx_spawner_device)<suspends> : void=
    if(VFX.TeleportTo[Location,IdentityRotation()]):
        VFX.Enable()
        Sleep(0.2)
        VFX.Disable()


#Different options for how explosions should operate for projectile
ExplosionType := enum:
    None
    Looping
    Contact

#Class for each preset projectile
BallProjectile := class<concrete>():
    TT_BallProp<localizes>:message = "Creative Prop Used as Projectile\n*Required Settings*\nCollision Presets: No Collision\nShould Parent: 'BallExplosive', 'BallDamage', 'BallExplodeVFX', and 'LocationSound'"
    TT_BallExplosive<localizes>:message = "Explosive device that explodes at projectile location\n*Required Settings*\nCan Be Damaged: False\nStructure Damage: 5000\nVisible During Game: False\nCollision During Games: Off\nShow Health Bar: False\nTime Until Reset Allowed: 0.1"
    TT_BallDamage<localizes>:message = "Damage Volume Used to Track Contact and Damage Players\n*Required Settings*\nInvert Team Selection: True"
    TT_BallExplodeVFX<localizes>:message = "VFX Spawner Device that plays at projectile location\n*Required Settings*\nEnabled On Phase: None\nClear Particles On Disable: False"
    TT_LocationSound<localizes>:message = "Plays Sound at projecitle location\n*Required Settings*\nPlay Location: Instigating Player"
    @editable{ToolTip := TT_BallProp} BallProp : creative_prop = creative_prop{}
    @editable{ToolTip := TT_BallExplosive} BallExplosive : explosive_device = explosive_device{}
    @editable{ToolTip := TT_BallDamage} BallDamage : damage_volume_device = damage_volume_device{}
    @editable{ToolTip := TT_BallExplodeVFX} BallExplodeVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable{ToolTip := TT_LocationSound} LocationSound : audio_player_device = audio_player_device{}
    var IsAvailable : logic = true

#Arena settings for instigator and target in arena
ArenaActivateSetting := class<concrete>():
    TT_ArenaTP<localizes>:message = "Teleporter Device Used To Teleport Player\n*Required Settings*\nTeleporter Group: None\nTeleporter Target Group: None"
    TT_ArenaEffects<localizes>:message = "Effects granted to player when entering separate arena"
    TT_LeavePropAtInitialPosition<localizes>:message = "If Enabled, will spawn prop at players location in previous arena"
    @editable{ToolTip := TT_ArenaTP} ArenaTP : teleporter_device = teleporter_device{}
    @editable{ToolTip := TT_ArenaEffects} Effects : DurationEffect = DurationEffect{}
    @editable{ToolTip := TT_LeavePropAtInitialPosition} LeavePropAtInitialPosition : ?creative_prop_asset = false

#Freezes a specific player for a duration
FreezePlayerDuration(FC : fort_character , Duration : float)<suspends> : void=
    FC.PutInStasis(stasis_args{})
    Sleep(Duration)
    FC.ReleaseFromStasis()


#General Tool Tips
TT_AbilityManager<localizes>:message = "Ability Manager Verse Device Required To Use All Abilities"
TT_ActivateTrigger<localizes>:message = "Trigger Used to Activate an Ability"
TT_EquipTrigger<localizes>:message = "Trigger Used to Equip an Ability"
TT_UnEquipTrigger<localizes>:message = "Trigger Used to UnEquip an Ability"
TT_Cooldown<localizes>:message = "Duration in between uses of this Ability"
TT_HelperFunctions<localizes>:message = "Helper Functions Verse Device used to assist several abilities"
TT_GunSettings<localizes>:message = "Settings & Devices to control Weapon Abilities"
TT_Duration<localizes>:message = "Duration of Ability"
TT_ActivateSound<localizes>:message = "Plays Sound On Activation\n*Required Settings*\nPlay Location: Instigating Player"
TT_Position<localizes>:message = "Position of this Widget on a Canvas"
TT_Effects<localizes>:message = "Grants to Instigator on Activation"
TT_Explosive<localizes>:message = "Explosive device that explodes on activation\n*Required Settings*\nCan Be Damaged: False\nStructure Damage: 5000\nVisible During Game: False\nCollision During Games: Off\nShow Health Bar: False\nTime Until Reset Allowed: 0.1"
TT_OnlyWork1v1<localizes>:message = "Should this Ability only work in a 1v1 scenario"
TT_RemoteConditional<localizes>:message = "Conditional Button Device\n*Required Settings*\nKey Item 1: Signal Remote Used in Main Remote Manager"
TT_HUDMessage<localizes>:message = "Hud Message Device that displays a message to a player\n*Required Settings*\nMessage Recipient: Triggering Player"
TT_ItemRemover<localizes>:message = "Item Remover Device that Removes the Weapon Allocated with Ability\n*Required Settings*\nItem List 1: Item/Weapon Used For Ability"
TT_ItemGranter<localizes>:message = "Item Granter Device that Grants the Weapon Allocated with Ability\n*Required Settings*\nItem List 1: Item/Weapon Used For Ability\n On Grant Action: Keep All"
TT_ItemConditional<localizes>:message = "Conditional Button Device Used to Check if Players are Holding the Weapon/Item Alloacted with Ability\n*Required Settings*\nKey Item 1: Item/Weapon Used For Ability"
