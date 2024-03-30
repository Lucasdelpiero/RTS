class_name Main
extends Node2D

var player_army : Array = []
var enemy_army : Array = []
var player_nation : String = ""

var World : Variant = preload("res://Objects/Campaign/world/world.tscn")
#var _save := SaveGameAsJSON.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	_save.world = self
	Globals.main = self
	player_nation = Globals.player_nation
	
	# TEST
	#_create_or_load_save()
	#load_game()
	#save_game()
	#save_game()
	#save_game()
	#save_game()
	#save_game()

	pass # Replace with function body.

func start_battle() -> void:
	# Try loading map and if it works move there
	#region check for the battle_map
	var battle_map_scene := load("res://Objects/Battle/battle_map.tscn") as PackedScene
	if battle_map_scene == null:
		push_error("Scene couldnt be loaded")
		return 
	var battleWorld := battle_map_scene.instantiate() as BattleMap
	if battleWorld == null:
		push_error("Battlemap couldnt be instantiated")
		return
	#endregion
	
	# If it reached here then there is a map loaded and can save the game and move to the battle
	var world := get_tree().get_nodes_in_group("world")[0] as CampaignMap
	if world == null:
		push_error("World couldnt be found")
		return
	
	save_game() # Save before the battle
	
	world.queue_free() # delete the world
	
	# Now lets go to battle
	add_child(battleWorld)
	battleWorld.main = self
	battleWorld.sg_finished_battle.connect(return_from_battle)
	pass

func return_from_battle(data : Dictionary) -> void:
	data.battleMap.queue_free()
	var world := World.instantiate() as CampaignMap
	world.main = self
	add_child(world)
	Globals.reset_armies()
	load_game()
	
	
	pass

func save_game() -> void:
	var armies_to_save : Array = get_tree().get_nodes_in_group("armies")
	var nations_to_save : Array = get_tree().get_nodes_in_group("nations")
	
	var data : Dictionary = {
		"armies": armies_to_save, # not used
		"nations": nations_to_save,
	}
	var _save := SaveGameAsJSON.new()
	_save.write_savegame(data)
#	var data_to_load = _save.load_savegame()
#	print(data_to_load)
#	print("=================")
#	load_game(data_to_load) # This is just for testing



func load_game() -> void:
	var _save := SaveGameAsJSON.new()
	var data : Variant = _save.load_savegame()
	# Remove armies to clean before loading them
	var armies_to_remove : Array = get_tree().get_nodes_in_group("armies")
	for army in armies_to_remove as Array[Node]:
		army.queue_free()
	
	# Give the data to every nation and they will use the data to
	# update their data and create the armies and give them data to load
	# like a cascade
	var nations : Array = get_tree().get_nodes_in_group("nations")
	for el : Dictionary in data.nations:
		for nation in nations as Array[Nation]:
			if el.nation_tag == nation.nation_tag:
				nation.load_data(el)
				nation.set_colors()
				pass
	var world : CampaignMap = get_tree().get_nodes_in_group("world")[0] as CampaignMap
	if world == null:
		push_error("There is no world found")
		return
	world.initialize_world()

func _create_or_load_save() -> void:
#	if SaveGame.save_exists():
#		_save = SaveGame.load_savegame()
#	else:

#		save.write_savegame()
	save_game()

func window_resized() -> void:
	var to_update : Array = get_tree().get_nodes_in_group("update_on_window_resize")
	for node : Node in to_update:
#		if node.has("update_on_window_resize"):
		node.update_on_window_resize()
