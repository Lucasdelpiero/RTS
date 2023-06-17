@tool
extends Node
class_name SpawnPoint

@export var spawnMarker : Marker2D = null
@export_color_no_alpha var army_color = Color(0.5, 0.5, 0.5) : set = set_color
var army := []

# Called when the node enters the scene tree for the first time.
func _ready():
	start_units()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func start_units():
	set_starting_position()
	set_color(army_color)

func set_starting_position():
	if spawnMarker == null:
		return
	var spacing = Vector2(cos(spawnMarker.rotation) * 220, 0.0)
	army = get_children()
	for i in army.size():
		army[i].global_position = spawnMarker.global_position + spacing * i
		army[i].set_destination("pan") # Used just to update the destination to the current position

func set_color(value):
	army = get_children()
	army_color = value
	for unit in army:
		unit.army_color = army_color
		unit.modulate = army_color
