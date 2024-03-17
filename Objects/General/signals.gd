extends Node

var battle_map : BattleMap = null 

signal sg_battlemap_set_units_selected(unit : Unit, value : bool) # DO NOTHING YET
signal sg_battlemap_set_units_hovered(unit : Unit, value : bool) # DO NOTHING YET

# UI
# UI request data -> DiplomacyManager recieve it  
signal sg_diplomacy_nation_request_data(nation_tag : String)
# DiplomacyManager get a request for data and then send the data 
signal sg_diplomacy_nation_send_data(data : DiplomacyNation)


