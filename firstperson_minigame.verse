using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

firstperson_minigame := class(creative_device):

    @editable FirstPersonCamrea:gameplay_camera_orbit_device = gameplay_camera_orbit_device{}

    StartMinigame():void=
        if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
            UtilsSystem.GrantStandardItems()

        FirstPersonCamrea.AddToAll()

    ResetMinigame():void=
        FirstPersonCamrea.RemoveFromAll()