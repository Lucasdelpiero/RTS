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
	#BUILDING_TEMPLE
) var building_type : String = DEFAULT


var province_data : ProvinceData = ProvinceData.new()

var ICON_DEFAULT : Texture2D = preload("res://Assets/ui/buildings/building_icon.png")

var current_level = 1
@export var levels : Array[BuildingData] = []

@export var icon_normal : Texture2D = ICON_DEFAULT
@export var icon_hover : Texture2D = ICON_DEFAULT

#region CONSTANTS for buildings
const DEFAULT : String = "DEFAULT"
const BUILDING_GOVERNMENT : String = "BUILDING_GOVERNMENT"
const BUILDING_FARM : String = "BUILDING_FARM"
#const BUILDING_TEMPLE : String = "BUILDING_TEMPLE"

var BUILDING_CONSTANTS : Array[String] = [
	DEFAULT,
	BUILDING_GOVERNMENT,
	BUILDING_FARM,
	#BUILDING_TEMPLE
]
#endregion



 
