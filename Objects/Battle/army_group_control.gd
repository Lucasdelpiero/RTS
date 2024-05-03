@tool
class_name UnitsGroupControl
extends Node

@export var spawnMarker : Marker2D = null
@export_color_no_alpha var army_color : Color = Color(0.5, 0.5, 0.5) : set = set_color
@export var setInPosition : bool = true
@export var ownership : String = ""
var army : Array[Unit] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_units()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	pass

func start_units() -> void:
	if setInPosition:
		set_starting_position()
	set_color(army_color)

func set_starting_position() -> void:
	await get_tree().create_timer(0).timeout # It needs to wait until the tree has loaded for the "move_to" function to work well
	if spawnMarker == null:
		return
	var spacing := Vector2(cos(spawnMarker.rotation) * 276, 0.0)
	army = get_units_group()
	var offset : Vector2 = Vector2(cos(spawnMarker.rotation ), 0.0) * 276 * (max(1, army.size() - 1)) / 2
	for i in army.size():
		var unit : Unit = army[i] as Unit
		var newPos : Vector2 = spawnMarker.global_position + spacing * i - offset
		unit.global_position = newPos
		unit.set_destination(Vector2.ZERO) # Used just to update the destination to the current position
		unit.set_face_direction(spawnMarker.rotation)
		unit.state = unit.State.IDLE # In case units overlaps while spawning and are set to melee stance
		if ownership != "":
			unit.ownership = ownership
		else:
			push_error("Group doesnt have an ownerhip to be given")

func set_color(value : Color) -> void:
	army = get_units_group()
	army_color = value
	for unit in army as Array[Unit]:
		unit.army_color = army_color
#		unit.modulate = army_color

# BUG it returs zero units at the start of the battle while initialializing the world
func get_units_group() -> Array[Unit]:
	var units : Array = get_children()
	var units_group_typed : Array[Unit] = []
	units_group_typed.assign(units)
	return units_group_typed
