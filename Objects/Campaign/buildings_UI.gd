extends Control

#TODO move this node and code to the UI folder

@onready var buildings_container = %BuildingsContainer
@onready var overview_container = %OverviewContainer
@onready var ButtonBuilding  = preload("res://Objects/Campaign/button_building.tscn")
@export var buildings_manager : BuildingsManager # checks what can or can not be build

@onready var to_be_built_container = %ToBeBuiltContainer # used to show or not the buildings container
@export var np_buildings_available_container : NodePath # Show buttons of available buildings
@onready var buildings_available_container = get_node(np_buildings_available_container)

var province_data : ProvinceData = ProvinceData.new() : # Updated when clicked on a province
	set(value):
		province_data = value
		buildings = value.buildings
		buildings_manager.province_data = value
		var to_be_built : Array[Building] = buildings_manager.get_buildings_not_made(buildings)
		
		
		return 
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
		#value.province.buildings_manager.buildings = new_buildings
		to_be_built_container.visible = false

var buildings : Array[Building] :
	set(value):
		#print(value)
		var children = buildings_container.get_children()
		if value.is_empty():
			push_error("There are no buildings in the data provided")
			return
		
		buildings = []
		
		for to_delete in children:
			if to_delete is BuildingButton:
				to_delete.queue_free()
		
		for building in value:
			var button = ButtonBuilding.instantiate() as BuildingButton
			buildings_container.add_child(button)
			
			
			button.province_data = province_data
			button.texture_normal = building.icon_normal
			button.texture_hover = building.icon_hover
		
		buildings = value
		to_be_built_container.visible = false

# TEST to create buildings


func _on_add_building_pressed():
	if buildings_available_container == null:
		push_error("There is no nodepath where to add the buttons")
		return
	
	# Delete buildings buttons to create a fresh list, the filter avoid deleting the "back button"
	for building in buildings_available_container.get_children().filter(
		func(el) : return el is BuildingButton
	): 
		building.queue_free()
	
	# Create buttons for the available buildings in the province
	var not_built : Array[Building] = buildings_manager.get_buildings_not_made(buildings)
	
	for building in not_built:
		var button = ButtonBuilding.instantiate() as BuildingButton
		buildings_available_container.add_child(button)
		
		button.province_data = province_data
		button.texture_normal = building.icon_normal
		button.texture_hover = building.icon_hover
		button.building_reference = building.duplicate(true)
		button.sg_construction_started.connect(start_construction)
	
	to_be_built_container.visible = true
	pass # Replace with function body.


func _on_back_button_pressed():
	to_be_built_container.visible = false

func start_construction(aBuilding : Building):
	var new_buildings = buildings.duplicate(true)
	new_buildings.push_back(aBuilding.duplicate(true))
	province_data.province.buildings_manager.buildings = new_buildings.duplicate(true)
	
	province_data.province.send_data_to_ui()

