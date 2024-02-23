class_name ProvinceData
extends Resource


var province : Province = null
var name : String = "Unnamed"
var base_income : float = 0.0
var population : int = 1
var religion : String = "none"
var culture : String = "none"
var terrain_type : String = "none"

var buildings : Array[Building] = []

# Uses the province and all the data is setted here
func set_data_from_object(aProvince : Province = null) -> void:
	if aProvince == null:
		push_error("There is not object to set data from")
		return
	
	# Getting names of properties in the province
	var province_property_list : Array = aProvince.get_property_list().map(func(el : Dictionary) -> String: return el.name)
	var data_property_list : Array = get_property_list().map(func(el : Dictionary) -> String: return el.name)
	var in_both : Array[String] = []
	
	# Store the ones that are in both objects
	for data_property in data_property_list as Array[String]:
		if data_property in province_property_list:
			in_both.push_back(data_property)
	in_both.erase("script") # thing that i for sure DONT want to overwrite 
	
	# Set the properties automatically in the resource
	for property in in_both as Array[String]:
		set(property, aProvince.get(property))
		#print("%s: %s" % [property, get(property)])
	
	# For properties that are not shared it has to be done here
	buildings = aProvince.buildings_manager.buildings 
	province = aProvince # reference to the province

