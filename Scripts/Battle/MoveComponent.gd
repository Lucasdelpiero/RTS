extends Node
class_name  MoveComponent

@export var unit : Unit = null
var current_position = Vector2.ZERO
var destination : Vector2 = Vector2.ZERO
var chasing := false
var chase_in_queue = false # The chasing was ordered after queueing a path that has to be completed before going after the enemy
var next_point : Vector2 = Vector2.ZERO
var path : PackedVector2Array = []
var navigation_tilemap : TileMap = null : set = set_nav_map
var nav_map = null
@export_range(1,500, 1) var speed = 200
@onready var line = $Line2D
var face_direction : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	face_direction = unit.rotation
	if unit == null:
		return
	next_point = unit.global_position
	destination = unit.global_position
	pass # Replace with function body.

func _physics_process(delta):
	if unit == null:
		return
	
	draw_path()
	
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
	if path.size() == 0:
		unit.reached_destination()
	update_facing_angle()

# The unit will chase the target by updating the path every time the enemy moves in a set time
func chase(target : Unit):
	if chase_in_queue:
		if path.size() < 1: # Withouth this the last_point_in_path can crash
			return
		var last_point_in_path = path[path.size() - 1]
		if last_point_in_path != target.global_position:
			var arr = path.duplicate()
			arr.push_back(target.global_position)
			path = arr.duplicate()
	if not chase_in_queue:
		move_to(target.global_position, unit.global_position.angle_to_point(target.global_position))
	
	await get_tree().create_timer(0.5).timeout
	if chasing:
		chase(target)


func move_to(to, final_face_direction):
	if unit == null or nav_map == null:
		push_error("%s doesnt have a nav_map or unit" % [owner.name])
		return
	if unit.state == unit.State.MELEE:
		stop_movement()
		return
	destination = to
	#######################
	# Once i create obstacles i will get this pathing
#	path = NavigationServer2D.map_get_path(nav_map, unit.global_position, destination, true)
	####################
#	path = [unit.global_position, to] 
	path = get_pathing(to)
	
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

func face_unit(value : Unit):
	stop_movement()
	face_direction = unit.global_position.angle_to_point(value.global_position) + ( PI / 2)

func update_facing_angle():
#	print(path.size())
	var rot_speed = 0.05
	# Once the destination is reached it will face the desired angle
	if path.size() < 1:
		unit.rotation = lerp_angle(unit.rotation, face_direction, rot_speed)
		return
#	print(path)
#	print("what")
	# While moving it will face to the movement direction
	var angle = unit.global_position.angle_to_point(next_point) + PI / 2
	angle = unit.global_position.angle_to_point(unit.global_position + unit.velocity) + PI / 2
	unit.rotation = lerp_angle(unit.rotation,angle, rot_speed)

func draw_path():
	var has_to_draw = ( unit.selected and unit.ownership == Globals.playerNation )
	line.visible = has_to_draw
	if not has_to_draw:
		return
	
	var arr = [unit.global_position]
	for point in path:
		arr.push_back(point)
		line.points.push_back(point)
	line.points = arr.duplicate()


func move_to_face_melee(areas):
	if unit.ownership != "ROME":
		return
	if unit.state == unit.State.MELEE:
		return
	chase_in_queue = false
	var closest = areas[0] # default value
	
	# From the enemy face direction we calculate the angle difference to the angle from the enemy to the player,
	# we use this angle difference to choose the flank we will go into melee
	var angle_to_flank = 55 # Angle in radians from the center to the limit to one of the flanks
	var enemy_face_direction = Vector2(cos(closest.owner.rotation - PI /2), -sin(closest.owner.rotation + PI / 2)) 
	var angle_from_enemy_to_other = closest.owner.global_position.angle_to_point(unit.global_position)
	var v2 = Vector2(cos(angle_from_enemy_to_other), sin(angle_from_enemy_to_other))
	var angle_difference = enemy_face_direction.angle_to(v2)
	angle_difference = rad_to_deg(angle_difference)
	angle_difference = abs(angle_difference)
	var side = true # boolean is easier to use than multiple conditions
	var flank = ""
	# Choose flank acording to the angle difference
	if angle_difference < angle_to_flank:
		flank = "Front"
		side = false
	if angle_difference > 180 - angle_to_flank and angle_difference < 180 + angle_to_flank:
		flank = "Back"
		side = false
	if side:
		var left : Vector2
		var right : Vector2
		for area in areas:
			if area.name == "Left":
				left = area.global_position
			if area.name == "Right":
				right = area.global_position
		if left.distance_to(unit.global_position) < right.distance_to(unit.global_position):
			flank = "Left"
		else:
			flank = "Right"
	# Choose the closest if they are in a chosen flank
	for area in areas:
		if area.name == flank:
			closest = area
	###
	var targetSide = closest.meleePoint.global_position # Place were the unit is going to move
	var targetAngle = closest.meleePoint.rotation # Rotation of the place were is going to go
	var targetOwner = closest.owner # Has to add the rotation of the unit to the angle of the hurtbox to get the corret rotation
	face_direction = targetAngle + targetOwner.rotation
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

func get_pathing(to):
	var arr = path.duplicate()
	if Input.is_action_pressed("Shift"):
		arr.push_back(to)
		return arr
	return [unit.global_position, to]

func stop_movement():
	path.clear()
	unit.velocity = Vector2.ZERO
	chasing = false # maybe this cause a bug when following a unit that is running

func set_nav_map(value : TileMap):
	nav_map = value.get_navigation_map(0)
	pass




