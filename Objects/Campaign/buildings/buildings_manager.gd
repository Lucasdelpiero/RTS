extends Resource
class_name BuildingsManager


@export var buildings : Array[Building]
var province_data : ProvinceData = ProvinceData.new() :
	set(value):
		province_data = value
		buildings = value.buildings
		#for building in buildings:
			#Globals.debug_update_label(
				#"%s_%s" % [province_data.name, building.building_type],
				#building.building_type
			#)
		get_buildings_not_made(buildings)


var building_types : Array[Building] = [
	load("res://Objects/Campaign/buildings/building_farm.tres"),
	load("res://Objects/Campaign/buildings/building_government.tres")
]

func get_buildings_not_made(buildings : Array[Building]) -> Array[Building] :
	 #Create a new resource to get the constants stored in a variable
	var new_building : Building = Building.new()
	var all_buildings_constants : Array = new_building.BUILDING_CONSTANTS
	
	Globals.debug_update_label("constants", "constants: %s" %[all_buildings_constants])
	
	# Add already built buildings in an array to know which ones are built in the province
	var already_built_constants : Array = []
	for building in buildings:
		#if all_buildings_constants.has(building.building_type):
			#already_built_constants.push_back(building.building_type)
		if building.building_type in all_buildings_constants:
			already_built_constants.push_back(building.building_type)
	
	Globals.debug_update_label("built", "built: %s" %[already_built_constants])
	
	# Get buildings that hasnt been built in the city
	var buildings_available_to_build : Array = []
	for constant in all_buildings_constants:
		if not constant in already_built_constants:
			buildings_available_to_build.push_back(constant)

	Globals.debug_update_label("available", "available: %s" % [buildings_available_to_build])

	
	return []

# BUG loading these resources causes a crash 
#const farm = building.new()
var BUILDING_RESOURCES = [
	#preload("res://Objects/Campaign/buildings/building_farm.tres"),
	#preload("res://Objects/Campaign/buildings/building_government.tres") as Building,
]
