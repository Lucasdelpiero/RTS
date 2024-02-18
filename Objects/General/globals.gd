extends Node

var mouse_in_province : int = 1
var camera_angle : float = 0.0
var playerNation : String = "ROME"
var player_nation_node : Nation = null
# Array of armies of the player to be loaded in the battlemap
# it NEEDS to be a normal Array and not a typed one to perform functions as "push" and "has"
var playerArmy : Array = [] 
var playerArmyData : Array[ArmyData] = []  # Array of armies data each containing units
var player_gold : int = 0 # used by UI in buttons to easily check the amount of money the player has
var player_manpower : int = 0
# Array of army of the enemy player to be loaded in the battlemap
# it NEEDS to be a normal Array and not a typed one to perform functions as "push" and "has"
var enemyArmy : Array = []
var enemyArmyData : Array[ArmyData] = []
var debug : Debug = null
var debug_personal : Array = []
var main : Main = null
var campaign_map : CampaignMap = null
var battle_map : BattleMap = null : set = set_battle_map
var campaign_UI : CampaignUI = null

var shader_hovered := preload("res://Shaders/hovered.tres") as Material
var shader_selected := preload("res://Shaders/selected.tres") as Material

signal sg_battlemap_set_units_selected(unit : Unit, value : bool)

var PERSONAL_DEBUGGER : String = "DebugPersonal" # just to avoid mistakes

func set_battle_map(value : BattleMap) -> void:
	battle_map = value
	Signals.battle_map = value

func battlemap_set_units_selected(unit : Unit, value : bool) -> void:
	sg_battlemap_set_units_selected.emit(unit, value)
	pass

func reset_armies() -> void:
	playerArmy = []
	playerArmyData = []
	enemyArmy = []
	enemyArmyData = []

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

