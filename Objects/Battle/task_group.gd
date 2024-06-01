class_name TaskGroup
extends UnitsManagement

var group  : Array[Unit] = [] 
var group_name : String = "" # used mainly to debug
@export var debug : bool = false


var enemy_group_focused  : Array[Unit] = [] :
	set(value):
		# Potential BUG here so is a place to look for if there is a problem in the future
		# As only the number is checked if it swaps to other unit but the number is the same it can cause a problem
		# Maybe a hashmap will be needed in the future
		if value.size() != enemy_group_focused.size() :
			if debug:
				print("changed: %s" % value.size())
			enemy_group_focused = value
			if enemy_group_focused.size() < group.size():
				print("Reducing size")
				var redundant_troops_amount : int = enemy_group_focused.size() - group.size()
				var redundant_troops : Array = []
				for i in redundant_troops_amount:
					redundant_troops.push_back(group[i])
				for unit in redundant_troops as Array[Unit]:
					Signals.sg_ia_unit_not_needed_in_side.emit(unit)
					print("%s is FREEEE" % unit.name)
				
	

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
	pass

func move_units_to_markers() -> void:
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
		if debug:
			print("it wont be deleted from here: u=%s / tg=%s" % [unit.name, task_group.group_name])
		return
	
	if group.has(unit):
		if debug:
			print("before: %s" % group.size())
			print("it will delete the unit: %s" % unit.name)
		group.erase(unit)
		if debug:
			print("after: %s" % group.size())
	pass

func _on_move_timer_timeout() -> void:
	#return
	move_units_to_markers()
	moveTimer.start(5)
	pass
