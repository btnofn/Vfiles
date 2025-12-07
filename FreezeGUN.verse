

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }


FreezeGUN := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable FreezeGunClassNumber : int = 100
    @editable ClassRequirement : int = 0
    #0 : no class requirement
    #1 : class requirement





    @editable FreezeGUNConditional: conditional_button_device = conditional_button_device{}
    @editable FreezeGUNFreezeTime : float = 0.0
    @editable FreezeGUNCooldownTime : float = 0.0
    @editable FreezeGUNProp : creative_prop = creative_prop{}
    @editable FreezeGUNItemRemover : item_remover_device = item_remover_device{}
    @editable FreezeGUNItemGranter : item_granter_device = item_granter_device{}
    @editable FreezeGUNSound : audio_player_device = audio_player_device{}



    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)
            FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamaged)
    OnPlayerDamaged(DamageResult: damage_result): void = 
        if: 
            Instigator := DamageResult.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            FreezeGUNConditional.IsHoldingItem[Agent]
            Target:= fort_character[DamageResult.Target]
        then:
            if(ClassRequirement = 0):
                spawn:
                    FreezePlayer(Target,Agent)
            else if(ClassRequirement = 1):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = FreezeGunClassNumber):
                    spawn:
                        FreezePlayer(Target,Agent)
                else:
    FreezePlayer(Target : fort_character,Agent:agent)<suspends> : void=
        if(Player := player[Agent], FC:= Player.GetFortCharacter[],TargetAgent := Target.GetAgent[]):
            if(Target = FC):   
                block:
            else:
                spawn:
                    RemoveandGive(Agent)
                FreezeGUNSound.Play(TargetAgent)
                Target.PutInStasis(stasis_args{})
                if(FreezeGUNProp.TeleportTo[Target.GetTransform().Translation - vector3{Z:=80.0}, Target.GetTransform().Rotation]){}
                Sleep(FreezeGUNFreezeTime)
                Target.ReleaseFromStasis()
                if(FreezeGUNProp.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=1000.0},FreezeGUNProp.GetTransform().Rotation]){}
                

    RemoveandGive(Agent : agent)<suspends> : void=
        FreezeGUNItemRemover.Remove(Agent)
        Sleep(FreezeGUNCooldownTime)
        FreezeGUNItemGranter.GrantItem(Agent)