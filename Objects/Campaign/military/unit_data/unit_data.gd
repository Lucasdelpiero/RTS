extends Resource
class_name UnitData

@export var unit_name : String = ""
@export var scene : PackedScene =  preload("res://Objects/Battle/Units/box.tscn")
# If its empty it wont replace anything
@export var scene_unit_data : SceneUnitData = null 
@export var experience : int = 0
@export_range(0.1, 100, 0.1) var health : float = 100.0
@export_range(0, 10000, 1) var base_cost: int = 100
@export_range(0, 10000, 1) var base_maintanance_cost : int = 10

