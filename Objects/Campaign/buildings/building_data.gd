class_name BuildingData
extends Resource

@export var building_name : String = "" # If its empty it will inherit the name of the building containing the data
@export_range(0, 50000, 1) var cost : int = 100
@export_range(0, 100, 1) var time_to_build : int = 5

@export var flat_production : Array[FlatProduction] = []
@export var bonuses : Array[Bonus] = []

var description : String = "" # Empty value that is assigned at from the building data

func set_building_name(value : String) -> void:
	if building_name == "":
		building_name = value
