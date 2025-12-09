using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#══════════════════════════════════════════════════════════════════════════════
# SIMULATOR PET - Système de pets avec follow visuel
#══════════════════════════════════════════════════════════════════════════════

#──────────────────────────────────────────────────────────────────────────────
# DÉFINITION D'UN TYPE DE PET (Configuration)
#──────────────────────────────────────────────────────────────────────────────
pet_type_config := class<concrete>:
    @editable
    ID : int = 0

    @editable
    Name : string = "Pet"

    @editable
    Rarity : pet_rarity = pet_rarity.Common

    @editable
    BaseDamage : float = 1.0

    @editable
    BaseSpeed : float = 0.0

    @editable
    BaseCurrencyBonus : float = 0.0

    @editable
    PropAsset : creative_prop_asset = creative_prop_asset{}

    @editable
    Scale : float = 1.0

    @editable
    FloatHeight : float = 100.0  # Hauteur de flottement au-dessus du sol

    @editable
    FloatAmplitude : float = 20.0  # Amplitude du mouvement de flottement

    @editable
    FloatSpeed : float = 2.0  # Vitesse du mouvement de flottement

#──────────────────────────────────────────────────────────────────────────────
# INSTANCE D'UN PET ACTIF (Spawned et suivant un joueur)
#──────────────────────────────────────────────────────────────────────────────
active_pet := class:
    Config : pet_type_config
    OwnerPlayer : player
    var Prop : ?creative_prop = false
    var IsActive : logic = false

    # Position dans l'orbite (pour plusieurs pets)
    var OrbitIndex : int = 0
    var OrbitAngle : float = 0.0

    # Animation de flottement
    var FloatTimer : float = 0.0

    #──────────────────────────────────────────────────────────────────────────
    # SPAWN LE PET
    #──────────────────────────────────────────────────────────────────────────
    Spawn(SpawnPosition : vector3, Manager : simulator_pet_manager) : void =
        # Spawn le prop
        SpawnedProp := Manager.SpawnProp(Config.PropAsset, SpawnPosition)
        if (NewProp := SpawnedProp?):
            set Prop = option{NewProp}
            set IsActive = true

    #──────────────────────────────────────────────────────────────────────────
    # DESPAWN LE PET
    #──────────────────────────────────────────────────────────────────────────
    Despawn() : void =
        if (CurrentProp := Prop?):
            # Déplace sous la map pour "despawn"
            CurrentPos := CurrentProp.GetTransform().Translation
            HidePos := CurrentPos - vector3{Z := 50000.0}
            if (CurrentProp.TeleportTo[HidePos, CurrentProp.GetTransform().Rotation]) {}
        set IsActive = false
        set Prop = false

    #──────────────────────────────────────────────────────────────────────────
    # MISE À JOUR POSITION (appelée chaque tick)
    #──────────────────────────────────────────────────────────────────────────
    UpdatePosition(TargetPosition : vector3, DeltaTime : float, TotalPets : int) : void =
        if (not IsActive?):
            return

        if (CurrentProp := Prop?):
            # Calcule la position en orbite
            AngleOffset := (2.0 * 3.14159) * (OrbitIndex * 1.0) / (TotalPets * 1.0)
            set OrbitAngle += SimulatorConstants.PetOrbitSpeed * DeltaTime
            FinalAngle := OrbitAngle + AngleOffset

            # Position en cercle autour du joueur
            OrbitRadius := SimulatorConstants.PetFollowDistance
            OffsetX := Cos(FinalAngle) * OrbitRadius
            OffsetY := Sin(FinalAngle) * OrbitRadius

            # Animation de flottement vertical
            set FloatTimer += Config.FloatSpeed * DeltaTime
            FloatOffset := Sin(FloatTimer) * Config.FloatAmplitude

            # Position cible
            TargetPos := vector3:
                X := TargetPosition.X + OffsetX
                Y := TargetPosition.Y + OffsetY
                Z := TargetPosition.Z + Config.FloatHeight + FloatOffset

            # Interpolation smooth vers la cible
            CurrentPos := CurrentProp.GetTransform().Translation
            LerpSpeed := SimulatorConstants.PetFollowSpeed * DeltaTime
            NewPos := vector3:
                X := Lerp(CurrentPos.X, TargetPos.X, LerpSpeed)
                Y := Lerp(CurrentPos.Y, TargetPos.Y, LerpSpeed)
                Z := Lerp(CurrentPos.Z, TargetPos.Z, LerpSpeed)

            # Rotation pour regarder le joueur
            DirectionToPlayer := TargetPosition - NewPos
            if (Length(DirectionToPlayer) > 0.1):
                LookRotation := MakeLookRotation(DirectionToPlayer, vector3{Z := 1.0})
                if (CurrentProp.TeleportTo[NewPos, LookRotation]) {}
            else:
                if (CurrentProp.TeleportTo[NewPos, CurrentProp.GetTransform().Rotation]) {}

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR LA DÉFINITION
    #──────────────────────────────────────────────────────────────────────────
    GetDefinition() : pet_definition =
        pet_definition:
            ID := Config.ID
            Name := Config.Name
            Rarity := Config.Rarity
            BaseDamage := Config.BaseDamage
            BaseSpeed := Config.BaseSpeed
            BaseCurrencyBonus := Config.BaseCurrencyBonus
            PropAsset := Config.PropAsset

#══════════════════════════════════════════════════════════════════════════════
# MANAGER DES PETS
#══════════════════════════════════════════════════════════════════════════════
simulator_pet_manager := class(creative_device):

    @editable
    PetTypes : []pet_type_config = array{}

    @editable
    PropSpawners : []prop_spawner_device = array{}  # Pool de spawners

    @editable
    UpdateTickRate : float = 0.05  # 20 FPS pour le mouvement des pets

    # Pets actifs par joueur
    var PlayerPets : [player][]active_pet = map{}

    # Index du prochain spawner disponible
    var NextSpawnerIndex : int = 0

    #──────────────────────────────────────────────────────────────────────────
    # INITIALISATION
    #──────────────────────────────────────────────────────────────────────────
    OnBegin<override>()<suspends> : void =
        # Démarre la boucle de mise à jour
        spawn{UpdateLoop()}

        # Subscribe aux événements de joueur
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

        # Initialise les joueurs existants
        for (Player : GetPlayspace().GetPlayers()):
            InitializePlayerPets(Player)

    #──────────────────────────────────────────────────────────────────────────
    # BOUCLE DE MISE À JOUR
    #──────────────────────────────────────────────────────────────────────────
    UpdateLoop()<suspends> : void =
        loop:
            Sleep(UpdateTickRate)
            UpdateAllPets()

    UpdateAllPets() : void =
        for (Player -> Pets : PlayerPets):
            if (FC := Player.GetFortCharacter[]):
                PlayerPos := FC.GetTransform().Translation
                TotalPets := Pets.Length
                for (Pet : Pets):
                    Pet.UpdatePosition(PlayerPos, UpdateTickRate, TotalPets)

    #──────────────────────────────────────────────────────────────────────────
    # GESTION DES JOUEURS
    #──────────────────────────────────────────────────────────────────────────
    OnPlayerJoined(Player : player) : void =
        InitializePlayerPets(Player)

    OnPlayerLeft(Player : player) : void =
        # Despawn tous les pets du joueur
        if (Pets := PlayerPets[Player]):
            for (Pet : Pets):
                Pet.Despawn()

        # Retire de la map
        var NewMap : [player][]active_pet = map{}
        for (Key -> Value : PlayerPets):
            if (Key <> Player):
                if (set NewMap[Key] = Value) {}
        set PlayerPets = NewMap

    InitializePlayerPets(Player : player) : void =
        if (not PlayerPets[Player]):
            if (set PlayerPets[Player] = array{}) {}

        # Charge les pets équipés depuis la persistence
        EquippedPetIDs := GetEquippedPets(Player)
        for (PetID : EquippedPetIDs):
            SpawnPetForPlayer(Player, PetID)

    #──────────────────────────────────────────────────────────────────────────
    # SPAWN UN PET POUR UN JOUEUR
    #──────────────────────────────────────────────────────────────────────────
    SpawnPetForPlayer(Player : player, PetID : int) : ?active_pet =
        # Trouve la config du pet
        var PetConfig : ?pet_type_config = false
        for (Config : PetTypes):
            if (Config.ID = PetID):
                set PetConfig = option{Config}
                break

        if (Config := PetConfig?):
            # Obtient la position du joueur
            SpawnPos := vector3{}
            if (FC := Player.GetFortCharacter[]):
                set SpawnPos = FC.GetTransform().Translation + vector3{Z := Config.FloatHeight}

            # Crée le pet actif
            NewPet := active_pet:
                Config := Config
                OwnerPlayer := Player

            # Définit l'index d'orbite
            if (ExistingPets := PlayerPets[Player]):
                set NewPet.OrbitIndex = ExistingPets.Length

            # Spawn le prop
            NewPet.Spawn(SpawnPos, Self)

            # Ajoute à la liste
            if (ExistingPets := PlayerPets[Player]):
                if (set PlayerPets[Player] = ExistingPets + array{NewPet}) {}
            else:
                if (set PlayerPets[Player] = array{NewPet}) {}

            return option{NewPet}

        false

    #──────────────────────────────────────────────────────────────────────────
    # DESPAWN UN PET
    #──────────────────────────────────────────────────────────────────────────
    DespawnPetForPlayer(Player : player, PetID : int) : void =
        if (Pets := PlayerPets[Player]):
            var NewPets : []active_pet = array{}
            var IndexCounter : int = 0
            for (Pet : Pets):
                if (Pet.Config.ID = PetID):
                    Pet.Despawn()
                else:
                    set Pet.OrbitIndex = IndexCounter
                    set IndexCounter += 1
                    set NewPets += array{Pet}
            if (set PlayerPets[Player] = NewPets) {}

    #──────────────────────────────────────────────────────────────────────────
    # DESPAWN TOUS LES PETS D'UN JOUEUR
    #──────────────────────────────────────────────────────────────────────────
    DespawnAllPetsForPlayer(Player : player) : void =
        if (Pets := PlayerPets[Player]):
            for (Pet : Pets):
                Pet.Despawn()
            if (set PlayerPets[Player] = array{}) {}

    #──────────────────────────────────────────────────────────────────────────
    # SPAWN UN PROP (utilise le pool de spawners)
    #──────────────────────────────────────────────────────────────────────────
    SpawnProp(Asset : creative_prop_asset, Position : vector3) : ?creative_prop =
        if (PropSpawners.Length > 0):
            if (Spawner := PropSpawners[NextSpawnerIndex mod PropSpawners.Length]):
                set NextSpawnerIndex += 1
                # Note: Dans UEFN, on utiliserait SpawnProp avec l'asset
                # Pour l'instant, on retourne false car le système exact dépend de l'implémentation
                return false
        false

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR UN TYPE DE PET PAR ID
    #──────────────────────────────────────────────────────────────────────────
    GetPetTypeByID(PetID : int) : ?pet_type_config =
        for (Config : PetTypes):
            if (Config.ID = PetID):
                return option{Config}
        false

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR LES PETS ACTIFS D'UN JOUEUR
    #──────────────────────────────────────────────────────────────────────────
    GetActivePets(Player : player) : []active_pet =
        if (Pets := PlayerPets[Player]):
            Pets
        else:
            array{}

    #──────────────────────────────────────────────────────────────────────────
    # OBTENIR TOUS LES TYPES DE PETS PAR RARETÉ
    #──────────────────────────────────────────────────────────────────────────
    GetPetTypesByRarity(Rarity : pet_rarity) : []pet_type_config =
        var Result : []pet_type_config = array{}
        for (Config : PetTypes):
            if (Config.Rarity = Rarity):
                set Result += array{Config}
        Result

#══════════════════════════════════════════════════════════════════════════════
# FONCTIONS MATHÉMATIQUES UTILITAIRES
#══════════════════════════════════════════════════════════════════════════════

# Interpolation linéaire
Lerp(A : float, B : float, T : float) : float =
    A + (B - A) * Clamp(T, 0.0, 1.0)

# Clamp
Clamp(Value : float, Min : float, Max : float) : float =
    if (Value < Min):
        Min
    else if (Value > Max):
        Max
    else:
        Value

# Longueur d'un vecteur
Length(V : vector3) : float =
    Sqrt(V.X * V.X + V.Y * V.Y + V.Z * V.Z)

# Crée une rotation pour regarder une direction
MakeLookRotation(Direction : vector3, Up : vector3) : rotation =
    # Simplifié - dans un vrai projet, utilisez les fonctions de SpatialMath
    IdentityRotation()

# Rotation identité
IdentityRotation() : rotation =
    rotation{}

#══════════════════════════════════════════════════════════════════════════════
# SYSTÈME DE PETS SIMPLIFIÉ (Version alternative avec props pré-placés)
#══════════════════════════════════════════════════════════════════════════════
simple_pet_follow := class(creative_device):
    @editable
    Prop : creative_prop = creative_prop{}

    @editable
    OwnerPlayerIndex : int = 0  # Index du joueur (0-based)

    @editable
    OrbitRadius : float = 150.0

    @editable
    OrbitSpeed : float = 2.0

    @editable
    FloatHeight : float = 100.0

    @editable
    FloatAmplitude : float = 20.0

    @editable
    FloatSpeed : float = 2.0

    @editable
    FollowLerpSpeed : float = 5.0

    var OrbitAngle : float = 0.0
    var FloatTimer : float = 0.0
    var OwnerPlayer : ?player = false

    OnBegin<override>()<suspends> : void =
        # Trouve le joueur propriétaire
        Players := GetPlayspace().GetPlayers()
        if (OwnerPlayerIndex < Players.Length):
            if (P := Players[OwnerPlayerIndex]):
                set OwnerPlayer = option{P}

        # Boucle de suivi
        loop:
            Sleep(0.033)  # ~30 FPS
            UpdateFollow(0.033)

    UpdateFollow(DeltaTime : float) : void =
        if (Player := OwnerPlayer?):
            if (FC := Player.GetFortCharacter[]):
                PlayerPos := FC.GetTransform().Translation

                # Orbite
                set OrbitAngle += OrbitSpeed * DeltaTime
                OffsetX := Cos(OrbitAngle) * OrbitRadius
                OffsetY := Sin(OrbitAngle) * OrbitRadius

                # Flottement
                set FloatTimer += FloatSpeed * DeltaTime
                FloatOffset := Sin(FloatTimer) * FloatAmplitude

                # Position cible
                TargetPos := vector3:
                    X := PlayerPos.X + OffsetX
                    Y := PlayerPos.Y + OffsetY
                    Z := PlayerPos.Z + FloatHeight + FloatOffset

                # Interpolation
                CurrentPos := Prop.GetTransform().Translation
                LerpFactor := FollowLerpSpeed * DeltaTime
                NewPos := vector3:
                    X := Lerp(CurrentPos.X, TargetPos.X, LerpFactor)
                    Y := Lerp(CurrentPos.Y, TargetPos.Y, LerpFactor)
                    Z := Lerp(CurrentPos.Z, TargetPos.Z, LerpFactor)

                if (Prop.TeleportTo[NewPos, Prop.GetTransform().Rotation]) {}
