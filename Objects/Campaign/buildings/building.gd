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
	BUILDING_TEMPLE,
	BUILDING_MARKET,
	BUILDING_THEATER
) var building_type : String = DEFAULT
#==============NEEDS to be added to the buildings_UI==================
#region CONSTANTS for buildings
const DEFAULT = "DEFAULT"
const BUILDING_GOVERNMENT = "BUILDING_GOVERNMENT"
const BUILDING_FARM = "BUILDING_FARM"
const BUILDING_TEMPLE = "BUILDING_TEMPLE"
const BUILDING_MARKET = "BUILDING_MARKET"
const BUILDING_THEATER = "BUILDING_THEATER"

#==============NEEDS to be added to the buildings_UI==================
var BUILDING_CONSTANTS : Array = [
	BUILDING_GOVERNMENT,
	BUILDING_FARM,
	BUILDING_TEMPLE,
	BUILDING_MARKET,
	BUILDING_THEATER
]
#endregion

var province_data : ProvinceData = ProvinceData.new()
# Gives a default name to the BuildingData in case that
# the BuildingData at that level doesnt have an unique name 
@export var building_name : String = ""  
@export var is_built : bool = false
@export var current_level : int = 0
@export var levels : Array[BuildingData] = []

@export_multiline var description : String = ""

# Used to get the current level easier and with the type data
func get_building(look_at_specific_level : bool = false , level_to_look : int = 0) -> BuildingData:
	#region error handling
	if (current_level - 1) > levels.size():
		push_error("The current level is higher than the disponible level")
		return null
	
	# In case it tried to upgrade a level more than the max level, returns the max level
	if (level_to_look ) > levels.size() - 1:
		var building_data_max_level : BuildingData = levels[levels.size() - 1].duplicate(true) as BuildingData
		building_data_max_level.cost = 0
		building_data_max_level.time_to_build = 0
		building_data_max_level.description = description
		building_data_max_level.set_building_name(building_name)
		return building_data_max_level

	#endregion
	
	if look_at_specific_level:
		var building_data_level : BuildingData = levels[level_to_look].duplicate(true) as BuildingData
		building_data_level.description = description
		building_data_level.set_building_name(building_name)
		return building_data_level
	
	#var building_data : BuildingData = levels[current_level - 1].duplicate(true) as BuildingData
	var building_data : BuildingData = levels[current_level].duplicate(true) as BuildingData
	building_data.description = description # easier than assign it at creation time at each level
	building_data.set_building_name(building_name)
	return building_data

func get_building_next_level() -> BuildingData:
	var next_level : int = current_level + 1
	return get_building(true, next_level)

func is_max_level() -> bool:
	return current_level == ( levels.size() - 1 )
	
# When "destroyed" the stats sets back to the default at level zero
func destroy() -> void:
	current_level = 0
	is_built = false

 
