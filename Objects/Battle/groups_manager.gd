extends Node
class_name GroupsManager

var task_group_res = preload("res://Objects/Battle/task_group.tscn")

var groups = []
var main_enemy_group = [] : set = set_main_enemy_group

func _ready():
	for node in get_children(): 
		node.queue_free()

func create_group(units_group = [], enemy_group = [], market_to_follow = null, start_from_center : bool = false, right_to_left : bool = false):
	var task_group = task_group_res.instantiate() as TaskGroup
	task_group.group = units_group.duplicate(true)
	task_group.enemy_group_focused = enemy_group.duplicate(true)
	task_group.startFromCenter = start_from_center
	task_group.right_to_left = right_to_left
	if market_to_follow != null:
		task_group.marker_to_follow = market_to_follow
		task_group.marker_to_anchor = market_to_follow.get_parent()
	add_child(task_group)

func set_main_enemy_group(value):
	main_enemy_group = value.duplicate(true)
	for child in get_children():
		child.main_enemy_group = value.duplicate(true)
	
func tell_move_units_to_markers():
	for child in get_children():
		child.move_units_to_markers()
	pass
