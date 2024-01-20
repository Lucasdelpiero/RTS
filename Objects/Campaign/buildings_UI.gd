extends Control

#TODO move this node and code to the UI folder

@onready var buildings_container = %BuildingsContainer
@onready var overview_container = %OverviewContainer
@onready var ButtonBuilding  = preload("res://Objects/Campaign/button_building.tscn")

var province_data : ProvinceData = ProvinceData.new() :
	set(value):
		province_data = value
		buildings = value.buildings

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
