extends Node

var battle_map : BattleMap = null 

signal sg_battlemap_set_units_selected(unit : Unit , value : bool )
signal sg_battlemap_set_units_hovered(unit : Unit , value : bool )

func battlemap_set_units_selected(unit : Unit , value : bool) -> void:
	sg_battlemap_set_units_selected.emit(unit, value)
	pass

func battlemap_set_units_hovered(unit : Unit, value : bool) -> void:
	sg_battlemap_set_units_hovered.emit(unit, value)
	pass
