extends Node

@export var unit : Unit = null
var current_position = Vector2.ZERO
var destination : Vector2 = Vector2.ZERO
var path : PackedVector2Array = []
@export_range(1,500, 1) var speed = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	if unit == null:
		return
	
	destination = unit.global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if unit == null:
		return
	var angle = (unit.global_position).angle_to_point(destination)
	unit.velocity = Vector2(cos(angle), sin(angle)) * speed
	if unit.global_position.distance_to(destination) <= speed * delta:
		unit.global_position = destination
		unit.velocity = Vector2.ZERO
	unit.move_and_slide()

func move_to():
#	var new_path = NavigationServer2D.map_get_path()
	pass
