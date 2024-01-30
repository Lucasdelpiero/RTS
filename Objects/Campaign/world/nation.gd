@tool
extends Node
class_name Nation

signal sg_update_resources_ui(data)

@export var NATION_TAG  = ""
@export_color_no_alpha var nationOutline = Color(0, 0, 0)
@export_color_no_alpha var nationColor = Color(0, 0, 0)
@export_range(10, 1000, 0.1) var gold : float = 100
@export_range(0, 500000, 1) var manpower : int = 10000
@export var isPlayer = false
@export var nation_banuses : Array[Bonus] = []

var resources_generated : Array[Production] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	set_colors()

func set_colors():
	var armies = get_children()
	for a in armies:
		a.army_color = nationColor # Color used in the "selected" shader
		a.modulate = nationColor # Color used normally

func resource_incoming(data : Production):
	resources_generated.push_back(data)

func process_resources_recieved():
	
	var total = resources_generated.map(func(el): return el.base_income).reduce(func(a,b): return a + b)
	if total == null:
		push_error("Error in calculating resources")
		return
	
	gold += total
	
	#markup to a function to calc the earnings
	var national_bonus : float = 0.1
	var provincial_bonus : float = 0.2
	var total_bonus : float = national_bonus + provincial_bonus
	
	var total_generated = total * (1.0 + total_bonus)
	
	Globals.debug_update_label("generated", "generated: %s = %s * (1.0 + %s + %s)" % 
	[
		total_generated,
		total,
		national_bonus, 
		provincial_bonus
	]
	)
	
	# Reset the resources for the next frame
	resources_generated.clear()
	#print("nation: %s  money: %s  resources generated: %s" % [NATION_TAG, gold, total])
	
	var data : Dictionary = {
		"gold" = gold,
		"manpower" = manpower
	}
	sg_update_resources_ui.emit(data)
	pass



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


