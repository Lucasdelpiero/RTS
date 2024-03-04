@tool
class_name Nation
extends Node

signal sg_update_resources_ui(data : TotalProductionData)

@export var NATION_TAG  : String = ""
@export var culture : Cultures.list = Cultures.list.NONE
@export_color_no_alpha var nationOutline : Color = Color(0, 0, 0)
@export_color_no_alpha var nationColor : Color = Color(0, 0, 0)
@export_range(10, 1000, 0.1) var gold : float = 100 : 
	set(value):
		gold = value
		var data : TotalProductionData = total_production_last_time
		if data == null:
			total_production_last_time = TotalProductionData.new()
			data = total_production_last_time
		data.gold = int(gold)
		sg_update_resources_ui.emit(data) # needed to update when money is spent
@export_range(0, 500000, 1) var manpower : int = 10000
@export var isPlayer : bool = false
@export var nation_banuses : Array[Bonus] = []
@export var capital : Province = null :
	set(value):
		if value == null: # reset value (for editing)
			capital = value
			return
		# Capital needs to be owned by the nation to be set
		if value.ownership == NATION_TAG: 
			capital = value
			return
		
		push_error("Capital is not owned by the nation")

var resources_generated : Array[Production] = []

var total_production_last_time : TotalProductionData = null



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_colors()
	if capital == null:
		capital = get_default_capital()
		pass

func set_colors() -> void:
	var armies_temp : Array = get_children()
	var armies : Array[ArmyCampaing] = []
	armies.assign(armies_temp)
	for a in armies :
		a.army_color = nationColor # Color used in the "selected" shader
		a.modulate = nationColor # Color used normally

# Used mostly to get a capital for small nation of 1 or few provinces
func get_default_capital() -> Province:
	var provinces : Array = get_tree().get_nodes_in_group("provinces")
	var my_provinces : Array = provinces.filter(func(el: Province) -> bool: return NATION_TAG == el.ownership)
	var new_capital : Province = null
	if my_provinces.size() > 0:
		new_capital = my_provinces[0]
	return new_capital

func resource_incoming(data : Production) -> void:
	resources_generated.push_back(data)

func process_resources_recieved() -> void:
	var total_gold_generated : int = resources_generated.map(func(el : Production) -> int: return el.gold).reduce(func(a : int,b : int) -> int: return a + b)
	var gold_delta : int = 0
	if total_gold_generated == null:
		push_error("Error in calculating resources")
		return
	
	# Armies cost
	var armies : Array[ArmyCampaing] = []
	armies.assign(get_children())
	var army_cost_list : Array[int] = []
	army_cost_list.assign(armies.map(func(el: ArmyCampaing) -> int: return el.army_data.get_army_cost()))
	var army_total_cost : int = 0
	# Uses a for loop instead of a reduce to handle empty arrays
	for cost in army_cost_list:
		army_total_cost += cost
	
	gold_delta = total_gold_generated - army_total_cost
	
	gold += gold_delta
	
	var total_manpower_generated : int = resources_generated.map(func(el : Production) -> int: return el.manpower).reduce(func(a : int,b : int) -> int: return a + b)
	if total_manpower_generated == null:
		push_error("Error in calculating resources")
		return
	
	manpower += total_manpower_generated
	
	# Reset the resources for the next frame
	resources_generated.clear()
	#print("nation: %s  money: %s  resources generated: %s" % [NATION_TAG, gold, total])

	var data : TotalProductionData = TotalProductionData.new()
	data.gold = int(gold)
	data.manpower = manpower
	data.gold_generated = total_gold_generated - army_total_cost
	data.manpower_generated = total_manpower_generated
	sg_update_resources_ui.emit(data)
	
	total_production_last_time = data


# The nations stores all their data and their armies data and returns it to be used in the savegame
func save() -> Dictionary:
	# Every army gets called to save all their data and store all dictionaries
	# in an array
	var armies : Array = get_children()
	var army_array : Array = []
	for army in armies as Array[ArmyCampaing]:
		army_array.push_back(army.save())
	
	var save_dict : Dictionary = {
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

# TODO change this so it recieves a resource instead of a dictionary
func load_data(data : Dictionary) -> void:
	# Have to clear this garbage
#	var world = get_tree().get_nodes_in_group("world")[0] 
#	var mouse = get_tree().get_nodes_in_group("mouse")[0]
	#####################################
	gold = data.gold
	manpower = data.manpower
	# Every army is created and their data is sent to them to be processed
	for army : Variant in data.armies:
		var scene := load(army.filename).instantiate() as ArmyCampaing
		if scene == null:
			push_error("Error loading an army")
			continue
		add_child(scene)
		scene.load_data(army)


