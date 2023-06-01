@tool
extends Node
class_name Nation

@export var NATION_TAG  = ""
@export_color_no_alpha var nationOutline = Color(0, 0, 0)
@export_color_no_alpha var nationColor = Color(0, 0, 0)
@export_range(10, 1000, 0.1) var gold = 100
@export_range(0, 500000, 1) var manpower = 10000
@export var isPlayer = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_colors()

func set_colors():
	var armies = get_children()
	for a in armies:
		a.army_color = nationColor # Color used in the "selected" shader
		a.modulate = nationColor # Color used normally

# The nations stores all their data and their armies data and returns it to be used in the savegame
func save():
	# Every army gets called to save all their data and store all dictionaries
	# in an array
	var armies = get_children()
	var army_array = []
	for army in armies:
		army_array.push_back(army.save())
	
	var save_dict = {
		"NATION_TAG" : NATION_TAG,
		"nationOutline" : {
			"r" : nationOutline.r,
			"g" : nationOutline.g,
			"b" : nationOutline.b,
		},
		"nationColor" : {
			"r" : nationColor.r,
			"g" : nationColor.g,
			"b" : nationColor.b,
		},
		"gold" : gold,
		"manpower" : manpower,
		"armies" : army_array,
	}
	return save_dict

func load_data(data : Dictionary):
	# Have to clear this garbage
#	var world = get_tree().get_nodes_in_group("world")[0] 
#	var mouse = get_tree().get_nodes_in_group("mouse")[0]
	#####################################
	gold = data.gold
	manpower = data.manpower
	# Every army is created and their data is sent to them to be processed
	for army in data.armies:
		var scene = load(army.filename).instantiate() 
		add_child(scene)
		scene.load_data(army)

