class_name TaskGroup
extends UnitsManagement

var group  : Array[Unit] = []
var enemy_group_focused  : Array[Unit] = [] :
	set(value):
		# Potential BUG here so is a place to look for if there is a problem in the future
		# As only the number is checked if it swaps to other unit but the number is the same it can cause a problem
		# Maybe a hashmap will be needed in the future
		if value.size() != enemy_group_focused.size() :
			print("changed: %s" % value.size())
			enemy_group_focused = value
			# send signal to other groups to delete the units assigned here
var main_enemy_group : Array[Unit] = []
var marker_to_anchor : Marker2D = null # Parent marker to all markers used to get the angle to position the units
var marker_to_follow : Marker2D = null
@onready var moveTimer : Timer = $moveTimer

# Used to poition while following the marker
var startFromCenter : bool = false
var right_to_left : bool = false

enum Task {FOLLOW_MARKER, HOLD, ADVANCE, SKIRMISH, MELEE, FLEE}

var task : int = Task.FOLLOW_MARKER

func move_units_to_markers() -> void:
	if marker_to_follow == null or marker_to_anchor == null:
		return
	var average_pos : Vector2 = get_average_position(main_enemy_group)
	var angle : float = marker_to_anchor.global_position.angle_to_point(average_pos) 
	angle += PI/4 # Adds a quarter rotation so that the unit looks at that place
	
	
	move_units(group,
		marker_to_follow.global_position, 
		angle, 
		angle,
		startFromCenter,
		right_to_left)

# Thee difference between the group and its enemy assigned
func get_strengh_difference() -> float:
	
	return 100

# The amount of soldiers that the IA has above the player
func get_soldiers_above_requirement() -> int:
	
	return 0

func add_units_to_group(units: Array[Unit]) -> void:
	var temp_group : Array = []
	temp_group.append_array(group)
	temp_group.append_array(units)
	var group_casted : Array[Unit] = []
	group_casted.assign(temp_group)
	group = group_casted

func _on_move_timer_timeout() -> void:
	return
	move_units_to_markers()
	moveTimer.start(5)
	pass
