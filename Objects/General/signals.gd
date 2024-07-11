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

# On right click open the diplomacy screen on the clicked province owner
# Emmited by the province.gd script
# Listened by the Globals.gd script
signal sg_province_open_diplomacy(nation_tag: String)

# Changes the last province hovered in the Globals variable
signal sg_last_province_hovered_owner(nation_tag: String)

signal sg_battlemap_set_units_selected(unit : Unit, value : bool) # DO NOTHING YET
signal sg_battlemap_set_units_hovered(unit : Unit, value : bool) # DO NOTHING YET

# Used in the battlemap when pressing a number to select a group
func battlemap_set_units_selected(unit : Unit, value : bool) -> void:
	sg_battlemap_set_units_selected.emit(unit, value)

func battlemap_set_units_hovered(unit : Unit, value : bool) -> void:
	sg_battlemap_set_units_hovered.emit(unit, value)

#region IA

# TaskGroup -> Other TaskGroup`s
# When an unit changes from one task group to another, this is called
# to ensure that the unit is deleted from other groups
signal sg_ia_unit_changed_group(task_group : TaskGroup, unit : Unit)

# TaskGroup -> GroupsManager
# When an unit protecting a side is no longer needed, like when they have 
# more units than the ones they need to defend against, this is called
# an unit no longer needed is put in a generic task group in the battle line
signal sg_ia_unit_not_needed_in_side(unit: Unit)

# ai_battle_debug -> task_group
# Sends the units from the left flank to attack
signal sg_ia_attack_from(group_name : String)


# task_group -> enemy_battle_ia
# Task group ask to recieve orders to attack from the enemy battle ia
signal sg_ia_request_orders_to_attack(group : Array[Unit], enemy_group : Array[Unit])

# debug_button -> task_group
# sends a signal to the task group to send an unit to attack
signal sg_ia_debug_send_one_to_attack(group_name : String)

# task_group -> enemy_battle_ia
# Task group ask to recieve orders to have 1 unit to attack an enemy unit from a group
# sending 1 unit at a time to have a "mistake" made by the IA by sending 1 unit
# at a time to face the player
signal sg_ia_request_order_to_attack_one(unit : Unit, enemy_group : Array[Unit])



# Starts the battle IA to test things
signal sg_battle_ia_start_update

# Signal stops the battle ia to test things
signal sg_battle_ia_stop_update

#endregion
