class_name BuildingButton
extends TextureButton


var province_data : ProvinceData = ProvinceData.new() :
	set(value):
		#print("name: %s / culture: %s / religion: %s" % [
			#value.name,
			#value.culture,
			#value.religion
		#])
		province_data = value

