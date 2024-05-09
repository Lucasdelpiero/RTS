extends Node
class_name GroupsManager

# Used by the UI to organize units in groups so they can have a task to do when needed

var task_group_res : PackedScene = preload("res://Objects/Battle/task_group.tscn")

var groups : Array[Unit] = []
var main_enemy_group : Array[Unit] = [] : set = set_main_enemy_group

# Groups created to avoid flanking and encirclements
var side_left : TaskGroup = null
var side_right : TaskGroup = null
var side_back : TaskGroup = null


func _ready() -> void:
	# Clean the node tree
	for node in get_children(): 
		node.queue_free()
	
	var side_temp1 := task_group_res.instantiate()
	add_child(side_temp1)
	side_left = side_temp1
	var side_temp2 := task_group_res.instantiate()
	add_child(side_temp2)
	side_right = side_temp2
	var side_temp3 := task_group_res.instantiate()
	add_child(side_temp3)
	side_back = side_temp3
	

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

# If a side doesnt have a similar number of units it will create a new group
func check_side_has_enough_units(side : String , enemy_group : Array[Unit]) -> void:
	match side:
		"left":
			assign_units_side_group(side_left, enemy_group)
		"right":
			assign_units_side_group(side_right, enemy_group)
		"back":
			assign_units_side_group(side_back, enemy_group)

func assign_units_side_group(task_group : TaskGroup , enemy_group : Array[Unit]) -> void:
	var units_needed : int = 0
	task_group.enemy_group_focused = enemy_group
	if task_group.group.size() < enemy_group.size():
		units_needed =  enemy_group.size() - task_group.group.size()
		print("not enough soldiers : %s units needed" % units_needed)
		var units_free : Array[Unit] = get_units_that_are_free()
		task_group.add_units_to_group( units_free )
		for unit in units_free:
			Signals.sg_ia_unit_changed_group.emit(task_group, unit)

# Will give the soldiers that is able to spare, it will have a minimium of 1 o 2 units at least
func get_units_that_are_free() -> Array[Unit]:
	var units_to_add : Array = []
	
	# The group doesnt look for the sides so they wont steal from eachother
	# TODO refactor this so if there are units that can be spared from the sides
	# then it could be used in other places
	var groups_to_look : Array[TaskGroup] = []
	
	for task_group in get_children() as Array[TaskGroup]:
		if task_group != side_left and task_group != side_left and task_group != side_left:
			groups_to_look.push_back(task_group) 
	
	for task_group in groups_to_look:
		for unit in task_group.group:
		# TEST 
		# Add 2 infantry for testing
			if unit.get_type() == 1 and units_to_add.size() < 2:
				units_to_add.push_back(unit)
			pass
		pass
	
	var units_casted : Array[Unit] = []
	units_casted.assign(units_to_add)
	return units_casted


func set_main_enemy_group(value : Array[Unit]) -> void:
	main_enemy_group.assign(value)
	for child in get_children():
		child.main_enemy_group = value.duplicate(true)
	
func tell_move_units_to_markers() -> void:
	for child in get_children():
		child.move_units_to_markers()
	pass


