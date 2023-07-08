@tool
extends Node
class_name Weapon

@export_enum("Dagger", "Sword", "Spear", "Bow") var weapon = "Dagger" : set = set_weapon_type
var type = null
var melee_weapons = ["Dagger", "Sword", "Spear"]
var range_weapons = ["Box"]
@export_category("Melee")
@export_range(0, 1000, 1) var base_attack : int = 1
@export_range(0, 100, 1) var charge : int = 1
@export_range(0.0, 90, 0.1) var parry_chance = 0.0
@export_category("Range")
@export var is_range_weapon : bool = false
@export_range(1, 10000, 1) var base_max_range = 1000
@export_range(0.0, 10.0, 0.1) var base_shooting_speed = 1.0

func set_weapon_type(value):
	weapon = value
	if melee_weapons.has(weapon):
		type = "Melee"
	if range_weapons.has(weapon):
		type = "Range"

func get_attack():
	# Space for modifiers
	return base_attack

func get_shooting_range():
	# Space for modifiers
	return base_max_range

func get_shooting_speed():
	# Space for modifiers
	return base_shooting_speed
