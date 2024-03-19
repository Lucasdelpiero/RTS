extends Node

var battle_map : BattleMap = null 

signal sg_battlemap_set_units_selected(unit : Unit, value : bool) # DO NOTHING YET
signal sg_battlemap_set_units_hovered(unit : Unit, value : bool) # DO NOTHING YET

# UI
# UI request data -> DiplomacyManager recieve it  
signal sg_diplomacy_nation_request_data(nation_tag : String)

# DiplomacyManager get a request for data and then send the data 
signal sg_diplomacy_nation_send_data(data : DiplomacyNation)

# Used to use the function in the diplomacy manager
signal sg_diplomacy_nation_improve_relations(sender: String, receiver: String, amount: int)

# When a diplomacy_nation changes the relations with a nation it sends to all listeners and they update the value if their nationg_tag identifier are the same
signal sg_diplomacy_relations_changed(nation_tag: String, new_value: int)

# Used when the button representing a nation is pressed to send data to create
# a panel so the nation can be interacted with
signal sg_btn_diplomacy_nation_selected(nation_tag : String)

# Used in the battlemap when pressing a number to select a group
func battlemap_set_units_selected(unit : Unit, value : bool) -> void:
	sg_battlemap_set_units_selected.emit(unit, value)

func battlemap_set_units_hovered(unit : Unit, value : bool) -> void:
	sg_battlemap_set_units_hovered.emit(unit, value)


