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
	_save.load_savegame()
#	print(armies_to_save)
#	print(nations_to_save)
	pass

func _create_or_load_save() -> void:
#	if SaveGame.save_exists():
#		_save = SaveGame.load_savegame()
#	else:

#		save.write_savegame()
		save_game()
