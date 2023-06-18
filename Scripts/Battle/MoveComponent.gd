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
	
	if unit.state == unit.State.MELEE:
		unit.global_position = lerp(unit.global_position, destination, 0.2)
	
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
#		print(path)
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
	
	if unit.state == unit.State.MELEE:
		stop_movement()
#		print("volvetee")
		return
	
	destination = to
	path = NavigationServer2D.map_get_path(nav_map, unit.global_position, destination, true)
	
	
	if path.size() > 0:
		next_point = path[0]
	face_direction = final_face_direction # angle of the unit once reaches its destination
	# Rotate if the angle is large
	if path.size() > 0 : 
		if path[path.size() - 1].distance_to(unit.global_position) > 128:
			var a = Vector2(cos(face_direction), sin(face_direction))
			var b = Vector2(cos(unit.rotation), sin(unit.rotation))
			if a.dot(b) < 0 and not chasing:
				return
#				unit.rotation = lerp_angle(unit.rotation, unit.rotation + PI, 1.0)

func update_facing_angle():
#	print(path.size())
	var rot_speed = 0.05
	# Once the destination is reached it will face the desired angle
	if path.size() <= 1:
		unit.rotation = lerp_angle(unit.rotation, face_direction, rot_speed)
		return
	# While moving it will face to the movement direction
	var angle = unit.global_position.angle_to_point(next_point) + PI / 2
	unit.rotation = lerp_angle(unit.rotation,angle, rot_speed)

func move_to_face_melee(areas):
	if unit.ownership != "ROME":
		return
	if unit.state == unit.State.MELEE:
		return
	# Get closer area
	var closest = areas[0]
#	print("areas : " +str(areas))
	for area in areas:
		var closest_distance = unit.global_position.distance_to(closest.global_position)
		var distance = unit.global_position.distance_to(area.global_position)
#		print("%s from: %s distance: %s /closest distance: %s" % [area.name,area.owner , distance, closest_distance])
#		print("unit_pos: %s / area_pos: %s" % [unit.global_position, area.global_position])
		if distance < closest_distance:
			closest = area
	var targetSide = closest.meleePoint.global_position
	var targetAngle = closest.meleePoint.rotation
	face_direction = targetAngle
#	print(closest)
#	print(targetAngle)
	stop_movement()
	destination = targetSide
#	var line = Line2D.new()
#	add_child(line)
#	line.add_point(unit.global_position)
#	line.add_point(closest.global_position)
#	move_to(targetSide, targetAngle)
	
	
#	print("closest: " +str(closest))
	
#	print(data)
	pass

func stop_movement():
	path.clear()
	unit.velocity = Vector2.ZERO

func set_nav_map(value : TileMap):
	nav_map = value.get_navigation_map(0)
	pass




