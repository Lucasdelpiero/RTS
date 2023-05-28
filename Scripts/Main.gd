extends Node2D
class_name Main

var playerArmy : Array = []
var enemyArmy : Array = []
var playerNation = ""

var _save := SaveGameAsJSON.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	_save.world = self
	playerNation = Globals.playerNation
	_create_or_load_save()
#	save_game()
	pass # Replace with function body.

func start_battle():
	var world = get_tree().get_nodes_in_group("world")[0] as Node2D
	world.queue_free()
	var battleWorld = load("res://Scenes/Battle/battle_map.tscn").instantiate()
	add_child(battleWorld)
	
func save_game():
	var armies_to_save = get_tree().get_nodes_in_group("armies")
	var nations_to_save = get_tree().get_nodes_in_group("nations")
	
	var data = {
		"armies": armies_to_save,
		"nations": nations_to_save,
	}
	_save.write_savegame(data)
	var data_to_load = _save.load_savegame()
	load_game(data_to_load)


func load_game(data : Dictionary):
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
