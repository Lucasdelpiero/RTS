extends Resource
class_name Building

var province_data : ProvinceData = ProvinceData.new()

var ICON_DEFAULT : Texture2D = preload("res://Assets/ui/buildings/building_icon.png")

var current_level = 1
@export var levels : Array[BuildingData] = []

@export var icon_normal : Texture2D = ICON_DEFAULT
@export var icon_hover : Texture2D = ICON_DEFAULT




 
