class_name ArmyCreatorUI
extends Control

# Interface used by the player to spawn units in the map
# Gets the units that can be created and put them in a list to select which ones to build
# Once the units selected are to be created, they will be put in an army in
# the province that is selected to spawn in


@export var BtnArmyCreatorUnit : PackedScene
@export var ArmyCampaignP : PackedScene 
@onready var province_to_spawn_in : Province = null
@onready var label_province_to_spawn_in := %LabelProvinceSpawn as Label
@onready var army_creator_component := %ArmyCreatorComponent as ArmyCreatorComponent
# Container of the buttons used to add units to a list to create new army
@onready var container_btn_creator_units := %ContainerBtnCreatorUnits as VBoxContainer
# Container of the buttons that are the in the new army to be created
@onready var container_btn_new_army := %ContainerBtnNewArmy as VBoxContainer
@onready var new_army_manager := %NewArmyManager as PanelContainer

# TEST
func _ready() -> void:
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
	
	army_creator_component.create_army(nation, army_data, spawn_position)
	delete_buttons_new_army()

func delete_buttons_new_army() -> void:
	var buttons := container_btn_new_army.get_children() as Array
	for button in buttons as Array[Button]:
		button.queue_free()
