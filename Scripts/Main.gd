extends Node2D
class_name Main

var playerArmy : Array = []
var enemyArmy : Array = []
var playerNation = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	playerNation = Globals.playerNation
	pass # Replace with function body.

func start_battle():
	var world = get_tree().get_nodes_in_group("world")[0] as Node2D
	world.queue_free()
	var battleWorld = load("res://Scenes/Battle/battle_map.tscn").instantiate()
	add_child(battleWorld)
	
