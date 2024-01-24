class_name BuildingButton
extends TextureButton

signal construction_started(value)

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
	if building_reference == null:
		push_error("There is not reference to building in the button")
		return
	
	construction_started.emit(building_reference)
	pass # Replace with function body.
