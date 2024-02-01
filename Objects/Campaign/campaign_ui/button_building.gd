class_name BuildingButton
extends Button

# Connected from the buildings_UI script on the buildings available to be built
# Tells the building UI when the construction starts, which triggers an update in the province UI
signal sg_construction_started(value) 
signal sg_send_data_to_overview(value : BuildingData, image : Texture2D)

var building_reference : Building

var province_data : ProvinceData = ProvinceData.new() :
	set(value):
		#print("name: %s / culture: %s / religion: %s" % [
			#value.name,
			#value.culture,
			#value.religion
		#])
		province_data = value



func _on_pressed():
	# NOTE I think that these safeguards are not even needed
	#if sg_construction_started.get_connections().size() < 1:
		#print("Its not connected to anything")
		#return
		
	if building_reference == null:
		push_error("There is not reference to building in the button")
		return
	
	var building_data : BuildingData = building_reference.get_building()
	sg_send_data_to_overview.emit(building_data, icon)
	sg_construction_started.emit(building_reference)
	
	pass # Replace with function body.
