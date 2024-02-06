class_name BuildingButton
extends Button

# Connected from the buildings_UI script on the buildings available to be built
# Tells the building UI when the construction starts, which triggers an update in the province UI
signal sg_construction_started(value) 
signal sg_send_data_to_overview(value : BuildingData, image : Texture2D)

@onready var is_built : bool = true # used just to check when to emit the signal of the overview

var building_reference : Building = null

var province_data : ProvinceData = ProvinceData.new() :
	set(value):
		#print("name: %s / culture: %s / religion: %s" % [
			#value.name,
			#value.culture,
			#value.religion
		#])
		province_data = value

func _ready():
	await get_tree().create_timer(0.01).timeout # Gives time to the UI to update the gold of the player
	update()

# Checks if the requiriments for the building are met
# Currently only checks for the money cost
func can_be_built() -> bool:
	if building_reference == null:
		return false
	if building_reference.get_building().cost > Globals.player_gold:
		return false
	
	return true

func update() -> void:
	if not is_built:
		disabled = !can_be_built()
	pass


func _on_pressed():
	# NOTE I think that these safeguards are not even needed
	#if sg_construction_started.get_connections().size() < 1:
		#print("Its not connected to anything")
		#return
		
	if building_reference == null:
		push_error("There is not reference to building in the button")
		return
	
	var building_data : BuildingData = building_reference.get_building()
	if building_data != null:
		sg_send_data_to_overview.emit(building_data, icon)
	# If not built, it will send a signal to the building_UI to create a new building
	if not is_built:
		sg_construction_started.emit(building_reference)
	
	
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	if is_built:
		return
	var building_data : BuildingData = building_reference.get_building()
	if building_data == null: # 
		return
	sg_send_data_to_overview.emit(building_data, icon)
	pass # Replace with function body.
