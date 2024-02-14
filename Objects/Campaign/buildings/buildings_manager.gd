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

@export var building_types : Array[Building]  # Buildings that can be uilt


func get_buildings_not_made(aBuildings : Array[Building]) -> Array[Building] :
	 #Create a new resource to get the constants stored in a variable
	var new_building : Building = Building.new()
	var all_buildings_constants : Array = new_building.BUILDING_CONSTANTS
	
	
	#Globals.debug_update_label("constants", "constants: %s" %[all_buildings_constants])
	
	# Add already built buildings in an array to know which ones are built in the province
	var already_built_constants : Array = []
	for building in aBuildings:
		#if all_buildings_constants.has(building.building_type):
			#already_built_constants.push_back(building.building_type)
		if building.building_type in all_buildings_constants:
			already_built_constants.push_back(building.building_type)
	
	#Globals.debug_update_label("built", "built: %s" %[already_built_constants])
	
	# Get buildings that hasnt been built in the city
	var buildings_types_available_to_build : Array = []
	for constant in all_buildings_constants:
		if not constant in already_built_constants:
			buildings_types_available_to_build.push_back(constant)
	
	
	#Globals.debug_update_label("available", "available: %s" % [buildings_types_available_to_build])
	
	# Put the buildings that can be built in an array as a resource
	var to_be_built : Array[Building] = []
	for building in building_types:
		if building.building_type in buildings_types_available_to_build:
			to_be_built.push_back(building)
	
	#Globals.debug_update_label("to_be_built", "to be built: %s" % [to_be_built])
	
	
	return to_be_built

# Get the production of all buildings at flat rates
func get_buildings_flat_production() -> Production :
	var total_production : Production = Production.new()
	for building in buildings:
		var building_data : BuildingData = building.get_building()
		if building_data == null:
			push_error("Error: building_data is null (empty production sent)")
			return total_production
		
		for production in building_data.flat_production:
			match production.type_produced:
				"gold": total_production.gold += production.amount
				"manpower": total_production.manpower += production.amount
	
	
	
	return total_production

# Get the bonuses from all buildgins and merge them into an array where all bonuses of the same type are merged into a unique bonus
func get_buildings_bonuses() -> Array[Bonus]:
	
	var bonuses : Array[Bonus] = []

	# Check in each building
	for building in buildings:
		# Check each bonus in the buildings
		var current_building : BuildingData = building.get_building() # variable create just to have the chance of an early return
		if current_building == null:
			push_error("Building data returned null")
			continue # skip the things below
		var building_level_bonuses  : Array[Bonus] = current_building.bonuses
		for bonus in building_level_bonuses:
			# Check if a bonus of the same type is saved in the array
			var bonus_pos = bonuses.map(func(el) : return el.type_produced).filter(func(el) : return el != "default").find(bonus.type_produced) 
			
			# If doesnt exists in the bonuses array, add it
			# A new resource has to be created, otherwise the value of the bonus is not reseted for the next calculation
			var new_bonus = Bonus.new()
			new_bonus.type_produced = bonus.type_produced
			new_bonus.multiplier_bonus = bonus.multiplier_bonus
			
			if bonus_pos == -1:
				bonuses.push_back(new_bonus)
				continue # avoids going below 
			
			# If it already exits, increase its value by merging them
			bonuses[bonus_pos].multiplier_bonus += bonus.multiplier_bonus
			
	return bonuses
