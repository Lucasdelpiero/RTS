extends Resource
class_name BuildingsManager


@export var buildings : Array[Building]
var province_data : ProvinceData = ProvinceData.new() :
	set(value):
		province_data = value
		buildings = value.buildings
		#var alf = get_buildings_not_made(buildings)
		#Globals.debug_update_label("alf", "buildings:%s" %[alf])


var building_types : Array[Building] = [
	load("res://Objects/Campaign/buildings/building_farm.tres"),
	load("res://Objects/Campaign/buildings/building_government.tres")
]

func get_buildings_not_made(data : Array[Building]) -> Array[Building] :
	# Create a new resource to get the constants stored in a variable
	return []
	var new_building : Building = Building.new()
	var all_buildings_constants : Array = new_building.BUILDING_CONSTANTS
	
	#Globals.debug_update_label("constants", "constants: %s" %[all_buildings_constants])
	
	# Add already built buildings in an array to know which ones are built in the province
	var already_built_constants : Array = []
	for building in data:
		#if all_buildings_constants.has(building.building_type):
			#already_built_constants.push_back(building.building_type)
		if building.building_type in all_buildings_constants:
			already_built_constants.push_back(building.building_type)
	
	#Globals.debug_update_label("built", "built: %s" %[already_built_constants])
	
	var buildings_available_to_build : Array[Building] = []
	#for building in data:
		#if not building.building_type in all_buildings_constants:
			#buildings_available_to_build.push_back(building)
	#for building_to_test in BUILDING_RESOURCES:
		#Globals.debug_update_label("building_res", "resources: %s" %building_to_test)

	
	return []
	pass


const BUILDING_RESOURCES = [
	preload("res://Objects/Campaign/buildings/building_farm.tres"),
	preload("res://Objects/Campaign/buildings/building_government.tres"),
	preload("res://Objects/Campaign/buildings/building_temple.tres")
]
