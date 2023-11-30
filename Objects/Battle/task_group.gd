extends UnitsManagement
class_name TaskGroup

var group  = []
var enemy_group_focused  = []
var main_enemy_group = []
var marker_to_anchor = null # Parent marker to all markers used to get the angle to position the units
var marker_to_follow = null

# Used to poition while following the marker
var startFromCenter : bool = false
var right_to_left : bool = false

enum Task {FOLLOW_MARKER, HOLD, ADVANCE, SKIRMISH, MELEE, FLEE}

var task = Task.FOLLOW_MARKER


func _on_move_timer_timeout():
	if marker_to_follow == null or marker_to_anchor == null:
		return
	var average_pos = get_average_position(main_enemy_group)
	var angle = marker_to_anchor.global_position.angle_to_point(average_pos) 
	# i dont know what this do
	if abs(marker_to_follow.rotation - angle) > PI / 3:
		angle += PI/2 
	
	move_units(group,
		marker_to_follow.global_position, 
		angle, 
		angle,
		startFromCenter,
		right_to_left)
	pass # Replace with function body.
