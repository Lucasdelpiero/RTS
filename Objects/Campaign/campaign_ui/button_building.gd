class_name BuildingButton
extends Button

# Connected from the buildings_UI script on the buildings available to be built
# Tells the building UI when the construction starts, which triggers an update in the province UI
signal sg_construction_started(value : Building)
signal sg_building_upgrade(value : Building) 
signal sg_send_data_to_overview(value : BuildingData, image : Texture2D)
signal sg_send_building_reference_to_overview(value : Building, image : Texture2D)
signal sg_send_province_data_reference(value : ProvinceData)
signal sg_send_building_manager_reference(value : BuildingsManager)

@onready var is_built : bool = true # used just to check when to emit the signal of the overview

var building_reference : Building = null

var province_data : ProvinceData = ProvinceData.new() :
	set(value):
		#push_warning("name: %s / culture: %s / religion: %s" % [
			#value.name,
			#value.culture,
			#value.religion
		#])
		province_data = value

func _ready() -> void:
	await get_tree().create_timer(0.01).timeout # Gives time to the UI to update the gold of the player
	update()

# Checks if the requiriments for the building are met
# Currently only checks for the money cost
# remake this shit
func can_be_built() -> bool:
	if building_reference == null:
		return false
	
	# If it is already built it will check for an upgrade
	if is_built:
		var building_cost : int = building_reference.get_building_next_level().cost
		return building_cost <= Globals.player_gold
	
	 # Checking if the building can be built at the first level
	if building_reference.get_building().cost > Globals.player_gold:
		return false
	
	return true



func update() -> void:
	if not is_built:
		disabled = !can_be_built()
	pass


func _on_pressed() -> void:
	if building_reference == null:
		push_error("There is not reference to building in the button")
		return
	
	# Upgrades the existing building
	if is_built and can_be_built():
		sg_building_upgrade.emit(building_reference)
		
	# If not built, it will send a signal to the building_UI to create a new building
	if not is_built:
		sg_construction_started.emit(building_reference)


func _on_mouse_entered() -> void:
	# Sends the data to the ovewview with +1 level
	if is_built:
		# TEST
		if building_reference == null:
			push_error("Doesnt have a building reference")
			return
		var next_level : int = building_reference.current_level + 1
		var building_data_next_level : BuildingData = building_reference.get_building(true, next_level)
		sg_send_data_to_overview.emit(building_data_next_level, icon)
		sg_send_building_reference_to_overview.emit(building_reference, icon)
		sg_send_province_data_reference.emit(province_data)
		#push_warning("done")
		# TEST
		return 
	
	var building_data_current_level : BuildingData = building_reference.get_building()
	if building_data_current_level == null: # 
		push_warning("no data to send")
		return
	sg_send_data_to_overview.emit(building_data_current_level, icon)
	sg_send_building_reference_to_overview.emit(building_reference, icon)
	sg_send_province_data_reference.emit(province_data)
	pass # Replace with function body.
