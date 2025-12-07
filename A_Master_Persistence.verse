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

#THIS SCRIPT HOLDS & ADDS ALL PERSISTABLE VARIABLES FOR PLAYERS

#Stat type that is persistable
player_stat := class<final><persistable>:
    CurrentValue:int = 0
    SetHighestValue(NewValue:int)<transacts>:int=
        CurrentValue

#Makes a new stat based off of the current value
MakeUpdatedPlayerStat<constructor>(OldStats:player_stat, NewValue:int)<transacts> := player_stat:
    CurrentValue := NewValue

#Table holding all of the different persistable variables
player_stats_table := class<final><persistable>:

#Tycoon Content -----------------------------------------------------------------------------------------------------------------------------
    BoughtPets : []int = array {}
    BoughtDoors : []int = array {}
    BoughtApparels : []int = array{}
    BoughtColors : []int = array{}
    ClaimedRewards : []int = array{}
    
    EquippedPets : []int = array {}
    EquippedApparels : []int = array {0,0,0}

    Rebirths : float = 0.0
    Playtime : float = 0.0

    Bar1Upgrades : []int = array {}
    Bar2Upgrades : []int = array {}
    Bar3Upgrades : []int = array{}

    Currency1 : float = 0.0
    Currency2 : float = 0.0
    Currency3 : float = 0.0
    Currency4 : float = 0.0
    Currency5 : float = 0.0
    Currency6 : float = 0.0
    Currency7 : float = 0.0
    Currency8 : float = 0.0
    Currency9 : float = 0.0
    Currency10 : float = 0.0

#Ranked Content -------------------------------------------------------------------------------------------------------------------------------
    RankValue : float = 0.0
    Eliminations : float = 0.0
    Deaths : float = 0.0
    Wins : float = 0.0
    Loses : float = 0.0
    Prestiges : float = 0.0

#Finisher Content -------------------------------------------------------------------------------------------------------------------------------
    BoughtFinishers : []int = array {}
    EquippedFinisher : int = 0
    
#Player map to connect all of the values to a player
var PlayerStatsMap:weak_map(player, player_stats_table) = map{}

#Makes a new stats table from the current/old table
MakePlayerStatsTable<constructor>(OldTable:player_stats_table)<transacts> := player_stats_table:
    BoughtPets := OldTable.BoughtPets
    BoughtDoors := OldTable.BoughtDoors
    BoughtApparels := OldTable.BoughtApparels
    BoughtColors := OldTable.BoughtColors
    ClaimedRewards := OldTable.ClaimedRewards

    EquippedPets := OldTable.EquippedPets
    EquippedApparels := OldTable.EquippedApparels

    Rebirths := OldTable.Rebirths
    Playtime := OldTable.Playtime

    Bar1Upgrades := OldTable.Bar1Upgrades
    Bar2Upgrades := OldTable.Bar2Upgrades 
    Bar3Upgrades := OldTable.Bar3Upgrades

    Currency1 := OldTable.Currency1
    Currency2 := OldTable.Currency2
    Currency3 := OldTable.Currency3
    Currency4 := OldTable.Currency4
    Currency5 := OldTable.Currency5
    Currency6 := OldTable.Currency6
    Currency7 := OldTable.Currency7
    Currency8 := OldTable.Currency8
    Currency9 := OldTable.Currency9
    Currency10 := OldTable.Currency10





    RankValue := OldTable.RankValue
    Eliminations := OldTable.Eliminations
    Deaths := OldTable.Deaths
    Wins := OldTable.Wins
    Loses := OldTable.Loses
    Prestiges := OldTable.Prestiges


    BoughtFinishers := OldTable.BoughtFinishers
    EquippedFinisher := OldTable.EquippedFinisher


#Base stat type for each resource
stat_type := class<computes><abstract> :
    Name : string

#Classes of all different stat types
StatType := module:
    doors<public> := class<computes>(stat_type):
    pets<public> := class<computes>(stat_type):
    apparels<public> := class<computes>(stat_type):
    colors<public> := class<computes>(stat_type):
    rewards<public> := class<computes>(stat_type):


    equippedpets<public> := class<computes>(stat_type):
    equippedapparels<public> := class<computes>(stat_type):


    rebirths<public> := class<computes>(stat_type):
    playtime<public> := class<computes>(stat_type):

    bar1upgrades<public> := class<computes>(stat_type):
    bar2upgrades<public> := class<computes>(stat_type):
    bar3upgrades<public> := class<computes>(stat_type):

    currency1<public> := class<computes>(stat_type):
    currency2<public> := class<computes>(stat_type):
    currency3<public> := class<computes>(stat_type):
    currency4<public> := class<computes>(stat_type):
    currency5<public> := class<computes>(stat_type):
    currency6<public> := class<computes>(stat_type):
    currency7<public> := class<computes>(stat_type):
    currency8<public> := class<computes>(stat_type):
    currency9<public> := class<computes>(stat_type):
    currency10<public> := class<computes>(stat_type):




    rankvalue_stat<public> := class<computes>(stat_type):

    eliminations_stat<public> := class<computes>(stat_type):

    deaths_stat<public> := class<computes>(stat_type):

    wins_stat<public> := class<computes>(stat_type):

    loses_stat<public> := class<computes>(stat_type):

    prestiges_stat<public> := class<computes>(stat_type):




    boughtfinishers<public> := class<computes>(stat_type):
    equippedfinisher<public> := class<computes>(stat_type):
        
          


    # Instances of each stat_type you can use in your experience

    Doors <public>:doors = doors{Name := "Doors"}
    Pets <public>:pets = pets{Name := "Pets"}
    Apparels <public>:apparels = apparels{Name := "Apparels"}
    Colors <public>:colors = colors{Name := "Colors"}
    ClaimedRewards<public>:rewards = rewards{Name := "ClaimedRewards"}

    EquippedPets <public>:equippedpets = equippedpets{Name := "EquippedPets"}
    EquippedApparels <public>:equippedapparels = equippedapparels{Name := "EquippedApparels"}

    Rebirths <public>:rebirths = rebirths{Name := "Rebirths"}
    Playtime <public>:playtime = playtime{Name := "Playtime"}

    Bar1Upgrades <public>:bar1upgrades = bar1upgrades{Name := "Bar1Upgrades"}
    Bar2Upgrades <public>:bar2upgrades = bar2upgrades{Name := "Bar2Upgrades"}
    Bar3Upgrades <public>:bar3upgrades = bar3upgrades{Name := "Bar3Upgrades"}


    Currency1 <public>:currency1 = currency1{Name := "Currency1"}
    Currency2<public>:currency2 = currency2{Name := "Currency2"}
    Currency3<public>:currency3 = currency3{Name := "Currency3"}
    Currency4<public>:currency4 = currency4{Name := "Currency4"}
    Currency5<public>:currency5 = currency5{Name := "Currency5"}
    Currency6<public>:currency6 = currency6{Name := "Currency6"}
    Currency7<public>:currency7 = currency7{Name := "Currency7"}
    Currency8<public>:currency8 = currency8{Name := "Currency8"}
    Currency9<public>:currency9 = currency9{Name := "Currency9"}
    Currency10<public>:currency10 = currency10{Name := "Currency10"}




    RankValue<public>:rankvalue_stat = rankvalue_stat{Name := "RankValue"}
    Eliminations<public>:eliminations_stat = eliminations_stat{Name := "Eliminations"}
    Deaths<public>:deaths_stat = deaths_stat{Name := "Deaths"}
    Wins<public>:wins_stat = wins_stat{Name := "Wins"}
    Loses<public>:loses_stat = loses_stat{Name := "Loses"}
    Prestiges<public>:prestiges_stat = prestiges_stat{Name := "Prestiges"}
   


    BoughtFinishers <public>:boughtfinishers = boughtfinishers{Name := "BoughtFinishers"}
    EquippedFinisher <public>:equippedfinisher = equippedfinisher{Name := "EquippedFinisher"}