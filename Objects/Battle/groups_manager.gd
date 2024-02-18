extends Node
class_name GroupsManager

# Used by the UI to organize units in groups so they can have a task to do when needed

var task_group_res : PackedScene = preload("res://Objects/Battle/task_group.tscn")

var groups : Array[Unit] = []
var main_enemy_group : Array[Unit] = [] : set = set_main_enemy_group

func _ready() -> void:
	for node in get_children(): 
		node.queue_free()

func create_group(
		units_group : Array[Unit] = [], 
		enemy_group : Array[Unit] = [], 
		marker_to_follow : Marker2D = null, 
		start_from_center : bool = false, 
		right_to_left : bool = false
		) -> void:
	
	if enemy_group.is_empty():
		push_error("enemy_group is empty")
		return
	
	var task_group := task_group_res.instantiate() as TaskGroup
	task_group.group.assign( units_group.duplicate(true) ) # Cast Array into Array[Unit]
	task_group.enemy_group_focused.assign( enemy_group.duplicate(true) ) # Cast Array into Array[Unit]
	task_group.startFromCenter = start_from_center
	task_group.right_to_left = right_to_left
	if marker_to_follow != null:
		task_group.marker_to_follow = marker_to_follow
		task_group.marker_to_anchor = marker_to_follow.get_parent() as Marker2D
	add_child(task_group)

func set_main_enemy_group(value : Array[Unit]) -> void:
	main_enemy_group.assign(value)
	for child in get_children():
		child.main_enemy_group = value.duplicate(true)
	
func tell_move_units_to_markers() -> void:
	for child in get_children():
		child.move_units_to_markers()
	pass


