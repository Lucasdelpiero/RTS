extends Control

#TODO move this node and code to the UI folder

@onready var buildings_container = %BuildingsContainer
@onready var overview_container = %OverviewContainer
@onready var ButtonBuilding  = preload("res://Objects/Campaign/button_building.tscn")
@export var buildings_manager : BuildingsManager # checks what can or can not be build


var province_data : ProvinceData = ProvinceData.new() : # Updated when clicked on a province
	set(value):
		province_data = value
		buildings = value.buildings
		buildings_manager.province_data = value
		var to_be_built : Array[Building] = buildings_manager.get_buildings_not_made(buildings)
		
		
		
		if to_be_built.is_empty():
			print("already built :)")
		var new_buildings : Array[Building] = buildings.duplicate(true)
		for building in to_be_built:
			var button = ButtonBuilding.instantiate()
			buildings_container.add_child(button)
			
			var new_building : Building 
			new_building = building.duplicate(true) as Building
			
			
			new_buildings.push_back(new_building)
			
			button.province_data = province_data
			button.texture_normal = building.icon_normal
			button.texture_hover = building.icon_hover
		# TEST
		
		value.province.buildings_manager.buildings = new_buildings

var buildings : Array[Building] :
	set(value):
		#print(value)
		var children = buildings_container.get_children()
		if value.is_empty():
			push_error("There are no buildings in the data provided")
			return
		
		buildings = []
		
		for to_delete in children:
			to_delete.queue_free()
		
		for building in value:
			var button = ButtonBuilding.instantiate() as BuildingButton
			buildings_container.add_child(button)
			
			
			button.province_data = province_data
			button.texture_normal = building.icon_normal
			button.texture_hover = building.icon_hover
		
		buildings = value

# TEST to create buildings
