extends Node

var mouse_in_province = 1
var camera_angle := 0.0
var playerNation = "ROME"
var playerArmy = [] # Array of armies of the player
var playerArmyData : Array[ArmyData] = []  # Array of armies data each containing units
var enemyArmy = []
var enemyArmyData : Array[ArmyData] = []
var debug : Debug = null
var debug_personal : Array = []
var main : Main = null
var campaign_map : CampaignMap = null
var battle_map : BattleMap = null : set = set_battle_map
var campaign_UI : CampaignUI = null

var shader_hovered = preload("res://Shaders/hovered.tres")
var shader_selected = preload("res://Shaders/selected.tres")

signal sg_battlemap_set_units_selected(unit, value)

var PERSONAL_DEBUGGER : String = "DebugPersonal" # just to avoid mistakes

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_battle_map(value):
	battle_map = value
	Signals.battle_map = value

func battlemap_set_units_selected(unit, value):
	sg_battlemap_set_units_selected.emit(unit, value)
	pass

func reset_armies():
	playerArmy = []
	playerArmyData = []
	enemyArmy = []
	enemyArmyData = []

func debug_update_label(variable_name : String , value):
	if debug == null:
		return
	debug.update_label(variable_name, value)
	pass

func personal_debug_update(owner_node ,ID , value ):
	var personal_debugger = owner_node.find_child(PERSONAL_DEBUGGER) as DebugPersonal
	if personal_debugger == null:
		push_warning("%s doesnt have a personal debugger" % [owner_node.name])
		return
		
	personal_debugger.update_local_value_label(ID, value)
	

func window_resized():
	var to_update = get_tree().get_nodes_in_group("update_on_window_resize")
	for node in to_update:
		node.update_on_window_resize()
	if main == null:
		return
	main.window_resized()

