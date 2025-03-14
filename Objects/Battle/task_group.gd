@icon("res://Assets/ui/node_icons/ia_icon.png")
class_name TaskGroup
extends UnitsManagement

var group  : Array[Unit] = [] 
var group_name : String = "" # used mainly to debug
@export var debug : bool = false
# Stores units that are currently attacking
# TODO needs a signal to go from the unit to here to update when is attacking
var group_units_attacking : Array[Unit] = []

var enemy_group_focused  : Array[Unit] = [] :
	set(value):
		# Potential BUG here so is a place to look for if there is a problem in the future
		# As only the number is checked if it swaps to other unit but the number is the same it can cause a problem
		# Maybe a hashmap will be needed in the future
		if value.size() != enemy_group_focused.size() :
			enemy_group_focused = value
			if enemy_group_focused.size() < group.size():
				var redundant_troops_amount : int = group.size() - enemy_group_focused.size() 
				var redundant_troops : Array = []
				for i in redundant_troops_amount:
					redundant_troops.push_back(group[i])
				#push_warning("redundant troops: %s" % [redundant_troops])
				for unit in redundant_troops as Array[Unit]:
					Signals.sg_ia_unit_not_needed_in_side.emit(unit)



# This will be stopped when it has to perform certain task
# like skirmishing or going melee
var move_to_marker : bool = true

var main_enemy_group : Array[Unit] = []
var marker_to_anchor : Marker2D = null # Parent marker to all markers used to get the angle to position the units
var marker_to_follow : Marker2D = null
@onready var moveTimer : Timer = $moveTimer

# Used to poition while following the marker
var startFromCenter : bool = false
var right_to_left : bool = false

enum Task {FOLLOW_MARKER, HOLD, ADVANCE, SKIRMISH, MELEE, FLEE}

var task : int = Task.FOLLOW_MARKER

func _ready() -> void:
	Signals.sg_ia_unit_changed_group.connect(erase_unit_if_changed_group)
	Signals.sg_ia_task_group_set_moving_to_marker.connect(set_moving_to_markers)
	Signals.sg_ia_state_melee_attack_one.connect(check_name_to_send_one_unit_to_melee)
	Signals.sg_ia_state_melee_attack.connect(check_name_to_send_units_to_melee)
	
	Signals.sg_ia_attack_from.connect(debug_check_name_to_send_attack)
	Signals.sg_battle_ia_start_update.connect(debug_start_update)
	Signals.sg_battle_ia_stop_update.connect(debug_stop_update)
	Signals.sg_ia_debug_send_one_to_attack.connect(debug_attack_one)
	Signals.sg_unit_died.connect(update_enemy_groups_when_unit_die)

# Clears from the groups the enemies that died so the IA doesnt go after units that are dead
func update_enemy_groups_when_unit_die(unit : Unit) -> void:
	main_enemy_group.erase(unit)
	group_units_attacking.erase(unit)
	enemy_group_focused.erase(unit)

func move_units_to_markers() -> void:
	if move_to_marker == false:
		return
	
	if marker_to_follow == null or marker_to_anchor == null:
		if debug:
			push_error("Didnt found a markert to follow or anchor")
		return
	#var average_pos : Vector2 = get_average_position(main_enemy_group)
	#var angle : float = marker_to_anchor.global_position.angle_to_point(average_pos) 
	var average_pos : Vector2 = get_average_position(enemy_group_focused)
	#var angle : float = marker_to_anchor.global_position.angle_to_point(average_pos) 
	#angle += PI/2 # Adds a quarter rotation so that the unit looks at that place
	
	var angle : float = marker_to_anchor.rotation + marker_to_follow.rotation
	if debug:
		Globals.debug_update_label("angle", "angle: %s" % angle)
	
	# Only move units that are not attacking
	var units_to_move_to_marker : Array[Unit] = []
	var units_to_move_to_marker_temp : Array = []
	var in_melee : Array[Unit] = get_units_in_melee(group)
	for unit in group:
		if not group_units_attacking.has(unit) and not in_melee.has(unit):
			units_to_move_to_marker_temp.push_back(unit)
	units_to_move_to_marker.assign(units_to_move_to_marker_temp)
	
	move_units(units_to_move_to_marker,
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
	for unit in units: # It prevets duplicacion in the groups
		if not temp_group.has(unit):
			temp_group.push_back(unit)
	var group_casted : Array[Unit] = []
	group_casted.assign(temp_group)
	group = group_casted
	for unit in units:
		Signals.sg_ia_unit_changed_group.emit(self, unit)

func erase_unit_if_changed_group(task_group: TaskGroup , unit: Unit) -> void:
	if task_group == self:
		#if debug:
			#push_warning("it wont be deleted from here: u=%s / tg=%s" % [unit.name, task_group.group_name])
		return
	
	if group.has(unit):
		if debug:
			#push_warning("before: %s" % group.size())
			push_warning("it will delete the unit: %s" % unit.name)
		group.erase(unit)
		#if debug:
			#push_warning("after: %s" % group.size())
	pass


func set_moving_to_markers(a_name : String = "", value : bool = false) -> void:
	if group_name == a_name:
		move_to_marker = value

func check_name_to_send_one_unit_to_melee(arg_name : String) -> void:
	if group_name != arg_name:
		return
	
	var group_random_order : Array = group.duplicate()
	group_random_order.shuffle()
	for unit in group_random_order as Array[Unit]:
		if not group_units_attacking.has(unit):
			group_units_attacking.push_back(unit)
			Signals.sg_ia_request_order_to_attack_one.emit(unit, enemy_group_focused)
			return

func check_name_to_send_units_to_melee(arg_name : String, amount : int) -> void:
	if group_name != arg_name:
		return
	
	# Pick random units to send
	var group_random_order : Array[Unit] = group.duplicate() as Array[Unit]
	group_random_order.shuffle()
	var amount_to_send : int = floori(min(amount, group_random_order.size()))
	group_random_order = group_random_order.slice(0, amount_to_send) as Array[Unit]
	for unit in group_random_order as Array[Unit]:
		if not group_units_attacking.has(unit):
			group_units_attacking.push_back(unit)
	Signals.sg_ia_request_orders_to_attack.emit(group_random_order, enemy_group_focused)
	

func debug_check_name_to_send_attack(arg_name : String) -> void:
	if group_name == arg_name:
		debug_attack_enemy_focused()
	pass

func debug_attack_enemy_focused() -> void:
	Signals.sg_ia_request_orders_to_attack.emit(group, enemy_group_focused)
	pass

# attack one enemy from the group
func debug_attack_one(a_group_name : String) -> void :
	if group_name != a_group_name:
		return
	var group_random_order : Array = group.duplicate()
	group_random_order.shuffle()
	for unit in group_random_order as Array[Unit]:
		if not group_units_attacking.has(unit):
			group_units_attacking.push_back(unit)
			Signals.sg_ia_request_order_to_attack_one.emit(unit, enemy_group_focused)
			return

func _on_move_timer_timeout() -> void:
	#return
	move_units_to_markers()
	moveTimer.start(5)
	pass
	

# Intended to merge the groups of units sent to attack and add the ones that got
# into melee 
# easier than having signals 
func merge_groups(aGroup : Array[Unit], aGroup2 : Array[Unit]) -> Array[Unit]:
	var new_array : Array[Unit] = aGroup.duplicate()
	for unit in aGroup2:
		if not new_array.has(unit):
			new_array.push_back(unit)
	return new_array
	

	

func debug_start_update() -> void:
	moveTimer.start(0)
	
func debug_stop_update() -> void:
	moveTimer.stop()
