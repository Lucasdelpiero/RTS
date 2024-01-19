extends Resource
class_name BuildingsManager

@export var government : BuildingGovernment = BuildingGovernment.new()

var buildings : Array[Building] = [
	government
]
