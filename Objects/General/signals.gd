extends Node

var battle_map : BattleMap = null 

# World
# When the world has new or less nations and modify its array containing the nations
# all the things that needs to keep an array of the living nations are updated with
# the new array (UI, diplomacy relationships, etc)
signal sg_nations_array_changed(nation_array: Array[Nation])

# For when a nation is deleted and one wants to delete this specific nation from
# parts of the code without having to use the entire list of nations
# ex. removing a deleted nation from a list without having to create the list from zero
# with all the nations containing the array 
# Used in the world when a nation is annexed
signal sg_nation_deleted(nation_tag : String)

# UI
#region diplomacy
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

signal sg_btn_diplomacy_annexed_nation(nation_tag: String, target_tag: String)

signal sg_annex_provinces(nation_tag: String, provinces: Array[Province])

#endregion


signal sg_battlemap_set_units_selected(unit : Unit, value : bool) # DO NOTHING YET
signal sg_battlemap_set_units_hovered(unit : Unit, value : bool) # DO NOTHING YET

# Used in the battlemap when pressing a number to select a group
func battlemap_set_units_selected(unit : Unit, value : bool) -> void:
	sg_battlemap_set_units_selected.emit(unit, value)

func battlemap_set_units_hovered(unit : Unit, value : bool) -> void:
	sg_battlemap_set_units_hovered.emit(unit, value)


