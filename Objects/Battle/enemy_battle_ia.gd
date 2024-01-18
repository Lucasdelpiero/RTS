class_name IA
extends UnitsManagement

#region Properties

@export var armyGroup : Node = null 
var units := []
@onready var armyMarker : Marker2D = %ArmyMarker
@onready var infantryMarker : Marker2D = %InfantryMarker
@onready var rangeMarker : Marker2D = %RangeMarker
@onready var leftFlankMarker : Marker2D= %LeftFlank
@onready var rightFlankMarker : Marker2D= %RightFlank
@export var playerGroup : Node = null
var player_units := []
var distance_to_be_in_group = 500
var playerGroups : Array[Array] = []
@export var general : General 
@onready var groups_manager  = %GroupsManager as GroupsManager
@onready var timerAdvance = %TimerAdvance

var infantry_units = []
var range_units = []
var cavalry_units = []

var group_front = []
var group_archers = []
var group_left_flank = []
var group_right_flank = []
var group_reserves = []

# This array stores the units that already where targeted by the IA to be atacked
# TODO move this property and behaviout asociated to other place for a behaviour tree 
var units_already_targeted : Array = []

enum GeneralStates {
	WAITING,
	MOVING,
	SKIRMISHING,
	FIGHTING,
	FLEEING
}
var generalState = GeneralStates.WAITING

#endregion

func _ready():
	if general == null:
		general = General.new()
#	print(general.charisma)
	if armyGroup == null:
		return
	if playerGroup == null:
		return
	player_units = playerGroup.get_children() 
	get_enemy_groups(player_units, 2000)
	await get_tree().create_timer(0.1).timeout # Used to give time to load components of units
	units = armyGroup.get_children() as Array[Unit]
	group_units_by_type(units as Array[Unit])
#	move_units(units, armyMarker.global_position , 0.0, PI)
	move_to_group_marker(units)
#	print(get_main_group(get_enemy_groups(player_units, 2000)))
	# TEST
	var main_group = get_main_group(get_enemy_groups(player_units, 2000))
	groups_manager.create_group(group_front, main_group, infantryMarker, true)
	groups_manager.create_group(group_archers, main_group, rangeMarker, true)
	groups_manager.create_group(group_left_flank, main_group, leftFlankMarker, false, true)
	groups_manager.create_group(group_right_flank, main_group, rightFlankMarker, false)

# Makes the IA focus on the largest
func focus_on_largest_group():
	var groups = get_enemy_groups(player_units, 2000)
	if groups == null:
		push_error("enemy groups not detected")
		return
	var closest = get_distance_to_closest(groups, armyMarker.global_position)
	var action = general.get_next_action()
	var focus = general.get_largest_group(groups)
	groups_manager.main_enemy_group = focus
#	Globals.debug_update_label("size", focus.size())
#	Globals.debug_update_label("closest", "closest: %s" %[closest])
	var to_sort = groups.duplicate(true)
	to_sort.sort_custom(func(a, b): return a.size() > b.size())
	var groups_by_size = to_sort.duplicate(true)
	var text_group_size : String = ""
	for i in groups_by_size.size():
		text_group_size += "size: %s \n" % [groups_by_size[i].size()]
	Globals.debug_update_label("size%s", "size: %s" % [text_group_size])
	if focus == null:
		return
	var average_pos = get_average_position(focus)
	var angle = armyMarker.global_position.angle_to_point(average_pos) 
	var new_pos = armyMarker.global_position + Vector2(cos(angle), -sin(angle)) * 20
#	Globals.debug_update_label("focus", "Focus: %s" %[focus.map(func(el): return el.name)])
	
	# Parent marker will look towards main player group
	if abs(armyMarker.rotation - angle) > PI / 3:
		armyMarker.rotation = angle + PI/2
	
	# just to test
#	var angle_formation = armyMarker.rotation
#	move_units(group_front,infantryMarker.global_position, angle_formation, angle_formation, true)
#	move_units(group_archers,rangeMarker.global_position, angle_formation, angle_formation, true)
#	move_units(group_left_flank, leftFlankMarker.global_position, angle_formation, angle_formation, false, true)
#	move_units(group_right_flank, rightFlankMarker.global_position , angle_formation, angle_formation , false)
#	
	
	match(action):
		"move" :
#			move_units(units, armyMarker.global_position , 0.0, PI)
#			print("alf")
			pass
#	generalState = GeneralStates.FIGHTING
	pass

func group_units_by_type(aUnits):
	if aUnits == null or typeof(aUnits) != 28:
		push_error("invalid argument")
		return
	infantry_units = aUnits.filter(func(el) : return el.type == 1)
	range_units = aUnits.filter(func(el) : return el.type == 2)
	cavalry_units = aUnits.filter(func(el) : return el.type == 3)
	
	# Groups used for the formation
	group_front = infantry_units.duplicate()
	group_archers = range_units.duplicate()
	var half_cavalry = int(floor(cavalry_units.size() / 2))
	group_left_flank = cavalry_units.slice(0, half_cavalry).duplicate()
	group_right_flank = cavalry_units.slice(half_cavalry).duplicate()

func get_data_to_think_next_action():
	
	pass


func move_to_group_marker(aUnits):
	if typeof(aUnits) != 28:
		push_error("Expected array in function")
		return
	var infantry_in_arg = aUnits.filter(func(el) : return el.get_type() == 1)
	var range_in_arg = aUnits.filter(func(el) : return el.get_type() == 2)
	var cavalry_in_arg = aUnits.filter(func(el) : return el.get_type() == 3)
	var half_cavalry = int(floor(cavalry_in_arg.size() / 2))
	var cavalry_left_flank = cavalry_in_arg.slice(0, half_cavalry)
	var cavalry_right_flank = cavalry_in_arg.slice(half_cavalry)
	move_units(infantry_in_arg,infantryMarker.global_position,PI, PI, true)
	move_units(range_in_arg,rangeMarker.global_position, PI, PI, true)
	
	var distance_from_infantry = 512
	var right_flank_pos = get_flank_position(infantry_in_arg, "right", PI, distance_from_infantry)
	var left_flak_pos = get_flank_position(infantry_in_arg, "left", PI, distance_from_infantry)
	rightFlankMarker.global_position = right_flank_pos
	leftFlankMarker.global_position = left_flak_pos
	move_units(cavalry_left_flank, leftFlankMarker.global_position, PI, PI, false, true)
	move_units(cavalry_right_flank, rightFlankMarker.global_position , PI, PI , false)


func get_flank_position(aUnits : Array = [], flank : String = "none", angle_formation : float = 0, distance : float = 0.0):
	var units_group = aUnits as Array[Unit]
	if units.size() == 0 or flank == "none":
		return armyMarker.position # it needs to be te local position
	if flank == "left":
		return ( units_group[0].get_destination() -Vector2(cos(angle_formation), sin(angle_formation)) * distance )
	if flank == "right":
		return (units_group[units_group.size() - 1].get_destination() + Vector2(cos(angle_formation), sin(angle_formation)) * distance )

# TODO move this code to a separated node to create a behavior tree
func check_to_advance():
	var a_units_to_move : Array = units
	var a_player_units : Array = player_units
	if a_player_units.size() == 0 or a_units_to_move.size() == 0:
		push_error("There are no units of the player or the IA")
		return
	
	# Currently moves towards the average, should be changed to be able to chose one of the groups 
	var current_position : Vector2 = armyMarker.global_position
	var place_to_move : Vector2 = get_average_position(a_player_units)
	
	advance(a_units_to_move, place_to_move, current_position, 30, true)
	pass

# The units will move towards the position at a certian distance as a time, that distance as absolute values or as percentage of distance to the target
# TODO move this code to a separated node to create a behavior tree
func advance(aUnits: Array, target_position : Vector2, current_position : Vector2, distance_to_move : float, as_percentage: bool = false) -> void:
	#region Safeguard
	for unit in aUnits:
		if not unit is Unit:
			push_error("An element in the array is not of Unit class")
			return
	#endregion
	
	# there should be a variable to tell them when they reached the point
	var angle : float = current_position.angle_to_point(target_position)
	var delta_to_move : Vector2 = Vector2(cos(angle), sin(angle)) * distance_to_move
	if as_percentage:
		delta_to_move = (target_position - current_position) * (distance_to_move / 100) 
	var place_to_move_to : Vector2 = current_position + delta_to_move 
	
	armyMarker.global_position = place_to_move_to
	armyMarker.rotation = angle + PI/2
	groups_manager.tell_move_units_to_markers() # So they move instantly
	#move_units(aUnits, place_to_move_to, angle)

# Send units to attack to melee, units already targeted are stored in units_already_targeted array
# TODO move this code to a separated node to create a behavior tree
func send_units_to_attack(aGroup : Array, aEnemy_units : Array):
	#region Safeguard
	for unit in aGroup:
		if not unit is Unit:
			push_error("There is an object that is not a unit")
			return
	for unit in aEnemy_units:
		if not unit is Unit:
			push_error("There is an object that is not a unit")
			return
	#endregion
	
	for unit in aGroup as Array[Unit]:
		var unit_has_targeted_enemy = false # used to store when the unit has chosen an enemy to attack
		var enemies_by_distance = get_units_ordered_by_distance(aEnemy_units, unit.global_position)
		for enemy in enemies_by_distance as Array[Unit]:
			if not units_already_targeted.has(enemy) and not unit_has_targeted_enemy:
				units_already_targeted.push_back(enemy)
				unit.set_chase(enemy)
				unit_has_targeted_enemy = true
		


func _on_timer_timeout():
	#focus_on_largest_group()
	#get_enemy_groups(player_units, 2000)
	return
	# TEST
	if units_already_targeted.size() < 1:
		#send_units_to_attack(units, player_units)
		send_units_to_attack(group_left_flank, player_units)
		send_units_to_attack(group_front, player_units)
		send_units_to_attack(group_right_flank, player_units)
	# TEST
	# Check bug if it the timer goes fast
#	move_units(units, armyMarker.global_position , 0.0, PI)
	pass # Replace with function body.


func _on_timer_advance_timeout():
	#timerAdvance.start(5)
	#check_to_advance()
	pass
