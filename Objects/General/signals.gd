extends Node

var battle_map : BattleMap = null 

signal sg_battlemap_set_units_selected(unit, value )
signal sg_battlemap_set_units_hovered(unit, value )

func battlemap_set_units_selected(unit, value) -> void:
	sg_battlemap_set_units_selected.emit(unit, value)
	pass

func battlemap_set_units_hovered(unit, value) -> void:
	sg_battlemap_set_units_hovered.emit(unit, value)
	pass
