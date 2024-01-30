extends Control

# Used to send a signal to the province to ask them to update the UI using the send_data_to_ui function
signal sg_update_UI_requested

#TODO move this node and code to the UI folder

@onready var buildings_container = %BuildingsContainer
@onready var overview_container = %OverviewContainer
@onready var ButtonBuilding  = preload("res://Objects/Campaign/campaign_ui/button_building.tscn")
@export var buildings_manager : BuildingsManager # checks what can or can not be build

@onready var to_be_built_container = %ToBeBuiltContainer # used to show or not the buildings container
@export var np_buildings_available_container : NodePath # Show buttons of available buildings
@onready var buildings_available_container = get_node(np_buildings_available_container)

# Icons for the buildings stored in the UI manager to avoid wasting memory on a texture for each building
@export_group("Buildings icons")
@export var icon_default : Texture2D 
@export var icon_building_government : Texture2D
@export var icon_building_farm : Texture2D
@export var icon_building_temple : Texture2D


var province_data : ProvinceData = ProvinceData.new() : # Updated when clicked on a province
	set(value):
		province_data = value
		buildings = value.buildings
		buildings_manager.province_data = value
		var to_be_built : Array[Building] = buildings_manager.get_buildings_not_made(buildings)

var buildings : Array[Building] :
	set(value):
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
			button.icon = get_icon_for_building(building.building_type)
		
		buildings = value
		to_be_built_container.visible = false



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
		button.icon = get_icon_for_building(building.building_type)
		button.building_reference = building.duplicate(true)
		button.sg_construction_started.connect(start_construction)
	
	to_be_built_container.visible = true
	pass # Replace with function body.


func _on_back_button_pressed():
	to_be_built_container.visible = false

# Uses the string in "building_type" in the resource to return the corresponding icon
# each new building type needs to get added here with a corresponding icon stored in a variable
func get_icon_for_building(type : String) -> Texture2D:
	match type:
		"BUILDING_FARM": return icon_building_farm
		"BUILDING_GOVERNMENT": return icon_building_government
		"BUILDING_TEMPLE": return icon_building_temple
		_: return icon_default

func start_construction(aBuilding : Building) -> void:
	if aBuilding == null:
		push_error("There is not building to be built")
		return
	
	var new_buildings = buildings.duplicate(true)
	new_buildings.push_back(aBuilding.duplicate(true))
	province_data.province.buildings_manager.buildings = new_buildings.duplicate(true)
	
	# Done in this way to lower coupling
	var province_to_update_UI : Province = province_data.province
	if province_to_update_UI == null:
		push_error("There is no reference to province in province data resource")
		return
	sg_update_UI_requested.connect(province_to_update_UI.send_data_to_ui)
	sg_update_UI_requested.emit()
	sg_update_UI_requested.disconnect(province_to_update_UI.send_data_to_ui)
	

