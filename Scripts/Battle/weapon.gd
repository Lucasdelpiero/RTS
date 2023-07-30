@tool
extends Node2D
class_name Weapon

var type = null
var weapon := ""

func connect_signals_to_manager(parent : WeaponsManager):
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
