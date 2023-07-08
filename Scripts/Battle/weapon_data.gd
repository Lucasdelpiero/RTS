@tool
extends Resource
class_name WeaponData

@export_enum("Dagger", "Sword", "Spear", "Bow") var weapon = "Dagger" : set = set_weapon_and_type
var type = "Melee"
@export_group("Melee")
@export_range(0, 1000, 1) var base_attack = 1
@export_range(0, 100, 1) var charge = 1
@export_range(0.0, 90, 0.1) var parry_chance = 0.0
@export_group("Range")
@export_range(1, 10000, 1) var base_max_range = 1000
@export_range(0.0, 10.0, 0.1) var base_shooting_speed = 1.0
var melee_weapons = ["Dagger", "Sword", "Spear"]
var range_weapons = ["Bow", "Slingshot"]

func set_weapon_and_type(value):
	weapon = value
	if melee_weapons.has(value):
		type = "Melee"
	if range_weapons.has(value):
		type = "Range"

