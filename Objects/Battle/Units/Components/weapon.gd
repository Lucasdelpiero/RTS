@tool
extends Node2D
class_name Weapon


var type = null
var weapon := ""

func connect_signals_to_manager(_parent : WeaponsManager):
	pass

func get_attack():
	# Space for modifiers
	pass

func get_shooting_range():
	# Space for modifiers
	pass

func get_shooting_speed():
	# Space for modifiers
	pass

func get_type():
	return type

func set_visibility(value):
	visible = value
	pass

func has_ammo():
	return false # Used so the melee range return something 
