extends Node
class_name GroupsManager

var task_group_res = preload("res://Objects/Battle/task_group.tscn")

var groups = []

func _ready():
	for node in get_children():
		node.queue_free()

func create_group(units_group = [], enemy_group = [], market_to_follow = null):
	var task_group = task_group_res.instantiate() as TaskGroup
	task_group.group = units_group.duplicate(true)
	task_group.enemy_group_focused = enemy_group.duplicate(true)
	if market_to_follow != null:
		task_group.marker_to_follow = market_to_follow
	add_child(task_group)
