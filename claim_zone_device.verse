
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
claim_zone_device := class(creative_device):
    var CustomPlayers : [player]custom_player = map{}
    var LaClasse : int = 0
    

    @editable
    zone_class : int = 0

    @editable
    zone_claim : mutator_zone_device = mutator_zone_device{}

    @editable
    zones_text : []creative_prop = array{}

    @editable
    zone_selector : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    balise : beacon_device = beacon_device{}

    @editable
    companion1 : []creative_prop_asset = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        zone_selector.ClassSwitchedEvent.Subscribe(OnClassSwitched)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)

    OnClassSwitched(pAgent : agent) : void=
        Print("Je change de classe")
        zone_claim.Disable()
        for (zone_text : zones_text) :
            zone_text.Hide()

        balise.Disable()

        if (lPlayer := player[pAgent]) :
            if (Existing := CustomPlayers[lPlayer]) :
                Print("Le joueur existe")
            else :
                Print("Le joueur n'existe pas")
                if (lCompanion := companion1[0]) :
                    CustomPlayer := custom_player{Player := lPlayer}
                    CustomPlayer.SetClass(zone_class)

                    if (set CustomPlayers[lPlayer] = CustomPlayer) {}

    OnPlayerLeftServer(pPlayerLeaving : player) : void=
        if (Existing := CustomPlayers[pPlayerLeaving]) :
            set LaClasse = Existing.GetClass()
            if (LaClasse = zone_class) :
                Print("Un joueur a quitté le serveur CLAIM Classe {LaClasse}")
                zone_claim.Enable()
                for (zone_text : zones_text) :
                    zone_text.Show()

                balise.Enable()

            # Remove the player from our map to free up memory
            var NewCustomPlayerMap : [player]custom_player = map{}

            for (Key -> Value : CustomPlayers, Key <> pPlayerLeaving):
                set NewCustomPlayerMap = ConcatenateMaps( NewCustomPlayerMap, map{Key => Value})

            set CustomPlayers = NewCustomPlayerMap

            