class_name BuildingsUI
extends Control

# Used to send a signal to the province to ask them to update the UI using the send_data_to_ui function
signal sg_update_UI_requested

#TODO move this node and code to the UI folder

@onready var buildings_container := %BuildingsContainer
@onready var overview_container : OverviewContainer = %OverviewContainer as OverviewContainer
@onready var add_building_button : Button = %AddBuilding  as Button
@onready var ButtonBuilding : PackedScene = preload("res://Objects/Campaign/campaign_ui/button_building.tscn")
@export var buildings_manager : BuildingsManager # checks what can or can not be build

@onready var to_be_built_container := %ToBeBuiltContainer # used to show or not the buildings container
@export var np_buildings_available_container : NodePath # Show buttons of available buildings
@onready var buildings_available_container := get_node(np_buildings_available_container) as HBoxContainer 

# Icons for the buildings stored in the UI manager to avoid wasting memory on a texture for each building
@export_group("Buildings icons")
@export var icon_default : Texture2D 
@export var icon_building_government : Texture2D
@export var icon_building_farm : Texture2D
@export var icon_building_temple : Texture2D


var province_data : ProvinceData = ProvinceData.new() : # Updated when clicked on a province
	set(value):
		# Only when clicked a new province it hides the UI, not when updated
		if province_data.province != value.province:
			overview_container.hide()
		
		province_data = value
		buildings = value.buildings
		buildings_manager.province_data = value
		var to_be_built : Array[Building] = buildings_manager.get_buildings_not_made(buildings)
		
		# Disable new buildings button if the player doesnt own the province
		var is_the_owner_of_province : bool = (province_data.province.ownership == Globals.player_nation)
		add_building_button.visible = is_the_owner_of_province

var buildings : Array[Building] : # updated when province data changes <- updated when clicked on a province
	set(value):
		if value.is_empty():
			push_error("There are no buildings in the data provided")
			return
		
		create_building_buttons(value)
		
		# Only hide new buildings buildings when a something was built, not when updated the UI with the same buildings (like when updates the population, religion, etc)
		if buildings != value:
			to_be_built_container.visible = false
		buildings = value 
		


# Creates the buttons for the avialable buildings to be built
func _on_add_building_pressed() -> void:
	if buildings_available_container == null:
		push_error("There is no nodepath where to add the buttons")
		return
	
	# Delete buildings buttons to create a fresh list, the filter avoid deleting the "back button"
	for building : BuildingButton in buildings_available_container.get_children().filter(
		func(el : Node) -> bool: return el is BuildingButton
	): 
		building.queue_free()
	
	# Create buttons for the available buildings in the province
	var not_built : Array[Building] = buildings_manager.get_buildings_not_made(buildings)
	
	for building in not_built:
		var button := ButtonBuilding.instantiate() as BuildingButton
		buildings_available_container.add_child(button)
		
		button.province_data = province_data
		button.icon = get_icon_for_building(building.building_type)
		button.building_reference = building.duplicate(true)
		button.sg_construction_started.connect(start_construction)
		button.sg_send_building_reference_to_overview.connect(overview_container.show_building_overview)
		button.sg_send_province_data_reference.connect(overview_container.update_province_reference)
		button.is_built = false # used just to check when to emit the signal of the overview
		var campaign_ui : CampaignUI = Globals.campaign_UI
		if campaign_ui != null:
			campaign_ui.sg_gold_amount_changed.connect(button.update)
	
	to_be_built_container.visible = true
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	to_be_built_container.visible = false
	overview_container.hide()

# Creates the buttens used in the UI to build and and to look for already built buildings
func create_building_buttons(aBuildings : Array[Building]) -> void:
	
	var children : Array[Node] = buildings_container.get_children()
	for to_delete in children:
		if to_delete is BuildingButton:
			to_delete.queue_free()
	
	var campaign_ui : CampaignUI = Globals.campaign_UI
	for building in aBuildings:
		var button : BuildingButton = ButtonBuilding.instantiate() as BuildingButton
		buildings_container.add_child(button)
		
		button.building_reference = building
		button.province_data = province_data
		button.icon = get_icon_for_building(building.building_type)
		button.sg_send_building_reference_to_overview.connect(overview_container.show_building_overview)
		button.sg_send_province_data_reference.connect(overview_container.update_province_reference)
		
		# Buildings will only be upgradable pressing the button if the player owns that province
		if button.province_data.province.nation_owner == Globals.player_nation_node:
			button.sg_building_upgrade.connect(upgrade_building)
	
	pass


# Uses the string in "building_type" in the resource to return the corresponding icon
# each new building type needs to get added here with a corresponding icon stored in a variable
func get_icon_for_building(type : String) -> Texture2D:
	match type:
		"BUILDING_FARM": return icon_building_farm
		"BUILDING_GOVERNMENT": return icon_building_government
		"BUILDING_TEMPLE": return icon_building_temple
		_: return icon_default


# Recieves signal from the button_building to start a new building
# NOTE needs refactor, its not right to have the UI alter the state of the building manager
func start_construction(aBuilding : Building) -> void:
	if aBuilding == null:
		push_error("There is not building to be built")
		return
	
	var new_buildings : Array[Building] = buildings.duplicate(true) as Array[Building]
	aBuilding.is_built = true
	aBuilding.building_religion = province_data.religion_owner
	aBuilding.building_culture = province_data.culture_owner
	new_buildings.push_back(aBuilding.duplicate(true))
	# NOTE currently the buildings are done in an instant, they should be refactored
	province_data.province.buildings_manager.buildings = new_buildings.duplicate(true)
	province_data.province.buildings_manager.sg_new_building_done.emit()
	
	# Done in this way to lower coupling
	var province_to_update_UI : Province = province_data.province
	if province_to_update_UI == null:
		push_error("There is no reference to province in province data resource")
		return
	sg_update_UI_requested.connect(province_to_update_UI.send_data_to_ui)
	sg_update_UI_requested.emit()
	sg_update_UI_requested.disconnect(province_to_update_UI.send_data_to_ui)
	#region check for player nation
	var campaign_map : CampaignMap = Globals.campaign_map
	if campaign_map == null:
		push_error("Cant find campaign map, didnt deduct money from construction")
		return
	var player_nation : Nation = campaign_map.get_nation_by_tag()
	if player_nation == null:
		push_error("Cant find player nation, didnt deduct money from construction")
		return
	#endregion
	player_nation.gold -= aBuilding.get_building().cost


# Recieves signal from button_building to upgrade a building
func upgrade_building(aBuilding : Building) -> void:
	#region early returns
	if aBuilding == null:
		push_error("There is not building to be built")
		return
	# Wonrt be upgraded if at max level
	var max_level : int = aBuilding.levels.size() - 1
	if aBuilding.current_level == max_level:
		#push_error("upgrade not made, building at max level already")
		return
	#endregion
	

		#region check for player nation
	var campaign_map : CampaignMap = Globals.campaign_map
	if campaign_map == null:
		push_error("Cant find campaign map, didnt deduct money from construction")
		return
	var player_nation : Nation = campaign_map.get_nation_by_tag()
	if player_nation == null:
		push_error("Cant find player nation, didnt deduct money from construction")
		return
	#endregion
	
	var cost : int = aBuilding.get_building_next_level().cost
	player_nation.gold -= cost
	aBuilding.current_level += 1
	buildings = buildings # doing this, updates the UI easily
	#province_data.province.buildings_manager.buildings = buildings # UPDATES province UI (loyalty)
	province_data.province.buildings_manager.sg_new_building_done.emit()

func show_overview() -> void:
	pass
