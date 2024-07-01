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

func set_unit_data(unit : UnitData) -> UnitData:
	scene_path = unit.scene.get_path()
	print(scene_path)
	#scene = load(unit.scene_path)
	scene = load(scene_path)
	health = unit.health
	base_cost = unit.base_cost
	base_maintanance_cost = unit.base_maintanance_cost
	base_manpower_cost = unit.base_maintanance_cost
	
	return self
	
