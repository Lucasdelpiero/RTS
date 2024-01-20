extends Resource
class_name BuildingsManager


@export var buildings : Array[Building]
var province_data : ProvinceData = ProvinceData.new() :
	set(value):
		province_data = value
		buildings = value.buildings


var building_types : Array[Building] = [
	load("res://Objects/Campaign/buildings/building_farm.tres"),
	load("res://Objects/Campaign/buildings/building_government.tres")
]

func _ready():
	print(building_types)
	
	pass
