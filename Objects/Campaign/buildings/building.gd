extends Resource
class_name Building

# Used to identify a building, uses strings stored in constants, as they are 
# more confortable to use than enums, specially if adding buildings in between 2 values
# as their value will be always the same string and not an "int" that changes value and needs workarounds
# also the constants are easily shareable to other resources as an array
@export_enum(
	DEFAULT,
	BUILDING_FARM,
	BUILDING_GOVERNMENT,
	BUILDING_TEMPLE
) var building_type : String = DEFAULT

#region CONSTANTS for buildings
const DEFAULT = "DEFAULT"
const BUILDING_GOVERNMENT = "BUILDING_GOVERNMENT"
const BUILDING_FARM = "BUILDING_FARM"
const BUILDING_TEMPLE = "BUILDING_TEMPLE"

var BUILDING_CONSTANTS : Array = [
	BUILDING_GOVERNMENT,
	BUILDING_FARM,
	BUILDING_TEMPLE
]
#endregion

var province_data : ProvinceData = ProvinceData.new()

@export var current_level : int = 1
@export var levels : Array[BuildingData] = []

@export_multiline var description : String = ""

# Used to get the current level easier and with the type data
func get_building() -> BuildingData:
	if (current_level - 1) > levels.size():
		push_error("The current level is higher than the disponible level")
		return null
	var building_data : BuildingData = levels[current_level - 1].duplicate(true) as BuildingData
	building_data.description = description # easier than assign it at creation time at each level
	return building_data




 
