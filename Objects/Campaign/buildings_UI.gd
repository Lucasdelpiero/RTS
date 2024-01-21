extends Control

#TODO move this node and code to the UI folder

@onready var buildings_container = %BuildingsContainer
@onready var overview_container = %OverviewContainer
@onready var ButtonBuilding  = preload("res://Objects/Campaign/button_building.tscn")
@export var buildings_manager = BuildingsManager.new() # checks what can or can not be build


var province_data : ProvinceData = ProvinceData.new() :
	set(value):
		province_data = value
		buildings = value.buildings
		buildings_manager.province_data = value

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
		
		for building in value as Array[Building]:
			var button = ButtonBuilding.instantiate() as BuildingButton
			buildings_container.add_child(button)
			
			var alf : Building = building
			
			print(value.size())
			print(value)
			print(alf.ICON_DEFAULT)
			#print(province_data.name)
			#if building.icon_normal == null:
				#print("alfonso")
			button.province_data  = province_data as ProvinceData
			button.texture_normal = building.icon_normal
			button.texture_hover = building.icon_hover
		
		buildings = value

