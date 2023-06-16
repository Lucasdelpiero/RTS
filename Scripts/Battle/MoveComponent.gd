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
	if path.size() > 0:
		unit.velocity = Vector2(cos(angle), sin(angle)) * speed
	else:
		unit.velocity = Vector2.ZERO
	unit.move_and_slide()
#	if owner.name == "Rome1":
#		print(unit.velocity)
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

func move_to_face_melee(data):
	if owner.ownership != "ROME":
		return
	chasing = false
	var target = data["targetFlank"]
	var target_children = target.get_children()
	var target_pos = target.global_position
#	if target.name != "Back":
#		"nono"
#		return
	for i in target_children:
#		print(i)
		if i.is_in_group("meleePoint"):
#			print("is in group")
			target_pos = i.global_position
			var final_angle = i.rotation
			move_to(target_pos, final_angle)
			path.clear()
			unit.global_position = target_pos
#	print(target_pos)
#	print(target.global_position)
	var collisionPoint = data["collisionPoint"]
	var final_angle = target.rotation + PI
	var angle = target.rotation
	var margin = 128 + 12
	var new_pos = target.global_position + Vector2(cos(angle), sin(angle)) * margin
#	move_to(new_pos, final_angle)
#	new_pos = target_pos
#	move_to(new_pos, final_angle)
#	path.clear()
#	unit.global_position = new_pos
#	print(target)
	pass

func move_to_face_melee_new(areas):
	var closest = areas[0]
	var closest_distance = unit.global_position.distance_to(closest.global_position)
	for area in areas:
		var distance = unit.global_position.distance_to(closest.global_position)
		if distance < closest_distance:
			closest = area
	print(closest)
	
#	print(data)
	pass

func set_nav_map(value : TileMap):
	nav_map = value.get_navigation_map(0)
	pass




