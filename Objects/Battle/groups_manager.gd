@icon("res://Assets/ui/node_icons/ia_icon.png")
extends Node
class_name GroupsManager

# Used by the UI to organize units in groups so they can have a task to do when needed

var task_group_res : PackedScene = preload("res://Objects/Battle/task_group.tscn")

var groups : Array[Unit] = []
var main_enemy_group : Array[Unit] = [] : set = set_main_enemy_group


# Starting groups
var task_group_infantry : TaskGroup = null
var task_group_archers : TaskGroup = null
var task_group_flank_left : TaskGroup = null
var task_group_flank_right : TaskGroup = null 

# Groups created to avoid flanking and encirclements
var side_left : TaskGroup = null
var side_right : TaskGroup = null
var side_back : TaskGroup = null

@export var army_marker : Marker2D = null
@export var left_flank_marker : Marker2D = null
@export var right_flank_marker : Marker2D = null
@export var left_side_marker : Marker2D = null
@export var right_side_marker : Marker2D = null
@export var back_side_marker : Marker2D = null


func _ready() -> void:
	Signals.sg_ia_unit_not_needed_in_side.connect(unit_not_needed_in_side)
	
	# Clean the node tree
	for node in get_children(): 
		node.queue_free()
	
	var side_temp1 := task_group_res.instantiate()
	add_child(side_temp1)
	side_left = side_temp1
	side_left.group_name = "side_left"
	side_left.marker_to_follow = left_side_marker
	side_left.marker_to_anchor = army_marker # TEST
	var side_temp2 := task_group_res.instantiate()
	add_child(side_temp2)
	side_right = side_temp2
	side_right.group_name = "side_right"
	side_right.marker_to_follow = right_side_marker
	side_right.marker_to_anchor = army_marker # TEST
	var side_temp3 := task_group_res.instantiate()
	add_child(side_temp3)
	side_back = side_temp3
	# BUG done just so it doesnt scream to me the debugger
	side_back.group_name = "side_back"
	side_back.marker_to_anchor = army_marker
	side_back.marker_to_follow = back_side_marker
	

func create_group(
		units_group : Array[Unit] = [], 
		enemy_group : Array[Unit] = [], 
		marker_to_follow : Marker2D = null, 
		start_from_center : bool = false, 
		right_to_left : bool = false,
		group_name : String = "none"
		) -> void:
	
	if enemy_group.is_empty():
		push_error("enemy_group is empty")
		return
	
	var task_group := task_group_res.instantiate() as TaskGroup
	task_group.group.assign( units_group.duplicate(true) ) # Cast Array into Array[Unit]
	task_group.enemy_group_focused.assign( enemy_group.duplicate(true) ) # Cast Array into Array[Unit]
	task_group.startFromCenter = start_from_center
	task_group.right_to_left = right_to_left
	task_group.group_name = group_name
	if marker_to_follow != null:
		task_group.marker_to_follow = marker_to_follow
		task_group.marker_to_anchor = marker_to_follow.get_parent() as Marker2D
	add_child(task_group)
	
	# TODO it should be created manually as it doesnt add a benefit 
	# creating groups in code if all armies will have the same starting groups
	# Create reference to task groups
	if group_name == "infantry":
		task_group_infantry = task_group
	if group_name == "archers":
		task_group_archers = task_group
	if group_name == "flank_left":
		task_group_flank_left = task_group
	if group_name == "flank_right":
		task_group_flank_right = task_group
	

# If a side doesnt have a similar number of units it will create a new group
func check_side_has_enough_units(side : String , enemy_group : Array[Unit]) -> void:
	match side:
		"left": # TODO refactor this to send a resource as an argument
			assign_units_side_group(side_left, enemy_group, left_side_marker, side)
		"right":
			assign_units_side_group(side_right, enemy_group, right_side_marker, side)
		"back":
			assign_units_side_group(side_back, enemy_group, back_side_marker)

func assign_units_side_group(task_group : TaskGroup ,
		enemy_group : Array[Unit],
		marker_to_follow : Marker2D = null,
		side : String = "") -> void:
	var units_needed : int = 0
	task_group.enemy_group_focused = enemy_group
	if task_group.group.size() < enemy_group.size():
		units_needed =  enemy_group.size() - task_group.group.size()
		# Get units ordered by the distance to the marker of the side
		var units_free : Array[Unit] = get_units_that_are_free()
		var units_sorted : Array[Unit] = sort_by_closest_distance(units_free, marker_to_follow.global_position)
		
		var units_to_assign_temp : Array = []
		# Currently it gets the minimum amount of troops to equalize the enemy, may change in the future
		for i : int in min(units_needed, units_sorted.size()):
			units_to_assign_temp.push_back(units_sorted[i])
		
		var units_to_assign : Array[Unit] = [] # Casting to a typed array
		units_to_assign.assign(units_to_assign_temp)
		
		# Send the units to the side 
		task_group.add_units_to_group( units_to_assign )
		for unit in units_to_assign:
			Signals.sg_ia_unit_changed_group.emit(task_group, unit)
		
	if marker_to_follow == null:
		push_error("There is no marker to follow")
		return
		
	if side == "left":
		task_group.right_to_left = true
	task_group.main_enemy_group = main_enemy_group
	task_group.marker_to_follow = marker_to_follow

# Will give the soldiers that is able to spare, it will have a minimium of 1 o 2 units at least
func get_units_that_are_free() -> Array[Unit]:
	var units_to_add : Array = []
	
	# The group doesnt look for the sides so they wont steal from eachother
	# TODO refactor this so if there are units that can be spared from the sides
	# then it could be used in other places
	var groups_to_look : Array[TaskGroup] = []
	
	# Takes all groups except the ones in the sides and search for empty units
	for task_group in get_children() as Array[TaskGroup]:
		if task_group != side_right and task_group != side_left and task_group != side_back:
			groups_to_look.push_back(task_group) 
	
	for task_group in groups_to_look:
		for unit in task_group.group:
		# TEST 
			if unit.get_type() == 1:
				units_to_add.push_back(unit)
			pass
		pass
	
	var units_casted : Array[Unit] = []
	units_casted.assign(units_to_add)
	return units_casted


func sort_by_closest_distance(units: Array[Unit], position_to_compare: Vector2) -> Array[Unit]:
	if units.is_empty():
		push_error("Empty array on sort by distance")
		return []
	var temp_units : Array = units.duplicate()
	temp_units.sort_custom(func(a: Unit, b: Unit) -> bool: return a.global_position.distance_to(position_to_compare) < b.global_position.distance_to(position_to_compare) )
	var typed_units : Array[Unit] = []
	typed_units.assign(temp_units)
	return typed_units


# TaskGroup -> GroupsManager
# When an unit protecting a side is no longer needed, like when they have 
# more units than the ones they need to defend against, this is called
# an unit no longer needed is put in a generic task group in the battle line
func unit_not_needed_in_side(unit: Unit) -> void:
	if unit == null:
		push_error("Unit is null")
		return
	
	if unit.get_type() == 1 and task_group_infantry != null:
		task_group_infantry.add_units_to_group([unit])

func group_not_needed_in_side(side : String) -> void:
	for task_group in get_children() as Array[TaskGroup]:
		if task_group.group_name == "side_%s" % side and task_group.group.size() > 0:
			task_group_infantry.add_units_to_group(task_group.group)
			for unit in task_group.group:
				unit_not_needed_in_side(unit)
	pass

func set_main_enemy_group(value : Array[Unit]) -> void:
	main_enemy_group.assign(value)
	for child in get_children():
		child.main_enemy_group = value.duplicate(true)
	
func tell_move_units_to_markers() -> void:
	for child in get_children():
		child.move_units_to_markers()
	pass


