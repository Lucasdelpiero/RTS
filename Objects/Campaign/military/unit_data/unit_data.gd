extends Resource
class_name UnitData

@export var unit_name : String = ""
@export var scene : PackedScene =  preload("res://Objects/Battle/Units/box.tscn")
var scene_path : Variant = ""
# If its empty it wont replace anything
@export var scene_unit_data : SceneUnitData = null 
@export var experience : int = 0
@export_range(0.1, 100, 0.1) var health : float = 100.0
@export_range(0, 10000, 1) var base_cost: int = 100
@export_range(0, 10000, 1) var base_maintanance_cost : int = 10
@export_range(0, 10000, 1) var base_manpower_cost : int = 200


# Creates a dictionary for the save file for the specific unit
func get_data_as_dict() -> Dictionary:
	var save_dict : Dictionary = {}
	
	save_dict.unit_name = unit_name
	save_dict.scene_path = scene.get_path()
	save_dict.experience = experience
	save_dict.health = health
	save_dict.base_cost = base_cost
	save_dict.base_maintanance_cost = base_maintanance_cost
	save_dict.base_manpower_cost = base_manpower_cost
	
	# TODO  scene_unit_data 
	
	return save_dict
	pass

func load_unit_data(data : Dictionary) -> UnitData:
	scene_path = data.scene_path
	scene = load(scene_path)
	health = data.health
	base_cost = data.base_cost
	base_maintanance_cost = data.base_maintanance_cost
	base_manpower_cost = data.base_manpower_cost
	
	# TODO scene_unit_data
	
	return self
