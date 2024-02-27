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

# TEST
var units_to_create : Array[UnitData] = []
func _ready() -> void:
	var buttons : Array = container_btn_creator_units.get_children()
	for button in buttons as Array[ButtonArmyCreatorUnit]:
		# TEST
		button.sg_send_unit_data.connect(add_unit_to_list)
		# TEST
	
	pass
# TEST

func add_unit_to_list(data : UnitData) -> void:
	var untyped_array := units_to_create.duplicate(true)
	untyped_array.push_back(data)
	units_to_create.assign(untyped_array)
	pass

func _on_btn_create_army_pressed() -> void:
	if province_to_spawn_in == null:
		#push_error("There needs to be a province where to spawn in")
		#return
		pass
	
	
	var army_data := ArmyData.new() as ArmyData
	
	var unit_data_array := [] # Needs to not be typed to use push_back function
	#for unit in 5:
		#var new_unit := UnitData.new()
		#unit_data_array.push_back(new_unit)
	
	for unit in units_to_create:
		unit_data_array.push_back(unit)
	
	# Creating a typed array to give data as requered
	var unit_data_array_typed : Array[UnitData] = []
	unit_data_array_typed.assign(unit_data_array) 
	
	army_data.army_units = unit_data_array_typed
	# TEST
	#print(unit_data_array_typed)
	#print(army_data.army_units)
	
	var world := Globals.campaign_map as CampaignMap
	if world == null:
		push_error("Couldnt find the world")
		return
	
	var player_tag : String = Globals.playerNation
	var nation := world.get_nation_by_tag(player_tag) as Nation
	
	if nation == null:
		push_error("Couldnt find the player nation")
		return
	
	var spawn_position := Vector2(200, 200)
	
	army_creator_component.create_army(nation, army_data, spawn_position)
	
	#army_creator_component.create_army()
	# TEST
	
	pass # Replace with function body.
