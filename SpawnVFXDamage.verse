
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

SpawnVFXDamage := class(creative_device):

    @editable GameStartDevice : GameStart = GameStart{}
    @editable SpawnVFXDamClassNumber : int = 100

    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable SpawnVFXDamTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}


    @editable SpawnVFXDamSoundForAll : audio_player_device = audio_player_device{}
    @editable SpawnVFXDamSoundForOne : audio_player_device = audio_player_device{}

    @editable SpawnVFXDamLength : float = 0.0

    @editable SpawnVFXDamBottomVFXs : []vfx_spawner_device = array{}
    @editable SpawnVFXDamBottomZone : mutator_zone_device = mutator_zone_device{}


    @editable SpawnVFXDamPlayerVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable SpawnVFXDamPlayerZone : mutator_zone_device = mutator_zone_device{}

    @editable ZoneDMGAmount : float = 0.0
    @editable ZoneHealAmount : float = 0.0
    var Time : logic = false

    @editable SpawnVFXDamHealSetting : int = 0
    #1 = do nothing if activating play is in zone
    #2 = dmg if activating player in zone
    #3 = heal activating player in zone



    @editable SpawnVFXDamAreaSetting : int = 0
    #1 = full bottom floor
    #2 = only around player




    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        SpawnVFXDamTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        SpawnVFXDamTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false

    SpawnVFXDamageAbility(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            SpawnVFXDamTimer.Start(Agent)
            set MaybeCooldown=true
            spawn:
                ZoneCheck()
            if(SpawnVFXDamAreaSetting = 1):
                for(Player : GetPlayspace().GetPlayers()):
                    if(FC := Player.GetFortCharacter[], NewAgent:= FC.GetAgent[]):
                        SpawnVFXDamSoundForAll.Play(NewAgent)
                for(VFX : SpawnVFXDamBottomVFXs):
                    VFX.Enable()
                SpawnVFXDamBottomZone.Enable()
                Sleep(SpawnVFXDamLength)
                for(VFX : SpawnVFXDamBottomVFXs):
                    VFX.Disable()
                SpawnVFXDamBottomZone.Disable()

            else if(SpawnVFXDamAreaSetting = 2):
                SpawnVFXDamSoundForOne.Play(Agent)
                if(Player := player[Agent], FC:= Player.GetFortCharacter[]):
                    if(SpawnVFXDamPlayerVFX.TeleportTo[FC.GetTransform().Translation,IdentityRotation()]){}
                    if(SpawnVFXDamPlayerZone.TeleportTo[FC.GetTransform().Translation,IdentityRotation()]){}

                    SpawnVFXDamPlayerVFX.Enable()
                    SpawnVFXDamPlayerZone.Enable()
                    Sleep(SpawnVFXDamLength)
                    SpawnVFXDamPlayerVFX.Disable()
                    SpawnVFXDamPlayerZone.Disable()
                    if(SpawnVFXDamPlayerVFX.TeleportTo[vector3{X:=10000.0,Y:= 10000.0, Z:=10000.0},IdentityRotation()]){}
                    if(SpawnVFXDamPlayerZone.TeleportTo[vector3{X:=10000.0,Y:= 10000.0, Z:=10000.0},IdentityRotation()]){}
        else:
            CooldownMSG.Show(Agent)
    ZoneCheck()<suspends> : void=
        Sleep(3.0)
        set Time = false
        spawn:
            Timer()
        loop:
            Sleep(1.0)
            for(Player : GetPlayspace().GetPlayers()):
                if(FC := Player.GetFortCharacter[], Agent:= FC.GetAgent[]):
                    if(SpawnVFXDamBottomZone.IsInVolume[Agent]):
                        if(GameStartDevice.EachPlayerMap[Agent].ClassNum = SpawnVFXDamClassNumber):
                            if(SpawnVFXDamHealSetting = 1):
                            else if(SpawnVFXDamHealSetting =2):
                                FC.Damage(ZoneDMGAmount)

                            else if(SpawnVFXDamHealSetting = 3):
                                SheildAmount := FC.GetShield()
                                HealthAmount := FC.GetHealth()
                                    if(SheildAmount > 0.0):
                                        FC.SetShield(SheildAmount + ZoneHealAmount)
                                    else if(SheildAmount = 0.0 and HealthAmount < 100.0):
                                        FC.Heal(ZoneHealAmount)
                                    else:
                                        FC.SetShield(SheildAmount + ZoneHealAmount)
                        else:
                            FC.Damage(ZoneDMGAmount)



                    else if(SpawnVFXDamPlayerZone.IsInVolume[Agent]):
                        if(GameStartDevice.EachPlayerMap[Agent].ClassNum = SpawnVFXDamClassNumber):
                            if(SpawnVFXDamHealSetting = 1):
                            else if(SpawnVFXDamHealSetting =2):
                                FC.Damage(ZoneDMGAmount)

                            else if(SpawnVFXDamHealSetting = 3):
                                SheildAmount := FC.GetShield()
                                HealthAmount := FC.GetHealth()
                                    if(SheildAmount > 0.0):
                                        FC.SetShield(SheildAmount + ZoneHealAmount)
                                    else if(SheildAmount = 0.0 and HealthAmount < 100.0):
                                        FC.Heal(ZoneHealAmount)
                                    else:
                                        FC.SetShield(SheildAmount + ZoneHealAmount)
                        else:
                            FC.Damage(ZoneDMGAmount)

    Timer()<suspends> : void=
        Sleep(SpawnVFXDamLength)
        set Time = true




