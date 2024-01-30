extends Node2D
class_name Main

var playerArmy : Array = []
var enemyArmy : Array = []
var playerNation = ""

var World = preload("res://Objects/Campaign/world/world.tscn")
#var _save := SaveGameAsJSON.new()

# Called when the node enters the scene tree for the first time.
func _ready():
#	_save.world = self
	Globals.main = self
	playerNation = Globals.playerNation
	
	# TEST
	#_create_or_load_save()
	#load_game()
	#save_game()
	#save_game()
	#save_game()
	#save_game()
	#save_game()

	pass # Replace with function body.

func start_battle():
	save_game()
	var world = get_tree().get_nodes_in_group("world")[0] as Node2D
	world.queue_free()
	var battleWorld = load("res://Objects/Battle/battle_map.tscn").instantiate() as BattleMap
	add_child(battleWorld)
	battleWorld.main = self
	battleWorld.sg_finished_battle.connect(return_from_battle)
	pass

func return_from_battle(data : Dictionary):
	data.battleMap.queue_free()
	var world = World.instantiate()
	world.main = self
	add_child(world)
	Globals.reset_armies()
	load_game()
	
	
	pass

func save_game():
	var armies_to_save = get_tree().get_nodes_in_group("armies")
	var nations_to_save = get_tree().get_nodes_in_group("nations")
	
	var data = {
		"armies": armies_to_save, # not used
		"nations": nations_to_save,
	}
	var _save := SaveGameAsJSON.new()
	_save.write_savegame(data)
#	var data_to_load = _save.load_savegame()
#	print(data_to_load)
#	print("=================")
#	load_game(data_to_load) # This is just for testing



func load_game():
	var _save := SaveGameAsJSON.new()
	var data = _save.load_savegame()
	# Remove armies to clean before loading them
	var armies_to_remove = get_tree().get_nodes_in_group("armies")
	for army in armies_to_remove:
		army.queue_free()
	
	# Give the data to every nation and they will use the data to
	# update their data and create the armies and give them data to load
	# like a cascade
	var nations = get_tree().get_nodes_in_group("nations")
	for el in data.nations:
		for nation in nations:
			if el.NATION_TAG == nation.NATION_TAG:
				nation.load_data(el)
				nation.set_colors()
				pass
	var world = get_tree().get_nodes_in_group("world")[0]
	world.initialize_world()

func _create_or_load_save() -> void:
#	if SaveGame.save_exists():
#		_save = SaveGame.load_savegame()
#	else:

#		save.write_savegame()
	save_game()

func window_resized():
	var to_update = get_tree().get_nodes_in_group("update_on_window_resize")
	for node in to_update:
#		if node.has("update_on_window_resize"):
		node.update_on_window_resize()
