extends Node

var battle_map : BattleMap = null 

signal sg_battlemap_set_units_selected(unit, value)

func battlemap_set_units_selected(unit, value):
	sg_battlemap_set_units_selected.emit(unit, value)
	pass
