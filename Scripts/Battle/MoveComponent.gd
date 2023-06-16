extends Node

@export var unit : Unit = null
var current_position = Vector2.ZERO
var destination : Vector2 = Vector2.ZERO
var chasing := false
var next_point : Vector2 = Vector2.ZERO
var path : PackedVector2Array = []
var navigation_tilemap : TileMap = null : set = set_nav_map
var nav_map = null
@export_range(1,500, 1) var speed = 200
@onready var line = $Line2D
var face_direction : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if unit == null:
		return
	
	next_point = unit.global_position
	destination = unit.global_position
	pass # Replace with function body.

func _physics_process(delta):
	if unit == null:
		return
	line.points = path
	
	if unit.global_position.distance_to(next_point) <= speed * delta:
		unit.global_position = next_point
		unit.velocity = Vector2.ZERO
		
		if path.size() > 0:
			path.remove_at(0)
			
		if path.size() > 0 :
			next_point = path[0]
	
	var angle = (unit.global_position).angle_to_point(next_point)
	unit.velocity = Vector2(cos(angle), sin(angle)) * speed
	unit.move_and_slide()
	update_facing_angle()

func chase(target : Unit):
	move_to(target.global_position, unit.global_position.angle_to_point(target.global_position))
	await get_tree().create_timer(0.5).timeout
	if chasing:
		chase(target)


func move_to(to, final_face_direction):
	if unit == null or nav_map == null:
		return
	
	destination = to
	path = NavigationServer2D.map_get_path(nav_map, unit.global_position, destination, true)
	
	if path.size() > 0:
		next_point = path[0]
	face_direction = final_face_direction # angle of the unit once reaches its destination

func update_facing_angle():
	# Once the destination is reached it will face the desired angle
	if path.size() <= 1:
		unit.rotation = lerp_angle(unit.rotation, face_direction, 0.05)
		return
	# While moving it will face to the movement direction
	var angle = unit.global_position.angle_to_point(next_point) + PI / 2
	unit.rotation = lerp_angle(unit.rotation,angle, 0.05)

func set_nav_map(value : TileMap):
	nav_map = value.get_navigation_map(0)
	pass




