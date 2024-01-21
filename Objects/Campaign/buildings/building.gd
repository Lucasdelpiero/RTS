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

var ICON_DEFAULT : Texture2D = preload("res://Assets/ui/buildings/building_icon.png")

var current_level = 1
@export var levels : Array[BuildingData] = []

@export var icon_normal : Texture2D = ICON_DEFAULT
@export var icon_hover : Texture2D = ICON_DEFAULT





 
