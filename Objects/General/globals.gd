extends Node

var global_units : GlobalUnits = null

var mouse_in_province : int = -1  # -1 means that no province is selected
var camera_angle : float = 0.0
var player_nation : String = "ROME"
var player_nation_node : Nation = null
# Array of armies of the player to be loaded in the battlemap
# it NEEDS to be a normal Array and not a typed one to perform functions as "push" and "has"
var player_army : Array = [] 
var player_army_data : Array[ArmyData] = []  # Array of armies data each containing units
# used by UI in buttons to easily check the amount of money the player has
var player_gold : int = 0
var player_manpower : int = 0
# Array of army of the enemy player to be loaded in the battlemap
# it NEEDS to be a normal Array and not a typed one to perform functions as "push" and "has"
var enemy_army : Array = []
var enemy_army_data : Array[ArmyData] = []
var debug : Debug = null
var debug_personal : Array = []
var main : Main = null
var campaign_map : CampaignMap = null
var battle_map : BattleMap = null : set = set_battle_map
var campaign_UI : CampaignUI = null

var shader_hovered := preload("res://Shaders/hovered.tres") as Material
var shader_selected := preload("res://Shaders/selected.tres") as Material

var global_units_res_path := preload("res://Objects/Campaign/military/unit_data/global_units.tres") as GlobalUnits

signal sg_battlemap_set_units_selected(unit : Unit, value : bool)

var PERSONAL_DEBUGGER : String = "DebugPersonal" # just to avoid mistakes

func _ready() -> void:
	# global_units NEED to be setted in the ready function as if they are tried to be set
	# in the editor they dont show up, thats why they are preloaded and setted here
	global_units = global_units_res_path


func set_battle_map(value : BattleMap) -> void:
	battle_map = value
	Signals.battle_map = value

func battlemap_set_units_selected(unit : Unit, value : bool) -> void:
	sg_battlemap_set_units_selected.emit(unit, value)
	pass

func reset_armies() -> void:
	player_army = []
	player_army_data = []
	enemy_army = []
	enemy_army_data = []

func debug_update_label(variable_name : String , value : Variant) -> void:
	if debug == null:
		return
	var value_string : String = str(value)
	debug.update_label(variable_name, value_string)
	pass

func personal_debug_update(owner_node : Node ,ID : String, value : Variant ) -> void:
	var value_string : String = str(value)
	var personal_debugger := owner_node.find_child(PERSONAL_DEBUGGER) as DebugPersonal
	if personal_debugger == null:
		push_warning("%s doesnt have a personal debugger" % [owner_node.name])
		return
		
	personal_debugger.update_local_value_label(ID, value_string)
	

func window_resized() -> void:
	var to_update : Array = get_tree().get_nodes_in_group("update_on_window_resize")
	for node in to_update as Array[Node]:
		node.update_on_window_resize()
	if main == null:
		return
	main.window_resized()


func get_units_by_culture(culture_id : int) -> Array[UnitData]:
	var culture_units : Array[UnitData] = []
	for culture in global_units.cultural_group_unit_data:
		if culture.cultural_group_exlclusive == culture_id:
			culture_units.assign(culture.array_scene_unit_data)

	return culture_units


func get_units_by_nation(nation_tag : String) -> Array[UnitData]:
	var national_units : Array[UnitData] = []
	for nation in global_units.national_group_unit_data:
		if nation.nation_exclusive == nation_tag:
			national_units.assign(nation.array_scene_unit_data)
	
	return national_units



