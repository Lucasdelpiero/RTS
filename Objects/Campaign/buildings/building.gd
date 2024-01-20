extends Resource
class_name Building


@export var building_name : String = "" : # used to identify the building, ex: "building_farm"
	set(value): # needs to have the value setted like this or it doesnt update the resource name
		resource_name = value

var province_data : ProvinceData = ProvinceData.new()

var ICON_DEFAULT : Texture2D = preload("res://Assets/ui/buildings/building_icon.png")

var current_level = 1
@export var levels : Array[BuildingData] = []

@export var icon_normal : Texture2D = ICON_DEFAULT
@export var icon_hover : Texture2D = ICON_DEFAULT




 
