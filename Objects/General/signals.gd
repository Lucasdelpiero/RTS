extends Node

var battle_map : BattleMap = null 



signal sg_battlemap_set_units_selected(unit : Unit, value : bool) # DO NOTHING YET
signal sg_battlemap_set_units_hovered(unit : Unit, value : bool) # DO NOTHING YET


# UI
signal sg_diplomacy_nation_request_data(nation_tag : String)
signal sg_diplomacy_nation_send_data(data : DiplomacyNation)

func _init() -> void:
	
	pass

func battlemap_set_units_selected(unit : Unit, value : bool) -> void:
	sg_battlemap_set_units_selected.emit(unit, value)
	pass

func battlemap_set_units_hovered(unit : Unit, value : bool) -> void:
	sg_battlemap_set_units_hovered.emit(unit, value)
	pass


# UI request data -> DiplomacyManager recieve it 
func diplomacy_nation_request_data(nation_tag: String) -> void:
	sg_diplomacy_nation_request_data.emit(nation_tag)

func diplomacy_nation_send_data(data : DiplomacyNation) -> void:
	sg_diplomacy_nation_send_data.emit(data)
