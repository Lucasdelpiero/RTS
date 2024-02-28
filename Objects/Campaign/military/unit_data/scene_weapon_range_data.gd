class_name SceneWeaponRangeData
extends SceneWeaponData

# Stores data to spawn a range weapon for the unit in the battlemap

@export_enum("Bow", "Javelin","Slingshot") var weapon_type : String = "Bow"
@export var ProjectileP : PackedScene = preload("res://Objects/Battle/Units/Components/projectile.tscn") # NOTE needs to be a path 
@export_range(1, 1000, 1) var base_attack : int = 1
@export_range(1, 10000, 1) var base_max_range : int = 1000
@export_range(0.0, 2.0, 0.01) var base_reloading_speed : float = 1.0
@export_range(0.1, 30.0, 0.1) var reload_time : float = 3.0
@export_range(1, 1000, 1) var base_ammunition : int = 30
@export var fire_shot : bool = false
@export var pierce_armor : bool = false
@export var move_while_shooting : bool = false
@export var partian_shooting : bool = false
@export var degree_margin : float = 60 # Angle cone from where it can shoot
