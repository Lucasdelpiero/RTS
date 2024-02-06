class_name BuildingData
extends Resource

@export_range(0, 10, 1) var level : int = 1 
@export_range(0, 50000, 1) var cost : int = 100
@export_range(0, 100, 1) var time_to_build : int = 5

@export var flat_production : Array[FlatProduction] = []
@export var bonuses : Array[Bonus] = []

var description : String = "" # Empty value that is assigned at from the building data
