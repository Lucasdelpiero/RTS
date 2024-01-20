extends Resource
class_name BuildingsManager


@export var buildings : Array[Building] 

var building_types : Array[Building] = [
	load("res://Objects/Campaign/buildings/building_farm.tres"),
	load("res://Objects/Campaign/buildings/building_government.tres")
]
