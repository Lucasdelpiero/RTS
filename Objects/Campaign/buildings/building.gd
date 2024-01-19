extends Resource
class_name Building

var province_data : ProvinceData = ProvinceData.new()
@export_range(0, 10, 1) var level : int = 1 #0 means that is not built
@export_range(0, 50000, 1) var cost : int = 100
@export_range(0, 100, 1) var time_to_build : int = 5
var test

@export var levels : Array[Building] = []

#@export_group("Levels")
#@export_subgroup("1")
#@export_range(0, 50000, 1) var cost_1 : int = 100
#@export_range(0, 100, 1) var time_to_build_1 : int = 5
#@export_subgroup("2")
#@export_range(0, 50000, 1) var cost_2 : int = 100
#@export_range(0, 100, 1) var time_to_build_2 : int = 5




 
