@tool
extends Node
class_name SpawnPoint

@export var spawnMarker : Marker2D = null
@export_color_no_alpha var army_color = Color(0.5, 0.5, 0.5) : set = set_color
@export var setInPosition : bool = true
var army := []

# Called when the node enters the scene tree for the first time.
func _ready():
	start_units()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func start_units():
	if setInPosition:
		set_starting_position()
	set_color(army_color)

func set_starting_position():
	await get_tree().create_timer(0).timeout # It needs to wait until the tree has loaded for the "move_to" function to work well
	if spawnMarker == null:
		return
	var spacing = Vector2(cos(spawnMarker.rotation) * 220, 0.0)
	army = get_children()
	var offset = Vector2(cos(spawnMarker.rotation ), 0.0) * 220 * (max(1, army.size() - 1)) / 2
	for i in army.size():
		var unit = army[i] as Unit
		var newPos = spawnMarker.global_position + spacing * i - offset
		unit.global_position = newPos
		unit.set_destination("pan") # Used just to update the destination to the current position
		unit.set_face_direction(spawnMarker.rotation)
		unit.state = unit.State.IDLE # In case units overlaps while spawning and are set to melee stance

func set_color(value):
	army = get_children()
	army_color = value
	for unit in army:
		unit.army_color = army_color
#		unit.modulate = army_color
