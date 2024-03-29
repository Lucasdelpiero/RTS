class_name RangeWeapon
extends WeaponData

var type : String = "Range"
@export_enum("Bow", "Javelin","Slingshot") var weapon : String = "Bow"
@export_range(1, 1000, 1) var base_attack : int = 1
@export_range(1, 10000, 1) var base_max_range : int = 1000
@export_range(0.0, 10.0, 0.1) var base_shooting_speed : float = 1.0
@export_range(1, 1000, 1) var base_ammunition : int = 30
@export var fire_shot : bool = false
@export var pierce_armor : bool = false

func get_type() -> String:
	return "Range"

func get_damage() -> int:
	return 100
