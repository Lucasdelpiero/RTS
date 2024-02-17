@tool
extends Node2D
class_name Weapon

var type : String = ""
var weapon := ""

func connect_signals_to_manager(_parent : WeaponsManager) -> void:
	pass

func get_attack() -> int :
	# Space for modifiers
	return 0
	pass

func get_shooting_range() -> float:
	# Space for modifiers
	return 0
	pass

func get_shooting_speed() -> float:
	# Space for modifiers
	return 0
	pass

func get_type() -> String:
	return type

func set_visibility(value : bool) -> void:
	visible = value
	pass

func has_ammo() -> bool:
	return false # Used so the melee range return something 
