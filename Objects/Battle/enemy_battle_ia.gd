class_name IA
extends UnitsManagement

# The EnemyBattleIA will tell the units how they will be groupder and
# an task (hold on, advance, skirmish, melee) to the groups
# These groups tell the units exactly what to do
# The units will have the capacity to ovrride the orders if they see it fit  

#region Properties

@export var armyGroup : UnitsGroupControl = null 
var units : Array[Unit] = []
@onready var armyMarker : Marker2D = %ArmyMarker
@onready var infantryMarker : Marker2D = %InfantryMarker
@onready var rangeMarker : Marker2D = %RangeMarker
@onready var leftFlankMarker : Marker2D= %LeftFlank
@onready var rightFlankMarker : Marker2D= %RightFlank
@onready var sideLeft : Marker2D = %SideLeft # used to protect the left and right side from flanking attacks
@onready var sideRight : Marker2D = %SideRight
@export var playerGroup : UnitsGroupControl = null
var player_units : Array[Unit] = []
var distance_to_be_in_group : int = 500
var playerGroups : Array[Array] = []
@export var general : General 
@onready var groups_manager  := %GroupsManager as GroupsManager
@onready var timerAdvance := %TimerAdvance as Timer

# Type of units
var infantry_units : Array[Unit] = []
var range_units : Array[Unit] = []
var cavalry_units : Array[Unit] = []

# Group of units
var group_front : Array[Unit] = []
var group_archers : Array[Unit] = []
var group_left_flank : Array[Unit] = [] # cavalry
var group_right_flank : Array[Unit]= [] # cavalry
var group_reserves : Array[Unit] = []

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
var generalState : int = GeneralStates.WAITING

#endregion

func _ready() -> void:
	if general == null:
		general = General.new()
#	push_warning(general.charisma)
	if armyGroup == null:
		return
	if playerGroup == null:
		return
	# NOTE without the timer it doesnt count all the units, only the ones that were in the battlefield before the ones in the battlemap can load
	await get_tree().create_timer(0.0).timeout
	# get_enemy_groups needs a typed array, so to be safe
	var player_units_temp : = playerGroup.get_children() 
	var player_units_typed : Array[Unit] = []
	player_units_typed.assign(player_units_temp)
	player_units.assign(player_units_typed)
	var enemy_units_temp := armyGroup.get_children()
	units.assign(enemy_units_temp)
	
	get_enemy_groups(player_units, 2000)
	
	await get_tree().create_timer(0.1).timeout # Used to give time to load components of units
	
	units = armyGroup.get_units_group()

	group_units_by_type(units )
#	move_units(units, armyMarker.global_position , 0.0, PI)
	move_to_group_marker(units)
#	push_warning(get_main_group(get_enemy_groups(player_units, 2000)))
	# TEST
	var main_group : Array = get_main_group(get_enemy_groups(player_units_typed, 2000))
	groups_manager.create_group(group_front, main_group, infantryMarker, true, false, "infantry")
	groups_manager.create_group(group_archers, main_group, rangeMarker, true, false, "archers")
	groups_manager.create_group(group_left_flank, main_group, leftFlankMarker, false, true, "flank_left")
	groups_manager.create_group(group_right_flank, main_group, rightFlankMarker, false, false,"flank_right")

func _unhandled_key_input(event: InputEvent) -> void:
	# TEST if the task_groups work correctly when the angle is different than the started in
	if  event.is_action_pressed("debug_1", true):
		army_marker_face_towards(armyMarker.get_global_mouse_position())

func army_marker_face_towards(position: Vector2 ) -> void:
	armyMarker.rotation = armyMarker.global_position.angle_to_point(position) + PI/2


# Makes the IA focus on the largest group of enemies
func focus_on_largest_group() -> void:
	var groups : Array = get_enemy_groups(player_units, 2000)
	if groups == null:
		push_error("enemy groups not detected")
		return
	var closest : float = get_distance_to_closest(groups, armyMarker.global_position)
	if closest == NAN : # in case of not finding a group closest will have value NAN
		push_error("Could not find an enemy group")
		return
	
	var action : String = general.get_next_action()
	var focus : Array[Unit] = general.get_largest_group(groups)
	groups_manager.main_enemy_group = focus
#	Globals.debug_update_label("size", focus.size())
#	Globals.debug_update_label("closest", "closest: %s" %[closest])
	var to_sort : Array = groups.duplicate(true)
	to_sort.sort_custom(func(a : Array, b : Array) -> bool : return a.size() > b.size())
	var groups_by_size : Array = to_sort.duplicate(true)
	var text_group_size : String = ""
	for i in groups_by_size.size():
		text_group_size += "size: %s \n" % [groups_by_size[i].size()]
	Globals.debug_update_label("size%s", "size: %s" % [text_group_size])
	if focus == null:
		return
	var average_pos : Vector2 = get_average_position(focus)
	var angle : float = armyMarker.global_position.angle_to_point(average_pos) 
	var new_pos : Vector2 = armyMarker.global_position + Vector2(cos(angle), -sin(angle)) * 20
#	Globals.debug_update_label("focus", "Focus: %s" %[focus.map(func(el): return el.name)])
	
	# Parent marker will look towards main player group
	if abs(armyMarker.rotation - angle) > PI / 3:
		armyMarker.rotation = angle + PI/2
	
	# just to test
	#var angle_formation : float = armyMarker.rotation
	#move_units(group_front,infantryMarker.global_position, angle_formation, angle_formation, true)
	#move_units(group_archers,rangeMarker.global_position, angle_formation, angle_formation, true)
	#move_units(group_left_flank, leftFlankMarker.global_position, angle_formation, angle_formation, false, true)
	#move_units(group_right_flank, rightFlankMarker.global_position , angle_formation, angle_formation , false)
#	
	
	#match(action):
		#"move" :
			#move_units(units, armyMarker.global_position , 0.0, PI)
#			push_warning("alf")
			#pass
#	generalState = GeneralStates.FIGHTING
	#pass


# It will group the enemies that are at the left, right or behind the front of the army
# It will be used to get know how many units it would be required to assign to the flanking
func get_enemy_groups_flanking() -> void :
	var enemy_groups := get_enemy_groups(player_units, 2000)
	
	var minimum_angle_for_flank : float= 30
	var maximium_angle_for_flank : float = 60
	
	Globals.debug_update_label("amount_enemies" , "Enemies size: %s"  % [enemy_groups.size()])
	
	# If no side group is needed it will order to disband it
	var needs_side_left : bool = false
	var needs_side_right : bool = false
	var needs_side_back : bool = false
	
	var text : String = "" # used to debug the position
	for group : Array in enemy_groups as Array:
		var group_temp : Array[Unit] = []
		group_temp.assign(group)
		var average_pos := get_average_position(group_temp)
		var army_pos := armyMarker.global_position
		# This needs to be used to get the dot product from the angle that the army is facing to
		var angle_to_average_pos : float = army_pos.angle_to_point(average_pos)
		var angle_army_is_facing : float = armyMarker.rotation - deg_to_rad(90)
		
		var angle_diff : float = angle_difference(angle_to_average_pos, angle_army_is_facing)
		angle_diff = rad_to_deg(angle_diff)
		#angle_diff -= 90 # The difference from the position that the rotation and the direction facing
		
		#if angle_diff < 0 : 
			#angle_diff += 360
		text += "group: %s \n  angle_diff: %s\n  side:%s\n" % [
			group.size(), 
			angle_diff, 
			get_side_by_degree_difference(angle_diff)
			]
		
		# Assign enought units to avoid beign encircled
		var side : String = get_side_by_degree_difference(angle_diff)
		var group_casted : Array[Unit] = []
		group_casted.assign(group)
		groups_manager.check_side_has_enough_units(side, group_casted)
		# TODO make it better
		if side == "left":
			needs_side_left = true
		if side == "right":
			needs_side_right = true
		if side == "back":
			needs_side_back = true
	
	# Groups that will be cleared if not needed
	if not needs_side_left:
		groups_manager.group_not_needed_in_side("left")
	if not needs_side_right:
		groups_manager.group_not_needed_in_side("right")
	if not needs_side_back:
		groups_manager.group_not_needed_in_side("back")
	
	Globals.debug_update_label("side", text)

func get_side_by_degree_difference(angle_diff: float) -> String:
	# 75-115 is a side
	
	if abs(angle_diff) > 115:
		return "back"
	if abs(angle_diff) < 75:
		return "front"
	if angle_diff > 0:
		return "left"
	else:
		return "right"
	
	return "none"
	pass

func group_units_by_type(aUnits : Array[Unit]) -> void:
	if aUnits == null or typeof(aUnits) != 28:
		push_error("invalid argument")
		return
	#infantry_units = aUnits.filter(func(el) : return el.type == 1)
	#range_units = aUnits.filter(func(el) : return el.type == 2)
	#cavalry_units = aUnits.filter(func(el) : return el.type == 3)
	infantry_units.assign(aUnits.filter(func(el : Unit) -> bool : return el.type == 1 ))
	range_units.assign(aUnits.filter(func(el : Unit) -> bool : return el.type == 2 ))
	cavalry_units.assign(aUnits.filter(func(el : Unit) -> bool : return el.type == 3))
	
	# Groups used for the formation
	#group_front = infantry_units.duplicate()
	#group_archers = range_units.duplicate()
	group_front.assign(infantry_units)
	group_archers.assign(range_units)
	var half_cavalry : int = floori( float( cavalry_units.size()) / 2.0 )
	#group_left_flank = cavalry_units.slice(0, half_cavalry).duplicate()
	#group_right_flank = cavalry_units.slice(half_cavalry).duplicate()
	group_left_flank.assign(cavalry_units.slice(0, half_cavalry).duplicate())
	group_right_flank.assign(cavalry_units.slice(half_cavalry).duplicate())

func get_data_to_think_next_action() -> void:
	
	pass


func move_to_group_marker(aUnits : Array[Unit]) -> void:
	if typeof(aUnits) != 28:
		push_error("Expected array in function")
		return
	var infantry_in_arg : Array = aUnits.filter(func(el : Unit) -> bool : return el.get_type() == 1 )
	var range_in_arg : Array = aUnits.filter(func(el : Unit) -> bool : return el.get_type() == 2 )
	var cavalry_in_arg : Array = aUnits.filter(func(el : Unit) -> bool : return el.get_type()  == 3 )
	var cavalry_amount : float = float(cavalry_in_arg.size()) # done to avoid the message of floating point dropped
	var half_cavalry : int = floori(cavalry_amount / 2.0) # done to avoid the message of floating point dropped
	var cavalry_left_flank : Array = cavalry_in_arg.slice(0, half_cavalry)
	var cavalry_right_flank : Array = cavalry_in_arg.slice(half_cavalry)
	move_units(infantry_in_arg,infantryMarker.global_position,PI, PI, true)
	move_units(range_in_arg,rangeMarker.global_position, PI, PI, true)
	
	var distance_from_infantry : int = 512
	var right_flank_pos : Vector2 = get_flank_position(infantry_in_arg, "right", PI, distance_from_infantry)
	var left_flak_pos : Vector2 = get_flank_position(infantry_in_arg, "left", PI, distance_from_infantry)
	rightFlankMarker.global_position = right_flank_pos
	leftFlankMarker.global_position = left_flak_pos
	move_units(cavalry_left_flank, leftFlankMarker.global_position, PI, PI, false, true)
	move_units(cavalry_right_flank, rightFlankMarker.global_position , PI, PI , false)


func get_flank_position(aUnits : Array[Unit] = [], flank : String = "none", angle_formation : float = 0, distance : float = 0.0) -> Vector2:
	var units_group := aUnits as Array[Unit]
	if units.size() == 0 or flank == "none":
		return armyMarker.position # it needs to be te local position
	if flank == "left":
		return ( units_group[0].get_destination() -Vector2(cos(angle_formation), sin(angle_formation)) * distance )
	if flank == "right":
		return (units_group[units_group.size() - 1].get_destination() + Vector2(cos(angle_formation), sin(angle_formation)) * distance )
	
	push_error("Not valid position could be obtained so the default army marker position was returned")
	return armyMarker.position

# TODO move this code to a separated node to create a behavior tree
func check_to_advance() -> void:
	var a_units_to_move : Array[Unit] = units
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
func advance(aUnits: Array[Unit], target_position : Vector2, current_position : Vector2, distance_to_move : float, as_percentage: bool = false) -> void:
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
func send_units_to_attack(aGroup : Array[Unit], aEnemy_units : Array[Unit]) -> void:
	#region Safeguard
	for unit in aGroup as Array[Unit]:
		if not unit is Unit:
			push_error("There is an object that is not a unit")
			return
	for unit in aEnemy_units as Array[Unit]:
		if not unit is Unit:
			push_error("There is an object that is not a unit")
			return
	#endregion
	
	for unit in aGroup as Array[Unit]:
		var unit_has_targeted_enemy : bool = false # used to store when the unit has chosen an enemy to attack
		var enemies_by_distance :Array[Unit] = get_units_ordered_by_distance(aEnemy_units, unit.global_position)
		for enemy in enemies_by_distance as Array[Unit]:
			if not units_already_targeted.has(enemy) and not unit_has_targeted_enemy:
				units_already_targeted.push_back(enemy)
				unit.set_chase(enemy)
				unit_has_targeted_enemy = true
		


func _on_timer_timeout() -> void:
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

var testing : bool= true
func _on_timer_advance_timeout() -> void:
	timerAdvance.start(5)
	get_enemy_groups_flanking()
	testing = false
	#check_to_advance()
	pass
