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


#region SAVE/LOAD

func save_range_data_as_dict() -> Dictionary:
	var data : Dictionary = {}
	
	data.class_name = "SceneWeaponRangeData"
	data.weapon_type = weapon_type
	data.projectile_scene_path = ProjectileP.get_path()
	data.base_attack = base_attack
	data.base_max_range = base_max_range
	data.base_reloading_speed = base_reloading_speed
	data.reload_time = reload_time
	data.base_ammunition = base_ammunition
	data.fire_shot = fire_shot
	data.pierce_armor = pierce_armor
	data.move_while_shooting = move_while_shooting
	data.partian_shooting = partian_shooting
	data.degree_margin = degree_margin
	
	return data


func load_range_data_as_dict(data : Dictionary) -> SceneWeaponRangeData:
	weapon_type = data.weapon_type
	ProjectileP = load(data.projectile_scene_path)  
	base_attack = data.base_attack
	base_max_range = data.base_max_range
	base_reloading_speed = data.base_reloading_speed
	reload_time = data.reload_time
	base_ammunition = data.base_ammunition
	fire_shot = data.fire_shot
	pierce_armor = data.pierce_armor
	move_while_shooting = data.move_while_shooting
	partian_shooting = data.partian_shooting
	degree_margin = data.degree_margin
	
	return self

#endregion

