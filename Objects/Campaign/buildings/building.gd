extends Resource
class_name Building

var province_data : ProvinceData = ProvinceData.new()
@export_range(0, 10, 1) var level : int = 1 #0 means that is not built
@export_range(0, 50000, 1) var cost : int = 100
@export_range(0, 100, 1) var time_to_build : int = 5

var ICON_DEFAULT : Texture2D = preload("res://Assets/ui/buildings/building_icon.png")



@export var levels : Array[Building] = []

@export var icon_normal : Texture2D = ICON_DEFAULT
@export var icon_hover : Texture2D = ICON_DEFAULT




 
