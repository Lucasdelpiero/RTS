extends Node
class_name  MoveComponent

@export var unit : Unit = null
var current_position : Vector2 = Vector2.ZERO
var destination : Vector2 = Vector2.ZERO
var target : Unit = null
var want_to_chase : bool = false
var chasing : bool = false
var chase_in_queue : bool= false # The chasing was ordered after queueing a path that has to be completed before going after the enemy
var next_point : Vector2 = Vector2.ZERO
var path : PackedVector2Array = []
var navigation_tilemap : TileMap = null : set = set_nav_map
var nav_map : Variant = null
@export_range(1,800, 1) var speed : int = 200
var pushVector := Vector2.ZERO
var anchored := true # if an unit reached an empty position is true, else it will be false unit is true
@onready var line : Line2D = $Line2D
@onready var timerChase : Timer = $TimerChase
var face_direction : float = 0.0

const MARGIN_DISTANCE_TO_MOVE : float = 10
const MARGIN_ANGLE_TO_MOVE : float = PI/16
var last_position_moved_to : Vector2 = Vector2.ZERO
var last_angle_moved_to : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if unit == null:
		return
	face_direction = unit.rotation
	next_point = unit.global_position
	destination = unit.global_position
	pass # Replace with function body.

func _physics_process(delta : float) -> void:
	if unit == null:
		return
	
	draw_path()
	
	if unit.state == unit.State.MELEE:
		unit.global_position = lerp(unit.global_position, destination, 0.2)
	
	if unit.global_position.distance_to(next_point) <= speed * delta and path.size() > 0 :
		if not unit.unitDetector.is_colliding():
			unit.global_position = next_point
		unit.velocity = Vector2.ZERO
		
		if path.size() > 0:
			path.remove_at(0)
			
		if path.size() > 0 :
			next_point = path[0]
	
	var angle : float = (unit.global_position).angle_to_point(next_point)
	var new_speed := Vector2.ZERO
	if path.size() > 0:
		unit.velocity = Vector2(cos(angle), sin(angle)) * speed
		new_speed = Vector2(cos(angle), sin(angle)) * speed
	else:
		unit.velocity = Vector2.ZERO
		new_speed = Vector2.ZERO
	
	var pushStrength := Vector2.ZERO
	if unit.unitDetector.is_colliding():
#		pushVector = unit.unitDetector.get_push_vector()
		pushStrength = unit.unitDetector.get_push_strength()
	update_is_anchored() # used here so if the pathsize is 0 it will be true
#	var push = pushVector * (speed / 2)  * int(!anchored)  # should know if the other unit is also anchored
	pushStrength *=  int(!anchored)  # should know if the other unit is also anchored
#	var new = new_speed + push
	var new : Vector2 = new_speed + pushStrength
	unit.velocity = new
	if unit.name == "Hastati":
#		push_warning(push)
#		push_warning("new_seed: ", new_speed + push)
#		push_warning("new: ", new)
		pass
	unit.move_and_slide()
#	if owner.name == "Rome1":
#		push_warning(path)
#		push_warning(unit.velocity)
	if path.size() == 0:
		unit.reached_destination()
	update_facing_angle()

func set_destination(aDestination : Vector2) -> void:
	destination = aDestination

func set_next_point(aNextPoint : Vector2) -> void:
	next_point = aNextPoint

# The unit will chase the target by updating the path every time the enemy moves in a set time
func chase(target_to_chase : Unit = null) -> void:
	if target_to_chase != null: # Stores the target unit
		target = target_to_chase 
	if target == null :
		push_error("fuuuu")
		return
	if chase_in_queue:
		if path.size() < 1: # Withouth this the last_point_in_path can crash
			return
		var last_point_in_path : Vector2 = path[path.size() - 1]
		if last_point_in_path != target.global_position:
			var arr : Array = path.duplicate()
			arr.push_back(target.global_position)
			path = arr.duplicate()
	if not chase_in_queue:
		move_to(target.global_position, unit.global_position.angle_to_point(target.global_position))
	
	if timerChase.is_stopped() and chasing:
#		push_warning("timer set")
		timerChase.start(0.5)
#	await get_tree().create_timer(0.5).timeout
#	if chasing:
#		push_warning(target.name)
#		chase()


func move_to(to : Vector2, final_face_direction: float) -> void:
	if unit == null or nav_map == null:
		#push_error("%s doesnt have a nav_map or unit" % [owner.name])
		push_error("%s doesnt have a nav_map or unit" % ["test"])
		return
	if unit.state == unit.State.MELEE:
		stop_movement()
		return
	destination  = to
	
	# Avoid having the units have a seizure when they move small distances or angles
	# or more importantly, when they move to the same position and angle
	if (last_position_moved_to != Vector2.ZERO) and (last_angle_moved_to !=0):
		var distance_diff : float = destination.distance_to(last_position_moved_to)
		var angle_diff : float = abs(angle_difference(final_face_direction, last_angle_moved_to))
		
		if (distance_diff < MARGIN_DISTANCE_TO_MOVE) and (angle_diff < MARGIN_ANGLE_TO_MOVE):
			return
	last_position_moved_to = destination
	last_angle_moved_to = final_face_direction
	


	#######################
	# Once i create obstacles i will get this pathing
#	path = NavigationServer2D.map_get_path(nav_map, unit.global_position, destination, true)
	####################
#	path = [unit.global_position, to] 
#   path = HERE i should use a navigation agent maybe
	path = get_pathing(to)
	
	if path.size() > 0:
		next_point = path[0]
	Globals.personal_debug_update(owner, "face dir", "Face_dir: %s/%s" % [face_direction, final_face_direction])
	face_direction = final_face_direction # angle of the unit once reaches its destination
	# Rotate if the angle is large
	update_is_anchored() # used here to not anchor the unit if the distance is greater than 128 pixels
	if path.size() > 0 : 
		if path[path.size() - 1].distance_to(unit.global_position) > 128:
			var a : Vector2 = Vector2(cos(face_direction), sin(face_direction))
			var b : Vector2 = Vector2(cos(unit.rotation), sin(unit.rotation))
			if a.dot(b) < 0 and not chasing:
				return
#				unit.rotation = lerp_angle(unit.rotation, unit.rotation + PI, 1.0)

func set_face_direciton(value : float) -> void:
	face_direction = value

func face_unit(value : Unit) -> void:
	stop_movement()
	face_direction = unit.global_position.angle_to_point(value.global_position) + ( PI / 2)

func update_facing_angle() -> void:
#	push_warning(path.size())
	var rot_speed : float = 0.05 * Engine.time_scale
	# Once the destination is reached it will face the desired angle
	if path.size() < 1:
		unit.rotation = lerp_angle(unit.rotation, face_direction, rot_speed )
		return
#	push_warning(path)
#	push_warning("what")
	# While moving it will face to the movement direction
	var angle : float = unit.global_position.angle_to_point(next_point) + PI / 2
	angle = unit.global_position.angle_to_point(unit.global_position + unit.velocity) + PI / 2
	unit.rotation = lerp_angle(unit.rotation,angle, rot_speed )

# The anchor variable is used to set when the unit can be pushed or not by another unit when they intersect their collision areas
func update_is_anchored(value : Variant = null) -> void:
	if path.size() == 0:
			if not unit.unitDetector.is_colliding():
				anchored = true
	
	if path.size() > 0 : 
		anchored = false
#		if path[path.size() - 1].distance_to(unit.global_position) > 128:
#			anchored = false # should this be here?
	
	if unit.state == unit.State.FIRING or unit.state == unit.State.MELEE:
		anchored = true
	
	if value != null: # used to override the anchor value just in case
		anchored = value

func draw_path() -> void:
	var has_to_draw : bool = ( unit.selected and unit.ownership == Globals.player_nation )
	line.visible = has_to_draw
	if not has_to_draw:
		return
	
	var arr : Array = [unit.global_position]
	for point in path:
		arr.push_back(point)
		line.points.push_back(point)
	line.points = arr.duplicate()


func move_to_face_melee(areas : Array[Area2D]) -> void:
#	if unit.ownership != "ROME":
#		return
	if unit.state == unit.State.MELEE:
		return
	chase_in_queue = false
	var closest : Area2D = areas[0] as Area2D # default value
	
	# From the enemy face direction we calculate the angle difference to the angle from the enemy to the player,
	# we use this angle difference to choose the flank we will go into melee
	var angle_to_flank : float = 55 # Angle in radians from the center to the limit to one of the flanks
	var enemy_face_direction : Vector2 = Vector2(cos(closest.owner.rotation - PI /2), -sin(closest.owner.rotation + PI / 2)) 
	var angle_from_enemy_to_other : float = closest.owner.global_position.angle_to_point(unit.global_position)
	var v2 : Vector2 = Vector2(cos(angle_from_enemy_to_other), sin(angle_from_enemy_to_other))
	var angle_diff : float = enemy_face_direction.angle_to(v2)  
	angle_diff = rad_to_deg(angle_diff)
	angle_diff = abs(angle_diff)
	var side : bool = true # boolean is easier to use than multiple conditions
	var flank : String = ""
	# Choose flank acording to the angle difference
	if angle_diff < angle_to_flank:
		flank = "Front"
		side = false
	if angle_diff > 180 - angle_to_flank and angle_diff < 180 + angle_to_flank:
		flank = "Back"
		side = false
	if side:
		var left : Vector2
		var right : Vector2
		for area in areas as Array[Area2D]:
			if area.name == "Left":
				left = area.global_position
			if area.name == "Right":
				right = area.global_position
		if left.distance_to(unit.global_position) < right.distance_to(unit.global_position):
			flank = "Left"
		else:
			flank = "Right"
	# Choose the closest if they are in a chosen flank
#	push_warning("=====================")
	for area in areas as Array[HurtBox]:
		if area.name == flank:
			if area.occupied and area.occupant == unit:
				closest = area
#				push_warning("its free for me")
			else:
				closest = area ## temporal
#				closest = null
#				push_warning("its fucking occupied")
	###
	if closest == null :
#		push_warning("you are fucked dud")
#		push_warning(angle_difference)
		var second_closest : HurtBox = null
		var max_distance : float = 10000
		for area in areas as Array[HurtBox]:
#			push_warning(area.name)
			var distance : float = unit.global_position.distance_to(area.global_position)
			if distance < max_distance and area.occupant == unit:
#				push_warning("new area selected")
				second_closest = area
				max_distance = distance
		closest = second_closest
		
#		return
	if closest == null:
#		push_warning("now u are fucked")
		return
	
	var targetSide : Vector2 = closest.meleePoint.global_position # Place were the unit is going to move
	var targetAngle : float = closest.meleePoint.rotation # Rotation of the place were is going to go
	var targetOwner  : Unit = closest.owner # Has to add the rotation of the unit to the angle of the hurtbox to get the corret rotation
	face_direction = targetAngle + targetOwner.rotation
	stop_movement()
	destination = targetSide
#	var line = Line2D.new()
#	add_child(line)
#	line.add_point(unit.global_position)
#	line.add_point(closest.global_position)
#	move_to(targetSide, targetAngle)
	
	
#	push_warning("closest: " +str(closest))
	
#	push_warning(data)
	pass

func get_pathing(to : Vector2) -> Array:
	var arr : Array = path.duplicate()
	if Input.is_action_pressed("Shift"):
		arr.push_back(to)
		return arr
	return [unit.global_position, to]

func stop_movement() -> void:
	path.clear()
	unit.velocity = Vector2.ZERO
	chasing = false # maybe this cause a bug when following a unit that is running
	unit.reached_destination()

func set_nav_map(value : TileMap) -> void:
	nav_map = value.get_navigation_map(0)
	pass


func _on_timer_chase_timeout() -> void:
#	push_warning("timer done")
	if chasing:
		chase()
	pass # Replace with function body.
