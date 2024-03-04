class_name ArmyCreatorUI
extends Control

# Interface used by the player to spawn units in the map
# Gets the units that can be created and put them in a list to select which ones to build
# Once the units selected are to be created, they will be put in an army in
# the province that is selected to spawn in


@export var BtnArmyCreatorUnit : PackedScene
@export var ArmyCampaignP : PackedScene 
@onready var province_to_spawn_in : Province = null
@onready var army_creator_component := %ArmyCreatorComponent as ArmyCreatorComponent
# Container of the buttons used to add units to a list to create new army
@onready var container_btn_creator_units := %ContainerBtnCreatorUnits as VBoxContainer
# Container of the buttons that are the in the new army to be created
@onready var container_btn_new_army := %ContainerBtnNewArmy as VBoxContainer
@onready var new_army_manager := %NewArmyManager as NewArmyManager
@onready var btn_create_army := %BtnCreateArmy as Button # Create army if the player has enough money

@onready var button_open_window : Button = null
@onready var spawn_province_panel := %SpawnProvincePanel as PanelContainer
@onready var spawn_province_container := %SpawnProvinceContainer as VBoxContainer
@export var btn_provinceP : PackedScene = null
@onready var btn_province_spawn := %BtnProvinceSpawn as Button

# TEST
func _ready() -> void:
	visible = false
	spawn_province_panel.visible = false 
	var buttons : Array = container_btn_creator_units.get_children()
	
	for button in buttons as Array[ButtonArmyCreatorUnit]:
		# TEST
		button.sg_send_unit_data.connect(new_army_manager.add_unit_to_list)
		# TEST
# TEST

func _on_btn_create_army_pressed() -> void:
	if province_to_spawn_in == null:
		#push_error("There needs to be a province where to spawn in")
		#return
		pass
	
	var army_data := ArmyData.new() as ArmyData
	var unit_data_array := [] # Needs to not be typed to use push_back function
	var new_army_buttons : Array = container_btn_new_army.get_children()
	
	for button in new_army_buttons as Array[ButtonArmyCreatorUnit]:
		unit_data_array.push_back(button.unit_data)
	
	# Creating a typed array to give data as requered
	var unit_data_array_typed : Array[UnitData] = []
	unit_data_array_typed.assign(unit_data_array) 
	army_data.army_units = unit_data_array_typed
	
	#region error handling
	var world := Globals.campaign_map as CampaignMap
	if world == null:
		push_error("Couldnt find the world")
		return
	
	var player_tag : String = Globals.playerNation
	var nation := world.get_nation_by_tag(player_tag) as Nation
	
	if nation == null:
		push_error("Couldnt find the player nation")
		return
	#endregion
	
	var spawn_position := Vector2(200, 200)
	
	if province_to_spawn_in != null:
		spawn_position = province_to_spawn_in.global_position
	
	army_creator_component.create_army(nation, army_data, spawn_position)
	new_army_manager.delete_buttons_new_army()


func _on_btn_close_window_pressed() -> void:
	visible = false
	if button_open_window == null:
		return
	button_open_window.set_toggled(false)

# Open the window to create a new army
func _on_btn_army_creation_pressed() -> void:
	var player_nation : Nation = Globals.player_nation_node
	if player_nation == null:
		push_error("Couldnt find player nation")
		return
	province_to_spawn_in = player_nation.capital
	btn_province_spawn.text = "Recruited in: %s" % [province_to_spawn_in.name]
	visible = !visible
	
	# Clean the list
	var buttons_to_delete : Array = container_btn_creator_units.get_children()
	for button in buttons_to_delete as Array[Node]:
		button.queue_free()
	
	# Get units by the nation_tag (exclusive)
	var nation_units_data : Array[UnitData] = Globals.get_units_by_nation(Globals.playerNation)
	for unit_data in nation_units_data:
		var new_button_unit := BtnArmyCreatorUnit.instantiate() as ButtonArmyCreatorUnit
		container_btn_creator_units.add_child(new_button_unit)
		new_button_unit.unit_data = unit_data
		new_button_unit.sg_send_unit_data.connect(new_army_manager.add_unit_to_list)
	
	# Get units by the culture (exclusive)
	var culture_units_data : Array[UnitData] = Globals.get_units_by_culture(player_nation.culture)
	for unit_data in culture_units_data:
		var new_button_unit := BtnArmyCreatorUnit.instantiate() as ButtonArmyCreatorUnit
		container_btn_creator_units.add_child(new_button_unit)
		new_button_unit.unit_data = unit_data
		new_button_unit.sg_send_unit_data.connect(new_army_manager.add_unit_to_list)

func _on_btn_province_spawn_pressed() -> void:
	# Clean container
	var button_to_delete : Array = spawn_province_container.get_children().filter(func(el: Control) -> bool: return el is BtnProvince)
	for button in button_to_delete as Array[Button]:
		button.queue_free()
	
	spawn_province_panel.visible = !spawn_province_panel.visible
	
	#region error handling
	if btn_provinceP == null:
		push_error("There is no packedscene to instantiate")
	var world : CampaignMap = Globals.campaign_map
	if world == null:
		push_error("There is no campaign map reference in global script")
		return
	#endregion
	
	var player_provinces : Array[Province] = world.get_provinces_by_tag(Globals.playerNation)
	
	for province in player_provinces as Array[Province]:
		var new_button_province := btn_provinceP.instantiate() as BtnProvince
		spawn_province_container.add_child(new_button_province)
		new_button_province.province = province
		new_button_province.pressed_btn_province.connect(set_province_to_spawn_in)
		if province == Globals.player_nation_node.capital:
			new_button_province.move_to_front()
	

func set_province_to_spawn_in(value : Province) -> void:
	if value == null:
		push_error("Invalid province value to set army to spawn in")
		return
	province_to_spawn_in = value
	btn_province_spawn.text = "Recruited in: %s" % [province_to_spawn_in.name]
	spawn_province_panel.visible = false

# Its called when:
# - The amount of money of the player changes in the UI
# - There is a change in the list of units to create in the army
func check_if_can_afford_army() -> void:
	btn_create_army.disabled = Globals.player_gold < new_army_manager.army_cost

func _on_campaing_ui_sg_gold_amount_changed() -> void:
	check_if_can_afford_army()
